=begin
# Challenge EXAMPLE
challenges = [
        ["Get <c2=039F2108>3</c2> takedowns on <c2=039F2108>Lights</c2> using <c2=039F2108>Heracross</c2>", 1, 3],
        ["Win <c2=039F2108>1</c2> match on <c2=039F2108>Oasis</c2> using <c2=039F2108>Farfetch'd</c2>", 0, 1],
        ["Open <c2=039F2108>1</c2> lootbox", 1, 1]
      ]
=end

# Each day at midnight, the player gets a new set of challenges. They can complete these challenges to earn rewards.
# The challenges are stored in a hash, with the key being the challenge ID and the value being the challenge data.
# The challenge data is an array with the following values:
#   0: The challenge text. This is what the player sees.
#   1: The challenge type. This determines how the challenge is completed.
#   2: The challenge goal. This determines how many times the challenge must be completed.
#   3: The challenge progress. This is how many times the challenge has been completed.
#   4: The challenge reward. This is how many levels the player's Pivot Pass will increase by.

# Challenge types:
#   0:  Win X matches.
#   1:  Win X matches on a specific map.
#   2:  Win X matches using a specific Pokemon.
#   3:  Win X matches on a specific map using a specific Pokemon.
#   4:  Get X takedowns.
#   5:  Get X takedowns on a specific map.
#   6:  Get X takedowns using a specific Pokemon.
#   7:  Get X takedowns on a specific map using a specific Pokemon.
#   8:  Open X lootboxes.
#   9:  Emote X times.
#   10: Emote X times on a specific map.
#   11: Evolve X times.
#   12: Evolve a specific Pokémon X times.
#   13: Play X matches.
#   14: Play X matches on a specific map.
#   15: Play X matches using a specific Pokémon.
#   16: Play X matches on a specific map using a specific Pokémon.
#   17: Win X matches in a row.
#   etc.


class Challenge
  attr_accessor :id
  attr_accessor :text
  attr_accessor :type
  attr_accessor :goal
  attr_accessor :progress
  attr_accessor :reward
  attr_accessor :arena
  attr_accessor :pokemon

  def initialize(id, text, type, goal, reward, progress = 0, arena = nil, pokemon = nil)
    @id = id
    @text = text
    @type = type
    @goal = goal
    @reward = reward
    @progress = progress
    @arena = arena.map_id if arena
    @pokemon = pokemon.internal if pokemon
  end

  def progress=(value)
    @progress = value
    if @progress >= @goal
      icon = nil
      if @pokemon
        icon = "Graphics/Characters/#{@pokemon}/icon"
      end
      notification("Challenge Completed!",short_description(self.category, @goal),icon)
      # Add the reward to the player's Pivot Pass.
      $player.pp_level += @reward
    end
  end

  def complete?
    return @progress >= @goal
  end

  def increase_progress
    @progress += 1
  end

  def category
    return challenge_category(@type)
  end
end

def short_description(category, amt)
  case category
  when "Win"
    return "Win #{amt} matches"
  when "Takedowns"
    return "Get #{amt} takedowns"
  when "Lootboxes"
    return "Open #{amt} lootboxes"
  when "Emotes"
    return "Emote #{amt} times"
  when "Evolutions"
    return "Evolve #{amt} times"
  when "Matches"
    return "Play #{amt} matches"
  end
end

def check_for_challenge(category, arena = nil, pokemon = nil)
  if $player.challenges.any? { |challenge| challenge.category == category }
    challenge = $player.challenges.find { |challenge| challenge.category == category }
    return if challenge.nil?
    return if challenge.complete?
    if !challenge.arena.nil?
      return if challenge.arena != arena
    end
    if !challenge.pokemon.nil?
      return if challenge.pokemon != pokemon
    end
    challenge.progress += 1
  end
end

def challenge_category(type)
  case type
  when 0, 1, 2, 3
    return "Win"
  when 4, 5, 6, 7
    return "Takedowns"
  when 8
    return "Lootboxes"
  when 9, 10
    return "Emotes"
  when 11, 12
    return "Evolutions"
  when 13, 14, 15, 16
    return "Matches"
  end
end

