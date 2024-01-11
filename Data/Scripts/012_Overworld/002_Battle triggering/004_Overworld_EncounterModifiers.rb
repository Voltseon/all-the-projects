################################################################################
# This section was created solely for you to put various bits of code that
# modify various wild Pokémon and trainers immediately prior to battling them.
# Be sure that any code you use here ONLY applies to the Pokémon/trainers you
# want it to apply to!
################################################################################

# Make all wild Pokémon shiny while a certain Switch is ON (see Settings).
EventHandlers.add(:on_wild_pokemon_created, :make_shiny_switch,
  proc { |pkmn|
    pkmn.shiny = true if $game_switches[Settings::SHINY_WILD_POKEMON_SWITCH]
  }
)

# Used in the random dungeon map. Makes the levels of all wild Pokémon in that
# map depend on the levels of Pokémon in the player's party.
# This is a simple method, and can/should be modified to account for evolutions
# and other such details.  Of course, you don't HAVE to use this code.

EventHandlers.add(:on_wild_pokemon_created, :shadow_lugia,
  proc { |pkmn|
    next if pkmn.species != :LUGIA
    pkmn.makeShadow
    pkmn.update_shadow_moves(true)
    pkmn.shiny = false
  }
)

EventHandlers.add(:on_wild_pokemon_created, :level_depends_on_party,
  proc { |pkmn|
    next if $game_map.map_id != 51
    new_level = pbBalancedLevel($player.party) - 4 + rand(5)   # For variety
    new_level = new_level.clamp(1, GameData::GrowthRate.max_level)
    pkmn.level = new_level
    pkmn.calc_stats
    pkmn.reset_moves
  }
)

EventHandlers.add(:on_wild_pokemon_created, :level_scaling,
  proc { |pkmn|
    next if true
    pkmn = levelscale(pkmn)
  }
)

EventHandlers.add(:on_wild_pokemon_created, :hidden_ability_chance,
  proc { |pkmn|
    pkmn.ability_index = 2 if rand(20) == 1 # 5% chance for wild hidden ability pokemon to appear.
  }
)

EventHandlers.add(:on_wild_pokemon_created, :fishing_modifier,
  proc { |pkmn|
    next
    next unless $game_temp.encounter_type.to_s.include?("Rod")
    case $fishing_rod
    when 1 then levelModif = -2 # Old Rod
    when 2 then levelModif = 1  # Good Rod
    when 3 then levelModif = 4  # Super Rod
    end
    pkmn.level = (pkmn.level + levelModif).clamp(2,GameData::GrowthRate.max_level)
  }
)

EventHandlers.add(:on_wild_pokemon_created, :randomize_wild_level,
  proc { |pkmn|
    next
    next if $game_temp.overworld_encounter
    pkmn.level = (pkmn.level + rand(-2..2)).clamp(2,GameData::GrowthRate.max_level)
    new_evo_mon = pbCheckEvolveDevolve(pkmn.species, pkmn.level)
    pkmn.species = new_evo_mon[0]
    pkmn.calc_stats
    pkmn.reset_moves
  }
)

# Returns an array of species and integer
# -1 means devolve, 0 means stay, 1 means evolve
# [Species, integer]
def pbCheckEvolveDevolve(s, level)
  ret = [s, 0]
  return ret unless s.is_a?(Symbol)
  species = GameData::Species.get(s)
  prevo = GameData::Species.get(species.get_previous_species)
  choices = []
  unless prevo.species == s
    prevo.get_evolutions(true).each do |evo|
      next unless evo[0] == s
      if (evo[1].to_s.include?("Level") || [:Cascoon, :Silcoon, :AttackGreater,
        :AtkDefEqual, :DefenseGreater, :Ninjask].include?(evo[1])) && evo[2] > level
        choices.push(prevo.species)
        ret[1] = -1
        break
      end
    end
  end
  if ret[1] > -1
    species.get_evolutions(true).each do |evo|   # [new_species, method, parameter]
      next if evo[3]
      if (evo[1].to_s.include?("Level") || [:Cascoon, :Silcoon, :AttackGreater,
        :AtkDefEqual, :DefenseGreater, :Ninjask].include?(evo[1])) && evo[2] <= level
        choices.push(evo[0])
        ret[1] = 1
      end
    end
  end
  ret[0] = choices.sample unless choices.empty?
  ret = pbCheckEvolveDevolve(ret[0], level) unless ret[1] == 0
  return ret
end

# This is the basis of a trainer modifier. It works both for trainers loaded
# when you battle them, and for partner trainers when they are registered.
# Note that you can only modify a partner trainer's Pokémon, and not the trainer
# themselves nor their items this way, as those are generated from scratch
# before each battle.
#EventHandlers.add(:on_trainer_load, :put_a_name_here,
#  proc { |trainer|
#    if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#      YOUR CODE HERE
#    end
#  }
#)

EventHandlers.add(:on_trainer_load, :remove_caught_shadows,
  proc { |trainer|
    if trainer
      trainer.party.each_with_index do |pkmn,i|
        if pkmn.shadowPokemon?
          if $player.shadow_pkmn[pkmn.species].is_a?(Array)
            trainer.party.delete_at(i) if $player.shadow_pkmn[pkmn.species][1]
          end
        end
      end
    end
  }
)

