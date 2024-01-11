# Nuzlocke Rules:
#
# 1. You can only catch the first encounter in a route (even when encountering your first pokemon in an easier difficulty)
# 2. All opposing pokemon their levels are increased for more difficulty
# 3. Shiny pokemon are always allowed for capturing
# 4. When a pokemon faints it cannot be recovered or revived
# 5. If your entire party is knocked out one pokemon is revived for gameplay value
# 6. Rules only apply when the player receives their first pokeballs
# 7. Some encounters may be caught because of story importance

class Trainer
  attr_writer :encounter_maps
  attr_writer :encounter_mons
  attr_writer :nuzlocke_started

  def encounter_maps
		@encounter_maps = [] if !@encounter_maps
		return @encounter_maps
  end

  def encounter_mons
		@encounter_mons = [] if !@encounter_mons
		return @encounter_mons
  end
  
  def nuzlocke_started
		@nuzlocke_started = false if !@nuzlocke_started
		return @nuzlocke_started
	end
end

class PokemonSystem
  attr_writer :difficulty
  
	def difficulty
		@difficulty = 1 if !@difficulty # 0 = Easy, 1 = Normal , 2 = Hard, 3 = Nuzlocke
		return @difficulty
  end
end
  

class PokemonOption_Scene
	def pbAddOnOptions(options)
    oldval = $PokemonSystem.difficulty
    option = [_INTL("E"),_INTL("N"),_INTL("H"),_INTL("Nuz")]
    options.push(EnumOption.new(_INTL("Difficulty"),option,
      proc { $PokemonSystem.difficulty },
      proc { |value|
        $PokemonSystem.difficulty = value
      }
    ))
		return options
	end
end

def changeDifficulty
  shouldChange = pbMessage(_INTL("\\w[]"),[_INTL("Change"), _INTL("Cancel")])
  if shouldChange == 0
    commands = [_INTL("Easy"),_INTL("Normal"),_INTL("Hard"),_INTL("Nuzlocke")]
    command = pbMessage(_INTL("\\w[]"),commands)
    $PokemonSystem.difficulty = command
    pbMessage(_INTL("\\wdChanged your difficulty to {1}!",commands[command]))
  end
end

def updatePokemonLevel(pokemon, modifier)
  new_level = pokemon.level * modifier
  pokemon.level = new_level.round
  pokemon.calc_stats
  pokemon.reset_moves
end

Events.onWildPokemonCreate += proc { |_sender, e|
  pokemon = e[0]
  case $PokemonSystem.difficulty
  when 0 then updatePokemonLevel(pokemon, 0.8)
  when 2 then updatePokemonLevel(pokemon, 1.1)
  when 3 then updatePokemonLevel(pokemon, 1.2)
  end
}

Events.onWildBattleEnd += proc { |_sender, e|
  if $PokemonSystem.difficulty == 3
    if !$Trainer.encounter_maps.include?($game_map.name) && !$Trainer.encounter_mons.include?(e[0].species) && $Trainer.nuzlocke_started
      $Trainer.encounter_maps.push($game_map.name)
      $Trainer.encounter_mons.push(e[0].species)
    end
  end
}