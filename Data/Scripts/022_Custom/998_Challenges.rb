class Player < Trainer
  attr_accessor :challenges
  attr_accessor :shinies_found
  attr_accessor :encounter_locations
  attr_accessor :special_items

  def nostory;				              initialize_challenges;            @challenges[:nostory];				              end
  def permadeath;				            initialize_challenges;            @challenges[:permadeath];				            end
  def randomizer_encounter;				  initialize_challenges;            @challenges[:randomizer_encounter];				  end
  def randomizer_abilities;				  initialize_challenges;            @challenges[:randomizer_abilities];				  end
  def randomizer_learnset;				  initialize_challenges;            @challenges[:randomizer_learnset];				  end
  def randomizer_evolutions;				initialize_challenges;            @challenges[:randomizer_evolutions];				end
  def randomizer_trainer;				    initialize_challenges;            @challenges[:randomizer_trainer];				    end
  def randomizer_special;				    initialize_challenges;            @challenges[:randomizer_special];				    end
  def randomizer_item;				      initialize_challenges;            @challenges[:randomizer_item];				      end
  def randomizer_tms;				        initialize_challenges;            @challenges[:randomizer_tms];				        end
  def randomizer_mart;				      initialize_challenges;            @challenges[:randomizer_mart];				      end
  def randomizer_warp;				      initialize_challenges;            @challenges[:randomizer_warp];				      end
  def sbq;				                  initialize_challenges;            @challenges[:sbq];				                  end
  def difficulty;				            initialize_challenges;            @challenges[:difficulty];				            end
  def lvl100trainers;				        initialize_challenges;            @challenges[:lvl100trainers];		            end
  def metronome;				            initialize_challenges;            @challenges[:metronome];				            end
  def wonderguard;				          initialize_challenges;            @challenges[:wonderguard];				          end
  def shadowtag;				            initialize_challenges;            @challenges[:shadowtag];				            end
  def noability;				            initialize_challenges;            @challenges[:noability];				            end
  def nomoveeffects;				        initialize_challenges;            @challenges[:nomoveeffects];				        end
  def nospecialphysicalsplit;				initialize_challenges;            @challenges[:nospecialphysicalsplit];				end
  def shinyonly;				            initialize_challenges;            @challenges[:shinyonly];				            end
  def levelone;				              initialize_challenges;            @challenges[:levelone];				              end
  def noevgain;                     initialize_challenges;            @challenges[:noevgain];                     end
  def onehp;				                initialize_challenges;            @challenges[:onehp];				                end
  def nohealing;				            initialize_challenges;            @challenges[:nohealing];				            end
  def losehponstep;	                initialize_challenges;            @challenges[:losehponstep];	                end
  def hatemode;				              initialize_challenges;            @challenges[:hatemode];				              end
  def rocketmode;				            initialize_challenges;            @challenges[:rocketmode];				            end
  def murphyslaw;				            initialize_challenges;            @challenges[:murphyslaw];				            end
  def pacifist;				              initialize_challenges;            @challenges[:pacifist];				              end
  def random_before_battles;				initialize_challenges;            @challenges[:random_before_battles];		    end
  def weatherclear;				          initialize_challenges;            @challenges[:weatherclear];				          end
  def weatherrain;				          initialize_challenges;            @challenges[:weatherrain];				          end
  def weathersun;				            initialize_challenges;            @challenges[:weathersun];				            end
  def weatherhail;				          initialize_challenges;            @challenges[:weatherhail];				          end
  def weathersandstorm;				      initialize_challenges;            @challenges[:weathersandstorm];				      end
  def customstarters;				        initialize_challenges;            @challenges[:customstarters];				        end
  def starterpkmn1;				          initialize_challenges;            @challenges[:starterpkmn1];				          end
  def starterpkmn2;				          initialize_challenges;            @challenges[:starterpkmn2];				          end
  def starterpkmn3;				          initialize_challenges;            @challenges[:starterpkmn3];				          end
  def starteritem;				          initialize_challenges;            @challenges[:starteritem];				          end
  def godmode;				              initialize_challenges;            @challenges[:godmode];				              end
  def lovemode;				              initialize_challenges;            @challenges[:lovemode];				              end

  def shinyodds
    initialize_challenges
    odds_index = @challenges[:shinyodds]
    odds = [0, 0.000122, 0.000244, 0.000488, 0.00976, 0.002, 0.005, 0.01, 0.1, 0.25, 0.5, 0.75, 1, 100]
    return (odds[odds_index] * 65536).round
  end

  def expmultiplier
    initialize_challenges
    multiplier_index = @challenges[:expmultiplier]
    multipliers = [-1, 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 5, 10, 25, 50, 100, 1000]
    return multipliers[multiplier_index]
  end

  def catchmultiplier
    initialize_challenges
    multiplier_index = @challenges[:catchmultiplier]
    multipliers = [0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 5, 10, 25, 50, 100, 1000]
    return multipliers[multiplier_index]
  end

  def moneymultiplier
    initialize_challenges
    multiplier_index = @challenges[:moneymultiplier]
    multipliers = [-1, 0, 0.25, 0.5, 0.75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 5, 10, 25, 50, 100, 1000]
    return multipliers[multiplier_index]
  end

  def battle_pokemon_usage
    initialize_challenges
    usage_index = @challenges[:battle_pokemon_usage]
    usages = ["3v3", "3v2", "3v1", "2v1", nil, "1v2", "1v3", "2v3", "2v2"]
    return usages[usage_index]
  end

  def typeonly
    initialize_challenges
    type_index = @challenges[:typeonly]
    types = [nil, :NORMAL, :GRASS, :FIRE, :WATER, :ELECTRIC, :ICE, :FIGHTING, :POISON, :GROUND, :FLYING, :PSYCHIC, :BUG, :ROCK, :GHOST, :DRAGON, :DARK, :STEEL, :FAIRY]
    return types[type_index]
  end

  def firstencounter
    initialize_challenges
    index = @challenges[:firstencounter]
    options = [false, true, :SHINY, :SHADOW]
    return options[index]
  end

  def generation
    initialize_challenges
    return @challenges[:generation] + 1 if @challenges[:generation]
    return Settings::MECHANICS_GENERATION
  end

  def find_shiny
    @shinies_found = 0 if !@shinies_found
    @shinies_found += 1
  end

  def shinies_found
    @shinies_found = 0 if !@shinies_found
    return @shinies_found
  end

  def encounter_locations
    @encounter_locations = [] if !@encounter_locations
    return @encounter_locations
  end

  def add_encounter_location(mapid)
    @encounter_locations = [] if !@encounter_locations
    @encounter_locations.push(mapid) if !@encounter_locations.include?(mapid)
  end

  def special_items
    if @special_items.nil? || !self.randomizer_item
      @special_items = {
        :FOLLOWER => [:POTION,:SUPERPOTION,:FULLRESTORE,:REVIVE,:PPUP,:PPMAX,:RARECANDY,:REPEL,:MAXREPEL,:ESCAPEROPE,:HONEY,:TINYMUSHROOM,:PEARL,:NUGGET,:GREATBALL,:ULTRABALL,:THUNDERSTONE,:MOONSTONE,:SUNSTONE,:DUSKSTONE],
        :FOLLOWER_BATTLE => [:POKEBALL,:POKEBALL,:POKEBALL,:GREATBALL,:GREATBALL,:ULTRABALL],
        :PICKUP_COMMON_ITEMS => [:POTION,:ANTIDOTE,:SUPERPOTION,:GREATBALL,:REPEL,:ESCAPEROPE,:FULLHEAL,:HYPERPOTION,:ULTRABALL,:REVIVE,:RARECANDY,:SUNSTONE,:MOONSTONE,:BIGMUSHROOM,:FULLRESTORE,:MAXREVIVE,:PPUP,:MAXELIXIR],
        :PICKUP_RARE_ITEMS => [:HYPERPOTION,:NUGGET,:KINGSROCK,:FULLRESTORE,:ETHER,:IRONBALL,:DESTINYKNOT,:ELIXIR,:DESTINYKNOT,:LEFTOVERS,:DESTINYKNOT],
        :HONEYGATHER => :HONEY,
      }
    end
    return @special_items
  end
