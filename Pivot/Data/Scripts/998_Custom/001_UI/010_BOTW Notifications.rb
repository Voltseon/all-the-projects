# BOTW-Like Item Gathering by: Kyu
################################################################################
# How to install:
#   Add Object.png to the Graphics/Pictures folder.
#   Add this script over main.
#
# CREDITS MUST BE GIVEN TO EVERYONE LISTED ON THE POST
################################################################################
# CONSTANTS
################################################################################
NEWPICKBERRY = true # if true, berries will be picked directly with the new anim. 
ITEMGETSE = "Pivot/GUI notification" # ME that will play after obtaining an item.
################################################################################

if defined?(PluginManager)
  PluginManager.register({
    :name => "BOTW-Like Item Gathering",
    :version => "1.0",
    :credits => "Kyu"
  })
end
  
#UI Object with timer, animation and other relevant data
class UISprite < SpriteWrapper
  attr_accessor :scroll
  attr_accessor :timer
  attr_accessor :textpos

  def initialize(x, y, bitmap, viewport, textpos)
    super(viewport)
    self.bitmap = bitmap
    self.x = x
    self.y = y
    @textpos = textpos
    @scroll = false
    @timer = 0
  end

  def update
    return if self.disposed?
    @timer += 1
    case @timer
    when (0..125)
      self.x += self.bitmap.width/100
    when (2500..2600)
      self.x -= self.bitmap.width/100
    when 2601
      self.dispose
    else
      self.x = 0
    end
  end
end

module Mouse
  class << self
    # Handles all UI objects in order to control their positions on screen, timing 
    # and disposal. Acts like a Queue.
    class UIHandler
      def initialize(viewport)
        @viewport = viewport
        @sprites = []
      end

      def addSprite(x, y, bitmap, textpos)
        @sprites.each{|sprite|
          sprite.scroll = true
        }
        index = @sprites.length
        @sprites[index] = UISprite.new(x, y, bitmap, @viewport, textpos)
      end

      def update
        removed = []
        @sprites.each_index{|key|
          sprite = @sprites[key]
          if sprite.scroll
            sprite2 = @sprites[key + 1]
            if sprite.x >= sprite2.x && sprite.x <= sprite2.bitmap.width + sprite2.x
              if sprite.y >= sprite2.y && sprite.y <= sprite2.bitmap.height + sprite2.y + 5
                sprite.y += 5
              end
            else
              sprite.scroll = false
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

      def visible=(value)
        @sprites.each do |sprite|
          (value ? pbDrawTextPositions(sprite.bitmap,sprite.textpos) : sprite.bitmap.clear)
          sprite.visible = value
        end
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

    def ui
      return @ui
    end
  end
end

def notification(top_text="test",bottom_text="test",icon_bitmap=nil)
  bitmap = Bitmap.new("Graphics/Pictures/Object")
  pbSetSystemFont(bitmap)
  base = Color.new(248,248,248)
  shadow = Color.new(72,80,88)
  textpos = [[_INTL("{1}",top_text),12,12,false,base,shadow],[_INTL("{1}",bottom_text),12,42,false,base,shadow]]
  pbSEPlay(ITEMGETSE)
  Mouse.ui.addSprite(-bitmap.width,128,bitmap,textpos)
  bitmap.blt(210, 0, Bitmap.new(icon_bitmap), Rect.new(0,0,64,64)) if icon_bitmap
  pbDrawTextPositions(bitmap,textpos)
end