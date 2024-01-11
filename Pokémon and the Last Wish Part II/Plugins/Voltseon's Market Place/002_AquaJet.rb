GameData::TerrainTag.register({
  :id                     => :Whirlpool,
  :id_number              => 19,
  :can_surf               => true
})

HiddenMoveHandlers::CanUseMove.add(:AQUAJET,proc { |move,pkmn,showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLASH,showmsg)
  if $PokemonGlobal.surfing || !$game_player.pbFacingTerrainTag.can_surf_freely || $game_player.pbFacingEvent || !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player) || $PokemonGlobal.bridge > 0
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:AQUAJET,proc { |move,pokemon|
  shouldmessage = false
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!\1",pokemon.name,GameData::Move.get(move).name))
    shouldmessage = true
  end
  pbAquaJet(shouldmessage)
  next true
})

def pbAquaJet(message=true)
  old_toggled = $PokemonGlobal.follower_toggled
  FollowingPkmn.toggle_off(true)
  speciesname = ($Trainer.get_pokemon_with_move(:AQUAJET)) ? $Trainer.get_pokemon_with_move(:AQUAJET).name : $Trainer.name
  pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(:AQUAJET).name)) if !message
  pbCancelVehicles
  pbHiddenMoveAnimation($Trainer.get_pokemon_with_move(:AQUAJET)) if message
  pbStartAquaJet
  FollowingPkmn.toggle(old_toggled, false)
  #surfbgm = GameData::Metadata.get.surf_BGM
  #pbCueBGM(surfbgm,0.5) if surfbgm
  pbAquaJetSlide if $PokemonGlobal.surfing
end

def pbStartAquaJet
  pbCancelVehicles
  $PokemonEncounters.reset_step_count
  $PokemonGlobal.surfing = true
  pbUpdateVehicle
  $PokemonTemp.surfJump = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
  pbJumpToward
  $PokemonTemp.surfJump = nil
  $game_player.check_event_trigger_here([1,2])
  pbAquaJetSlide
end

def pbGetPlayerOppositeDirection
  case $game_player.direction
  when 2
    return 8
  when 4
    return 6
  when 6
    return 4
  when 8
    return 2
  end
end

def pbAquaJetSlide
  return if !$PokemonGlobal.surfing
  hasFollower = $PokemonGlobal.follower_toggled
  FollowingPkmn.toggle_off(true) if hasFollower
  $PokemonGlobal.sliding = true
  oldwalkanime = $game_player.walk_anime
  $game_player.straighten
  $game_player.walk_anime = false
  loop do
    player_facing_coords = $MapFactory.getFacingCoords($game_player.x,$game_player.y,$game_player.direction)
    if !$game_player.can_move_in_direction?($game_player.direction) || !$MapFactory.isPassableFromEdge?(player_facing_coords[0], player_facing_coords[1])
      new_player_facing_coords = $MapFactory.getFacingCoords($game_player.x,$game_player.y,pbGetPlayerOppositeDirection)
      if ($game_map.terrain_tag(new_player_facing_coords[0],new_player_facing_coords[1]).can_surf)
        pbJumpToward(-1,true,false)
      else
        x_offset = (pbGetPlayerOppositeDirection == 4) ? -1 : (pbGetPlayerOppositeDirection == 6) ? 1 : 0
        y_offset = (pbGetPlayerOppositeDirection == 8) ? -1 : (pbGetPlayerOppositeDirection == 2) ? 1 : 0
        pbSEPlay("Player jump")
        $game_player.direction = pbGetPlayerOppositeDirection
        pbEndSurf(x_offset, y_offset)
        break
      end
    elsif ($game_map.terrain_tag(player_facing_coords[0],player_facing_coords[1]).id == :Whirlpool)
      pbJumpLeft(1,true,false)
    end
    break if !$PokemonGlobal.surfing
    $game_player.move_forward
    while $game_player.moving?
      pbUpdateSceneMap
      Graphics.update
      Input.update
    end
  end
  $game_player.center($game_player.x, $game_player.y)
  $game_player.straighten
  $game_player.walk_anime = oldwalkanime
  FollowingPkmn.toggle_on(true) if hasFollower
  $PokemonGlobal.sliding = false
end

def pbJumpLeft(dist=1,playSound=false,cancelSurf=false)
  x = $game_player.x
  y = $game_player.y
  case $game_player.direction
  when 2 then $game_player.jump(-dist, 0)    # down
  when 4 then $game_player.jump(0, -dist)   # left
  when 6 then $game_player.jump(0, dist)    # right
  when 8 then $game_player.jump(dist, 0)   # up
  end
  if $game_player.x!=x || $game_player.y!=y
    pbSEPlay("Player jump") if playSound
    $PokemonEncounters.reset_step_count if cancelSurf
    $PokemonTemp.endSurf = true if cancelSurf
    while $game_player.jumping?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    return true
  end
  return false
end