end

def check_sbq(gym=0)
  return true if $player.shinies_found >= gym || $player.sbq == false
  pbMessage("You haven't caught enough shiny Pokémon yet to challenge this gym. You need #{gym-$player.shinies_found} more.")
  return false
end

class Gradient
  def initialize(colors)
    @colors = colors
    @steps = @colors.length
  end

  def get_color(percentage)
    percentage = 1 if percentage > 1
    percentage = 0 if percentage < 0
    color1 = @colors[[(@steps * percentage).floor, 0].max]
    color2 = @colors[[(@steps * percentage).ceil, @steps - 1].min]
    r = color1.red + (color2.red - color1.red) * percentage
    g = color1.green + (color2.green - color1.green) * percentage
    b = color1.blue + (color2.blue - color1.blue) * percentage
    return Color.new(r, g, b)
  end
end

MenuHandlers.add(:challenge, :nostory, {
  "name"        => _INTL("No Story"),
  "description" => _INTL("Play the game without the story."),
  "type"        => :HANDICAP,
  "default"     => false,
  "order"       => 0
})

MenuHandlers.add(:challenge, :permadeath, {
  "name"        => _INTL("Permadeath"),
  "description" => _INTL("Pokémon won't revive after fainting."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 1
})

MenuHandlers.add(:challenge, :firstencounter, {
  "name"        => _INTL("First Encounter Only"),
  "description" => _INTL("You can only catch the first encounter in each area."),
  "type"        => :CHALLENGE,
  "default"     => 0,
  "options"     => ["[OFF]", "[ON]", "Excl. Shiny", "Excl. Shadow&Shiny"],
  "gradient"    => Gradient.new([Color.new(168, 48, 56), Color.new(0, 144, 0), Color.new("F7BF25"), Color.new("4535F4")]),
  "order"       => 1
})

MenuHandlers.add(:challenge, :randomizer_encounter, {
  "name"        => _INTL("Randomized Encounters"),
  "description" => _INTL("All wild Pokémon will be randomized."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 1
})

MenuHandlers.add(:challenge, :randomizer_abilities, {
  "name"        => _INTL("Randomized Abilities"),
  "description" => _INTL("All Pokémon will have randomized abilities."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 1
})

MenuHandlers.add(:challenge, :randomizer_learnset, {
  "name"        => _INTL("Randomized Learnsets"),
  "description" => _INTL("All Pokémon will have randomized learnsets."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 1
})

MenuHandlers.add(:challenge, :randomizer_evolutions, {
  "name"        => _INTL("Randomized Evolutions"),
  "description" => _INTL("All Pokémon will have randomized evolutions (evolve after 1 level)."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 1
})

MenuHandlers.add(:challenge, :randomizer_trainer, {
  "name"        => _INTL("Randomized Trainers"),
  "description" => _INTL("Trainer Pokémon will be randomized. (Not Shadow Pokémon)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 2
})

MenuHandlers.add(:challenge, :randomizer_special, {
  "name"        => _INTL("Randomized Special"),
  "description" => _INTL("Pokémon such as startes, gift, trade, egg and static Pokémon will be randomized."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 3
})

MenuHandlers.add(:challenge, :randomizer_item, {
  "name"        => _INTL("Randomized Items"),
  "description" => _INTL("All items will be randomized, including items obtained from abilities. (Not HMs)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 4
})

MenuHandlers.add(:challenge, :randomizer_tms, {
  "name"        => _INTL("Randomized TMs"),
  "description" => _INTL("The moves contained in TMs will be completely random. (Not HMs)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 4
})

MenuHandlers.add(:challenge, :randomizer_mart, {
  "name"        => _INTL("Randomized Marts"),
  "description" => _INTL("All PokéMart items will be randomized. (Not HM Emulator and Key Items)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 5
})

MenuHandlers.add(:challenge, :randomizer_warp, {
  "name"        => _INTL("Randomized Warps"),
  "description" => _INTL("All doorways and warps will be randomized. (Not the start and Event Transfers)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 6
})

MenuHandlers.add(:challenge, :sbq, {
  "name"        => _INTL("Shiny Badge Quest"),
  "description" => _INTL("Requires you to catch at least 1 shiny Pokémon before challenging the next gym."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 7
})

MenuHandlers.add(:challenge, :difficulty, {
  "name"        => _INTL("Battle Difficulty"),
  "description" => _INTL("Changes the levels, movesets and AI of opponents."),
  "type"        => :CHALLENGE,
  "default"     => 1,
  "options"     => ["Easy", "Normal", "Hard", "Insane"],
  "order"       => 8
})

MenuHandlers.add(:challenge, :lvl100trainers, {
  "name"        => _INTL("Lv. 100 Trainers"),
  "description" => _INTL("All opposing trainers will be level 100."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 8
})

MenuHandlers.add(:challenge, :metronome, {
  "name"        => _INTL("Metronome Only"),
  "description" => _INTL("All Pokémon can only use Metronome."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 9
})

MenuHandlers.add(:challenge, :wonderguard, {
  "name"        => _INTL("Wonder Guard"),
  "description" => _INTL("Opponents can only be hit by super effective moves. (Not start)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 10
})

MenuHandlers.add(:challenge, :shadowtag, {
  "name"        => _INTL("Shadow Tag"),
  "description" => _INTL("You cannot switch out or run away."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 10
})

MenuHandlers.add(:challenge, :noability, {
  "name"        => _INTL("No Abilities"),
  "description" => _INTL("All in-battle abilities will be disabled."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 11
})

MenuHandlers.add(:challenge, :nomoveeffects, {
  "name"        => _INTL("No Move Effects"),
  "description" => _INTL("Disables the secondary effects of all damaging moves."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 12
})

MenuHandlers.add(:challenge, :nospecialphysicalsplit, {
  "name"        => _INTL("No Special/Physical Split"),
  "description" => _INTL("Moves will be physical or special based on their type."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 12
})

MenuHandlers.add(:challenge, :generation, {
  "name"        => _INTL("Generation Rules"),
  "description" => _INTL("Changes the battle rules to match a specific generation."),
  "type"        => :CHALLENGE,
  "default"     => Settings::MECHANICS_GENERATION-1,
  "options"     => ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
  "order"       => 13
})

MenuHandlers.add(:challenge, :typeonly, {
  "name"        => _INTL("Specific Type Only"),
  "description" => _INTL("You can only use Pokémon of a specific type."),
  "type"        => :CHALLENGE,
  "default"     => 0,
  "options"     => ["None", "Normal", "Grass", "Fire", "Water", "Electric", "Ice", "Fighting", "Poison", "Ground", "Flying", "Psychic", "Bug", "Rock", "Ghost", "Dragon", "Dark", "Steel", "Fairy"],
  "gradient"    => Gradient.new([Color.new(12 * 8, 12 * 8, 12 * 8), Color.new("A8A878"), Color.new("78C850"), Color.new("F08030"), Color.new("6890F0"), Color.new("F8D030"), Color.new("98D8D8"), Color.new("C03028"), Color.new("A040A0"), Color.new("E0C068"), Color.new("A890F0"), Color.new("F85888"), Color.new("A8B820"), Color.new("B8A038"), Color.new("705898"), Color.new("7038F8"), Color.new("705848"), Color.new("B8B8D0"), Color.new("EE99AC")]),
  "order"       => 13
})

MenuHandlers.add(:challenge, :shinyonly, {
  "name"        => _INTL("Shiny Only"),
  "description" => _INTL("You can only use shiny Pokémon."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 14
})

MenuHandlers.add(:challenge, :levelone, {
  "name"        => _INTL("Level 1"),
  "description" => _INTL("All your Pokémon will be level 1. You won't be able to level them up."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 14
})

MenuHandlers.add(:challenge, :noevgain, {
  "name"        => _INTL("No EV gain"),
  "description" => _INTL("Your Pokémon are unable to gain EVs from battles."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 14
})

MenuHandlers.add(:challenge, :onehp, {
  "name"        => _INTL("1HP"),
  "description" => _INTL("All your Pokémon will have 1 HP. You won't be able to heal them."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 15
})

MenuHandlers.add(:challenge, :nohealing, {
  "name"        => _INTL("No Healing"),
  "description" => _INTL("You can no longer heal your Pokémon. Reviving them will set them to 1HP."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 15
})

MenuHandlers.add(:challenge, :losehponstep, {
  "name"        => _INTL("Lose HP on Step"),
  "description" => _INTL("All party members lose 1 HP on every step."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 15
})

MenuHandlers.add(:challenge, :hatemode, {
  "name"        => _INTL("Hate Mode"),
  "description" => _INTL("All your Pokémon's friendship will be set to 0. You won't be able to increase it."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 16
})

MenuHandlers.add(:challenge, :rocketmode, {
  "name"        => _INTL("Rocket Mode"),
  "description" => _INTL("After a battle you get your opponent's team. You can't get new Pokémon."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 16
})

MenuHandlers.add(:challenge, :murphyslaw, {
  "name"        => _INTL("Murphy's Law"),
  "description" => _INTL("Anything that can go wrong, will go wrong."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 16
})

MenuHandlers.add(:challenge, :pacifist, {
  "name"        => _INTL("Pacifist"),
  "description" => _INTL("Your Pokémon are unable to use damaging moves. Use status moves to win battles."),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 16
})

MenuHandlers.add(:challenge, :random_before_battles, {
  "name"        => _INTL("Random Before Battles"),
  "description" => _INTL("Everything is randomized when a battle starts. (Not Shadow Pokémon)"),
  "type"        => :CHALLENGE,
  "default"     => false,
  "order"       => 16
})

MenuHandlers.add(:challenge, :battle_pokemon_usage, {
  "name"        => _INTL("Max Pokémon In Battle"),
  "description" => _INTL("Changes the max amount of Pokémon you or your opponents will use."),
  "type"        => :CHALLENGE,
  "options"     => ["3v3", "3v2", "3v1", "2v1", "Normal", "1v2", "1v3", "2v3", "2v2"],
  "default"     => 4,
  "order"       => 16
})

MenuHandlers.add(:challenge, :weatherclear, {
  "name"        => _INTL("Weather: Clear"),
  "description" => _INTL("Disabling this will ensure all enabled weather effect."),
  "type"        => :HANDICAP,
  "default"     => true,
  "order"       => 17
})

MenuHandlers.add(:challenge, :weatherrain, {
  "name"        => _INTL("Weather: Rain"),
  "description" => _INTL("Whether or not it can rain."),
  "type"        => :HANDICAP,
  "default"     => true,
  "order"       => 18
})

MenuHandlers.add(:challenge, :weathersun, {
  "name"        => _INTL("Weather: Sun"),
  "description" => _INTL("Whether or not it can be a sunny day."),
  "type"        => :HANDICAP,
  "default"     => true,
  "order"       => 19
})

MenuHandlers.add(:challenge, :weatherhail, {
  "name"        => _INTL("Weather: Hail"),
  "description" => _INTL("Whether or not it can hail."),
  "type"        => :HANDICAP,
  "default"     => true,
  "order"       => 20
})

MenuHandlers.add(:challenge, :weathersandstorm, {
  "name"        => _INTL("Weather: Sandstorm"),
  "description" => _INTL("Whether or not it can sandstorm."),
  "type"        => :HANDICAP,
  "default"     => true,
  "order"       => 21
})

MenuHandlers.add(:challenge, :customstarters, {
  "name"        => _INTL("Custom Starters"),
  "description" => _INTL("Override the default starters with your own."),
  "type"        => :HANDICAP,
  "default"     => false,
  "order"       => 22
})

MenuHandlers.add(:challenge, :starterpkmn1, {
  "name"        => _INTL("Starter 1"),
  "description" => _INTL("The first starter you can choose from. (Only if Custom Starters is enabled)"),
  "type"        => :HANDICAP,
  "data"        => :species,
  "default"     => :BULBASAUR,
  "order"       => 23
})

MenuHandlers.add(:challenge, :starterpkmn2, {
  "name"        => _INTL("Starter 2"),
  "description" => _INTL("The second starter you can choose from. (Only if Custom Starters is enabled)"),
  "type"        => :HANDICAP,
  "data"        => :species,
  "default"     => :CHARMANDER,
  "order"       => 24
})

MenuHandlers.add(:challenge, :starterpkmn3, {
  "name"        => _INTL("Starter 3"),
  "description" => _INTL("The third starter you can choose from. (Only if Custom Starters is enabled)"),
  "type"        => :HANDICAP,
  "data"        => :species,
  "default"     => :SQUIRTLE,
  "order"       => 25
})

MenuHandlers.add(:challenge, :starteritem, {
  "name"        => _INTL("Starter Item"),
  "description" => _INTL("Choose which item you want to be in the PC at the start of the game."),
  "type"        => :HANDICAP,
  "data"        => :item,
  "default"     => :POTION,
  "order"       => 26
})

MenuHandlers.add(:challenge, :shinyodds, {
  "name"        => _INTL("Shiny Odds"),
  "description" => _INTL("Odds of a Pokémon being shiny."),
  "type"        => :HANDICAP,
  "options"     => ["None", "0.01%", "0.02%", "0.05%", "0.10%", "0.20%", "0.50%", "1%", "10%", "25%", "50%", "75%", "Always"],
  "default"     => 3,
  "gradient"    => Gradient.new([Color.new("6B1717"), Color.new("FFC83D"), Color.new("72D829")]),
  "order"       => 27
})

MenuHandlers.add(:challenge, :expmultiplier, {
  "name"        => _INTL("Experience Multiplier"),
  "description" => _INTL("Multiplies the amount of experience gained."),
  "type"        => :HANDICAP,
  "options"     => ["-1x", "0x", "0.25x", "0.5x", "0.75", "1x", "1.25x", "1.5x", "1.75x", "2x", "2.5x", "3x", "3.5x", "4x", "5x", "10x", "25x", "50x", "100x", "1000x"],
  "default"     => 5,
  "gradient"    => Gradient.new([Color.new("6B1717"), Color.new("FFC83D"), Color.new("72D829")]),
  "order"       => 28
})

MenuHandlers.add(:challenge, :catchmultiplier, {
  "name"        => _INTL("Catch Multiplier"),
  "description" => _INTL("Multiplies the chance of catching a Pokémon."),
  "type"        => :HANDICAP,
  "options"     => ["0x", "0.25x", "0.5x", "0.75", "1x", "1.25x", "1.5x", "1.75x", "2x", "2.5x", "3x", "3.5x", "4x", "5x", "10x", "25x", "50x", "100x", "1000x"],
  "default"     => 4,
  "gradient"    => Gradient.new([Color.new("6B1717"), Color.new("FFC83D"), Color.new("72D829")]),
  "order"       => 29
})

MenuHandlers.add(:challenge, :moneymultiplier, {
  "name"        => _INTL("Money Multiplier"),
  "description" => _INTL("Multiplies all money gain."),
  "type"        => :HANDICAP,
  "options"     => ["-1x", "0x", "0.25x", "0.5x", "0.75", "1x", "1.25x", "1.5x", "1.75x", "2x", "2.5x", "3x", "3.5x", "4x", "5x", "10x", "25x", "50x", "100x", "1000x"],
  "default"     => 5,
  "gradient"    => Gradient.new([Color.new("6B1717"), Color.new("FFC83D"), Color.new("72D829")]),
  "order"       => 30
})

MenuHandlers.add(:challenge, :godmode, {
  "name"        => _INTL("God Mode"),
  "description" => _INTL("You cannot take any damage."),
  "type"        => :HANDICAP,
  "default"     => false,
  "order"       => 31
})

MenuHandlers.add(:challenge, :lovemode, {
  "name"        => _INTL("Love Mode"),
  "description" => _INTL("All Pokémon will have max friendship and will be unable to lose it."),
  "type"        => :HANDICAP,
  "default"     => false,
  "order"       => 32
})


class SpriteWindow_Challenges < Window_DrawableCommand
  def initialize(viewport = nil)
    @challenges = []
    @challenge_ids = []
    MenuHandlers.each_available(:challenge) do |option, hash, name|
      @challenges.push(hash)
      @challenge_ids.push(option)
    end
    super(0, 0, Graphics.width, Graphics.height-96, viewport)
  end

  def shadowtext(x, y, w, h, t, align = 0, colors = 0)
    width = self.contents.text_size(t).width
    case align
    when 1   # Right aligned
      x += (w - width)
    when 2   # Centre aligned
      x += (w / 2) - (width / 2)
    end
    y += 8   # TEXT OFFSET
    if colors.is_a?(Color)
      base = colors
    else
      base = Color.new(12 * 8, 12 * 8, 12 * 8)
      case colors
      when 1   # Red
        base = Color.new(168, 48, 56)
      when 2   # Green
        base = Color.new(0, 144, 0)
      end
    end
    pbDrawShadowText(self.contents, x, y, [width, w].max, h, t, base, Color.new(26 * 8, 26 * 8, 25 * 8))
  end

  def itemCount
    return @challenges.length
  end

  def drawItem(index, _count, rect)
    pbSetNarrowFont(self.contents)
    return if index >= @challenges.length
    colors = 0
    gradient = @challenges[index]["gradient"] || Gradient.new([Color.new("72D829"), Color.new("FFC83D"), Color.new("6B1717")])
    codeswitch = false 
    name = @challenges[index]["name"]
    val = $player.challenges[@challenge_ids[index]]
    if val.nil?
      status = "[-]"
      colors = 0
      codeswitch = true
    elsif val.is_a?(Integer)
      status = "#{@challenges[index]["options"][val]}"
      colors = gradient.get_color(val / @challenges[index]["options"].length.to_f)
    elsif @challenges[index]["data"] == :species
      status = "#{GameData::Species.get(val).name}"
      colors = ($player.challenges[:customstarters] ? 2 : 1)
    elsif @challenges[index]["data"] == :item
      status = "#{GameData::Item.get(val).name}"
      colors = (val == @challenges[index]["default"]) ? 0 : 2
    elsif val   # true
      status = "[ON]"
      colors = 2
    else   # false
      status = "[OFF]"
      colors = 1
    end
    name ||= ""
    id_text = @challenges[index]["type"] == :CHALLENGE ? "Challenge" : "Handicap"
    rect = drawCursor(index, rect)
    totalWidth = rect.width
    idWidth     = totalWidth * 25 / 100
    nameWidth   = totalWidth * 55 / 100
    statusWidth = totalWidth * 20 / 100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x + idWidth, rect.y, nameWidth, rect.height, name, 0, (codeswitch) ? 1 : 0)
    self.shadowtext(rect.x + idWidth + nameWidth, rect.y, statusWidth, rect.height, status, 1, colors)
  end
end

def pbChallenges
  $player.challenges = {} if $player.challenges.nil?
  old_challenges = $player.challenges.clone
  all_challenges = []
  challenge_ids = []
  MenuHandlers.each_available(:challenge) do |option, hash, name|
    $player.challenges[option] = hash["default"] if $player.challenges[option].nil?
    all_challenges.push(hash)
    challenge_ids.push(option)
  end
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_Challenges.new(viewport)
  right_window = sprites["right_window"]
  right_window.active   = true
  last_index = 0
  msgwindow = pbCreateMessageWindow
  pbMessageDisplay(msgwindow, all_challenges[0]["description"], false) 
  loop do
    Graphics.update
    Input.update
    msgwindow.update
    pbUpdateSpriteHash(sprites)
    if right_window.index != last_index
      last_index = right_window.index
      pbMessageDisplay(msgwindow, all_challenges[right_window.index]["description"], false)
    end
    if Input.trigger?(Input::BACK)
      pbPlayCancelSE
      break
    end
    if Input.trigger?(Input::LEFT)
      if all_challenges[right_window.index]["options"]
        $player.challenges[challenge_ids[right_window.index]] = ($player.challenges[challenge_ids[right_window.index]] - 1) % all_challenges[right_window.index]["options"].length
        pbPlayDecisionSE
        right_window.refresh
      end
    end
    if Input.trigger?(Input::RIGHT)
      if all_challenges[right_window.index]["options"]
        $player.challenges[challenge_ids[right_window.index]] = ($player.challenges[challenge_ids[right_window.index]] + 1) % all_challenges[right_window.index]["options"].length
        pbPlayDecisionSE
        right_window.refresh
      end
    end
    if Input.trigger?(Input::USE)
      pbPlayDecisionSE
      if all_challenges[right_window.index]["options"]
        $player.challenges[challenge_ids[right_window.index]] = ($player.challenges[challenge_ids[right_window.index]] + 1) % all_challenges[right_window.index]["options"].length
      elsif all_challenges[right_window.index]["data"] == :item
        $player.challenges[challenge_ids[right_window.index]] = pbChooseItemList($player.challenges[challenge_ids[right_window.index]]) || $player.challenges[challenge_ids[right_window.index]]
      elsif all_challenges[right_window.index]["data"] == :species
        $player.challenges[challenge_ids[right_window.index]] = pbChooseSpeciesList($player.challenges[challenge_ids[right_window.index]]) || $player.challenges[challenge_ids[right_window.index]]
      else
        $player.challenges[challenge_ids[right_window.index]] = !$player.challenges[challenge_ids[right_window.index]]
      end
      right_window.refresh
    end
  end
  pbDisposeSpriteHash(sprites)
  Graphics.update
  pbMessageDisplay(msgwindow, _INTL("Applying challenges, please wait for them to be applied.\\wtnp[0]"))
  $player.challenges.each_pair do |challenge, value|
    next if old_challenges[challenge] == value
    next unless value
    case challenge
    when :randomizer_encounter
      pbRandomizeEncounters
    when :randomizer_abilities
      pbRandomizeAbilities
    when :randomizer_trainer
      pbRandomizeTrainers
    when :randomizer_learnset
      pbRandomizeLearnsets
    when :randomizer_warp
      pbWarpRandomizer
    when :randomizer_evolutions
      pbRandomizeEvolutions
    when :randomizer_item
      pbRandomizeItems
    when :randomizer_special
      pbRandomizeSpecial
    when :randomizer_mart
      pbRandomizeMarts
    when :randomizer_tms
      pbRandomizeTMs
    when :metronome
      $player.party.each { |pkmn| pkmn.moves = [Pokemon::Move.new(:METRONOME)] }
      $PokemonStorage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; pkmn.moves = [Pokemon::Move.new(:METRONOME)] } }
      $PokemonGlobal.day_care.slots.each { |slot| next unless slot.filled?; slot.pokemon.moves = [Pokemon::Move.new(:METRONOME)] }
      $PokemonGlobal.purifyChamber.sets.each { |set| set.list.each { |pkmn| next if pkmn.nil?; pkmn.moves = [Pokemon::Move.new(:METRONOME)] } }
    when :onehp
      pbSetAllOneHP
    when :hatemode
      $player.party.each { |pkmn| pkmn.happiness = 0 }
      $PokemonStorage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; pkmn.happiness = 0 } }
      $PokemonGlobal.day_care.slots.each { |slot| next unless slot.filled?; slot.pokemon.happiness = 0 }
      $PokemonGlobal.purifyChamber.sets.each { |set| set.list.each { |pkmn| next if pkmn.nil?; pkmn.happiness = 0 } }
    when :lovemode
      $player.party.each { |pkmn| pkmn.happiness = 255 }
      $PokemonStorage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; pkmn.happiness = 255 } }
      $PokemonGlobal.day_care.slots.each { |slot| next unless slot.filled?; slot.pokemon.happiness = 255 }
      $PokemonGlobal.purifyChamber.sets.each { |set| set.list.each { |pkmn| next if pkmn.nil?; pkmn.happiness = 255 } }
    when :levelone
      $player.party.each { |pkmn| pkmn.level = 1 }
      $PokemonStorage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; pkmn.level = 1 } }
      $PokemonGlobal.day_care.slots.each { |slot| next unless slot.filled?; slot.pokemon.level = 1 }
      $PokemonGlobal.purifyChamber.sets.each { |set| set.list.each { |pkmn| next if pkmn.nil?; pkmn.level = 1 } }
    end
  end
  pbDisposeMessageWindow(msgwindow)
  viewport.dispose
  pbMEPlay("GUI save game")
  pbMessage(_INTL("Challenges have been applied!\\wtnp[20]"))
end

def pbSetAllOneHP
  return unless $player.onehp
  $player.party.each { |pkmn| pkmn.hp = 1 if pkmn.hp > 0 }
  $PokemonStorage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; pkmn.hp = 1 if pkmn.hp > 0 } }
  $PokemonGlobal.day_care.slots.each { |slot| next unless slot.filled?; slot.pokemon.hp = 1 if slot.pokemon.hp > 0 }
  $PokemonGlobal.purifyChamber.sets.each { |set| set.list.each { |pkmn| next if pkmn.nil?; pkmn.hp = 1 if pkmn.hp > 0 } }
end

def randomize_before_battle(foe_party)
  mons = valid_pokemon(true)
  abilities = valid_abilities
  moves = valid_moves
  items = valid_items
  [$player.party, foe_party].each_with_index do |party, side|
    party.each do |pkmn|
      next if pkmn.shadowPokemon?
      pkmn.species = mons.sample
      pkmn.ability = abilities.sample
      pkmn.level = rand(1..100)
      pkmn.level = 1 if $player.levelone && side == 0
      pkmn.calc_stats
      pkmn.reset_moves
      pkmn.item = items.sample if pkmn.item
      pkmn.shiny = true if rand(65536) <= $player.shinyodds
      pkmn.moves.each_with_index do |move, i|
        pkmn.moves[i] = Pokemon::Move.new(moves.sample)
        pkmn.moves[i].ppup = move.ppup
        pkmn.moves[i].pp = (pkmn.moves[i].pp * (move.pp.to_f/move.total_pp.to_f)).round
      end
    end
  end
end

def player_has_balls
  GameData::Item.each do |item|
    next unless item.is_poke_ball?
    return true if $bag.has?(item.id)
  end
  return false
end

def murphylawpkmn(pkmn, shininess=true)
  # Maximize stats
  GameData::Stat.each_main { |s| pkmn.iv[s.id] = 31 }
  stats = []
  pkmn.species_data.base_stats.each_pair { |s, v| stats.push([s, v]) }
  stats.sort! { |a, b| b[1] <=> a[1] }
  pkmn.ev[stats[0][0]] = 255
  pkmn.ev[stats[1][0]] = 255
  pkmn.ev[stats[2][0]] = 8
  # Change nature
  highest_offensive = (pkmn.species_data.base_stats[:ATTACK] < pkmn.species_data.base_stats[:SPECIAL_ATTACK] ? :SPECIAL_ATTACK : :ATTACK)
  slow_mon = (pkmn.species_data.base_stats[:SPEED] < 75)
  if slow_mon
    if (pkmn.species_data.base_stats[:ATTACK] - pkmn.species_data.base_stats[:SPECIAL_ATTACK]).abs <= 10
      pkmn.nature = (highest_offensive == :SPECIAL_ATTACK ? :BOLD : :CAREFUL)
    else
      pkmn.nature = (highest_offensive == :ATTACK ? :JOLLY : :TIMID)
    end
  else
    if (pkmn.species_data.base_stats[:ATTACK] - pkmn.species_data.base_stats[:SPECIAL_ATTACK]).abs <= 10
      pkmn.nature = :QUIET
    else
      pkmn.nature = (highest_offensive == :ATTACK ? :ADAMANT : :MODEST)
    end
  end
  # Recalculate stats
  pkmn.calc_stats
  # Make shiny if you don't have any balls otherwise make it not shiny
  pkmn.shiny = !player_has_balls if shininess
  # Send the pokemon
  return pkmn
end

EventHandlers.add(:on_wild_pokemon_created, :murphyslaw,
  proc { |pkmn|
    next unless $player.murphyslaw
    pkmn = murphylawpkmn(pkmn)
  }
)

EventHandlers.add(:on_trainer_load, :remove_caught_shadows,
  proc { |trainer|
    if trainer
      trainer.party.each_with_index do |pkmn,i|
        trainer.party[i] = murphylawpkmn(pkmn, false)
      end
    end
  }
)