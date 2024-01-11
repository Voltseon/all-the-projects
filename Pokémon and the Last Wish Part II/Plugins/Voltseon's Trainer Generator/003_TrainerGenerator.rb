######################################
#
# Voltseon's Trainer Generator
#
######################################
# Version 1.0
######################################
#
# Battle Generator
#
######################################
#
# To start generating a battle, call:
# vGenerateTrainer(eventID,items,levels,partySize,nameVar,classVar,genderVar)
#
# Example:
# vGenerateTrainer(5,2,[50,80],[1,2],1,2,3)
# This would initiate a random trainer to event #5
# The trainer will have items 2 random items
# They will have between 1 and 2 Pokémon
# Their pokemon will be between level 50 and 80
# Their name, class and gender will be pushed to variable 1, 2 and 3 (gender is either 0 or 1)
#
######################################

# Sets the event ID to a random generated trainer
def vGenerateTrainer(eventID,items=0,levels=[50,50],party_size=[3,6],name_variable=1,class_variable=2,gender_variable=3)
  # Check for event viability
  return false if eventID.nil? || (!eventID.is_a?(Integer) && !eventID.is_a?(Game_Event))
  # Set the event
  event = nil
  event = get_character(eventID) if !eventID.is_a?(Game_Event)
  # Set trainer to random gender, 0 = male, 1 = female
  trainer_gender = rand(0..1)
  # Get a random trainer name based on the arrays
  trainer_name = trainer_gender == 0 ? RT_MALE_NAMES[rand(0...RT_MALE_NAMES.length)] : RT_FEMALE_NAMES[rand(0...RT_FEMALE_NAMES.length)]
  # Try to get a gender neutral name based on chance
  trainer_name = RT_NEUTRAL_NAMES[rand(0...RT_NEUTRAL_NAMES.length)] if rand(100) < GENDER_NEUTRAL_CHANCE
  # Try to get a trainer class that corresponds to the gender
  trainer_class = []
  until trainer_class[1] == trainer_gender
    trainer_class = RT_TRAINER_WHITELIST[rand(0...RT_TRAINER_WHITELIST.length)]
  end
  # Update the trainer type
  trainer_class[0] = GameData::TrainerType.try_get(trainer_class[0])
  # Set variables that can be used in common event
  pbSet(name_variable,trainer_name)
  pbSet(class_variable,trainer_class[0].real_name)
  pbSet(gender_variable,trainer_gender)
  # Set the event itself
  event.character_name = trainer_class[2]
  event.character_hue = 0
  pbTurnTowardEvent(event,$game_player)
  pbCommonEvent(RT_COMMON_EVENT_ID)
  return vRandomTrainerBattle(trainer_class,trainer_name,items,levels,party_size)
end

# Generates and initiates a trainer battle
def vRandomTrainerBattle(trainer_class,trainer_name,items,levels,party_size)
  return false if trainer_class.nil? || trainer_name.nil?
  # Get a random lose text
  lose_text = LOSE_TEXTS[rand(0...LOSE_TEXTS.length)]
  # Create trainer object
  trainer = NPCTrainer.new(trainer_name, trainer_class[0])
  trainer.id        = $Trainer.make_foreign_ID
  trainer.items     = []
  trainer.lose_text = lose_text
  # Add random items based on input
  for i in 0...items
    item = ITEM_WHITELIST[rand(0...ITEM_WHITELIST.length)] if items>0
    trainer.items.push(GameData::Item.try_get(item))
  end
  # Create each Pokémon owned by the trainer
  for i in 0...rand(party_size[0]-1..party_size[1]) # Iterate through a random party size
    # Check if the trainer has any preferred types
    if trainer_class.length > 3
      preferred_types = trainer_class
      preferred_types.drop(3)
    end
    # Get the species based on the preferred types
    species = vGetRandomPreferredSpecies(preferred_types)
    # Add difficulty modifiers
    levelModif = 1.0
    case $PokemonSystem.difficulty
    when 0 then levelModif = 0.8
    when 2 then levelModif = 1.2
    when 3 then levelModif = 1.5
    end
    # Set level
    level = rand(levels[0]..levels[1]) * levelModif
    level.round
    # Create the Pokemon from its species data
    random_pokemon = Pokemon.new(species,level)
    # Push to trainer
    trainer.party.push(random_pokemon)
  end
  # Trigger the trainer battle
  pbTrainerBattleCore(trainer)
  return true
end

