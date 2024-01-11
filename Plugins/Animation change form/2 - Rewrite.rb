#-----------------------------------------------------#
#-----------------------------------------------------#
# Credit: KleinStudio (original), bo4p5687 (update)
#-----------------------------------------------------#
#-----------------------------------------------------#
#--------------------#
#--------------------#
#      Rewrite       #
#-------------------------------------------------#
# If you use script: Animation "item".
# Read this line: "Add for using animation item".
# Do like guide.
#                Thanks!
#-------------------------------------------------#

# 0 = item wasn't used; 1 = item used; 2 = close Bag to use in field
def pbUseItem(bag, item, bagscene = nil)
  itm = GameData::Item.get(item)
  useType = itm.field_use
  if useType == 1   # Item is usable on a Pokémon
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if itm.is_evolution_stone?
      annot = []
      $player.party.each do |pkmn|
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn {
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      screen.pbStartScene(_INTL("Use on which Pokémon?"), false, annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen = screen.pbChoosePokemon
        if chosen < 0
          ret = false
          break
        end
        pkmn = $player.party[chosen]
        next if !pbCheckUseOnPokemon(item, pkmn, screen)
        qty = 1
        max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
        max_at_once = [max_at_once, $bag.quantity(item)].min
        if max_at_once > 1
          qty = screen.scene.pbChooseNumber(
            _INTL("How many {1} do you want to use?", GameData::Item.get(item).name), max_at_once
          )
          screen.scene.pbSetHelpText("") if screen.is_a?(PokemonPartyScreen)
        end
        next if qty <= 0

				# Add animation change form
				ret = ItemHandlers.triggerAnimationForm(item, pkmn, screen, chosen)
        ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen) if !ret

        next unless ret && itm.consumed_after_use?
        bag.remove(item, qty)
        next if bag.has?(item)
        pbMessage(_INTL("You used your last {1}.", itm.name)) { screen.pbUpdate }
        break
      end
      screen.pbEndScene
      bagscene&.pbRefresh
    }
    return (ret) ? 1 : 0
  elsif useType == 2 || itm.is_machine?   # Item is usable from Bag or teaches a move
    intret = ItemHandlers.triggerUseFromBag(item)
    if intret >= 0
      bag.remove(item) if intret == 1 && itm.consumed_after_use?
      return intret
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end

def pbUseItemOnPokemon(item, pkmn, scene)
  itm = GameData::Item.get(item)
  # TM or HM
  if itm.is_machine?
    machine = itm.move
    return false if !machine
    movename = GameData::Move.get(machine).name
    if $player.metronome
      pbMessage(_INTL("Only Metronome is allowed!")) { scene.pbUpdate }
    elsif pkmn.shadowPokemon?
      pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { scene.pbUpdate }
    elsif !pkmn.compatible_with_move?(machine)
      pbMessage(_INTL("{1} can't learn {2}.", pkmn.name, movename)) { scene.pbUpdate }
    else
      pbMessage(_INTL("\\se[PC access]You booted up {1}.\1", itm.name)) { scene.pbUpdate }
      if pbConfirmMessage(_INTL("Do you want to teach {1} to {2}?", movename, pkmn.name)) { scene.pbUpdate }
        
				# Add for using "Animation item" #

				# If you use "Animation item", delete # this line (below) (if it exists) #
				#if pbLearnMove(pkmn, machine, false, true, item) { scene.pbUpdate }
				
				# If you use "Animation item", add # this line (below) (if it doesn't exist) #
         if pbLearnMove(pkmn, machine, false, true) { scene.pbUpdate }

          $bag.remove(item) if itm.consumed_after_use?
          return true
        end
      end
    end
    return false
  end
  # Other item
  qty = 1
  max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
  max_at_once = [max_at_once, $bag.quantity(item)].min
  if max_at_once > 1
    qty = scene.scene.pbChooseNumber(
      _INTL("How many {1} do you want to use?", itm.name), max_at_once
    )
    scene.scene.pbSetHelpText("") if scene.is_a?(PokemonPartyScreen)
  end
  return false if qty <= 0

	# Animation "Change form"
	chosen = $player.party.find_index { |i| i == pkmn }
	ret = ItemHandlers.triggerAnimationForm(item, pkmn, scene, chosen)
	ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, scene) if !ret

  scene.pbClearAnnotations
  scene.pbHardRefresh
  if ret && itm.consumed_after_use?
    $bag.remove(item, qty)
    if !$bag.has?(item)
      pbMessage(_INTL("You used your last {1}.", itm.name)) { scene.pbUpdate }
    end
  end
  return ret
end