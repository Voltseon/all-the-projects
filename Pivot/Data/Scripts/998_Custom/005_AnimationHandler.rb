EventHandlers.add(:on_frame_update, :animation_handler,
  proc {
    next if !$player
    next if $game_map.map_id == 1
    $game_temp.guard_timer -= Graphics.delta_s
    if $player.current_hp < 1
      $game_player.set_movement_type(:hurt)
    elsif $player.guarding
      $game_player.set_movement_type(:guard)
    elsif $scene.active_hud.aiming
      $game_player.set_movement_type(:idle)
      $game_player.move_speed = $player.speed
    elsif $player.using_melee
      $game_player.set_movement_type(:melee)
    elsif $player.using_ranged
      $game_player.set_movement_type(:ranged)
    elsif $player.character.movement_type == :PHASE && $game_player.pbTerrainTag.can_phase
      $game_player.set_movement_type(:ability)
    elsif $game_player.moving? || $game_player.moved_this_frame
      $game_player.set_movement_type(:walking)
      $game_player.move_speed = $player.speed
    else
      $game_player.set_movement_type(:idle)
      $game_player.move_speed = $player.speed
    end
  }
)
EventHandlers.add(:on_player_step_taken, :ability_priority,
  proc {
    if ($game_player.pbTerrainTag.can_phase && $player.character.movement_type != :NONE) || ($game_player.pbTerrainTag.can_surf_freely && $player.character.movement_type == :FLYING) && !$game_player.always_on_top
      pbMoveRoute($game_player, [PBMoveRoute::AlwaysOnTopOn])
    elsif !($game_player.pbTerrainTag.can_phase && $player.character.movement_type != :NONE) || ($game_player.pbTerrainTag.can_surf_freely && $player.character.movement_type == :FLYING) && $game_player.always_on_top
      pbMoveRoute($game_player, [PBMoveRoute::AlwaysOnTopOff])
    end
  }
)


class Game_Temp
  attr_accessor :guard_timer
  attr_accessor :dash_location
  attr_accessor :dash_distance
  def guard_timer; @guard_timer = 0 if !@guard_timer; return @guard_timer; end
  def guard_timer=(val); @guard_timer = val; end
  def dash_location; @dash_location = [0,0] if !@dash_location; return @dash_location; end
  def dash_location=(val); @dash_location = val; end
  def dash_distance; @dash_distance = 0 if !@dash_distance; return @dash_distance; end
  def dash_distance=(val); @dash_distance = val; end
end