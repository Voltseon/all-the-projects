################################################################################
# "More Pokedex Page : Height and Weight Comparison"
# By Caruban
#-------------------------------------------------------------------------------
# Its adding 2 new page in pokedex entry :
# - Height Comparison
# - Weight Comparison
# 
# For long/tall body type Pokemon like Ekans, Onix, alolan exeggutor, galarian farfetch'd, etc.
# You can add different sprite for Height Comparison (put the sprite inside \Graphics\Pokemon\Height)
# or
# You can add estimation height for sprite (from Config)
#
# The subject for the comparison is the player by default
# another subject can be added by using 
#   pbRegisterComparator(id)
################################################################################
# Configuration
################################################################################
module PokedexHWCConfig
  # Data for comparison
  ComparisonData = {
    # ID => [name, height (m), weight (kg), trainer type (set nil if same as ID), custom sprite file, custom charset file (in /Characters)]
    :POKEMONTRAINER_Red     => ["Maroon", 1.55, 46],
    :POKEMONTRAINER_Red2     => ["Maroon", 1.55, 46],
    :POKEMONTRAINER_Red3     => ["Maroon", 1.55, 46],
    :POKEMONTRAINER_Leaf    => ["Carmine", 1.40, 38],
    :POKEMONTRAINER_Leaf2    => ["Carmine", 1.40, 38],
    :POKEMONTRAINER_Leaf3    => ["Carmine", 1.40, 38],
    :POKEMONTRAINER_Aqua    => ["Jasper", 1.44, 45],
    :POKEMONTRAINER_Aqua2    => ["Jasper", 1.44, 45],
    :POKEMONTRAINER_Aqua3    => ["Jasper", 1.44, 45]
  }

  # Estimation pokemon height from sprites (based on sprite posture)
  SpeciesSpriteHeight = {
    :EKANS => 1.0,
    :ARBOK => 1.5,
    :ONIX => 4.5,
    :GYARADOS => 3.8,
    :DRAGONAIR => 2.2,
    :FURRET => 1.1,
    :AIPOM => 1.3,
    :STEELIX => 3.5,
    :WAILORD => 4.3,
    :SEVIPER => 1.3,
    :MILOTIC => 2.5,
    :GOREBYSS => 1.3,
    :HUNTAIL => 1.3,
    :RAYQUAZA => 3.5,
    :SERPERIOR => 1.6,
    :EXEGUTTOR_1 => 1.6,
  }
end

################################################################################
# Custom Sprite Script
################################################################################
module GameData
  class Species
    def self.height_sprite_bitmap(*params)
      bitmap = nil
      if PluginManager.installed?("Essentials Deluxe")
        data = species_sprite_params(*params)
        filename = data[:dmax] || data[:gmax] ? self.front_sprite_filename(*params) : self.height_sprite_filename(*params)
      else
        filename = self.height_sprite_filename(*params)
      end
      return (bitmap) ? bitmap : (filename) ? AnimatedBitmap.new(filename) : nil
    end
    def self.height_sprite_filename(*params)
      filename = nil
      if PluginManager.installed?("Essentials Deluxe")
        params = species_sprite_params(*params)
        dmax = (params[:gmax]) ? "Gigantamax" : (params[:dmax]) ? "Dynamax" : ""
        ret = self.check_graphic_file("Graphics/Pokemon/", params, "Height", dmax)
        filename = ret ? ret : self.check_graphic_file("Graphics/Pokemon/", params, "Front", dmax)
      else
        species = params[0] if params[0]
        form   = params[1] ? params[1] : 0
        gender = params[2] ? params[2] : 0
        ret = self.check_graphic_file("Graphics/Pokemon/", species, form, gender, false, false, "Height")
        filename = ret ? ret : self.front_sprite_filename(species, form, gender)
      end
      return filename
    end
  end
end

