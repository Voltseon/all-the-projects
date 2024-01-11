################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
    pokemon.shiny = true
  end
}

# Used in the random dungeon map.  Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if $game_map.map_id == 51
    new_level = pbBalancedLevel($Trainer.party) - 4 + rand(5)   # For variety
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pokemon.level = new_level
    pokemon.calc_stats
    pokemon.reset_moves
  end
}

# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
#Events.onTrainerPartyLoad += proc { |_sender, trainer|
#  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#    YOUR CODE HERE
#  end
#}

# 10% chance of getting a wild hidden ability pokemon
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if rand(10)==1
    pokemon.ability_index = 2
  end
}

WILD_ITEMS = [
  :POTION, :SUPERPOTION, :ETHER, :ELIXIR, :ENIGMABERRY, :ORANBERRY, :SITRUSBERRY, :LUMBERRY,
  :LEPPABERRY, :CHESTOBERRY, :CHERIBERRY, :ASPEARBERRY, :RAWSTBERRY, :PECHABERRY,
  :POKEBALL, :GREATBALL, :PEARL, :TINYMUSHROOM, :BIGMUSHROOM,
  :LEFTOVERS, :BERRYJUICE, :STARDUST, :EVERSTONE, :FIRESTONE, :WATERSTONE, :THUNDERSTONE,
  :PPUP, :CARBOS, :ZINC, :PROTEIN, :IRON, :HPUP, :CALCIUM,
  :IRONBALL, :REVIVE, :REPEL, :SUPERREPEL, :PRETTYWING, :CLEANSETAG,
  :AWAKENING, :ANTIDOTE, :BURNHEAL, :PARALYZEHEAL, :ICEHEAL
]

# Make all wild Pokémon have a chance to hold a random item.
Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  if !pokemon.item
    if rand(10) < 1
      pokemon.item = GameData::Item.get(WILD_ITEMS[rand(0..WILD_ITEMS.length-1)])
    end
  end
}
