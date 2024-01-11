def pbEngine
  pbFadeOutIn {
    scene = Engine.new
    scene.pbStartScreen
    scene.pbUpdate
    scene.pbEndScreen
  }
end

class Engine
  PATH = "Graphics/Pictures/Engine/"

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @switch_count = 8 - rand(4)
    @states = [false] * @switch_count
    @index = 0
    rand((@switch_count/2).floor).times { |i| @states[rand(@switch_count)] = true }
  end

  def pbStartScreen
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = Bitmap.new(PATH + "background")
    distance_between_switches = 700 / @switch_count
    @switch_count.times do |i|
      @sprites["switch#{i}"] = ChangelingSprite.new(distance_between_switches*(i+1)-44, 200, @viewport)
      @sprites["switch#{i}"].addBitmap(1, PATH + "switch_on")
      @sprites["switch#{i}"].addBitmap(0, PATH + "switch_off")
      @sprites["switch#{i}"].changeBitmap((@states[i] ? 1 : 0))
    end
    @sprites["sel"] = Sprite.new(@viewport)
    @sprites["sel"].y = 200
    @sprites["sel"].bitmap = Bitmap.new(PATH + "sel")
    pbFadeInAndShow(@sprites)
  end

  def pbUpdate
    loop do
      Graphics.update
      Input.update
      pbUpdateSpriteHash(@sprites)
      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        @index = (@index - 1) % @switch_count
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        @index = (@index + 1) % @switch_count
      elsif Input.trigger?(Input::C)
        pbSEPlay("toggle_switch", 100, 100)
        @states[@index] = !@states[@index]
        @sprites["switch#{@index}"].changeBitmap((@states[@index] ? 1 : 0))
      elsif Input.trigger?(Input::UP) && @states[@index] == false
        pbSEPlay("toggle_switch", 100, 100)
        @states[@index] = true
        @sprites["switch#{@index}"].changeBitmap(1)
      elsif Input.trigger?(Input::DOWN) && @states[@index] == true
        pbSEPlay("toggle_switch", 100, 100)
        @states[@index] = false
        @sprites["switch#{@index}"].changeBitmap(0)
      elsif Input.trigger?(Input::BACK)
        pbPlayBuzzerSE
        break if $DEBUG
      end
      @sprites["sel"].x = @sprites["switch#{@index}"].x
      if @states == [true] * @switch_count
        break
      end
    end
  end

  def pbEndScreen
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

