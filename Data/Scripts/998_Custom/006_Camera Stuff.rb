class Game_Temp
  attr_accessor :camera_pos
  attr_accessor :camera_x
  attr_accessor :camera_y
  attr_accessor :camera_shake
  attr_accessor :camera_speed

  def camera_pos
    @camera_pos = [0, 0] if !@camera_pos
    return @camera_pos || [(self.camera_x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X, (self.camera_y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y] || [0, 0]
  end

  def camera_pos=(value)
    self.camera_x = value[0]
    self.camera_y = value[1]
  end

  def camera_x=(value)
    @camera_x = value
    @camera_pos[0] = ((value == 0) ? 0 : (@camera_x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X)
  end

  def camera_y=(value)
    @camera_y = value
    @camera_pos[1] = ((value == 0) ? 0 : (@camera_y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y)
  end

  def camera_x
    return @camera_x || 0
  end

  def camera_y
    return @camera_y || 0
  end

  def camera_shake
    return @camera_shake || 0
  end

  def camera_shake=(value)
    @camera_shake = value
  end

  def camera_speed
    return (@camera_speed || 1) * 0.16
  end
end

def pbCameraScroll(relative_x, relative_y)
  $game_temp.camera_pos = [$game_player.x + relative_x, $game_player.y + relative_y]
end

def pbCameraScrollTo(x, y)
  $game_temp.camera_pos = [x, y]
end

def pbCameraReset
  $game_temp.camera_pos = [0, 0]
end

def pbCameraToEvent(event_id)
  event = $game_map.events[event_id]
  return if !event
  $game_temp.camera_pos = [event.x, event.y]
end

def pbCameraShake(power = 2)
  $game_temp.camera_shake = power
end

def pbCameraShakeOff
  $game_temp.camera_shake = 0
end

def pbCameraSpeed(speed=1)
  $game_temp.camera_speed = speed
end