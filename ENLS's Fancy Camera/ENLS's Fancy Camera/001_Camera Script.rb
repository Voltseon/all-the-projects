class Game_Temp
  attr_accessor :camera_pos, :camera_x, :camera_y, :camera_shake,
                :camera_speed, :camera_offset, :camera_target_event

  def camera_pos
    @camera_pos = [0, 0] if !@camera_pos
    return @camera_pos || [(self.camera_x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X, (self.camera_y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y] || [0, 0]
  end

  def camera_pos=(value)
    $game_temp.camera_target_event = nil
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
    return (@camera_speed || FancyCamera::DEFAULT_SPEED || 1) * 0.16
  end

  def camera_offset
    if !@camera_offset
      @camera_offset = [0, 0]
    end
    return @camera_offset
  end

  def camera_offset=(value)
    @camera_offset = value
  end

  def camera_target_event
    return @camera_target_event || 0
  end

  def camera_target_event=(value)
    @camera_target_event = value
  end
end

# Scrolls the camera to x, y relative the player
def pbCameraScroll(relative_x, relative_y, speed = nil)
  pbCameraSpeed(speed) if speed
  $game_temp.camera_pos = [$game_player.x + relative_x, $game_player.y + relative_y]
end

def pbCameraScrollDirection(direction, distance, speed = nil)
  speed = FancyCamera::DEFAULT_SPEED if !speed || speed == 0
  x = ($game_temp.camera_x == 0) ? $game_player.x : $game_temp.camera_x
  y = ($game_temp.camera_y == 0) ? $game_player.y : $game_temp.camera_y
  case direction
  when 1 # Down Left
    x -= 1 * distance
    y += 1 * distance
  when 2 # Down
    y += 1 * distance
  when 3 # Down Right
    x += 1 * distance
    y += 1 * distance
  when 4 # Left
    x -= 1 * distance
  when 6 # Right
    x += 1 * distance
  when 7 # Up Left
    x -= 1 * distance
    y -= 1 * distance
  when 8 # Up
    y -= 1 * distance
  when 9 # Up Right
    x += 1 * distance
    y -= 1 * distance
  end
  case speed
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

# Sets the camera to the player and resets the speed
def pbCameraReset(speed = nil)
  $game_temp.camera_speed = (speed != nil) ? speed : FancyCamera::DEFAULT_SPEED
  $game_temp.camera_target_event = nil
  $game_temp.camera_pos = [0, 0]
end

# Scrolls the camera to an event
def pbCameraToEvent(event_id = nil, speed = nil)
  pbCameraSpeed(speed) if speed
  event_id = get_self.id if !event_id
  event = $game_map.events[event_id]
  return if !event
  $game_temp.camera_target_event = event_id
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



def old_lerp(a, b, t)
  t = t / (Graphics.average_frame_rate / 60.0)
  return (1 - t) * a + t * b
end

def ease_in_out(a, b, t)
  return old_lerp(a, b, t * (3.0 - t))
end