# Checks through all the available pokemon for the preferred type
def vGetRandomPreferredSpecies(preferred_types)
  # Only get all species if using the blacklist
  if USE_SPECIES_BLACKLIST
    # Fill out an species array with all species in the game
    species_arr = []
    GameData::Species.each do |s|
      species_arr.push(s.id)
    end
    # Remove blacklist Pokémon from the array
    SPECIES_BLACKLIST.each do |bs|
      species_arr.delete(bs)
    end
  end
  # Generate any Pokemon if no preferred type is set
  return USE_SPECIES_BLACKLIST ? vGetNonBlacklistSpecies(species_arr) : GameData::Species.try_get(SPECIES_WHITELIST[rand(0...SPECIES_WHITELIST.length)]) if (preferred_types == [] || preferred_types.nil?)
  # Initializing values
  species = nil
  species_type1 = nil
  species_type2 = nil
  # Try to get the preferred types
  until preferred_types.include?(species_type1) || preferred_types.include?(species_type2)
    species = USE_SPECIES_BLACKLIST ? vGetNonBlacklistSpecies(species_arr) : GameData::Species.try_get(SPECIES_WHITELIST[rand(0...SPECIES_WHITELIST.length)])
    species_type1 = species.type1
    species_type2 = species.type2 if species.type2
  end
  return species
end

# Get a species that is not from the blacklist
def vGetNonBlacklistSpecies(species_arr)
  # Initializing values
  species = nil
  # Generate a random species
  species = GameData::Species.try_get(species_arr[rand(species_arr.length)])
  # Return the resulting species
  return species
end
# Play both the Last Wish games made by Voltseon and ENLS (1 with NocTurn and 2 with PurpleZaffre)


# Signature Battle for Felicity
def vSignatureBattleFelicity
  # Pokémon (Species,AbilityIndex,LevelModif,Item,Moves1..4,Nature,Gender)
  pkmn_array = [
    [:LUXRAY,1,-2,:CHARCOAL,:WILDCHARGE,:CRUNCH,:FIREFANG,:EXTREMESPEED,:ADAMANT,0],
    [:MANECTRIC,0,-2,:FOCUSSASH,:PARABOLICCHARGE,:FLAMETHROWER,:HYPERVOICE,:FOCUSBLAST,:TIMID,1],
    [:ROTOM_2,0,-1,:LIFEORB,:PARABOLICCHARGE,:SCALD,:HEX,:NASTYPLOT,:MODEST,0],
    [:RAICHU,0,0,:CHOICESPECS,:PARABOLICCHARGE,:THUNDERBOLT,:DISCHARGE,:AURASPHERE,:MODEST,1],
    [:MAGNEZONE,1,2,:METRONOME,:PARABOLICCHARGE,:TRIATTACK,:FLASHCANNON,:LIGHTSCREEN,:TIMID,0],
    [:JOLTEON,2,4,:AIRBALLOON,:PARABOLICCHARGE,:HYPERVOICE,:SHADOWBALL,:QUICKATTACK,:JOLLY,1]
  ]
  # Create trainer object
  trainer = NPCTrainer.new("Felicity", :LEADER_Felicity)
  trainer.id        = $Trainer.make_foreign_ID
  trainer.items     = [:XATTACK, :FULLRESTORE, :FULLRESTORE, :FULLHEAL, :FULLHEAL]
  trainer.lose_text = "Well that was to be expected from you, I mean, you truly are amazing as a trainer."
  # Create battle
  return vSignatureBatte(trainer,pkmn_array)
end

# Signature Battle for Tocke
def vSignatureBattleTocke
  # Pokémon (Species,AbilityIndex,LevelModif,Item,Moves1..4,Nature,Gender)
  pkmn_array = [
    [:NOCTOWL,0,-3,:WISEGLASSES,:HYPNOSIS,:DREAMEATER,:MOONBLAST,:AIRSLASH,:TIMID,1],
    [:STARAPTOR,0,-2,:ASSAULTVEST,:CLOSECOMBAT,:DRILLPECK,:EXTREMESPEED,:LUNGE,:ADAMANT,1],
    [:PELIPPER,1,-1,:MYSTICWATER,:HURRICANE,:THUNDER,:HYDROPUMP,:TAILWIND,:MODEST,0],
    [:CROBAT,2,1,:BLACKSLUDGE,:CROSSPOISON,:DRILLPECK,:LEECHLIFE,:SUBSTITUTE,:JOLLY,0],
    [:DRAGONITE,2,0,:PERSIMBERRY,:AQUATAIL,:OUTRAGE,:WINGATTACK,:FIREPUNCH,:ADAMANT,0],
    [:XATU,2,6,:BRIGHTPOWDER,:CALMMIND,:STOREDPOWER,:AIRSLASH,:OMINOUSWIND,:MODEST,1]
  ]
  # Create trainer object
  trainer = NPCTrainer.new("Tocke", :LEADER_Tocke)
  trainer.id        = $Trainer.make_foreign_ID
  trainer.items     = [:XSPATK, :FULLRESTORE, :FULLRESTORE, :FULLHEAL, :FULLHEAL]
  trainer.lose_text = "Heh! What an amazing display of strength yet again!"
  # Create battle
  return vSignatureBatte(trainer,pkmn_array)
