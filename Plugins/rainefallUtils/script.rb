# Graphics functions
class Bitmap
  # INEFFICIENT, NOT RECOMMENDED FOR REALTIME USE
  def blur(power, opacity = 128)
    power.times do |i|
      blt(1 + i * 2, 0, self, self.rect, opacity / (i+1))
      blt(-1 - i * 2, 0, self, self.rect, opacity / (i+1))
      blt(0, 1 + i * 2, self, self.rect, opacity / (i+1))
      blt(0, -1 - i * 2, self, self.rect, opacity / (i+1))
    end
  end
  
  # SLIGHTLY LESS INEFICCIENT
  def blur_fast(power, opacity = 128)
    blt(power * 2, 0, self, self.rect, opacity )
    blt(-power * 2, 0, self, self.rect, opacity)
    blt(0, power * 2, self, self.rect, opacity)
    blt(0, -power * 2, self, self.rect, opacity)
  end
end

class Sprite
  def create_outline_sprite(width = 2)
    return if !self.bitmap
    s = Sprite.new(self.viewport)
    s.x = self.x - width
    s.y = self.y - width
    s.z = self.z
    self.z += 1
    s.ox = self.ox
    s.oy = self.oy
    s.tone.set(255,255,255)
    s.bitmap = Bitmap.new(self.bitmap.width + width * 2, self.bitmap.height + width * 2)
    3.times do |y|
      3.times do |x|
        next if y == 1 && y == x
        s.bitmap.blt(x * width, y * width, self.bitmap, self.bitmap.rect)
      end
    end
    return s
  end
end

# Maths functions

def lerp(a, b, t)
  return (1 - t) * a + t * b
end

# Map scroll locking

if RfSettings::ENABLE_MAP_LOCKING
  class Game_Temp
    attr_accessor :map_locked
  end

  class Game_Player
    # Center player on-screen
    def update_screen_position(last_real_x, last_real_y)
      return if self.map.scrolling? || !(@moved_last_frame || @moved_this_frame) || $game_temp.map_locked
      self.map.display_x = @real_x - SCREEN_CENTER_X
      self.map.display_y = @real_y - SCREEN_CENTER_Y
    end
  end
end