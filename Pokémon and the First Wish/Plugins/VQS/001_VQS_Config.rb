class VQS_Config
  RANDOMIZED_POKEMON = [
    :BIDOOF,
    :HOOTHOOT,
    :SEWADDLE,
    :AZURILL,
    :TRUBBISH,
    :BUIZEL,
    :RALTS
  ]
  
  def self.randomized_reward
    return [
      [:POTION, rand(1..10)],
      [:SUPERPOTION, rand(1..5)],
      [:HYPERPOTION, rand(1..2)],
      [:POKEBALL, rand(1..20)],
      [:GREATBALL, rand(1..10)],
      [:ULTRABALL, rand(1..5)]
    ]
  end

  def self.randomized_proc(container)
    return [
      "return $player.pokedex.caught_count(:#{container[0]})-#{container[1]} >= #{container[2]}"
    ]
  end

  def self.randomized_progress(container)
    return [
      "return ($player.pokedex.caught_count(:#{container[0]}).to_f-#{container[1]}.to_f) / #{container[2]}.to_f"
    ]
  end

  def self.randomized_container
    mon = RANDOMIZED_POKEMON.sample
    return [
      [mon, $player.pokedex.caught_count(mon), rand(1..5)*5]
    ]
  end

  def self.randomized_name(container)
    return [
      "Capturing #{GameData::Species.get(container[0]).name}"
    ]
  end

  def self.randomized_description(container)
    return [
      "Explore the region and catch at least #{container[2]} #{GameData::Species.get(container[0]).name}!"
    ]
  end
end