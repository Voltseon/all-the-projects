#-------------------------------------------------------------------------------
# Hit Diglett Hit
#-------------------------------------------------------------------------------
# Voltseon's Minigame Pack
# A collection of cool custom minigames
#-------------------------------------------------------------------------------

SUBDIR = "/Hit Diglett Hit" # Subdirectory for Hit Diglett Hit

class HitDiglettHit_Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @index = 0
    @diglett_location = 0
    @hits = 0
    @diglett_state = 0
    @disposed = false
    resetting = false
  end

  def pbStartScene
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["background"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/bg.png"))
    @sprites["hammer"] = IconSprite.new(0,0,@viewport)
    @sprites["hammer"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/hammer_0.png"))
    @sprites["diglett"] = IconSprite.new(0,0,@viewport)
    @sprites["diglett"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/diglett_0.png"))
    @sprites["diglett"].visible = false
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbDiglettHit
    drawPresent
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @disposed
        break
      else
        diglettCheck
        if Input.trigger?(Input::RIGHT) && @index == 0
          pbPlayCursorSE
          @index = 4
          drawPresent
        elsif Input.trigger?(Input::LEFT) && @index == 0
          pbPlayCursorSE
          @index = 2
          drawPresent
        elsif Input.trigger?(Input::DOWN) && @index == 0
          pbPlayCursorSE
          @index = 3
          drawPresent
        elsif Input.trigger?(Input::UP) && @index == 0
          pbPlayCursorSE
          @index = 1
          drawPresent
        elsif Input.trigger?(Input::USE)
          pbPlayCursorSE
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    end
  end

  def placeDiglett
    @diglett_location = rand(1..4)
    @diglett_state = 1
    #pbWait(10)
    @sprites["diglett"].visible = true
    @sprites["diglett"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/diglett_0.png"))
    case @diglett_location
    when 1
      @sprites["diglett"].x = 233
      @sprites["diglett"].y = 73
    when 2
      @sprites["diglett"].x = 133
      @sprites["diglett"].y = 143
    when 3
      @sprites["diglett"].x = 233
      @sprites["diglett"].y = 223
    when 4
      @sprites["diglett"].x = 333
      @sprites["diglett"].y = 143
    end
    #pbWait(10)
    @diglett_state = 2 if @diglett_state != 3
    @sprites["diglett"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/diglett_1.png"))
    #pbWait(60)
    @diglett_state = 1 if @diglett_state != 3
    @sprites["diglett"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/diglett_0.png"))
    #pbWait(20)
    @diglett_state = 0 if @diglett_state != 3
    @sprites["diglett"].visible = false
  end

  def drawPresent
    @sprites["overlay"].bitmap.clear
    case @index
    when 0
      @sprites["hammer"].x = 243
      @sprites["hammer"].y = 143
    when 1
      @sprites["hammer"].x = 243
      @sprites["hammer"].y = 73
    when 2
      @sprites["hammer"].x = 143
      @sprites["hammer"].y = 143
    when 3
      @sprites["hammer"].x = 243
      @sprites["hammer"].y = 223
    when 4
      @sprites["hammer"].x = 343
      @sprites["hammer"].y = 143
    end
    if @index != 0
      hammerHit
    end
  end

  def diglettCheck
    if @diglett_state == 0
      placeDiglett
    end
    if @diglett_state == 3 && !resetting
      @sprites["diglett"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/diglett_2.png"))
      resetting = true
      #pbWait(10)
      @diglett_state = 0
      @sprites["diglett"].visible = false
      resetting = false
    end
  end

  def hammerHit
    i = 0
    while i < 10
      i+=1
    end
    @sprites["hammer"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/hammer_1.png"))
    if @diglett_state != 0 && @diglett_state != 3 && diglett_location == @index
      @hits += 1
      @diglett_state = 3
    end
    i = 0
    while i < 10
      i+=1
    end
    if @diglett_state != 0 && @diglett_state != 3 && diglett_location == @index
      @hits += 1
      @diglett_state = 3
    end
    @sprites["hammer"].setBitmap(sprintf(DIRECTORY+SUBDIR+"/hammer_0.png"))
    @index = 0
    drawPresent
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @viewport.dispose
  end

end

class HitDiglettHit_Screen
    def initialize(scene)
      @scene = scene
    end
  
    def pbStartScreen
      @scene.pbStartScene
      @scene.pbDiglettHit
      @scene.pbEndScene
    end
  end