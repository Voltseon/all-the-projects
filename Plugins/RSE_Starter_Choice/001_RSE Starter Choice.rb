RSE_CHOICE_PATH = "Graphics/Pictures/RSE Starter Choice"
MESSAGE_BASE_COLOR = Color.new(99,99,99)
MESSAGE_SHADOW_COLOR = Color.new(214,214,206)

def vChooseStarters(generation = 1, level = 5, message = "Choose your Starter Pokémon.")
  level = 1 if $player.levelone
  raw_starters = $player.special_pokemon[:STARTER]
  starters = []
  for i in 0...raw_starters.length/3
    starters.push([raw_starters[i*3], raw_starters[i*3+1], raw_starters[i*3+2]])
  end
  ret = nil
  pokemon = starters[generation-1]
  unless pokemon.is_a?(Array)
    echoln "Couldn't show starter choices for #{pokemon}"
    echoln "The Pokemon argument must be an array..."
    return false
  end
  pokemon = [$player.starterpkmn1, $player.starterpkmn2, $player.starterpkmn3] if $player.customstarters
  pbFadeOutIn {
    scene = RSESTarterChoice.new(pokemon, level, message)
    scene.pbStartScene
    scene.pbInputs
    ret = scene.pbEndScene
  }
  ret.ability_index = 2 if rand(20)==1
  pbAddPokemon(ret)
  return ret
end

