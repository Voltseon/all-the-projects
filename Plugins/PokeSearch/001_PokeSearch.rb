#-------------------------------------------------------------------------------
# PokéSearch v1.1
# Find your perfect encounter with style 😎
#-------------------------------------------------------------------------------
#
# Based on UI-Encounters by ThatWelshOne
# 
#-------------------------------------------------------------------------------
#
# Call the UI with: vPokeSearch
#
#-------------------------------------------------------------------------------
#
# If you want to add the PokeSearch to an item
# un-comment the following lines
#
#-------------------------------------------------------------------------------
#ItemHandlers::UseInField.add(:POKESEARCH, proc { |item|
#vPokeSearch
#next true
#})
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

def vPokeSearch
  scene = PokeSearch_Scene.new
  screen = PokeSearch_Screen.new(scene)
  return screen.pbStartScreen
end

class PokeSearch_Scene
  BASE_COLOR    = Color.new(255, 255, 255)
  SHADOW_COLOR  = Color.new(148, 198, 61)
  SHADOW_COLOR2 = Color.new(59, 63, 81)

  ONLY_ON_ENCOUNTER_TILE = true # Whether you can only search while on an encounter tile (grass, surfing, in a cave)

  # Initializes Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    mapid = $game_map.map_id
    @encounter_data = GameData::Encounter.get(mapid, $PokemonGlobal.encounter_version)
    if @encounter_data
        @encounter_tables = Marshal.load(Marshal.dump(@encounter_data.types))
        @max_enc, @eLength = getMaxEncounters(@encounter_tables)
    else
        @max_enc, @eLength = [1, 1]
    end
    @index_hor = 1
    @index_ver = 0
    if PBDayNight.isDay?
      @current_key = :LandDay
    else
      @current_key = :LandNight
    end
    case GameData::Weather.get($game_screen.weather_type).category
    when :Rain then @current_key = :LandRain
    when :Sun then @current_key = :LandSunny
    when :Hail then @current_key = :LandHail
    when :Sandstorm then @current_key = :LandSandstorm
    end
    @current_key = :Water if $PokemonGlobal.surfing
    if !$PokemonEncounters.has_encounter_type?(@current_key)
      if PBDayNight.isDay?
        @current_key = :LandDay
      else
        @current_key = :LandNight && $PokemonEncounters.has_encounter_type?(:LandNight)
      end
    end
    @current_key = :Cave if $PokemonEncounters.has_encounter_type?(:Cave)
    @current_key = :Land if !$PokemonEncounters.has_encounter_type?(@current_key)
    @current_key = :SeaGrass if $PokemonGlobal.diving
    @current_mon = nil
    @current_berry = nil
    @current_repel = nil
    @average_level = 1
    @default_key = @current_key
    @disposed = false
  end

  # draw scene elements
  def pbStartScene
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if $player.has_pdaplus
      @sprites["bg"].setBitmap("Graphics/Pictures/Pokegear/bg_plus")
      @sprites["background"].setBitmap("Graphics/Pictures/PokeSearch/bgplus")
    else
      @sprites["bg"].setBitmap("Graphics/Pictures/Pokegear/bg")
      @sprites["background"].setBitmap("Graphics/Pictures/PokeSearch/bg")
    end
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["success_rate"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["success_rate"].bitmap)
    @sprites["sel_berry"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_berry"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_small"))
    @sprites["sel_berry"].x = 96
    @sprites["sel_berry"].y = 96
    @sprites["sel_berry"].visible = false
    @sprites["sel_repel"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_repel"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_repel"))
    @sprites["sel_repel"].x = 360
    @sprites["sel_repel"].y = 96
    @sprites["sel_repel"].visible = false
    @sprites["sel_pokemon"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_pokemon"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_medium"))
    @sprites["sel_pokemon"].x = 166
    @sprites["sel_pokemon"].y = 102
    @sprites["sel_pokemon"].visible = true
    @sprites["sel_search"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_search"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_large_search"))
    @sprites["sel_search"].x = 96
    @sprites["sel_search"].y = 318
    @sprites["sel_search"].visible = false
    @sprites["sel_cancel"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_cancel"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_large_cancel"))
    @sprites["sel_cancel"].x = 288
    @sprites["sel_cancel"].y = 318
    @sprites["sel_cancel"].visible = false
    @sprites["berry_icon"] = ItemIconSprite.new(124,124,nil,@viewport)
    @sprites["berry_text"] = Window_UnformattedTextPokemon.newWithSize("",21, 155, 236, 174, @viewport)
    @sprites["berry_text"].baseColor   = BASE_COLOR
    @sprites["berry_text"].shadowColor = SHADOW_COLOR
    @sprites["berry_text"].visible     = true
    @sprites["berry_text"].windowskin  = nil
    @sprites["berry_text"].text = "Add a chip to this slot in order to affect the search weather."
    @sprites["repel_icon"] = ItemIconSprite.new(388,124,nil,@viewport)
    @sprites["repel_text"] = Window_UnformattedTextPokemon.newWithSize("",257, 155, 236, 174, @viewport)
    @sprites["repel_text"].baseColor   = BASE_COLOR
    @sprites["repel_text"].shadowColor = SHADOW_COLOR
    @sprites["repel_text"].visible     = true
    @sprites["repel_text"].windowskin  = nil
    @sprites["repel_text"].text = "Add a repel to this slot in order to increase the encounter odds."
    @sprites["berry_icon"].visible = false
    @sprites["repel_icon"].visible = false
    if $PokemonSystem.last_pokesearch_settings != []
      # Only set last pokemon if it's available in this map
      encounter_data = getEncData
      unless encounter_data.nil?
        if encounter_data[0].include?($PokemonSystem.last_pokesearch_settings[0])
          @current_mon = $PokemonSystem.last_pokesearch_settings[0]
          current_mon_name = GameData::Species.get(@current_mon).name
          overlay = @sprites["overlay"].bitmap
          overlay.clear
          pbDrawTextPositions(overlay,[[current_mon_name,Graphics.width/2,112,2,BASE_COLOR,SHADOW_COLOR]])
        end
      end
      # Only set last berry if it's available in the bag
      if $bag.has?($PokemonSystem.last_pokesearch_settings[1])
        @current_berry = $PokemonSystem.last_pokesearch_settings[1]
        @sprites["berry_icon"].item = @current_berry
        @sprites["berry_text"].text = description(@current_berry)
        case @current_berry
        when :CHIPRAIN then @current_key = :LandRain
        when :CHIPSUNNY then @current_key = :LandSunny
        when :CHIPHAIL then @current_key = :LandHail
        when :CHIPSAND then @current_key = :LandSandstorm
        when :CHIPCLEAR
          @current_key = :LandDay
          @current_key = :LandNight if $PokemonEncounters.has_encounter_type?(:LandNight) && PBDayNight.isNight?
        else @current_key = @default_key
        end
      end
      # Only set last repel if it's available in the bag
      if $bag.has?($PokemonSystem.last_pokesearch_settings[2])
        @current_repel = $PokemonSystem.last_pokesearch_settings[2]
        @sprites["repel_icon"].item = @current_repel
        @sprites["repel_text"].text = description(@current_repel)
      end
      drawPresent
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  # input controls
  def pbPokeSearch
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
            case @index_hor
            when 0
              selectBerry
            when 1
              selectMon
            when 2
              selectRepel
            end
          when 1
            case @index_hor
            when 0
              return true if startSearch
            when 1
              pbPlayCloseMenuSE
              break
            when 2
              pbPlayCloseMenuSE
              break
            end
          end
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
      if @sprites["bg"].y > -1
        @sprites["bg"].y = -128
      else
        @sprites["bg"].y+=1
      end
    end
    return false
  end

  # selecting the correct berry
  def selectBerry
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$bag)
      berry = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).flags.include?("WeatherChip") })
      @sprites["berry_icon"].item = berry
      if berry
        @sprites["berry_text"].text = description(berry)
        @sprites["berry_icon"].visible = true
      else
        @sprites["berry_text"].text = "Add a chip to this slot in order to affect the search weather."
        @sprites["berry_icon"].visible = false
      end
      case berry
      when :CHIPRAIN then @current_key = :LandRain
      when :CHIPSUNNY then @current_key = :LandSunny
      when :CHIPHAIL then @current_key = :LandHail
      when :CHIPSAND then @current_key = :LandSandstorm
      when :CHIPCLEAR
        @current_key = :LandDay
        @current_key = :LandNight if $PokemonEncounters.has_encounter_type?(:LandNight) && PBDayNight.isNight?
      else @current_key = @default_key
      end
      @current_mon = nil
      @sprites["overlay"].bitmap.clear
      @current_berry = berry
    }
    drawPresent
  end

  # returns the correct description
  def description(item)
    case item
    when :REPEL
      return _INTL("Because of the Repel there is a decent chance of an encounter.")
    when :SUPERREPEL
      return _INTL("Because of the Super Repel there is a good chance of an encounter.")
    when :MAXREPEL
      return _INTL("Because of the Max Repel an encounters are guaranteed.")
    when :CHIPCLEAR
      return _INTL("Nullifies weather and finds the neutral encounters.")
    when :CHIPRAIN
      return _INTL("Activates Rain and finds the exclusive encounters.")
    when :CHIPSUNNY
      return _INTL("Activates Sunny Day and finds the exclusive encounters.")
    when :CHIPHAIL
      return _INTL("Activates Hail and finds the exclusive encounters.")
    when :CHIPSAND
      return _INTL("Activates Sandstorm and finds the exclusive encounters.")
    end
  end

  # selecting mons based on the encounter table
  def selectMon
    commands = []
    mons = []
    if !getEncData.nil?
      command_list = getEncData[0]
      @average_level = getEncData[1]
    end
    if !command_list.nil?
      command_list.each { |mon| mons.push(mon)}
      mons.each { |thismon| commands.push(GameData::Species.get(thismon).name)}
    end
    commands.push("Cancel")
    command = pbShowCommands(nil,commands,commands.length)
    @current_mon = nil
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    if commands[command] != "Cancel"
      pbDrawTextPositions(overlay,[[commands[command],Graphics.width/2,112,2,BASE_COLOR,SHADOW_COLOR]])
      @current_mon = mons[command]
    end
  end

  # selecting repels
  def selectRepel
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$bag)
      repel = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item) == :REPEL || GameData::Item.get(item) == :SUPERREPEL || GameData::Item.get(item) == :MAXREPEL })
      @sprites["repel_icon"].item = repel
      if repel
        @sprites["repel_text"].text = description(repel)
        @sprites["repel_icon"].visible = true
      else
        @sprites["repel_text"].text = "Add a repel to this slot in order to increase the encounter odds."
        @sprites["repel_icon"].visible = false
      end
      @current_repel = repel
    }
    drawPresent
  end

  # checks all of the current parameters and initiates a battle if successful
  def startSearch
    if @current_mon.nil?
      pbPlayBuzzerSE()
      pbMessage("Select a Pokémon in order to scan.")
      return false
    end
    if !$PokemonEncounters.encounter_possible_here? && ONLY_ON_ENCOUNTER_TILE
      pbPlayBuzzerSE()
      pbMessage("Can only scan when standing in an area where you can get encounters.")
      return false
    end
    level = @average_level + rand(-2..2)
    if 1 > level || level > 100
      level = [level,1].max
      level = [level,100].min
    end
    $PokemonSystem.pokesearch_encounter = true
    odds = rand(0..100) < getRepelOdds
    if !@current_repel.nil?
      $bag.remove(@current_repel)
      @current_repel = nil
    end
    pbEndScene
    waitingMessage = "\\se[Battle ball shake]...\\. \\se[Battle ball shake]...\\. \\se[Battle ball shake]...\\| "
    finalMessage = ""
    for i in 0..rand(1,2); finalMessage += waitingMessage; end
    pbMessage(_INTL("{1}\\wtnp[2]", finalMessage))
    if odds
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID, $game_player.x, $game_player.y, true, 3)
      pbWait(20)
      case @current_berry
      when :CHIPCLEAR then setBattleRule("weather",:None)
      when :CHIPRAIN then setBattleRule("weather",:Rain)
      when :CHIPSUNNY then setBattleRule("weather",:Sun)
      when :CHIPHAIL then setBattleRule("weather",:Hail)
      when :CHIPSAND then setBattleRule("weather",:Sandstorm)
      end
      WildBattle.start(@current_mon, level)
    else
      pbMessage("No Pokémon appeared.")
    end
    $PokemonSystem.pokesearch_encounter = false
    return true
  end

  # in percentages
  def getRepelOdds
    return 0 if @current_mon.nil?
    case @current_repel
    when :REPEL
      return 50
    when :SUPERREPEL
      return 80
    when :MAXREPEL
      return 100
    end
    return 10
  end

  # update UI based on current status
  # thanks to ThatWelshOne
  def drawPresent
    @sprites["success_rate"].bitmap.clear
    pbDrawTextPositions(@sprites["success_rate"].bitmap,[["Success Rate: #{getRepelOdds}%",136,360,2,BASE_COLOR,SHADOW_COLOR2]])
    $PokemonSystem.last_pokesearch_settings = [ @current_mon, @current_berry, @current_repel ]
    @sprites["repel_icon"].visible = !@current_repel.nil?
    @sprites["berry_icon"].visible = !@current_berry.nil?
    @sprites["sel_berry"].visible = false
    @sprites["sel_pokemon"].visible = false
    @sprites["sel_repel"].visible = false
    @sprites["sel_search"].visible = false
    @sprites["sel_cancel"].visible = false
    case @index_ver
    when 0
      case @index_hor
      when 0
        @sprites["sel_berry"].visible = true
      when 1
        @sprites["sel_pokemon"].visible = true
      when 2
        @sprites["sel_repel"].visible = true
      end
    when 1
      case @index_hor
      when 0
        @sprites["sel_search"].visible = true
      when 1
        @sprites["sel_cancel"].visible = true
      when 2
        @sprites["sel_cancel"].visible = true
        @index_hor = 1
      end
    end
  end

  # get encounter data
  # again thanks to ThatWelshOne
  def getEncData
    return nil if @encounter_tables.nil?
    arr = []
    min_levels = 0
    max_levels = 0
    enc_array = []
    @encounter_tables[@current_key].each { |s| enc_array.push( GameData::Species.get(s[1]).id ); min_levels+= s[2]; max_levels += s[3] } unless @encounter_tables[@current_key].nil?
    enc_array.uniq!
    average_level = (enc_array.length>0) ? ((min_levels+max_levels)/2)/enc_array.length : 5
    return enc_array, average_level
  end

  # get max encounters
  # again again thanks to ThatWelshOne
  def getMaxEncounters(data)
    keys = data.keys
    a = []
    for key in keys
      b = []
      arr = data[key]
      for i in 0...arr.length
        b.push( arr[i][1] )
      end
      a.push(b.uniq.length)
    end
    return a.max, keys.length
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

class PokeSearch_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    r = @scene.pbPokeSearch
    @scene.pbEndScene
    return r
  end
end

class PokemonSystem
  attr_accessor :last_pokesearch_settings # Array[current_mon, current_berry, current_repel]
  attr_accessor :pokesearch_encounter
  
	def last_pokesearch_settings
    @last_pokesearch_settings = [] if !@last_pokesearch_settings
		return @last_pokesearch_settings
  end

  def pokesearch_encounter
		return @pokesearch_encounter
  end
end