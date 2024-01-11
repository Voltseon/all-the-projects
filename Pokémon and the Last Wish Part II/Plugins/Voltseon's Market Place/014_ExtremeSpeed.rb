GameData::TerrainTag.register({
  :id                     => :ESCorner_b,
  :id_number              => 21,
  :extreme_speed          => true
})

GameData::TerrainTag.register({
  :id                     => :ESCorner_d,
  :id_number              => 22,
  :extreme_speed          => true
})

GameData::TerrainTag.register({
  :id                     => :ESCorner_p,
  :id_number              => 23,
  :extreme_speed          => true
})

GameData::TerrainTag.register({
  :id                     => :ESCorner_q,
  :id_number              => 24,
  :extreme_speed          => true
})

HiddenMoveHandlers::CanUseMove.add(:EXTREMESPEED,proc { |move,pkmn,showmsg|
  next false if !pbCheckHiddenMoveSwitch(7,false)
  if $PokemonGlobal.surfing || $PokemonGlobal.scuba || ($game_player.pbFacingEvent && !$game_player.pbFacingEvent.name[/extremespeed/i]) || !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:EXTREMESPEED,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!\1",pokemon.name,GameData::Move.get(move).name))
  end
  pbExtremeSpeed
  next true
})

def pbExtremeSpeed
  old_toggled = $PokemonGlobal.follower_toggled
  FollowingPkmn.toggle_off(true)
  speciesname = ($Trainer.get_pokemon_with_move(:EXTREMESPEED)) ? $Trainer.get_pokemon_with_move(:EXTREMESPEED).name : $Trainer.name
  pbCancelVehicles
  pbStartExtremeSpeed
  FollowingPkmn.toggle(old_toggled, false)
  pbExtremeSpeedSlide if $PokemonGlobal.extremespeed
end

def pbStartExtremeSpeed
  pbCancelVehicles
  $PokemonEncounters.reset_step_count
  $PokemonGlobal.extremespeed = true
  pbUpdateVehicle
  $PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
  $PokemonTemp.surfJump = nil
  $game_player.check_event_trigger_here([1,2])
  pbExtremeSpeedSlide
  $PokemonGlobal.extremespeed = false
end

def pbExtremeSpeedSlide
  return if !$PokemonGlobal.extremespeed
  hasFollower = $PokemonGlobal.follower_toggled
  FollowingPkmn.toggle_off(true) if hasFollower
  $PokemonGlobal.sliding = true
  $game_player.straighten
  eventsToErase = []
  loop do
    old_through = $game_player.through
    facingEvent = $game_player.pbFacingEvent
    player_facing_coords = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
    facing_terrain = $game_map.terrain_tag(player_facing_coords[0], player_facing_coords[1]).id
    facing_corner = [:ESCorner_b, :ESCorner_d, :ESCorner_p, :ESCorner_q].include?(facing_terrain)
    $game_player.through = true if facing_corner
    if $game_map.terrain_tag(player_facing_coords[0], player_facing_coords[1],true).bridge
      pbMessage("The bridge is too unstable to Extreme Speed on...")
      break
    end
    if facingEvent
      if facingEvent.name[/extremespeed/i]
        pbSEPlay("Battle damage weak")
        pbMoveRoute(facingEvent,[
          PBMoveRoute::ThroughOn,
          PBMoveRoute::Wait,2,
          PBMoveRoute::TurnLeft,
          PBMoveRoute::Wait,2,
          PBMoveRoute::TurnRight,
          PBMoveRoute::Wait,2,
          PBMoveRoute::TurnUp,
          PBMoveRoute::Wait,2,
          PBMoveRoute::Graphic,"",0,0,0,0
       ])
       eventsToErase.push(facingEvent)
      elsif facingEvent.name[/ledge/i]
        $game_player.jump(0,-4)
      elsif facingEvent.name[/sewerentrance/i]
        pbCommonEvent(5)
      elsif facingEvent.name[/noextremecheck/i]
        facingEvent.start
        facingEvent.update
        facingEvent.clear_starting
      else
        break
      end
    elsif !$game_player.can_move_in_direction?($game_player.direction) && !facing_corner
      player_facing_coords2 = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction,2)
      if $game_map.terrain_tag(player_facing_coords[0], player_facing_coords[1]).ledge &&
          $game_player.can_move_from_coordinate?(player_facing_coords2[0], player_facing_coords2[1], pbGetPlayerOppositeDirection, false)
        pbJumpToward(2,true)
      else
        break
      end
    end
    break if !$PokemonGlobal.extremespeed
    case facing_terrain
    when :ESCorner_b then ($game_player.direction==2) ? $game_player.move_lower_right : $game_player.move_upper_left
    when :ESCorner_d then ($game_player.direction==2) ? $game_player.move_lower_left : $game_player.move_upper_right
    when :ESCorner_p then ($game_player.direction==8) ? $game_player.move_upper_right : $game_player.move_lower_left
    when :ESCorner_q then ($game_player.direction==8) ? $game_player.move_upper_left : $game_player.move_lower_right
    else $game_player.move_forward
    end
    while $game_player.moving?
      pbUpdateSceneMap
      Graphics.update
      Input.update
    end
    $game_player.through = old_through
  end
  for i in eventsToErase
    i.erase
    $PokemonMap.addErasedEvent(i.id) if $PokemonMap
  end
  $game_player.center($game_player.x, $game_player.y)
  $game_player.straighten
  FollowingPkmn.toggle_on(true) if hasFollower
  $PokemonGlobal.sliding = false
end
