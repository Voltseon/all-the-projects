#-------------------------------------------------------------------------------
# PokéSearch v1.0
# Find your perfect encounter with style 😎
#-------------------------------------------------------------------------------
#
# Based on UI-Encounters by ThatWelshOne
# 
#-------------------------------------------------------------------------------
#
# Call the UI with:
#
# scene = PokeSearch_Scene.new
# screen = PokeSearch_Screen.new(scene)
# screen.pbStartScreen
#
#-------------------------------------------------------------------------------
class PokeSearch_Scene
  ITEMTEXTBASECOLOR    = Color.new(248,248,248)
  ITEMTEXTSHADOWCOLOR  = Color.new(81,34,6)

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
    @current_key = 0
    #@current_key = 6 if ($PokemonGlobal.escapePoint rescue false) && $PokemonGlobal.escapePoint.length>0
    #@current_key = 12 if $PokemonGlobal.surfing
    @current_mon = nil
    @current_berry = nil
    @current_repel = nil
    @average_level = 1
    @disposed = false
  end

  # draw scene elements
  def pbStartScene
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/bg"))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["sel_berry"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_berry"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_small"))
    @sprites["sel_berry"].x = 96
    @sprites["sel_berry"].y = 96
    @sprites["sel_berry"].visible = false
    @sprites["sel_repel"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_repel"].setBitmap(sprintf("Graphics/Pictures/PokeSearch/sel_small"))
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
    @sprites["berry_text"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["berry_text"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["berry_text"].visible     = true
    @sprites["berry_text"].windowskin  = nil
    @sprites["berry_text"].text = "Add a berry to this slot in order to gain a secondary effect."
    @sprites["repel_icon"] = ItemIconSprite.new(388,124,nil,@viewport)
    @sprites["repel_text"] = Window_UnformattedTextPokemon.newWithSize("",257, 155, 236, 174, @viewport)
    @sprites["repel_text"].baseColor   = ITEMTEXTBASECOLOR
    @sprites["repel_text"].shadowColor = ITEMTEXTSHADOWCOLOR
    @sprites["repel_text"].visible     = true
    @sprites["repel_text"].windowskin  = nil
    @sprites["repel_text"].text = "Add a repel to this slot in order to increase the encounter odds."
    @sprites["berry_icon"].visible = false
    @sprites["repel_icon"].visible = false
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
              startSearch
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
    end
  end

  # selecting the correct berry
  def selectBerry
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$PokemonBag)
      berry = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item).is_berry? || GameData::Item.get(item) == :GOLDBERRY })
      @sprites["berry_icon"].item = berry
      if berry
        @sprites["berry_text"].text = description(berry)
        @sprites["berry_icon"].visible = true
      else
        @sprites["berry_text"].text = "Add a berry to this slot in order to gain a secondary effect."
      end
      @current_berry = berry
    }
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
    when :LUMBERRY
      return _INTL("Lum Berries increase the odds of hidden ability encounters.")
    when :CHESTOBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY, :PERSIMBERRY, :EMONBERRY, :ASPEARBERRY
      return _INTL("{1} increase the odds of Pokérus encounters.",GameData::Item.get(item).name_plural)
    when :ORANBERRY
      return _INTL("Oran Berries slightly increase the IVs of encounters.")
    when :SITRUSBERRY
      return _INTL("Sitrus Berries significantly increase the IVs of encounters.")
    when :LEPPABERRY
      return _INTL("Leppa Berries lower the level of encounters.")
    when :GOLDBERRY
      return _INTL("Gold Berries increase the odds of shiny encounters.")
    else
      return _INTL("{1} increase the level of encounters.",GameData::Item.get(item).name_plural)
    end
  end

  # selecting mons based on the encounter table
  def selectMon
    commands = []
    mons = []
    if getEncData != nil
      command_list = getEncData[0]
      @average_level = getEncData[1]
    end
    if command_list != nil
      command_list.each { |mon| mons.push(mon)}
      mons.each { |thismon| commands.push(GameData::Species.get(thismon).name)}
    end
    commands.push("Cancel")
    command = pbShowCommands(nil,commands,commands.length)
    @current_mon = nil
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    if commands[command] != "Cancel"
      pbDrawTextPositions(overlay,[[commands[command],Graphics.width/2,100,2,ITEMTEXTBASECOLOR,ITEMTEXTSHADOWCOLOR]])
      @current_mon = mons[command]
    end
  end

  # selecting repels
  def selectRepel
    pbFadeOutIn {
      scene = PokemonBag_Scene.new
      screen = PokemonBagScreen.new(scene,$PokemonBag)
      repel = screen.pbChooseItemScreen(Proc.new { |item| GameData::Item.get(item) == :REPEL || GameData::Item.get(item) == :SUPERREPEL || GameData::Item.get(item) == :MAXREPEL })
      @sprites["repel_icon"].item = repel
      if repel
        @sprites["repel_text"].text = description(repel)
        @sprites["repel_icon"].visible = true
      else
        @sprites["repel_text"].text = "Add a repel to this slot in order to increase the encounter odds."
      end
      @current_repel = repel
    }
  end

  # checks all of the current parameters and initiates a battle if successful
  def startSearch
    if @current_mon == nil
      pbPlayBuzzerSE()
      pbMessage("Select a Pokémon in order to scan.")
      return
    end
    if !$PokemonEncounters.encounter_possible_here?
      pbPlayBuzzerSE()
      pbMessage("Can only scan when standing in an area where you can get encounters.")
      return
    end
    level = @average_level + rand(-2..2)
    if @current_berry == :LEPPABERRY
      level = [level-3,1].max
    elsif @current_berry != nil && ![:CHESTOBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY, :PERSIMBERRY, :EMONBERRY, :ASPEARBERRY, :LUMBERRY, :ORANBERRY, :SITRUSBERRY, :GOLDBERRY].include?(@current_berry)
      level = [level+3,100].min
    end
    $PokemonSystem.current_berry = @current_berry
    $PokemonSystem.pokesearch_encounter = true
    odds = rand(0..100) < getRepelOdds
    if @current_repel != nil
      $PokemonBag.pbDeleteItem(@current_repel)
      @current_repel = nil
    end
    if @current_berry != nil
      $PokemonBag.pbDeleteItem(@current_berry)
      @current_berry = nil
    end
    pbEndScene
    waitingMessage = "\\se[Battle ball shake]...\\. \\se[Battle ball shake]...\\. \\se[Battle ball shake]...\\| "
    finalMessage = ""
    for i in 0..rand(1,2); finalMessage += waitingMessage; end
    pbMessage(_INTL("{1}\\wtnp[2]", finalMessage))
    if odds
      $scene.spriteset.addUserAnimation(Settings::EXCLAMATION_ANIMATION_ID,$game_player.x,$game_player.y-1,true,3)
      pbWait(20)
      pbWildBattle(@current_mon, level)
    else
      pbMessage("No Pokémon appeared.")
    end
    $PokemonSystem.current_berry = nil
    $PokemonSystem.pokesearch_encounter = false
  end

  # in percentages
  def getRepelOdds
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
    return nil if @encounter_tables == nil
    currKey = @encounter_tables.keys[@current_key]
    arr = []
    min_levels = 0
    max_levels = 0
    enc_array = []
    @encounter_tables[currKey].each { |s| arr.push( s[1] ); min_levels+= s[2]; max_levels += s[3] }
    GameData::Species.each { |s| enc_array.push(s.id) if arr.include?(s.id) } # From Maruno
    enc_array.uniq!
    average_level = ((min_levels+max_levels)/2)/arr.length
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
    @scene.pbPokeSearch
    @scene.pbEndScene
  end
end

class PokemonSystem
  attr_writer :current_berry
  attr_writer :pokesearch_encounter
  
	def current_berry
		return @current_berry
  end

  def pokesearch_encounter
		return @pokesearch_encounter
  end
end