def pbStartQuest0
  VQS_Quest.new(
    true, # Active
    "Catching Pokémon", # Name
    "Catch a Bidoof and a Hoothoot.", # Description
    [85,79,48,58], # Event
    "Selago Meadows", # Location
    [], # Rewards
    [], # Container
    "return $player.pokedex.caught_count(:BIDOOF)>0 && $player.pokedex.caught_count(:HOOTHOOT)>0", # Completion Check
    "return ($player.pokedex.caught_count(:BIDOOF)>0 ? $player.pokedex.caught_count(:HOOTHOOT)>0 ? 1 : 0.5 : $player.pokedex.caught_count(:HOOTHOOT)>0 ? 0.5 : 0)" # Progress Check
  )
end

def pbStartQuest1
  VQS_Quest.new(
    true, # Active
    "Temple Meeting", # Name
    "Someone at the Tomb of the Spirits is waiting for you.", # Description
    [8,8,8,8], # Event
    "Gondola Village", # Location
    [[:SOOTHEBELL,1]], # Rewards
    [], # Container
    "return true", # Completion Check
    "return 0" # Progress Check
  )
end

def pbStartQuest2
  VQS_Quest.new(
    true, # Active
    "Differing Species", # Name
    "Explore the region, register 10 different species of Pokémon in your Journal.", # Description
    [8,8,8,8], # Event
    nil, # Location
    [[:LUCKYEGG,1]], # Rewards
    [], # Container
    "return $player.pokedex.owned_count>9", # Completion Check
    "return $player.pokedex.owned_count.to_f/10.0" # Progress Check
  )
end

def pbStartQuest3
  VQS_Quest.new(
    true, # Active
    "Alpha Vespiquen", # Name
    "Defeat the rampaging Vespiquen that's attacking her own Combee colony.", # Description
    [8,8,8,8], # Event
    "Selago Meadows", # Location
    [[:EXPCHARM,1]], # Rewards
    [], # Container
    "return true", # Completion Check
    "return 0" # Progress Check
  )
end

def pbStartQuest4
  VQS_Quest.new(
    true, # Active
    "Alpha Pinsir and Heracross", # Name
    "The two alpha Pokémon are fighting over food! Help Axel end the feud.", # Description
    [31,83,23,14], # Event
    "Heliotrope Woods", # Location
    [[:HYPERPOTION,6]], # Rewards
    [], # Container
    "return true", # Completion Check
    "return 0" # Progress Check
  )
end