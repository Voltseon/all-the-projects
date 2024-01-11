#===============================================================================
# Rain Dance
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:RAINDANCE,proc { |move,pkmn,showmsg|
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !map_metadata || !map_metadata.outdoor_map
    pbMessage(_INTL("Can't use that indoors.")) if showmsg
    next false
  end
  if map_metadata.flags.include?("CannotRain")
    pbMessage(_INTL("Can't use that here")) if showmsg
    next false
  end
  if $game_screen.weather_type==:Rain ||
     $game_screen.weather_type==:HeavyRain
    pbMessage(_INTL("It's already raining.")) if showmsg
   next false
end
  for i in 0...pkmn.moves.length
    if pkmn.moves[i].id==:RAINDANCE
      moveno = i
    end
  end
  if pkmn.moves[moveno].pp==0
    pbMessage(_INTL("Not enough PP...")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:RAINDANCE,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!",pokemon.name,move.name))
  end
  $game_screen.weather(:Rain, 9, 20)
    for i in 0...pokemon.moves.length
      if pokemon.moves[i].id==:RAINDANCE
        pokemon.moves[i].pp -= 1
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  next true
})

#===============================================================================
# Sandstorm
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:SANDSTORM,proc { |move,pkmn,showmsg|
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !map_metadata || !map_metadata.outdoor_map
    pbMessage(_INTL("Can't use that indoors.")) if showmsg
    next false
  end
  if map_metadata.flags.include?("CannotHail")
    pbMessage(_INTL("Can't use that here")) if showmsg
    next false
  end
  if $game_screen.weather_type==:Sandstorm
    pbMessage(_INTL("There is already a sandstorm.")) if showmsg
   next false
  end
  for i in 0...pkmn.moves.length
    if pkmn.moves[i].id==:SANDSTORM
      moveno = i
    end
  end
  if pkmn.moves[moveno].pp==0
    pbMessage(_INTL("Not enough PP...")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:SANDSTORM,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!",pokemon.name,move.name))
  end
  $game_screen.weather(:Sandstorm, 9, 20)
  for i in 0...pokemon.moves.length
    if pokemon.moves[i].id==:SANDSTORM
        pokemon.moves[i].pp -= 1
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  next true
})

#===============================================================================
# Hail
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:HAIL,proc { |move,pkmn,showmsg|
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !map_metadata || !map_metadata.outdoor_map
    pbMessage(_INTL("Can't use that indoors.")) if showmsg
    next false
  end
  if map_metadata.flags.include?("CannotHail")
    pbMessage(_INTL("Can't use that here")) if showmsg
    next false
  end
  if $game_screen.weather_type==:Snow ||
     $game_screen.weather_type==:Blizzard
    pbMessage(_INTL("It's already snowing.")) if showmsg
   next false
  end
  for i in 0...pkmn.moves.length
    if pkmn.moves[i].id==:HAIL
      moveno = i
    end
  end
  if pkmn.moves[moveno].pp==0
    pbMessage(_INTL("Not enough PP...")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:HAIL,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!",pokemon.name,move.name))
  end
  $game_screen.weather(:Snow, 9, 20)
  for i in 0...pokemon.moves.length
    if pokemon.moves[i].id==:HAIL
        pokemon.moves[i].pp -= 1
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  next true
})

#===============================================================================
# Sunny Day
#===============================================================================
HiddenMoveHandlers::CanUseMove.add(:SUNNYDAY,proc { |move,pkmn,showmsg|
  map_metadata = GameData::MapMetadata.try_get($game_map.map_id)
  if !map_metadata || !map_metadata.outdoor_map
    pbMessage(_INTL("Can't use that indoors.")) if showmsg
    next false
  end
  if map_metadata.flags.include?("CannotSun")
    pbMessage(_INTL("Can't use that here")) if showmsg
    next false
  end
    if $game_screen.weather_type==:Sun
    pbMessage(_INTL("It's already sunny.")) if showmsg
   next false
  end
  if PBDayNight.isNight?
    pbMessage(_INTL("Can't use that at night.")) if showmsg
   next false
  end
  for i in 0...pkmn.moves.length
    if pkmn.moves[i].id==:SUNNYDAY
      moveno = i
    end
  end
  if pkmn.moves[moveno].pp==0
    pbMessage(_INTL("Not enough PP...")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:SUNNYDAY,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!",pokemon.name,move.name))
  end
  $game_screen.weather(:Sun, 9, 20)
  for i in 0...pokemon.moves.length
    if pokemon.moves[i].id==:SUNNYDAY
        pokemon.moves[i].pp -= 1
      end
    end
    Graphics.update
    Input.update
    pbUpdateSceneMap
  next true
})

