class Vector3
  attr_accessor :x
  attr_accessor :y
  attr_accessor :z

  def initialize(x=0, y=0, z=0)
    @x = x
    @y = y
    @z = z
  end

  def x; return @x; end
  def y; return @y; end
  def z; return @z; end

  def x=(newX)
    @x = newX
  end

  def y=(newY)
    @y = newY
  end

  def z=(newZ)
    @z = newZ
  end

  def self.zero
    return self.new(0, 0, 0)
  end

  def self.one
    return self.new(1, 1, 1)
  end
end

class Vector4 < Vector3
  attr_accessor :w

  def initialize(x=0, y=0, z=0, w=0)
    @x = x
    @y = y
    @z = z
  end

  def w; return @w; end

  def w=(newW)
    @w = newW
  end

  def self.identity
    return self.new(0, 0, 0, 0)
  end
end

class GameObject
  attr_accessor :position
  attr_accessor :rotation
  attr_accessor :scale

  def initialize(position, rotation, scale)
    @position = position
    @rotation = rotation
    @scale = scale
  end

  def position;     return @position;     end
  def rotation;     return @rotation;     end
  def scale;        return @scale;        end
end

class GameCamera < GameObject
  attr_accessor :fov

  def fov; return @fov; end

  def fov=(newFov)
    @fov = newFov
  end
end

def ttttt
  viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
  overlay = Sprite.new(viewport)
  camera = GameCamera.new(Vector3.zero,Vector4.identity,Vector3.one)
  camera.fov = 90
  loop do
    Graphics.update
    overlay.update
    Graphics.width.times do |x|
      Graphics.height.times do |y|
        
      end
    end
  end
end