EventHandlers.add(:on_trainer_load, :ngplus_trainer_buff,
  proc { |trainer|
    next unless $game_switches[82]
    if trainer
      trainer.party.each do |pkmn|
        pkmn.level = (pkmn.level+2).clamp(2, GameData::GrowthRate.max_level)
      end
    end
  }
)

EventHandlers.add(:on_trainer_load, :rematch_level_scaling,
  proc { |trainer|
    if trainer
      if pbPhoneBattleCount(trainer.trainer_type, trainer.name) > 0
        trainer.party.each do |pkmn|
          pkmn = levelscale(pkmn)
        end
      end
    end
  }
)

EventHandlers.add(:on_trainer_load, :lvl_100_challenge,
  proc { |trainer|
    next unless $player.lvl100trainers
    if trainer
      trainer.party.each do |pkmn|
        pkmn.level = 100
        pkmn.calc_stats
        pkmn.reset_moves
      end
    end
  }
)

def levelscale(pkmn)
  new_level = 0
  if true # depending on badges
    new_level = pbBalancedLevel($player.party) - 6 + rand(5)   # For variety
  else
    case $player.badge_count
    when 0 then new_level = 7
    when 1 then new_level = 11
    when 2 then new_level = 18
    when 3 then new_level = 26
    when 4 then new_level = 32
    when 5 then new_level = 39
    when 6 then new_level = 43
    when 7 then new_level = 47
    when 8 then new_level = 53
    end
    new_level += 8 if false # game beaten
    new_level += 10 if false # battle facility beaten
  end
  new_level = new_level.clamp(2, GameData::GrowthRate.max_level)
  pkmn.level = new_level
  pkmn.calc_stats
  pkmn.reset_moves
  return pkmn
end

EventHandlers.add(:on_trainer_load, :replacemons,
  proc { |trainer|
    if trainer
      case trainer.trainer_type
      when :RIVAL1
        trainer.party.each do |pkmn|
          next unless pkmn.isSpecies?(:STARTER)
          starters = [[:BULBASAUR,:CHARMANDER,:SQUIRTLE],
                      [:CHIKORITA,:CYNDAQUIL,:TOTODILE],
                      [:TREECKO,:TORCHIC,:MUDKIP],
                      [:TURTWIG,:CHIMCHAR,:PIPLUP],
                      [:SNIVY,:TEPIG,:OSHAWOTT],
                      [:CHESPIN,:FENNEKIN,:FROAKIE],
                      [:ROWLET,:LITTEN,:POPPLIO],
                      [:GROOKEY,:SCORBUNNY,:SOBBLE],
                      [:SPRIGATITO, :FUECOCO, :QUAXLY]
            ]
          if $player.randomizer_trainer
            chance_pokemon = valid_pokemon(true)
            starters = [[chance_pokemon.sample]*3]*8
          end
          borad_choice = pbGet(7)-2
          borad_choice = 2 if borad_choice == -1
          evolved_species = pbCheckEvolveDevolve(starters[pbGet(26)-1][borad_choice], pkmn.level)
          pkmn.species = evolved_species[0]
          pkmn.calc_stats
          pkmn.reset_moves
          pkmn.item = [:MIRACLESEED, :CHARCOAL, :MYSTICWATER][borad_choice] if pkmn.item == :MIRACLESEED
        end
      when :RIVAL2
        trainer.party.each do |pkmn|
          next unless pkmn.isSpecies?(:STARTER)
          starters = [[:BULBASAUR,:CHARMANDER,:SQUIRTLE],
                      [:CHIKORITA,:CYNDAQUIL,:TOTODILE],
                      [:TREECKO,:TORCHIC,:MUDKIP],
                      [:TURTWIG,:CHIMCHAR,:PIPLUP],
                      [:SNIVY,:TEPIG,:OSHAWOTT],
                      [:CHESPIN,:FENNEKIN,:FROAKIE],
                      [:ROWLET,:LITTEN,:POPPLIO],
                      [:GROOKEY,:SCORBUNNY,:SOBBLE],
                      [:SPRIGATITO, :FUECOCO, :QUAXLY]
            ]
            if $player.randomizer_trainer
              chance_pokemon = valid_pokemon(true)
              starters = [[chance_pokemon.sample]*3]*8
            end
          ashley_choice = pbGet(7)
          ashley_choice = 0 if ashley_choice == 3
          evolved_species = pbCheckEvolveDevolve(starters[pbGet(26)-1][ashley_choice], pkmn.level)
          pkmn.species = evolved_species[0]
          pkmn.calc_stats
          pkmn.reset_moves
          pkmn.item = [:MIRACLESEED, :CHARCOAL, :MYSTICWATER][ashley_choice] if pkmn.item == :MIRACLESEED
        end
      when :ROCKETBOSS
        trainer.party.each do |pkmn|
          next unless pkmn.isSpecies?(:STARTER)
          pkmn.species = [:MEGANIUM,:TYPHLOSION,:FERALIGATR][pbGet(7)-1]
          pkmn.calc_stats
          pkmn.reset_moves
          pkmn.item = [:MIRACLESEED, :CHARCOAL, :MYSTICWATER][pbGet(7)-1] if pkmn.item == :MIRACLESEED
        end
      end
    end
  }
)