def pbGenerateChallenge(type, difficulty)
  # Difficulty: 0 = Easy, 1 = Medium, 2 = Hard
  case type
  when 0
    # Win X matches.
    goal = rand(1..3) + difficulty
    reward = 1 + difficulty
    return Challenge.new(0, "Win <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""}.", type, goal, reward)
  when 1
    # Win X matches on a specific map.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    goal = rand(1..3) + difficulty
    reward = 1 + difficulty
    return Challenge.new(1, "Win <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""} on <c2=039F2108>#{arena.name}</c2>.", type, goal, reward, 0, arena)
  when 2
    # Win X matches using a specific Pokemon.
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal)
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(1..3) + difficulty
    reward = 1 + difficulty
    return Challenge.new(2, "Win <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""} using <c2=039F2108>#{pokemon.name}</c2>.", type, goal, reward, 0, nil, pokemon)
  when 3
    # Win X matches on a specific map using a specific Pokemon.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal)
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(1..3) + difficulty
    reward = 1 + difficulty
    return Challenge.new(3, "Win <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""} on <c2=039F2108>#{arena.name}</c2> using <c2=039F2108>#{pokemon.name}</c2>.", type, goal, reward, 0, arena, pokemon)
  when 4
    # Get X takedowns.
    goal = rand(3..5) + (difficulty * 2)
    reward = 1 + difficulty
    return Challenge.new(4, "Get <c2=039F2108>#{goal}</c2> takedown#{(goal > 1) ? "s" : ""}.", type, goal, reward)
  when 5
    # Get X takedowns on a specific map.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    goal = rand(3..5) + (difficulty)
    reward = 1 + difficulty
    return Challenge.new(5, "Get <c2=039F2108>#{goal}</c2> takedown#{(goal > 1) ? "s" : ""} on <c2=039F2108>#{arena.name}</c2>.", type, goal, reward, 0, arena)
  when 6
    # Get X takedowns using a specific Pokemon.
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal)
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(3..5) + (difficulty)
    reward = 1 + difficulty
    return Challenge.new(6, "Get <c2=039F2108>#{goal}</c2> takedown#{(goal > 1) ? "s" : ""} using <c2=039F2108>#{pokemon.name}</c2>.", type, goal, reward, 0, nil, pokemon)
  when 7
    # Get X takedowns on a specific map using a specific Pokemon.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal)
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(1..3) + (difficulty)
    reward = 1 + difficulty
    return Challenge.new(7, "Get <c2=039F2108>#{goal}</c2> takedown#{(goal > 1) ? "s" : ""} on <c2=039F2108>#{arena.name}</c2> using <c2=039F2108>#{pokemon.name}</c2>.", type, goal, reward, 0, arena, pokemon)
  when 8
    # Open X lootboxes.
    goal = 1 + difficulty
    reward = 1 + difficulty
    return Challenge.new(8, "Open <c2=039F2108>#{goal}</c2> lootbox#{(goal > 1) ? "es" : ""}.", type, goal, reward)
  when 9
    # Emote X times.
    goal = rand(10..20) + (difficulty * 15)
    reward = 1 + difficulty
    return Challenge.new(9, "Emote <c2=039F2108>#{goal}</c2> time#{(goal > 1) ? "s" : ""}.", type, goal, reward)
  when 10
    # Emote X times on a specific map.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    goal = rand(5..10) + (difficulty * 10)
    reward = 1 + difficulty
    return Challenge.new(10, "Emote <c2=039F2108>#{goal}</c2> time#{(goal > 1) ? "s" : ""} on <c2=039F2108>#{arena.name}</c2>.", type, goal, reward, 0, arena)
  when 11
    # Evolve X times.
    goal = rand(1..3) + (difficulty * 2)
    reward = 1 + difficulty
    return Challenge.new(11, "Evolve <c2=039F2108>#{goal}</c2> time#{(goal > 1) ? "s" : ""}.", type, goal, reward)
  when 12
    # Evolve a specific Pokémon X times.
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal) && character.evolution != nil
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(1..3) + (difficulty)
    reward = 1 + difficulty
    return Challenge.new(12, "Evolve <c2=039F2108>#{pokemon.name}</c2> <c2=039F2108>#{goal}</c2> time#{(goal > 1) ? "s" : ""}.", type, goal, reward, 0, nil, pokemon)
  when 13
    # Play X matches.
    goal = rand(3..5) + (difficulty * 4)
    reward = 1 + difficulty
    return Challenge.new(13, "Play <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""}.", type, goal, reward)
  when 14
    # Play X matches on a specific map.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    goal = rand(1..3) + (difficulty * 3)
    reward = 1 + difficulty
    return Challenge.new(14, "Play <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""} on <c2=039F2108>#{arena.name}</c2>.", type, goal, reward, 0, arena)
  when 15
    # Play X matches using a specific Pokemon.
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal)
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(1..3) + (difficulty * 3)
    reward = 1 + difficulty
    return Challenge.new(15, "Play <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""} using <c2=039F2108>#{pokemon.name}</c2>.", type, goal, reward, 0, nil, pokemon)
  when 16
    # Play X matches on a specific map using a specific Pokemon.
    arenas = []
    Arena.each_with_index do |arena, i|
      arenas.push(arena) if $player.unlocked_arenas.include?(arena.internal) && (arena.internal != :TRAININGROOM)
    end
    arena = arenas.sample
    unlocked_pokemon = []
    Character.each_with_index do |character, i|
      unlocked_pokemon.push(character) if $player.unlocked_characters.include?(character.internal)
    end
    pokemon = unlocked_pokemon.sample
    goal = rand(1..3) + difficulty
    reward = 1 + difficulty
    return Challenge.new(16, "Play <c2=039F2108>#{goal}</c2> match#{(goal > 1) ? "es" : ""} on <c2=039F2108>#{arena.name}</c2> using <c2=039F2108>#{pokemon.name}</c2>.", type, goal, reward, 0, arena, pokemon)
  end
end

def pbCreateDailyChallenges
  # Create 3 challenges for the player to complete, one of each difficulty.
  types = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16]
  challenges = []
  chosen_types = types.sample(3)
  # Check if any of the chosen types are duplicates, or have duplicate categories.
  while chosen_types[0] == chosen_types[1] || chosen_types[0] == chosen_types[2] || chosen_types[1] == chosen_types[2] || challenge_category(chosen_types[0]) == challenge_category(chosen_types[1]) || challenge_category(chosen_types[0]) == challenge_category(chosen_types[2]) || challenge_category(chosen_types[1]) == challenge_category(chosen_types[2])
    chosen_types = types.sample(3)
  end
  challenges.push(pbGenerateChallenge(chosen_types[0], 0))
  challenges.push(pbGenerateChallenge(chosen_types[1], 1))
  challenges.push(pbGenerateChallenge(chosen_types[2], 2))
  return challenges
end

def pbGetChallengeTexts
  return nil if $player.challenges.nil? || $player.challenges.empty?
  # Get the challenge texts for the player's current challenges.
  # Returns array: [[challenge_text, challenge_progress, challenge_goal], ...]
  challenge_texts = []
  $player.challenges.each do |challenge|
    challenge_texts.push([challenge.text, challenge.progress, challenge.goal])
  end
  return challenge_texts.reverse
end