# BOTW-Like Item Gathering by: Kyu
################################################################################
# How to install:
#   Add Object.png to the Graphics/Pictures folder.
#   Add this script over main.
#
# CREDITS MUST BE GIVEN TO EVERYONE LISTED ON THE POST
################################################################################

if defined?(PluginManager)
  PluginManager.register({
    :name => "BOTW-Like Item Gathering",
    :version => "1.0",
    :credits => "Kyu"
  })
end

DARK_OPACITY = 160
  
#UI Object with timer, animation and other relevant data
class UISprite < SpriteWrapper
  attr_accessor :scroll
  attr_accessor :timer

  def initialize(x, y, bitmap, viewport)
    super(viewport)
    self.bitmap = bitmap
    self.x = x
    self.y = y
    @scroll = false
    @timer = 0
  end

  def update
    return if self.disposed?
    @timer += 1
    case @timer
    when (0..10)
      self.x += self.bitmap.width/10
    when 11
      self.x = 4
    when (100..110)
      self.x -= self.bitmap.width/10
    when 111
      self.dispose
    end
  end
end


class Spriteset_Map
  # Handles all UI objects in order to control their positions on screen, timing 
  # and disposal. Acts like a Queue.
  class UIHandler
    def initialize
      @viewport = Viewport.new(0,0,Graphics.width,Graphics.height) # Uses its own viewport to make it compatible with both v16 and v17.
      @viewport.z = 9999
      @sprites = []
    end

    def addSprite(x, y, bitmap)
      @sprites.each{|sprite|
        sprite.scroll = true
      }
      index = @sprites.length
      @sprites[index] = UISprite.new(x, y, bitmap, @viewport)
    end

    def update
      removed = []
      @sprites.each_index{|key|
        sprite = @sprites[key]
        if sprite.scroll
          sprite2 = @sprites[key + 1]
          if sprite.y >= sprite2.y && sprite.y <= sprite2.bitmap.height + sprite2.y + 5
            sprite.y += 5
          end
        end
        sprite.update
        if sprite.disposed?
          removed.push(sprite)
        end
      }
      
      removed.each{|sprite|
        @sprites.delete(sprite)
      }
    end
        
    def dispose
      @sprites.each{|sprite|
        if !sprite.disposed?
          sprite.dispose
        end
      }
      @viewport.dispose
    end
  end
  
  alias :disposeOld :dispose
  alias :updateOld :update

  def dispose
    @ui.dispose if @ui
    disposeOld
  end

  def update
    @ui = UIHandler.new if !@ui
    @ui.update
    updateOld
  end

  def ui
    return @ui
  end
end


class Scene_Map
  def addSprite(x, y, bitmap)
    self.spriteset.ui.addSprite(x, y, bitmap)
  end
end

# darker means what text should be darker, 0 for neither, 1 for top, 2 for bottom and 3 for both, image data is path,x,y
def pbNotify(top_text, bottom_text = "", darker = 0, image_data = [])
  bitmap = Bitmap.new("Graphics/Pictures/notification")
  pbSetSystemFont(bitmap)
  top_base = Color.new(248, 248, 248) if darker == 0 || darker == 2
  top_shadow = Color.new(57, 198, 249) if darker == 0 || darker == 2
  bottom_base = Color.new(248, 248, 248) if darker == 0 || darker == 1
  bottom_shadow = Color.new(57, 198, 249) if darker == 0 || darker == 1
  top_base = Color.new(248, 248, 248, DARK_OPACITY) if darker == 1 || darker == 3
  top_shadow = Color.new(57, 198, 249, DARK_OPACITY) if darker == 1 || darker == 3
  bottom_base = Color.new(248, 248, 248, DARK_OPACITY) if darker == 2 || darker == 3
  bottom_shadow = Color.new(57, 198, 249, DARK_OPACITY) if darker == 2 || darker == 3
  if bottom_text == ""
    textpos = [[top_text, 32, 34, 0, top_base, top_shadow]]
  else
    textpos = [[top_text, 32, 20, 0, top_base, top_shadow], [bottom_text, 32, 52, 0, bottom_base, bottom_shadow]]
  end
  if !image_data.empty?
    image = Bitmap.new(image_data[0])
    bitmap.blt(image_data[1], image_data[2], image, Rect.new(0, 0, image.width, image.height))
  end
  pbDrawTextPositions(bitmap,textpos)
  $scene.addSprite(-bitmap.width,128,bitmap)
end