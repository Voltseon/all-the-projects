def pbPostCredit(amt)
  pbFadeOutIn(99999) {
    scene = PostCredit_Scene.new
    screen = PostCredit_Screen.new(scene)
    screen.pbStartScreen(amt)
  }
end


class PostCredit_Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
  end

  def pbShowPostCredit(amt)
    @sprites["device"].start
    pbBGMPlay(VoltseonsMarketPlace::PostCreditBGM)
    until @sprites["device"].opacity == 255
      Graphics.update
      pbUpdate
      @sprites["device"].opacity += 1
      pbWaitWithUpdate(1)
    end
    pbWaitWithUpdate(120)
    f = 0
    yt = 25.5
    vol = 80
    until f == 10
      Graphics.update
      pbUpdate
      playedse = false
      until @sprites["blink"].opacity > 240
        if @sprites["blink"].opacity > 150 && !playedse
          pbSEPlay(VoltseonsMarketPlace::PostCreditPingSound,vol)
          playedse = true
        end
        @sprites["blink"].opacity += yt
        Graphics.update
        pbUpdate
      end
      until @sprites["blink"].opacity < 10
        @sprites["blink"].opacity -= yt
        Graphics.update
        pbUpdate
      end
      pbWaitWithUpdate(50-f)
      f += 1
    end
    i = 0
    until i == amt*10
      yt = 52 if i == amt*5
      if i == amt*8
        yt = 77.5
        @sprites["blink"].setBitmap(sprintf("Graphics/Pictures/Post Credit/blinkeffectred"))
        vol = 150
      end
      Graphics.update
      pbUpdate
      playedse = false
      until @sprites["blink"].opacity > 240
        if @sprites["blink"].opacity > 150 && !playedse
          pbSEPlay(VoltseonsMarketPlace::PostCreditPingSound,vol)
          playedse = true
        end
        @sprites["blink"].opacity += yt
        Graphics.update
        pbUpdate
      end
      until @sprites["blink"].opacity < 10
        @sprites["blink"].opacity -= yt
        Graphics.update
        pbUpdate
      end
      pbWaitWithUpdate(amt*5-i*4)
      i += 1
    end
  end

  def pbStartScene
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Post Credit/bg"))
    @sprites["device"] = AnimatedSprite.new(sprintf("Graphics/Pictures/Post Credit/timedevice"),3,74,70,2,@viewport)
    @sprites["device"].x = 224
    @sprites["device"].y = 256
    @sprites["device"].opacity = 0
    @sprites["device"].visible = true
    @sprites["blink"] = IconSprite.new(0,0,@viewport)
    @sprites["blink"].setBitmap(sprintf("Graphics/Pictures/Post Credit/blinkeffect"))
    @sprites["blink"].x = 272
    @sprites["blink"].y = 258
    @sprites["blink"].opacity = 0
    @sprites["blink"].visible = true
    @sprites["blink"].z = @sprites["device"].z+1
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbWaitWithUpdate(50)
    pbMessage("\\xn[???]\\bDid it work? \\.Did I die?")
    pbDisposeSpriteHash(@sprites)
    $game_map.autoplay
    @viewport.dispose
  end

  def pbWaitWithUpdate(amt)
    i = 0
    until i >= amt
      Graphics.update
      pbUpdate
      i+=1
    end
  end 
end

class PostCredit_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(amt)
    @scene.pbStartScene
    @scene.pbShowPostCredit(amt)
    @scene.pbEndScene
  end
end