end

# Signature Battle for Cris
def vSignatureBattleCris
  # Starter (Species,AbilityIndex,LevelModif,Item,Moves1..4,Nature,Gender)
  starter = [
    [:SCEPTILE,0,7,:MIRACLESEED,:LEAFBLADE,:WISH,:NIGHTSLASH,:DUALCHOP,:ADAMANT,pbGet(29)],
    [:TYPHLOSION,0,7,:CHARCOAL,:ERUPTION,:WISH,:EARTHPOWER,:FLAMETHROWER,:TIMID,pbGet(29)],
    [:BLASTOISE,0,7,:MYSTICWATER,:HYDROPUMP,:WISH,:PROTECT,:ICEBEAM,:MODEST,pbGet(29)]
  ]
  # Pokémon (Species,AbilityIndex,LevelModif,Item,Moves1..4,Nature,Gender)
  pkmn_array = [
    [:UMBREON,0,-3,:BRIGHTPOWDER,:DARKPULSE,:WISH,:SHADOWBALL,:MOONLIGHT,:TIMID,0],
    [:GRANBULL,0,-2,:CHOICEBAND,:ICEFANG,:MAGNITUDE,:PLAYROUGH,:CRUNCH,:ADAMANT,1],
    [:WEAVILE,0,0,:LIFEORB,:NIGHTSLASH,:METALCLAW,:HONECLAWS,:ICEPUNCH,:ADAMANT,1],
    [:UNOWN_2,0,3,:CHOICESPECS,:HIDDENPOWER,nil,nil,nil,:MODEST,0],
    [:DUSCLOPS,0,1,:EVIOLITE,:SHADOWPUNCH,:SHADOWSNEAK,:FIREPUNCH,:ICEPUNCH,:JOLLY,0],
    starter[pbGet(28)]
  ]
  # Create trainer object
  trainer = NPCTrainer.new(pbGet(27), (pbGet(29)==0) ? :LEADER_Cris_F : :LEADER_Cris_F)
  trainer.id        = $Trainer.make_foreign_ID
  trainer.items     = [:XSPEED, :FULLRESTORE, :FULLRESTORE, :FULLHEAL, :FULLHEAL]
  trainer.lose_text = "Phew! That was a great battle, it really helped me cool down! Thanks a lot!"
  # Create battle
  return vSignatureBatte(trainer,pkmn_array)
end

# Does the battle stuff
def vSignatureBatte(trainer,pkmn_array)
  # Create each Pokémon owned by the trainer
  for pok in pkmn_array
    # Set level
    case $PokemonSystem.difficulty
    when 0 then modif = -3
    when 1 then modif = -2
    when 2 then modif = 1
    when 3 then modif = 2
    end
    level = [[pbBalancedLevel($Trainer.party) + pok[2] + modif,100].min ,1].max
    # Create the Pokemon from its species data
    pkmn = Pokemon.new(pok[0],level)
    # Set ability
    pkmn.ability_index = pok[1]
    # Set item
    pkmn.item = pok[3]
    # Set moves
    for i in 0...4
      next if pok[4+i].nil?
      pkmn.moves[i] = Pokemon::Move.new(pok[4+i])
    end
    # Set IVs
    GameData::Stat.each_main do |s|
      pkmn.iv[s.id] = 31
    end
    # Unown
    if pkmn.isSpecies?(:UNOWN)
      # Makes hidden power the psychic type
      pkmn.iv[:ATTACK] = 30
      pkmn.iv[:DEFENSE] = 30
      pkmn.iv[:SPEED] = 30
    end
    # Set Nature
    pkmn.nature = pok[8]
    # Set EVs
    if pkmn.nature == :JOLLY || pkmn.nature == :ADAMANT
      pkmn.ev[:ATTACK] = 252
    else
      pkmn.ev[:SPATK] = 252
    end
    pkmn.ev[:SPEED] = 252
    pkmn.ev[:HP] = 4
    # Set Gender
    pkmn.nature = pok[9]
    # Finalize
    pkmn.shiny = false
    pkmn.calc_stats
    # Push to trainer
    trainer.party.push(pkmn)
  end
  # Heal the player's party
  $Trainer.heal_party
  # Trigger the trainer battle
  BattleScripting.setTrainerAce(5)
  return pbTrainerBattleCore(trainer)==1
end