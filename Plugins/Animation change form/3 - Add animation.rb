#--------------------#
# There are examples #
#--------------------#

# Change form
ItemHandlers::AnimationForm.add(:GRACIDEA, proc { |item, pkmn, scene, chose|
  if !pkmn.isSpecies?(:SHAYMIN) || pkmn.form != 0 || pkmn.status == :FROZEN || PBDayNight.isNight?
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  pkmn.setForm(1) {

		# Add animation
		scene.change_form_animation(pkmn.speciesName, chose, pkmn.form) { scene.pbRefresh }

    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

ItemHandlers::AnimationForm.add(:REVEALGLASS, proc { |item, pkmn, scene, chose|
  if !pkmn.isSpecies?(:TORNADUS) && !pkmn.isSpecies?(:THUNDURUS) && !pkmn.isSpecies?(:LANDORUS)
	 scene.pbDisplay(_INTL("It had no effect."))
	 next false
 end
 if pkmn.fainted?
	 scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
	 next false
 end
 newForm = (pkmn.form==0) ? 1 : 0
 pkmn.setForm(newForm) {

		# Add animation
		scene.change_form_animation(pkmn.speciesName, chose, pkmn.form) { scene.pbRefresh }

		scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
 }
 next true
})

# Change form fusion
ItemHandlers::AnimationForm.add(:DNASPLICERS, proc { |item, pkmn, scene, chose|
  if !pkmn.isSpecies?(:KYUREM)
    scene.pbDisplay(_INTL("It had no effect."))
    next false
  end
  if pkmn.fainted?
    scene.pbDisplay(_INTL("This can't be used on the fainted Pokémon."))
    next false
  end
  # Fusing
  if pkmn.fused.nil?
    chosen = scene.pbChoosePokemon(_INTL("Fuse with which Pokémon?"))
    next false if chosen<0
    poke2 = $player.party[chosen]
    if pkmn==poke2
      scene.pbDisplay(_INTL("It cannot be fused with itself."))
      next false
    elsif poke2.egg?
      scene.pbDisplay(_INTL("It cannot be fused with an Egg."))
      next false
    elsif poke2.fainted?
      scene.pbDisplay(_INTL("It cannot be fused with that fainted Pokémon."))
      next false
    elsif !poke2.isSpecies?(:RESHIRAM) &&
          !poke2.isSpecies?(:ZEKROM)
      scene.pbDisplay(_INTL("It cannot be fused with that Pokémon."))
      next false
    end
    newForm = 0
    newForm = 1 if poke2.isSpecies?(:RESHIRAM)
    newForm = 2 if poke2.isSpecies?(:ZEKROM)
    pkmn.setForm(newForm) {

			# Add animation
			scene.change_form_animation_fusion(pkmn.speciesName, chose, pkmn.form, poke2.speciesName, chosen, poke2.form) {
				pkmn.fused = poke2
				$player.remove_pokemon_at_index(chosen)
			}
			
      scene.pbHardRefresh
      scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
    }
    next true
  end
  # Unfusing
  if $player.party_full?
    scene.pbDisplay(_INTL("You have no room to separate the Pokémon."))
    next false
  end
  pkmn.setForm(0) {

		# Add animation
		scene.change_form_animation(pkmn.speciesName, chose, pkmn.form) {
			$player.party[$player.party.length] = pkmn.fused
			pkmn.fused = nil
			scene.pbHardRefresh
		}
    
    scene.pbDisplay(_INTL("{1} changed Forme!",pkmn.name))
  }
  next true
})

#-----------------------------------------------#
# Give item and pokemon changes form (Giratina) #
#-----------------------------------------------#
def pbGiveItemToPokemon(item, pkmn, scene, pkmnid = 0)
  newitemname = GameData::Item.get(item).name
  if pkmn.egg?
    scene.pbDisplay(_INTL("Eggs can't hold items."))
    return false
  elsif pkmn.mail
    scene.pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", pkmn.name))
    return false if !pbTakeItemFromPokemon(pkmn, scene)
  end
  if pkmn.hasItem?
    olditemname = pkmn.item.name
    if pkmn.hasItem?(:LEFTOVERS)
      scene.pbDisplay(_INTL("{1} is already holding some {2}.\1", pkmn.name, olditemname))
    elsif newitemname.starts_with_vowel?
      scene.pbDisplay(_INTL("{1} is already holding an {2}.\1", pkmn.name, olditemname))
    else
      scene.pbDisplay(_INTL("{1} is already holding a {2}.\1", pkmn.name, olditemname))
    end
    if scene.pbConfirm(_INTL("Would you like to switch the two items?"))
      $bag.remove(item)
      if !$bag.add(pkmn.item)
        raise _INTL("Couldn't re-store deleted item in Bag somehow") if !$bag.add(item)
        scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
      elsif GameData::Item.get(item).is_mail?
				if pbWriteMail(item, pkmn, pkmnid, scene)
          pkmn.item = item
          scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.", olditemname, pkmn.name, newitemname))
          return true
				elsif !$bag.add(item)
					raise _INTL("Couldn't re-store deleted item in Bag somehow")
				end
			else

				# Add animation
				old = pkmn.item.id
				pkmn.item = item
				if [old, item].include?(:GRISEOUSORB) && pkmn.species == :GIRATINA
					chose = scene.party.find_index { |i| i == pkmn }
					scene.change_form_animation(pkmn.speciesName, chose, pkmn.form) { scene.pbRefreshSingle(chose) }
				end
				
				scene.pbDisplay(_INTL("Took the {1} from {2} and gave it the {3}.", olditemname, pkmn.name, newitemname))
        return true
			end
    end
  else
    if !GameData::Item.get(item).is_mail? || pbWriteMail(item, pkmn, pkmnid, scene)
			$bag.remove(item)
			pkmn.item = item
			
			# Add animation
			if pkmn.hasItem?(:GRISEOUSORB) && pkmn.species == :GIRATINA
				chose = scene.party.find_index { |i| i == pkmn }
				scene.change_form_animation(pkmn.speciesName, chose, pkmn.form) { scene.pbRefreshSingle(chose) }
			end
      
			scene.pbDisplay(_INTL("{1} is now holding the {2}.",pkmn.name,newitemname))
      return true
    end
  end
  return false
end

def pbTakeItemFromPokemon(pkmn,scene)
  ret = false
  if !pkmn.hasItem?
    scene.pbDisplay(_INTL("{1} isn't holding anything.", pkmn.name))
  elsif !$bag.can_add?(pkmn.item)
    scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
  elsif pkmn.mail
    if scene.pbConfirm(_INTL("Save the removed mail in your PC?"))
      if pbMoveToMailbox(pkmn)
        scene.pbDisplay(_INTL("The mail was saved in your PC."))
        pkmn.item = nil
        ret = true
      else
        scene.pbDisplay(_INTL("Your PC's Mailbox is full."))
      end
    elsif scene.pbConfirm(_INTL("If the mail is removed, its message will be lost. OK?"))
      $bag.add(pkmn.item)
      scene.pbDisplay(_INTL("Received the {1} from {2}.", pkmn.item.name, pkmn.name))
      pkmn.item = nil
      pkmn.mail = nil
      ret = true
    end
  else

		# Add animation
		olditemname = pkmn.item.name
		olditemid   = pkmn.item.id
		$bag.add(pkmn.item)
		pkmn.item = nil
		if olditemid == :GRISEOUSORB && pkmn.species == :GIRATINA && pkmn.form == 1
			chose = scene.party.find_index { |i| i == pkmn }
			scene.change_form_animation(pkmn.speciesName, chose, pkmn.form) { scene.pbRefreshSingle(chose) }
		end
		scene.pbDisplay(_INTL("Received the {1} from {2}.", olditemname, pkmn.name))

    ret = true
  end
  return ret
end