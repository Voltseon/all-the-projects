class NetworkingTrading_Scene
  TEXTBASECOLOR    = Color.new(248,248,248)
  TEXTSHADOWCOLOR  = Color.new(72,72,72)
  def initialize(roomcode,is_host)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @index_hor = 1
    @index_ver = 0
    @is_host = is_host
    @roomcode = roomcode

    if @is_host
      @trainer_host         = $Profile
      @trainer_connected    = nil
    else
      @trainer_host         = nil
      @trainer_connected    = $Profile
    end
    @pokemon_host         = nil
    @pokemon_connected    = nil
    @ready_host           = false
    @ready_connected      = false
    sync_data
  end

  def pbStartScene
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/Networking/Trading/bg"))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @sprites["text"]=BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["text"].bitmap)
    @sprites["text"].bitmap.font.size=26
    pbDrawShadowText(@sprites["text"].bitmap,8,16,118,26,_INTL("Code: {1}",@roomcode),TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbInputs
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @disposed
        break
      else
        if Input.trigger?(Input::RIGHT) && @index_hor < 2
          pbPlayCursorSE
          @index_hor += 1
          drawPresent
        elsif Input.trigger?(Input::LEFT) && @index_hor !=0
          pbPlayCursorSE
          @index_hor -= 1
          drawPresent
        elsif Input.trigger?(Input::DOWN) && @index_ver < 1
          pbPlayCursorSE
          @index_ver += 1
          drawPresent
        elsif Input.trigger?(Input::UP) && @index_ver !=0
          pbPlayCursorSE
          @index_ver -= 1
          drawPresent
        elsif Input.trigger?(Input::USE)
          pbPlayCursorSE
          case @index_ver # please ignore this awful code
          when 0
          end
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    end
  end

  def sync_data
    send = {
      :Trainer => $Profile,
      :Pokemon => (@is_host) ? @pokemon_host : @pokemon_connected,
      :Ready => (@is_host) ? @ready_host : @ready_connected
    }
    vnPost(@roomcode,send,@is_host)
    get_data = vnGet(@roomcode,!@is_host).split('&')
    if @is_host
      @trainer_connected = get_data[0].slice(0..get_data[0].index("="))
      @pokemon_connected = get_data[1].slice(0..get_data[1].index("="))
      @ready_connected = get_data[2].slice(0..get_data[2].index("="))
    else
      @trainer_host = get_data[0].slice(0..get_data[0].index("="))
      @pokemon_host = get_data[1].slice(0..get_data[1].index("="))
      @ready_host = get_data[2].slice(0..get_data[2].index("="))
    end
  end

  def drawPresent
    overlay = @sprites["overlay"].bitmap
    overlay.clear
  end

  def pbUpdate
    drawPresent if !@disposed
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @viewport.dispose
  end
end

class NetworkingTrading_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbInputs
    @scene.pbEndScene
  end
end