class PokemonSprite < SpriteWrapper
  def setSpeciesHeightBitmap(*params)
    @_iconbitmap&.dispose
    data = nil
    if PluginManager.installed?("Essentials Deluxe")
      data = species_sprite_params2(*params)
      @_iconbitmap = GameData::Species.height_sprite_bitmap(*data.values)
    else
      @_iconbitmap = GameData::Species.height_sprite_bitmap(params[0], params[1] || 0, params[2] || 0)
    end
    self.bitmap = (@_iconbitmap) ? @_iconbitmap.bitmap : nil
    if PluginManager.installed?("ZUD Mechanics")
      if data[:dmax] || data[:gmax]
        self.applyDynamax(data[:species] == :CALYREX)
        self.color = Color.new(0, 0, 0, 0)
      else
        self.unDynamax
      end
    end
    changeOrigin
  end
end
################################################################################
# Pokedex Scene
################################################################################
class PokemonPokedexInfo_Scene
  PosPkmnCharOnScale = [
    # pkmn x,y , trainer x,y
    [114,94,364,190], # 0 : 1
    [114,98,364,186], # 0.2 : 1
    [112,106,366,178], # 0.4 : 1
    [112,110,366,174], # 0.6 : 1
    [112,114,366,170], # 0.8 : 1
    [112,124,368,162], # 1 : 1
    [114,132,368,152], # 1.2 : 1
    [114,136,368,148], # 1.4 : 1
    [114,140,368,144], # 1.6 : 1
    [116,148,366,136], # 1.8 : 1
    [116,152,366,132], # 2+ : 1
  ]
  PosPkmnGmaxCharOnScale = [
    # pkmn x,y , trainer x,y
    [82,30,364,190], # 0 : 1
    [82,34,364,186], # 0.2 : 1
    [80,42,366,178], # 0.4 : 1
    [80,46,366,174], # 0.6 : 1
    [80,50,366,170], # 0.8 : 1
    [80,60,368,162], # 1 : 1
    [82,68,368,152], # 1.2 : 1
    [82,72,368,148], # 1.4 : 1
    [82,76,368,144], # 1.6 : 1
    [84,84,366,136], # 1.8 : 1
    [84,88,366,132], # 2+ : 1
  ]

  alias hw_pbStartScene pbStartScene
  def pbStartScene(dexlist,index,region)
    hw_pbStartScene(dexlist,index,region)

    #Size
    @sprites["pokesize"] = PokemonSprite.new(@viewport)
    @sprites["pokesize"].setOffset(PictureOrigin::BOTTOM)
    @baseY = 256
    @LnameX = (Graphics.width/4)
    @RnameX = (Graphics.width*3/4)
    @sprites["pokesize"].y = @baseY
    @sprites["overlay"].z += 1
    @sprites["pokesize"].tone=Tone.new(-255,-255,-255,0)
    @sprites["pokesize"].visible = false
    @sprites["trainer"] = IconSprite.new(0,0,@viewport)
    @sprites["trainer"].visible = false

    #Weight
    @sprites["scale"] = IconSprite.new(70,102,@viewport)
    @sprites["scale"].setBitmap("Graphics/Pictures/Pokedex/scale")
    charwidth  = @sprites["scale"].bitmap.width
    charheight = @sprites["scale"].bitmap.height
    @sprites["scale"].x = 102
    @sprites["scale"].y = 144
    @sprites["scale"].src_rect = Rect.new(0,5*charheight/11,charwidth,charheight/11)
    @sprites["scale"].visible = false
    @sprites["pokeicon"] = PokemonSpeciesIconSprite.new(0,@viewport)
    @sprites["pokeicon"].visible = false
    @sprites["tricon"] = IconSprite.new(70,102,@viewport)
    @sprites["tricon"].visible = false
    @hwComparator = $player.hwComparator
    resetPosScale
    @sprites["overlay2"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSmallFont(@sprites["overlay2"].bitmap)
    @availableComparator = pbGetAvailableComparators
    pbUpdateDummyPokemon
  end

  alias hw_drawPage drawPage
  def drawPage(page)
    hw_drawPage(page)
    if @sprites["overlay2"]
      overlay2 = @sprites["overlay2"].bitmap
      overlay2.clear
    end
    # Make certain sprites visible
    @sprites["pokesize"].visible      = (@page==4) if @sprites["pokesize"]
    @sprites["trainer"].visible       = (@page==4) if @sprites["trainer"]
    @sprites["pokeicon"].visible       = (@page==5) if @sprites["pokeicon"]
    @sprites["tricon"].visible       = (@page==5) if @sprites["tricon"]
    @sprites["scale"].visible       = (@page==5) if @sprites["scale"]
    # Draw page-specific information
    case page
    when 4; drawPageSizes
    when 5; drawPageW
    end
  end

  alias hw_pbUpdateDummyPokemon pbUpdateDummyPokemon
  def pbUpdateDummyPokemon
    hw_pbUpdateDummyPokemon
    #size and weight
    if @sprites["pokesize"]
      if PluginManager.installed?("Essentials Deluxe")
        @sprites["pokesize"].setSpeciesHeightBitmap(@species, @gender, @form, @shiny, @shadow, false, false, false, @gmax, @celestial)
      else
        @sprites["pokesize"].setSpeciesHeightBitmap(@species,@gender,@form)
      end
      @sprites["pokesize"].y = @baseY
    end
    if @sprites["pokeicon"]
      if PluginManager.installed?("Essentials Deluxe")
        @sprites["pokeicon"].pbSetParams(@species, @gender, @form, @shiny, @shadow, false, @gmax, @celestial)
      else
        @sprites["pokeicon"].pbSetParams(@species,@gender,@form)
      end
    end
  end
  
def drawPageSizes
    resetPosScale
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_size"))
    @sprites["trainer"].setBitmap(pbGetComparisonSprite(@hwComparator))
    @sprites["trainer"].tone=Tone.new(-255,-255,-255,0)
    @sprites["trainer"].x = 686 - (@sprites["trainer"].bitmap.width)/2
    @sprites["trainer"].y = 177 - (@sprites["trainer"].bitmap.height)
    overlay = @sprites["overlay"].bitmap
    overlay2 = @sprites["overlay2"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    species_data = GameData::Species.get_species_form(@species, @form)
    metrics_data = GameData::SpeciesMetrics.get_species_form(@species, @form)
    sp = pbGetPokemonHeight(@species, @form)
    height = PluginManager.installed?("Essentials Deluxe") && @gmax ? species_data.gmax_height : species_data.height || 1
    heightdata = height/10.0
    heightm = sp ? sp : heightdata
    trainerheight = pbGetComparisonHeight(@hwComparator) || 1.4 # in m
    resizer=128*1.2/@sprites["trainer"].bitmap.height
    @sprites["pokesize"].setOffset(PictureOrigin::BOTTOM)
    @sprites["pokesize"].zoom_x = resizer
    @sprites["pokesize"].zoom_y = resizer
    @sprites["trainer"].zoom_x  = resizer
    @sprites["trainer"].zoom_y  = resizer
    if trainerheight > heightm
      scale = heightm/trainerheight
      scale = 0.4 if scale < 0.4
      @sprites["pokesize"].zoom_x = scale * resizer
      @sprites["pokesize"].zoom_y = scale * resizer
    else
      @sprites["trainer"].zoom_x = (trainerheight/heightm)*resizer
      @sprites["trainer"].zoom_y = (trainerheight/heightm)*resizer
    end
    @sprites["pokesize"].x = 150
    @sprites["pokesize"].y = @baseY
    @sprites["trainer"].x  = 386
    @sprites["trainer"].y  = 252
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width * @sprites["trainer"].zoom_x)/2
    @sprites["trainer"].y -= @sprites["trainer"].bitmap.height * @sprites["trainer"].zoom_x
    @sprites["pokesize"].y += PluginManager.installed?("Essentials Deluxe") && @gmax ? 
                              metrics_data.gmax_front_sprite[1] * 2  * (@sprites["pokesize"].zoom_y/resizer) : 
                              metrics_data.front_sprite[1] * 2 * (@sprites["pokesize"].zoom_y/resizer)
    spriteresizer = 1
    if PluginManager.installed?("Generation 8 Pack Scripts")
      spriteresizer = Settings::FRONT_BATTLER_SPRITE_SCALE
      @sprites["pokesize"].zoom_x *= spriteresizer
      @sprites["pokesize"].zoom_y *= spriteresizer
    end
    @sprites["pokesize"].y -= PluginManager.installed?("Essentials Deluxe") && @gmax && !PluginManager.installed?("Generation 8 Pack Scripts") ? 
                              metrics_data.gmax_altitude * 4 : metrics_data.front_sprite_altitude * 4
    # @sprites["pokesize"].y -= PluginManager.installed?("Essentials Deluxe") && @gmax && !PluginManager.installed?("Generation 8 Pack Scripts") ? 
    #                           metrics_data.gmax_altitude * 2 * (@sprites["pokesize"].zoom_y/resizer) * spriteresizer : 
    #                           metrics_data.front_sprite_altitude * 2 * (@sprites["pokesize"].zoom_y/resizer) * spriteresizer
    @sprites["pokesize"].y -= 2.0 / @sprites["pokesize"].zoom_y * spriteresizer if @sprites["pokesize"].zoom_y < 1 # Base Y correction
    # Write species name, trainer name, and their height
    textpos = [
       [_INTL("{1}",species_data.name),@LnameX-76,Graphics.height-94+6,0,base,shadow],
       [_INTL("{1}",pbGetComparisonName(@hwComparator)),@RnameX-76,Graphics.height-94+6,0,base,shadow]
    ]
    # Height Record
    if System.user_language[3..4] == "US"   # If the user is in the United States
      inches   = (height/0.254).round
      trinches = (trainerheight*10/0.254).round
      trtext   = _ISPRINTF("{1:d}'{2:02d}\"",trinches/12,trinches%12)
      text = _ISPRINTF("???'??\"")
      text = _ISPRINTF("{1:d}'{2:02d}\"",inches/12,inches%12) if $player.owned?(@species)
    else
      trtext = _INTL("{1} m",trainerheight)
      text = _INTL("??? m")
      text = _INTL("{1} m",heightdata) if $player.owned?(@species)
    end
    textsm = [
      ["Height",@LnameX-76,Graphics.height-60,0,base,shadow],
      ["Height",@RnameX-76,Graphics.height-60,0,base,shadow]
    ]
    textpos.push([text,@LnameX+76,Graphics.height-62+6,1,base,shadow])
    textpos.push([trtext,@RnameX+76,Graphics.height-62+6,1,base,shadow])
    # Draw all text & image
    pbDrawTextPositions(overlay,textpos)
    pbDrawTextPositions(overlay2,textsm)
  end
  def drawPageW
    resetPosScale
    @sprites["background"].setBitmap(_INTL("Graphics/Pictures/Pokedex/bg_weight"))
    overlay = @sprites["overlay"].bitmap
    overlay2 = @sprites["overlay2"].bitmap
    base   = Color.new(88,88,80)
    shadow = Color.new(168,184,184)
    species_data = GameData::Species.get_species_form(@species, @form)
    weight = PluginManager.installed?("Essentials Deluxe") && @gmax ? 99999 : species_data.weight || 1
    weightkg = weight/10.0 # in kg 
    trainerweight = pbGetComparisonWeight(@hwComparator) || 40
    @weightcomp=weightkg/trainerweight
    @anim_play = true
    # Write species name, trainer name, and their height
    textpos = [
       [_INTL("{1}",pbGetComparisonName(@hwComparator)),@RnameX-76,Graphics.height-94+6,0,base,shadow],
       [_INTL("{1}",species_data.name),@LnameX-76,Graphics.height-94+6,0,base,shadow]
    ]
    # Weight Record
    if System.user_language[3..4] == "US"   # If the user is in the United States
      pounds = (weight/0.45359).round
      trpounds = (trainerweight*10/0.45359).round
      trtext = _ISPRINTF("{1:4.1f} lbs.",trpounds/10.0)
      text = _INTL("??? lbs.")
      text = _ISPRINTF("{1:4.1f} lbs.",pounds/10.0) if $player.owned?(@species)
      text = _INTL("??? lbs.") if PluginManager.installed?("Essentials Deluxe") && @gmax
    else
      trtext = _INTL("{1} kg",trainerweight)
      text   = _INTL("??? kg") 
      text   = _INTL("{1} kg",weightkg) if $player.owned?(@species)
      text   = _INTL("??? kg") if PluginManager.installed?("Essentials Deluxe") && @gmax
    end
    # Trainer and Pokemon Weight
    textsm = [
      ["Weight",@LnameX-76,Graphics.height-60,0,base,shadow],
      ["Weight",@RnameX-76,Graphics.height-60,0,base,shadow]
    ]
    textpos.push([text,@LnameX+76,Graphics.height-62+6,1,base,shadow])
    textpos.push([trtext,@RnameX+76,Graphics.height-62+6,1,base,shadow])
    # Draw all text
    pbDrawTextPositions(overlay,textpos)
    pbDrawTextPositions(overlay2,textsm)
  end

  def resetPosScale
    @sprites["scale"].src_rect.y = 0
    @sprites["pokeicon"].x = 114
    @sprites["pokeicon"].y = 34
    @sprites["pokeicon"].x -= 32 if PluginManager.installed?("Essentials Deluxe") && @gmax && !PluginManager.installed?("Generation 8 Pack Scripts")
    @sprites["pokeicon"].y -= 64 if PluginManager.installed?("Essentials Deluxe") && @gmax && !PluginManager.installed?("Generation 8 Pack Scripts")
    @sprites["tricon"].setBitmap(pbGetComparisonCharset(@hwComparator))
    @charwidth  = @sprites["tricon"].bitmap.width
    @charheight = @sprites["tricon"].bitmap.height
    @sprites["tricon"].x = 364-@charwidth/8
    @sprites["tricon"].y = 190-@charheight/8
    @sprites["tricon"].src_rect = Rect.new(0,0,@charwidth/4,@charheight/4)
    @anim_play = false
    @anim_pos = 0
    @frame = 0
    @scale_pos = 0
    @jump = true
    @jump_counter = 0
    @jump_counter_max = 0
  end

  def posOnScale(i,charjump=false)
    data = PluginManager.installed?("Essentials Deluxe") && @gmax && !PluginManager.installed?("Generation 8 Pack Scripts") ? PosPkmnGmaxCharOnScale[i] : PosPkmnCharOnScale[i]
    @sprites["pokeicon"].x = data[0]
    @sprites["pokeicon"].y = data[1]
    @sprites["tricon"].x = data[2]-@charwidth/8
    if !charjump
      @sprites["tricon"].y = data[3]-@charheight/8
    end
    @sprites["scale"].src_rect.y = i*@sprites["scale"].src_rect.height
  end

  def scaleAnim
    return if !@anim_play
    target_scale = (@weightcomp*10/2).to_i
    target_scale = 10 if target_scale>10
    jump = @weightcomp >= 30 ? 40 : @weightcomp >= 8 ? 30 : @weightcomp >= 5 ? 20 : @weightcomp >= 2 ? 15 : 10
    if @anim_pos == 0
      @sprites["pokeicon"].y += jump
      if @sprites["pokeicon"].y == PluginManager.installed?("Essentials Deluxe") && @gmax && !PluginManager.installed?("Generation 8 Pack Scripts") ? 30 : 94
        pbSEPlay("Battle ball shake", 80)
        @anim_pos = 1
      end
    elsif @anim_pos == 1 # to Scale
      @scale_pos += 1 if target_scale>0
      n = target_scale >= 8 ? 3 : target_scale >= 4 ? 2 : 1
      @scale_pos += n if @scale_pos < target_scale-n && target_scale>=2
      posOnScale(@scale_pos)
      if @scale_pos == target_scale
        @anim_pos = 2
        if [0,10].include?(@scale_pos)
          @shake_stage = 0 
        elsif @scale_pos<4
          @shake_stage = 3
        else
          @shake_stage = 7
        end
        @scale_shake = @scale_pos
        if @weightcomp >= 30 # gmax
          @jump_counter = 30
        elsif @weightcomp >= 10
          @jump_counter = 4*@weightcomp.to_i # 40
        elsif @weightcomp >= 8
          @jump_counter = 10
        elsif @weightcomp >= 5
          @jump_counter = 8
        elsif @weightcomp >= 2
          @jump_counter = 4
        end
        @jump_counter_max = @jump_counter
        @jump = (@jump_counter>0)
        pbSEPlay("GUI menu open", 80) if @jump && @weightcomp >= 10
        pbSEPlay("Battle throw", 80) if @jump && @weightcomp >= 8 && @weightcomp < 10
        pbSEPlay("Player jump", 80) if @jump && @weightcomp < 8
      end
    elsif @anim_pos == 2 # jump
      if @jump_counter_max > 0
        if @jump
          @jump_counter -= 1
          if @jump_counter == 0
            @jump = false
            if @weightcomp >= 30 && @sprites["tricon"].visible # gmax
              pbSEPlay("Mining iron", 80)
              @anim_pos = 3
            end
          else
            if @sprites["tricon"].y >= -1*@sprites["tricon"].bitmap.height/4
              @sprites["tricon"].y -= jump
            else
              @jump_counter_max -= 1
            end
          end
        else
          @jump_counter += 1
          if @jump_counter == @jump_counter_max
            pbSEPlay("Player bump", 80) if @weightcomp < 30
            posOnScale(@scale_pos)
            @anim_pos = 3
          else
            @sprites["tricon"].y += jump
          end
        end
      else
        @anim_pos = 3 
      end
    elsif @anim_pos == 3 # done
      @anim_play = false
    end
  end

  def pbGetAvailableComparators
    registered = $player.registeredComparator
    hw = []
    weight = PokedexHWCConfig::ComparisonData
    weight.each_key{|type|
      hw.push(type) if registered[type]
    }
    return hw
  end

  def pbChooseHWComparator
    @sprites["uparrow"].x = 372
    @sprites["downarrow"].x = 372
    index = 0
    hw = @availableComparator
    hw.length.times do |i|
      if hw[i] == @hwComparator
        index = i
        break
      end
    end
    oldindex = -1
    oldcomp = @hwComparator
    loop do
      if oldindex != index
        @hwComparator = hw[index]
        drawPage(@page) if oldindex >= 0
        @sprites["uparrow"].visible   = (index > 0)
        @sprites["downarrow"].visible = (index < hw.length - 1)
        oldindex = index
      end
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        index = (index + hw.length - 1) % hw.length
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        index = (index + 1) % hw.length
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        @hwComparator = oldcomp
        drawPage(@page)
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        break
      end
    end
    @sprites["uparrow"].visible   = false
    @sprites["downarrow"].visible = false
    @sprites["uparrow"].x = 242
    @sprites["downarrow"].x = 242
    $player.hwComparator = @hwComparator
  end
  
  def pbGetPokemonHeight(species,form=0)
    species = _INTL("{1}_{2}",species.to_s,form.to_s).to_sym if form > 0
    height = PokedexHWCConfig::SpeciesSpriteHeight[species]
    return height
  end
  
  def pbGetComparisonName(id)
    name = PokedexHWCConfig::ComparisonData[id][0]
    return "" if !name
    id = pbGetComparisonTrainerType(id)
    # name = GameData::TrainerType.get(id).real_name if !name
    name = $player.name if $player.trainer_type == id
    return name
  end
  
  def pbGetComparisonHeight(id)
    return PokedexHWCConfig::ComparisonData[id][1]
  end
  
  def pbGetComparisonWeight(id)
    return PokedexHWCConfig::ComparisonData[id][2]
  end

  def pbGetComparisonTrainerType(id)
    trainer_type = PokedexHWCConfig::ComparisonData[id][3]
    trainer_type = id if !trainer_type
    return trainer_type
  end
  
  def pbGetComparisonSprite(id)
    sprite = PokedexHWCConfig::ComparisonData[id][4]
    id = pbGetComparisonTrainerType(id)
    sprite = GameData::TrainerType.player_front_sprite_filename(id) if !sprite
    return sprite
  end
  
  def pbGetComparisonCharset(id)
    file = PokedexHWCConfig::ComparisonData[id][5]
    charset = "Graphics/Characters/"+file.to_s if file
    id = pbGetComparisonTrainerType(id)
    charset = GameData::TrainerType.charset_filename(id) if !file
    return charset
  end

  alias hw_pbUpdate pbUpdate
  def pbUpdate
    scaleAnim
    hw_pbUpdate
  end

  def pbScene
    Pokemon.play_cry(@species, @form)
    loop do
        Graphics.update
        Input.update
        pbUpdate
        dorefresh = false
        if Input.trigger?(Input::ACTION)
          pbSEStop
          Pokemon.play_cry(@species, @form) if @page == 1
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)
          if @page==1    # Info
            @checkingNumberBattled = !@checkingNumberBattled
            dorefresh = true
          elsif @page==3   # Forms
            if @available.length>1
              pbPlayDecisionSE
              pbChooseForm
              dorefresh = true
            end
          elsif (@page==4 || @page==5) && @availableComparator.length > 1 # Weight & Height
            pbPlayDecisionSE
            pbChooseHWComparator
          end
        elsif Input.trigger?(Input::UP)
          oldindex = @index
          pbGoToPrevious
          if @index!=oldindex
              pbUpdateDummyPokemon
              @available = pbGetAvailableForms
              pbSEStop
              (@page==1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
              dorefresh = true
          end
        elsif Input.trigger?(Input::DOWN)
          oldindex = @index
          pbGoToNext
          if @index!=oldindex
              pbUpdateDummyPokemon
              @available = pbGetAvailableForms
              pbSEStop
              (@page==1) ? Pokemon.play_cry(@species, @form) : pbPlayCursorSE
              dorefresh = true
          end
        elsif Input.trigger?(Input::LEFT)
          oldpage = @page
          @page -= 1
          @page = 1 if @page<1
          @page = 5 if @page>5
          if @page!=oldpage
              pbPlayCursorSE
              dorefresh = true
          end
        elsif Input.trigger?(Input::RIGHT)
          oldpage = @page
          @page += 1
          @page = 1 if @page<1
          @page = 5 if @page>5
          if @page!=oldpage
              pbPlayCursorSE
              dorefresh = true
          end
        end
        if dorefresh
          drawPage(@page)
        end
    end
    return @index
    end
  
end

#===============================================================================
# Trainer Comparison Variable
#===============================================================================
class Player < Trainer
  attr_accessor :hwComparator
  attr_accessor :registeredComparator

  def hwComparator
    @hwComparator = trainer_type if !@hwComparator
    return @hwComparator
  end

  def registeredComparator
    @registeredComparator = {} if !@registeredComparator
    @registeredComparator[trainer_type] = true if !@registeredComparator[trainer_type]
    return @registeredComparator
  end

  def setRegComparator(id)
    return false if !PokedexHWCConfig::ComparisonData[id]
    @registeredComparator = {} if !@registeredComparator
    @registeredComparator[id] = true
    return true
  end
end

def pbRegisterComparator(id)
  return $player.setRegComparator(id)
end

def pbRegisterAllComparator
  PokedexHWCConfig::ComparisonData.each_key{|id|
    $player.setRegComparator(id)
  }
end