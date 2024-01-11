def vPointingClefairy
  scene = VMPPointingClefairy_Scene.new
  screen = VMPPointingClefairy_Screen.new(scene)
  screen.pbStartScreen
end

class VMPPointingClefairy_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbInputs
    @scene.pbEndScene
  end
end

class VMPPointingClefairy_Scene
  TEXTBASECOLOR    = Color.new(248,248,248)
  TEXTSHADOWCOLOR  = Color.new(72,72,72)

  PATH = "Graphics/Pictures/Voltseon's Minigame Pack/Pointing Clefairy/"

  # Initializes Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @score = 0
    @timer = 300
    @dir = 0
    @time_at_correct = 300
    @sprite_versions = ["base", "left", "right", "up", "down"]
    @disposed = false
  end

  # draw scene elements
  def pbStartScene
    pbBGMPlay("HGSS 150 You're a Winner!")
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("%sbg",PATH))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["clefairy"] = ChangelingSprite.new(192,96,@viewport)
    @sprites["clefairy"].addBitmap("base",_INTL("{1}/clefairy_base",PATH))
    @sprites["clefairy"].addBitmap("left",_INTL("{1}/clefairy_left",PATH))
    @sprites["clefairy"].addBitmap("right",_INTL("{1}/clefairy_right",PATH))
    @sprites["clefairy"].addBitmap("up",_INTL("{1}/clefairy_up",PATH))
    @sprites["clefairy"].addBitmap("down",_INTL("{1}/clefairy_down",PATH))
    @sprites["timer"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["timer"].bitmap)
    @sprites["timer"].visible     = true
    @sprites["score"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["score"].bitmap)
    @sprites["score"].visible     = true
    pbFadeInAndShow(@sprites) { pbUpdate }
    @dir = rand(3)+1
    pbDrawShadowText(@sprites["score"].bitmap,0,256,512,32,
      "Score: #{@score}",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
  end

  # input controls
  def pbInputs
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @disposed
        break
      else
        if Input.trigger?(Input::LEFT) && @timer > 0
          (@dir == 1) ? correct : incorrect
        elsif Input.trigger?(Input::RIGHT) && @timer > 0
          (@dir == 2) ? correct : incorrect
        elsif Input.trigger?(Input::UP) && @timer > 0
          (@dir == 3) ? correct : incorrect
        elsif Input.trigger?(Input::DOWN) && @timer > 0
          (@dir == 4) ? correct : incorrect
        end
      end
      @timer -= 1 if @dir != 0 && @timer > 0
      break if checkTimer
    end
  end

  def checkTimer
    @sprites["timer"].bitmap.clear
    pbDrawShadowText(@sprites["timer"].bitmap,0,288,512,32,
      "Time: #{@timer}",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    return false if @timer > 0
    @dir = 0
    pbBGMFade(0.2)
    pbWait(10)
    return true
  end

  def correct
    pbSEPlay("GUI naming confirm")
    scr = 1
    if (@timer-@time_at_correct).abs > 50
      scr = 1
    elsif (@timer-@time_at_correct).abs > 40
      scr = 2
    elsif (@timer-@time_at_correct).abs > 30
      scr = 5
    elsif (@timer-@time_at_correct).abs > 25
      scr = 10
    elsif (@timer-@time_at_correct).abs > 10
      scr = 15
    else
      scr = 30
    end
    @score += scr
    @sprites["score"].bitmap.clear
    pbDrawShadowText(@sprites["score"].bitmap,0,256,512,32,
      "Score: #{@score}",TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    @timer = [@timer+50,300].min
    @time_at_correct = @timer
    last_dir = @dir
    @dir = 0
    pbWait(10)
    until @dir != last_dir && @dir != 0 do @dir = rand(4)+1; end
  end

  def incorrect
    pbPlayBuzzerSE()
    @timer = [@timer-100,0].max
    old_dir = @dir
    @dir = 0
    pbWait(10)
    @dir = old_dir
  end

  def pbUpdate
    @sprites["clefairy"].changeBitmap(@sprite_versions[@dir])
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @viewport.dispose
    $game_map.autoplay
  end
end
