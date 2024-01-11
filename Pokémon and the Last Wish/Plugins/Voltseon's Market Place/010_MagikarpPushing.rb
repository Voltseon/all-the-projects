class Interpreter
  def pbPushWithWater
    event = get_self
    old_x  = event.x
    old_y  = event.y
    old_through = event.through
    # Checking for water tiles
    newX = event.x
    newY = event.y
    ($game_player.direction == 4 || $game_player.direction == 8) ? modif = -1 : modif = 1
    ($game_player.direction == 2 || $game_player.direction == 8) ? isHorizontal = false : isHorizontal = true
    if isHorizontal
      newX += modif
    else
      newY += modif
    end
    cansurf = $game_map.terrain_tag(newX,newY).can_surf
    # Apply strict version of passable, which treats tiles that are passable
    # only from certain directions as fully impassible
    return if !event.can_move_in_direction?($game_player.direction, true) && !cansurf
    event.through = true if cansurf
    case $game_player.direction
    when 2 then event.move_down
    when 4 then event.move_left
    when 6 then event.move_right
    when 8 then event.move_up
    end
    $PokemonMap.addMovedEvent(@event_id) if $PokemonMap
    if old_x != event.x || old_y != event.y
      $game_player.lock
      loop do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        break if !event.moving?
      end
      if cansurf
        event.through = old_through
        vSST(@event_id)
        sprite = $scene.spriteset.addUserAnimation(19,event.x,event.y,0,2)
        while !sprite.disposed?
          Graphics.update
          Input.update
          pbUpdateSceneMap
        end
      end
      $game_player.unlock
    end
  end
end