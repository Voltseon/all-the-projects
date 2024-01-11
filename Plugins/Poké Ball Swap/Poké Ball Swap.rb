RECEIVE_OLD = true
RECEIVE_MASTER = false
ItemHandlers::UseOnPokemon.addIf(:pokeball_swap,
  proc { |item| GameData::Item.get(item).is_poke_ball? },
  proc { |item, qty, pkmn, scene|
    ballname = GameData::Item.get(item).name
    if pkmn.poke_ball != item
      if pbConfirmMessage(_INTL("Place {1} in the {2}?",pkmn.name,ballname))  { scene.pbUpdate }
        pbSEPlay("Battle recall")
        pbMessage(_INTL("{1} was placed in the {2}.",pkmn.name,ballname))  { scene.pbUpdate }
        if RECEIVE_OLD == true
          newitem = pkmn.poke_ball
          newname = GameData::Item.get(newitem).name
          if pkmn.poke_ball!=:MASTERBALL || RECEIVE_MASTER == true
            pbSEPlay("Battle catch click")
            pbMessage(_INTL("Took {1}'s old {2}.",pkmn.name,newname))  { scene.pbUpdate }
            $bag.add(newitem)
          else
            pbSEPlay("Battle damage weak")
            pbMessage(_INTL("{1}'s old {2} broke when you tried to remove it!",pkmn.name,newname))  { scene.pbUpdate }
          end
        end
        pkmn.poke_ball = item
        next true
      end
    end
    pbMessage(_INTL("{1} is already stored in a {2}.",pkmn.name,ballname))  { scene.pbUpdate }
    next false
  }
)