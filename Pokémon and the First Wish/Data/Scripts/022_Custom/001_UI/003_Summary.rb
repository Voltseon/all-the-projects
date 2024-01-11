class VSummary
  BASE_COLOR = Color.new(248,248,248)
  SHADOW_COLOR = Color.new(64,64,64)

  def initialize(pokemonidx)
    $game_temp.in_menu = true
    @viewport = nil
    @sprites = {}
    @overlay = nil
    @disposed = false
    if pokemonidx.is_a?(Pokemon)
      @pokemon_index = -1
      @pokemon = pokemonidx
    else
      @pokemon_index = pokemonidx
      @pokemon = $player.party[@pokemon_index]
    end
    @types = Bitmap.new("Graphics/Pictures/types")
    pbStartScene
  end

  def pbStartScene
    @viewport = Viewport.new(256,32,512,512)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/Active HUD/summary")
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].x = 100
    @sprites["pokemon"].y = 100
    @sprites["pokeball"] = IconSprite.new(356,4,@viewport)
    @sprites["pokeball"].setBitmap("Graphics/Pictures/Summary/icon_ball_#{@pokemon.poke_ball}")
    @sprites["item"] = IconSprite.new(4,460,@viewport)
    pbSetSystemFont(@overlay.bitmap)
    pbRefresh
    pbMain
  end

  def pbMain
    loop do
      break if @disposed
      pbUpdate
      @overlay.bitmap.clear
      textpos = []
      textpos.push(["#{@pokemon.name}", 272, 10, 2, BASE_COLOR, SHADOW_COLOR])
      textpos.push(["#{@pokemon.item.nil? ? "No Item" : GameData::Item.get(@pokemon.item).name}", 62, 474, 0, BASE_COLOR, SHADOW_COLOR])
      break if Input.trigger?(Input::BACK)
      if @pokemon_index != -1
        if Mouse.scroll_direction < 0 && @pokemon_index < $player.party.length-1
          @pokemon_index+=1
          @pokemon = $player.party[@pokemon_index]
          pbRefresh
        elsif Mouse.scroll_direction > 0 && @pokemon_index > 0
          @pokemon_index-=1
          @pokemon = $player.party[@pokemon_index]
          pbRefresh
        end
      end
      if @pokemon.types.length > 1
        @overlay.bitmap.blt(202, 40, @types, Rect.new(0, 28*GameData::Type.get(@pokemon.types[0]).icon_position, 64, 28))
        @overlay.bitmap.blt(278, 40, @types, Rect.new(0, 28*GameData::Type.get(@pokemon.types[1]).icon_position, 64, 28))
      else
        @overlay.bitmap.blt(240, 40, @types, Rect.new(0, 28*GameData::Type.get(@pokemon.types[0]).icon_position, 64, 28))
      end
      pbDrawTextPositions(@overlay.bitmap,textpos)
    end
    pbEndScene
  end

  def pbRefresh
    @sprites["pokemon"].setPokemonBitmap(@pokemon)
    @sprites["item"].setBitmap("#{GameData::Item.icon_filename(@pokemon.item)}")
    @sprites["item"].visible = !@pokemon.item.nil?
    @pokemon.play_cry
  end

  def pbUpdate
    return if @disposed
    Graphics.update
    Input.update
    $scene.update
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
    $game_temp.in_menu = false
  end
end