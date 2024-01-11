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
ITEMGETSE = "PLA Item Get" # ME that will play after obtaining an item.
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


def itemAnim(item,qty,ispkmn=false)
  bitmap = Bitmap.new("Graphics/Pictures/Object")
  pbSetSystemFont(bitmap)
  base = MessageConfig::DARK_TEXT_MAIN_COLOR
  shadow = MessageConfig::DARK_TEXT_SHADOW_COLOR
  if qty > 1
    textpos = [[_INTL("{1} x{2}",item.name_plural,qty),12,16,false,base,shadow]]
  else
    textpos = [[_INTL("{1}",item.name),12,16,false,base,shadow]]
  end
  pbDrawTextPositions(bitmap,textpos)

  if ispkmn
    bitmap.blt(204,-8,Bitmap.new(GameData::Species.icon_filename_from_pokemon(item)),Rect.new(0,0,64,64))
  else
    if pbResolveBitmap("Graphics/Items/#{item.id.to_s}")
      bitmap.blt(217,7,Bitmap.new("Graphics/Items/#{item.id.to_s}"),Rect.new(0,0,48,48))
    end
  end
  pbSEPlay(ITEMGETSE) unless ispkmn
  $scene.addSprite(-bitmap.width,128,bitmap)
end

def questAnim(questname)
  bitmap = Bitmap.new("Graphics/Pictures/NewQuest")
  pbSetSystemFont(bitmap)
  textpos = [["New Quest",12,10,false,Color.new(248,248,248),Color.new(138,198,242)],[questname,12,42,false,Color.new(232,232,232),Color.new(138,198,242)]]
  pbDrawTextPositions(bitmap,textpos)
  pbSEPlay("BW 999 Del Power")
  $scene.addSprite(-bitmap.width,128,bitmap)
end

def questCompleteAnim(questname)
  bitmap = Bitmap.new("Graphics/Pictures/NewQuest")
  pbSetSystemFont(bitmap)
  textpos = [["Quest Complete!",12,10,false,Color.new(248,248,248),Color.new(138,198,242)],[questname,12,42,false,Color.new(232,232,232),Color.new(138,198,242)]]
  pbDrawTextPositions(bitmap,textpos)
  pbMEPlay("BW 344 Mission Accomplished!")
  $scene.addSprite(-bitmap.width,128,bitmap)
end