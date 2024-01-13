class Game_Temp
  attr_accessor :camera_pos, :real_camera_pos, :real_camera_x, :real_camera_y, :camera_x, :camera_y, :camera_shake, :camera_speed, :camera_offset

  # Returns the camera position as an array of x and y coordinates.
  def camera_pos
    @camera_pos = [0, 0] if !@camera_pos
    return @camera_pos || [(self.camera_x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X, (self.camera_y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y] || [0, 0]
  end

  # Sets the camera position to the given value.
  def camera_pos=(value)
    self.camera_x = value[0]
    self.camera_y = value[1]
  end

  # Returns the camera's real position as an array of x and y coordinates.
  def real_camera_pos
    @real_camera_pos = [0, 0] if !@real_camera_pos
    return [self.real_camera_x, self.real_camera_y] || [0, 0]
  end

  # Sets the camera's real position to the given value.
  def real_camera_pos=(value)
    self.real_camera_x = value[0]
    self.real_camera_y = value[1]
  end

  # Returns the camera's real x coordinate.
  def real_camera_x
    return @real_camera_x || 0
  end

  # Returns the camera's real y coordinate.
  def real_camera_y
    return @real_camera_y || 0
  end

  # Sets the camera's real x coordinate to the given value.
  def real_camera_x=(value)
    @real_camera_x = value
  end

  # Sets the camera's real y coordinate to the given value.
  def real_camera_y=(value)
    @real_camera_y = value
  end

  # Sets the camera's x coordinate to the given value.
  def camera_x=(value)
    @camera_x = value
    @camera_pos[0] = ((value == 0) ? 0 : (@camera_x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X)
  end

  # Sets the camera's y coordinate to the given value.
  def camera_y=(value)
    @camera_y = value
    @camera_pos[1] = ((value == 0) ? 0 : (@camera_y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y)
  end

  # Returns the camera's x coordinate.
  def camera_x
    return @camera_x || 0
  end

  # Returns the camera's y coordinate.
  def camera_y
    return @camera_y || 0
  end

  # Returns the camera's shake power.
  def camera_shake
    return @camera_shake || 0
  end

  # Sets the camera's shake power to the given value.
  def camera_shake=(value)
    @camera_shake = value
  end

  # Returns the camera's speed.
  def camera_speed
    return (@camera_speed || FancyCamera::DEFAULT_SPEED || 1) * 0.16
  end

  # Returns the camera's speed without the multiplier.
  def camera_speed_real
    return @camera_speed || FancyCamera::DEFAULT_SPEED || 1
  end

  # Returns the camera's offset as an array of x and y coordinates.
  def camera_offset
    if !@camera_offset
      @camera_offset = [0, 0]
    end
    return @camera_offset
  end

  # Sets the camera's offset to the given value.
  def camera_offset=(value)
    @camera_offset = value
  end
end

# Scrolls the camera to x, y relative the player
def pbCameraScroll(relative_x, relative_y, speed = nil)
  pbCameraSpeed(speed) if speed
  $game_temp.camera_pos = [$game_player.x + relative_x, $game_player.y + relative_y]
end

# Scrolls the camera to x, y on the map
def pbCameraScrollTo(x, y, speed = nil)
  if x == $game_player.x && y == $game_player.y
    pbCameraReset(speed)
  else
    pbCameraSpeed(speed) if speed
  $game_temp.camera_pos = [x, y]
  end
end

# Scrolls the camera to the a real x, y on the map
def pbCameraScrollToReal(x, y, speed = nil)
  pbCameraSpeed(speed) if speed
  $game_temp.real_camera_pos = [x, y]
end

# Sets the camera to the player and resets the speed
def pbCameraReset(speed = nil)
  $game_temp.camera_speed = (speed != nil) ? speed : FancyCamera::DEFAULT_SPEED
  $game_temp.camera_pos = [0, 0]
  $game_temp.real_camera_pos = [0, 0]
end

# Scrolls the camera to an event
def pbCameraToEvent(event_id, speed = nil)
  pbCameraSpeed(speed) if speed
  event = $game_map.events[event_id]
  return if !event
  $game_temp.camera_pos = [event.x, event.y]
end

# Starts a camera shake
def pbCameraShake(power = 2)
  $game_temp.camera_shake = power
end

# Stops the camera shake
def pbCameraShakeOff
  $game_temp.camera_shake = 0
end

# Sets the camera speed
def pbCameraSpeed(speed)
  speed = FancyCamera::DEFAULT_SPEED if !speed || speed == 0
  $game_temp.camera_speed = speed
end

# Sets the camera offset
def pbCameraOffset(x, y)
  $game_temp.camera_offset = [x, y]
end

# This module contains math functions used for camera movement.
module Math
  # Linearly interpolates between two values.
  def self.lerp(a, b, t)
    return (1 - t) * a + t * b
  end
end

# Linearly interpolates between two values.
def lerp(a,b,t); Math.lerp(a,b,t); end

# Eases in and out between two values.
def ease_in_out(a, b, t)
  return lerp(a, b, t * t * (3.0 - 2.0 * t))
end