class RSESTarterChoice
  def initialize(pokemon, level, message)
    @pokemon_count = pokemon.length
    @pokemon = []
    @generated_pokemon = []
    @pokemon_count.times { |index|
      @pokemon[index] = pokemon[index]
      @generated_pokemon.push(Pokemon.new(pokemon[index], level))
    }
    @message_show = message.is_a?(String) && !nil_or_empty?(message)
    @message = (@message_show) ? message : ""
    @index = 0
    @move_speed = 10
  end

  def pbStartScene
    # Setup
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("#{RSE_CHOICE_PATH}/bg")
    # Bag
    @sprites["bag"] = IconSprite.new(Graphics.width/2 + 32, Graphics.height/3, @viewport)
    @sprites["bag"].setBitmap("#{RSE_CHOICE_PATH}/bag")
    @sprites["bag"].ox = @sprites["bag"].bitmap.width/2
    @sprites["bag"].oy = @sprites["bag"].bitmap.height/2
    # Infobox
    @sprites["infobox"] = IconSprite.new(Graphics.width/2, Graphics.height/3-32, @viewport)
    @sprites["infobox"].setBitmap("#{RSE_CHOICE_PATH}/infobox")
    @sprites["infobox"].ox = @sprites["infobox"].bitmap.width/2
    @sprites["infobox"].oy = @sprites["infobox"].bitmap.height/2
    # Pokeballs
    @pokemon_count.times do |i|
      @sprites["ball#{i}"] = AnimatedSprite.new("#{RSE_CHOICE_PATH}/ball", 4, 48, 40, 2, @viewport)
      @sprites["ball#{i}"].ox = 24
      sel_pos = calcPos(i)
      @sprites["ball#{i}"].x = sel_pos[0]
      @sprites["ball#{i}"].y = sel_pos[1] + 64
      @sprites["ball#{i}"].play if i == @index
    end
    # Selection
    @sprites["sel"] = AnimatedSprite.new("#{RSE_CHOICE_PATH}/sel", 4, 64, 84, 2, @viewport)
    @sprites["sel"].ox = 32
    sel_pos = calcPos(@index)
    @sprites["sel"].x = sel_pos[0]
    @sprites["sel"].y = sel_pos[1]
    @sprites["sel"].play
    @sprites["sel"].visible = false
    # Create message window (displays the message)
    msgWindow = Window_AdvancedTextPokemon.newWithSize("", 16, Graphics.height - 96 + 2, Graphics.width - 32, 96, @viewport)
    msgWindow.baseColor      = MESSAGE_BASE_COLOR
    msgWindow.shadowColor    = MESSAGE_SHADOW_COLOR
    msgWindow.letterbyletter = true
    @sprites["messageWindow"] = msgWindow
    @sprites["messageWindow"].text = @message
    # Pokemon Showcase
    @sprites["showcase"] = IconSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
    @sprites["showcase"].setBitmap("#{RSE_CHOICE_PATH}/select")
    @sprites["showcase"].x = Graphics.width/2
    @sprites["showcase"].y = Graphics.height/2
    @sprites["showcase"].ox = @sprites["showcase"].bitmap.width/2
    @sprites["showcase"].oy = @sprites["showcase"].bitmap.height/2
    @sprites["showcase"].zoom_x = 0
    @sprites["showcase"].zoom_y = 0
    @sprites["showcase"].visible = false
    # Pokemon itself
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon"].x = Graphics.width/2
    @sprites["pokemon"].y = Graphics.height/2
    @sprites["pokemon"].visible = false
    # Overlay
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Fade in
    pbFadeInAndShow(@sprites)
    # Show selection last
    @sprites["sel"].visible = true
  end

  def pbUpdate
    # Selected Pokémon species
    pkmn = GameData::Species.get(@pokemon[@index])
    # Text of selected pokemon
    base   = Color.new(248, 248, 248)
    shadow = Color.new(214, 214, 206)
    @sprites["overlay"].bitmap.clear
    if @sprites["pokemon"].visible
      textpos = [
        ["#{pkmn.name}", @sprites["infobox"].x, @sprites["infobox"].y-24, 2, base, shadow]
      ]
    else
      textpos = [
        ["#{pkmn.category} Pokémon", @sprites["infobox"].x, @sprites["infobox"].y-24, 2, base, shadow],
        ["#{pkmn.name}", @sprites["infobox"].x, @sprites["infobox"].y+8, 2, base, shadow]
      ]
    end
    # Update Pokeballs
    @pokemon_count.times do |i|
      next if i == @index
      @sprites["ball#{i}"].stop
      @sprites["ball#{i}"].frame = 0
    end
    @sprites["ball#{@index}"].play unless @sprites["ball#{@index}"].playing?
    # Move sel arrow
    sel_pos = calcPos(@index)
    sel_pos[1] -= 24
    while sel_pos != [@sprites["sel"].x, @sprites["sel"].y]
      textpos = []
      @sprites["sel"].x = move_to(@sprites["sel"].x, sel_pos[0], @move_speed)
      @sprites["sel"].y = move_to(@sprites["sel"].y, sel_pos[1], @move_speed)
      pbWait(1)
    end
    # Draw all text
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    # Update Sprite Hash
    pbUpdateSpriteHash(@sprites)
  end

  def pbInputs
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::LEFT) && @index > 0
        pbPlayCursorSE
        @index -= 1
      elsif Input.trigger?(Input::RIGHT) && @index < @pokemon_count-1
        pbPlayCursorSE
        @index += 1
      elsif Input.trigger?(Input::BACK)
        pbPlayBuzzerSE
      elsif Input.trigger?(Input::USE)
        @sprites["messageWindow"].visible = false
        pkmn = @generated_pokemon[@index]
        showPkmn(pkmn)
        if pbConfirmMessage(_INTL("Would you like to choose {1}?",pkmn.name))
          pbPlayDecisionSE
          break
        end
        @sprites["pokemon"].visible = false
        5.times do |i|
          @sprites["showcase"].zoom_x -= 0.2
          @sprites["showcase"].zoom_y -= 0.2
          pbWait(1)
        end
        @sprites["showcase"].zoom_x = 0
        @sprites["showcase"].zoom_y = 0
        @sprites["showcase"].visible = false
        @sprites["messageWindow"].visible = true
      end
    end
  end

  def move_to(start, stop, step)
    if start - stop >= 0 # positive
      newloc = start - step
      return (newloc < stop) ? stop : newloc
    else # negative
      newloc = start + step
      return (newloc > stop) ? stop : newloc
    end
  end

  def showPkmn(pkmn=nil)
    return false if pkmn.nil?
    @sprites["showcase"].visible = true
    10.times do |i|
      @sprites["showcase"].zoom_x += 0.1
      @sprites["showcase"].zoom_y += 0.1
      pbWait(1)
    end
    @sprites["pokemon"].visible = true
    pkmn.play_cry
    @sprites["pokemon"].setPokemonBitmap(pkmn)
    pbUpdate
  end
  
  def calcPos(n)
    offset = 128
    fractX = (Graphics.width-offset) / (@pokemon_count+1)
    retX = fractX * (n+1) + offset / 2
    middle = (@pokemon_count-1).to_f/2
    dist_middle = (middle - n).abs
    retY = Graphics.height / 2 - 16 * dist_middle - 106 + 16 * @pokemon_count - 32*(@pokemon_count.to_f/4).floor
    return [retX, retY]
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbSet(7,@index+1)
    return @generated_pokemon[@index]
  end
end