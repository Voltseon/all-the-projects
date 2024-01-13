class Game_Player < Game_Character
  # Center player on-screen
  def update_screen_position(_last_real_x, _last_real_y)
    return if self.map.scrolling?
    target = [@real_x - SCREEN_CENTER_X,@real_y - SCREEN_CENTER_Y]
    if $game_temp.camera_pos && $game_temp.camera_pos[0] != 0 && $game_temp.camera_pos[1] != 0
      target = $game_temp.camera_pos
    end
    if $game_temp.real_camera_pos && !($game_temp.real_camera_pos[0] == 0 && $game_temp.real_camera_pos[1] == 0)
      target = $game_temp.real_camera_pos
    end
    if $game_temp.spectating && !($Partners.empty? && AI.ais.empty?)
      if $Client_id > 3
        if $Partners[$game_temp.spectating_index] && $game_temp.spectating_index < 4
          target = [$Partners[$game_temp.spectating_index].real_x - SCREEN_CENTER_X, $Partners[$game_temp.spectating_index].real_y - SCREEN_CENTER_Y]
        elsif AI.get(-($game_temp.spectating_index+1)) && $game_temp.spectating_index < 4
          target = [AI.get(-($game_temp.spectating_index+1)).event.real_x - SCREEN_CENTER_X, AI.get(-($game_temp.spectating_index+1)).event.real_y - SCREEN_CENTER_Y]
        end
      else
        if $Partners[$game_temp.spectating_index] && $game_temp.spectating_index < 3
          target = [$Partners[$game_temp.spectating_index].real_x - SCREEN_CENTER_X, $Partners[$game_temp.spectating_index].real_y - SCREEN_CENTER_Y]
        elsif AI.get(-($game_temp.spectating_index+1)) && $game_temp.spectating_index < 3
          target = [AI.get(-($game_temp.spectating_index+1)).event.real_x - SCREEN_CENTER_X, AI.get(-($game_temp.spectating_index+1)).event.real_y - SCREEN_CENTER_Y]
        end
      end
    end
    if $game_temp.camera_shake > 0
      power = $game_temp.camera_shake * 25
      target = [target[0] + rand(-power..power), target[1] + rand(-power..power)]
    end
    if $game_temp.camera_offset && $game_temp.camera_offset != [0, 0]
      target = [target[0] + ($game_temp.camera_offset[0] * Game_Map::REAL_RES_X), target[1] + ($game_temp.camera_offset[1] * Game_Map::REAL_RES_Y)]
    end
    distance = Math.sqrt((target[0] - self.map.display_x)**2 + (target[1] - self.map.display_y)**2) / Game_Map::REAL_RES_X
    if distance < 0.025
      self.map.display_x = target[0]
      self.map.display_y = target[1]
    else
      self.map.display_x = ease_in_out(self.map.display_x, target[0], $game_temp.camera_speed)
      self.map.display_y = ease_in_out(self.map.display_y, target[1], $game_temp.camera_speed)
    end
  end

  def moveto(x, y, center = false)
    super
    center(x, y) if center
    make_encounter_count
  end
end

class Game_Character
  alias fancy_moveto moveto unless self.method_defined?(:fancy_moveto)

  def moveto(x, y, center = true)
    fancy_moveto(x, y)
  end
end

if FancyCamera::OVERRIDE_SCROLL_MAP
  class Interpreter
    #-----------------------------------------------------------------------------
    # * Scroll Map
    #-----------------------------------------------------------------------------
    def command_203
      return true if $game_temp.in_battle
      #$game_map.start_scroll(@parameters[0], @parameters[1], @parameters[2])
      x = ($game_temp.camera_x == 0) ? $game_player.x : $game_temp.camera_x
      y = ($game_temp.camera_y == 0) ? $game_player.y : $game_temp.camera_y
      case @parameters[0]
      when 2  # Down
        y += 1 * @parameters[1]
      when 4  # Left
        x -= 1 * @parameters[1]
      when 6  # Right
        x += 1 * @parameters[1]
      when 8  # Up
        y -= 1 * @parameters[1]
      end
      case @parameters[2]
      when 1  # Slowest
        speed = FancyCamera::DEFAULT_SPEED * 0.5
      when 2  # Slower
        speed = FancyCamera::DEFAULT_SPEED * 0.75
      when 3  # Slow
        speed = FancyCamera::DEFAULT_SPEED * 0.85
      when 4  # Fast
        speed = FancyCamera::DEFAULT_SPEED * 1
      when 5  # Faster
        speed = FancyCamera::DEFAULT_SPEED * 1.5
      when 6  # Fastest
        speed = FancyCamera::DEFAULT_SPEED * 2
      end
      pbCameraScrollTo(x, y, speed)
      return true
    end
  end
end

class Scene_Map
  def transfer_player(cancel_swimming = true)
    $game_temp.player_transferring = false
    pbCancelVehicles($game_temp.player_new_map_id, cancel_swimming)
    autofade($game_temp.player_new_map_id)
    pbBridgeOff
    @spritesetGlobal.playersprite.clearShadows
    if $game_map.map_id != $game_temp.player_new_map_id
      $map_factory.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y, true)
    case $game_temp.player_new_direction
    when 2 then $game_player.turn_down
    when 4 then $game_player.turn_left
    when 6 then $game_player.turn_right
    when 8 then $game_player.turn_up
    end
    $game_player.straighten
    $game_temp.followers.map_transfer_followers
    $game_map.update
    disposeSpritesets
    RPG::Cache.clear
    createSpritesets
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition
    end
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end
end