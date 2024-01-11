#===============================================================================
#
#===============================================================================
class PokemonLoadPanel < Sprite
  attr_reader :selected

  TEXTCOLOR             = Color.new(70,70,70)
  TEXTSHADOWCOLOR       = Color.new(136, 136, 136)
  MALETEXTCOLOR         = Color.new(56, 160, 248)
  MALETEXTSHADOWCOLOR   = Color.new(56, 104, 168)
  FEMALETEXTCOLOR       = Color.new(240, 72, 88)
  FEMALETEXTSHADOWCOLOR = Color.new(160, 64, 64)

  def initialize(index, title, isContinue, trainer, framecount, stats, mapid, viewport = nil)
    super(viewport)
    @index = index
    @title = title
    @isContinue = isContinue
    @trainer = trainer
    @totalsec = (framecount || 0) / Graphics.frame_rate
    @mapid = mapid
    @selected = (index == 0)
    @bgbitmap = AnimatedBitmap.new("Graphics/Pictures/loadPanels")
    @refreshBitmap = true
    @refreshing = false
    refresh
  end

  def mapid
    return @mapid
  end

  def dispose
    @bgbitmap.dispose
    self.bitmap.dispose
    super
  end

  def selected=(value)
    return if @selected == value
    @selected = value
    @refreshBitmap = true
    refresh
  end

  def pbRefresh
    @refreshBitmap = true
    refresh
  end

  def refresh
    return if @refreshing
    return if disposed?
    @refreshing = true
    if !self.bitmap || self.bitmap.disposed?
      self.bitmap = BitmapWrapper.new(@bgbitmap.width, 222)
      pbSetSystemFont(self.bitmap)
    end
    if @refreshBitmap
      @refreshBitmap = false
      self.bitmap&.clear
      self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, 444 + ((@selected) ? 46 : 0), @bgbitmap.width, 46))
      #if @isContinue
        #self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, (@selected) ? 222 : 0, @bgbitmap.width, 222))
      #else
        #self.bitmap.blt(0, 0, @bgbitmap.bitmap, Rect.new(0, 444 + ((@selected) ? 46 : 0), @bgbitmap.width, 46))
      #end
      textpos = []
      textpos.push([@title, 410, 12, 2, TEXTCOLOR, TEXTSHADOWCOLOR])
      pbDrawTextPositions(self.bitmap, textpos)
    end
    @refreshing = false
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene
  TEXTCOLOR             = PokemonLoadPanel::TEXTCOLOR
  TEXTSHADOWCOLOR       = PokemonLoadPanel::TEXTSHADOWCOLOR
  MALETEXTCOLOR         = PokemonLoadPanel::MALETEXTCOLOR
  MALETEXTSHADOWCOLOR   = PokemonLoadPanel::MALETEXTSHADOWCOLOR
  FEMALETEXTCOLOR       = PokemonLoadPanel::FEMALETEXTCOLOR
  FEMALETEXTSHADOWCOLOR = PokemonLoadPanel::FEMALETEXTSHADOWCOLOR

  def pbStartScene(commands, show_continue, trainer, frame_count, stats, map_id)
    @commands = commands
    @sprites = {}
    @backgroundsprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    @totalsec = (frame_count || 0) / Graphics.frame_rate
    if safeExists?("./Graphics/Pictures/lastsave#{$save_suffix}.png")
      RPG::Cache.load_bitmap("Graphics/Pictures/","lastsave#{$save_suffix}.png")
      $PokemonSystem.loadtransition = true
      addBackgroundOrColoredPlane(@backgroundsprites, "background", "lastsave#{$save_suffix}", Color.new(248, 248, 248), @viewport)
    else
      $PokemonSystem.loadtransition = false
      addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
    end
    y = 80
    y += 24 if commands.length == 4
    commands.length.times do |i|
      @sprites["panel#{i}"] = PokemonLoadPanel.new(
        i, commands[i], (show_continue) ? (i == 0) : false, trainer,
        frame_count, stats, map_id, @viewport
      )
      @sprites["panel#{i}"].x = 0
      @sprites["panel#{i}"].y = y
      @sprites["panel#{i}"].pbRefresh
      y += 48
    end
    @sprites["partywindow"] = IconSprite.new(0,0, @viewport)
    @sprites["partywindow"].setBitmap("Graphics/Pictures/loadPartyBox")
    @sprites["partywindow"].viewport = @viewport
    @sprites["partywindow"].visible  = show_continue && (trainer.party.length > 0)
    @sprites["infowindow"] = IconSprite.new(0,0, @viewport)
    @sprites["infowindow"].setBitmap("Graphics/Pictures/loadInfoBox")
    @sprites["infowindow"].viewport = @viewport
    @sprites["infowindow"].visible  = show_continue
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible  = false
    
    if show_continue
      textpos = []
      textpos.push([_INTL("Badges:"), 16, 250, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      textpos.push([trainer.badge_count.to_s, 178, 250, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      textpos.push([_INTL("Pokédex:"), 16, 282, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      textpos.push([trainer.pokedex.seen_count.to_s, 178, 282, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      textpos.push([_INTL("Time:"), 16, 314, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      hour = @totalsec / 60 / 60
      min  = @totalsec / 60 % 60
      if hour > 0
        textpos.push([_INTL("{1}h {2}m", hour, min), 178, 314, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      else
        textpos.push([_INTL("{1}m", min), 178, 314, 1, TEXTCOLOR, TEXTSHADOWCOLOR])
      end
      if trainer.male?
        textpos.push([trainer.name, 16, 218, 0, MALETEXTCOLOR, MALETEXTSHADOWCOLOR])
      elsif trainer.female?
        textpos.push([trainer.name, 16, 218, 0, FEMALETEXTCOLOR, FEMALETEXTSHADOWCOLOR])
      else
        textpos.push([trainer.name, 16, 218, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      end
      mapname = pbGetMapNameFromId(@sprites["panel0"].mapid)
      mapname.gsub!(/\\PN/, trainer.name)
      textpos.push([mapname, 16, 354, 0, TEXTCOLOR, TEXTSHADOWCOLOR])
      pbSetSystemFont(@sprites["infowindow"].bitmap)
      pbDrawTextPositions(@sprites["infowindow"].bitmap, textpos)
    end
  end

  def pbStartScene2(backgroundinstant = false)
    if backgroundinstant
      pbTransparentAndShow([@sprites, {}]) { pbUpdate }
    else
      pbTransparentAndShow([@backgroundsprites, @sprites]) { pbUpdate }
    end
  end

  def pbStartDeleteScene
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
  end

  def pbUpdate
    oldi = @sprites["cmdwindow"].index rescue 0
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@backgroundsprites)
    newi = @sprites["cmdwindow"].index rescue 0
    if oldi != newi
      @sprites["panel#{oldi}"].selected = false
      @sprites["panel#{oldi}"].pbRefresh
      @sprites["panel#{newi}"].selected = true
      @sprites["panel#{newi}"].pbRefresh
      while @sprites["panel#{newi}"].y > Graphics.height - 80
        @commands.length.times do |i|
          @sprites["panel#{i}"].y -= 48
        end
        #6.times do |i|
          #break if !@sprites["party#{i}"]
          #@sprites["party#{i}"].y -= 48
        #end
        @sprites["player"].y -= 48 if @sprites["player"]
      end
      while @sprites["panel#{newi}"].y < 32
        @commands.length.times do |i|
          @sprites["panel#{i}"].y += 48
        end
        #6.times do |i|
          #break if !@sprites["party#{i}"]
          #@sprites["party#{i}"].y += 48
        #end
        @sprites["player"].y += 48 if @sprites["player"]
      end
    end
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta = GameData::PlayerMetadata.get(trainer.character_ID)
=begin    
    if meta
      filename = pbGetPlayerCharset(meta.walk_charset, trainer, true)
      @sprites["player"] = TrainerWalkingCharSprite.new(filename, @viewport)
      charwidth  = @sprites["player"].bitmap.width
      charheight = @sprites["player"].bitmap.height
      @sprites["player"].x        = 112 - (charwidth / 8)
      @sprites["player"].y        = 112 - (charheight / 8)
      @sprites["player"].src_rect = Rect.new(0, 0, charwidth / 4, charheight / 4)
    end
=end
    trainer.party.each_with_index do |pkmn, i|
      @sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @viewport)
      @sprites["party#{i}"].setOffset(PictureOrigin::TOP_LEFT)
      @sprites["party#{i}"].x = 60 + (66 * i)
      @sprites["party#{i}"].y = -4
      @sprites["party#{i}"].z = 99999
    end
  end

  def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::USE)
        return @sprites["cmdwindow"].index
      end
    end
  end

  def pbEndScene
    if $PokemonSystem.loadtransition
      15.times do
        6.times do |i|
          break if !@sprites["party#{i}"]
          @sprites["party#{i}"].y -= 6
        end
        @sprites["partywindow"].y -= 6
        @commands.length.times do |i|
          @sprites["panel#{i}"].x += 14
        end
        @sprites["infowindow"].x -= 14
        Graphics.update
      end
    end
    pbTransparentAndHide(@sprites) { pbUpdate }
    pbFadeOutAndHide(@backgroundsprites) { pbUpdate } if !$PokemonSystem.loadtransition
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@backgroundsprites)
    @viewport.dispose
  end

  def pbCloseScene
    pbDisposeSpriteHash(@sprites)
    pbDisposeSpriteHash(@backgroundsprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonLoadScreen
  def initialize(scene)
    @scene = scene
    if SaveData.exists?
      @save_data = load_save_file(SaveData::FILE_PATH.gsub(".rxdata","#{$save_suffix}.rxdata"))
    else
      @save_data = {}
    end
  end

  # @param file_path [String] file to load save data from
  # @return [Hash] save data
  def load_save_file(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
      if File.file?(file_path + ".bak")
        pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
        save_data = load_save_file(file_path + ".bak")
      else
        self.prompt_save_deletion
        return {}
      end
    end
    return save_data
  end

  # Called if all save data is invalid.
  # Prompts the player to delete the save files.
  def prompt_save_deletion
    pbMessage(_INTL("The save file is corrupt, or is incompatible with this game."))
    exit unless pbConfirmMessageSerious(
      _INTL("Do you want to delete the save file and start anew?")
    )
    self.delete_save_data
    $game_system   = Game_System.new
    $PokemonSystem = PokemonSystem.new
  end

  def pbStartDeleteScreen
    @scene.pbStartDeleteScene
    @scene.pbStartScene2
    if SaveData.exists?
      if pbConfirmMessageSerious(_INTL("Delete all saved data?"))
        pbMessage(_INTL("Once data has been deleted, there is no way to recover it.\1"))
        if pbConfirmMessageSerious(_INTL("Delete the saved data anyway?"))
          pbMessage(_INTL("Deleting all data. Don't turn off the power.\\wtnp[0]"))
          self.delete_save_data
        end
      end
    else
      pbMessage(_INTL("No save file was found."))
    end
    @scene.pbEndScene
    $scene = pbCallTitle
  end

  def delete_save_data
    begin
      SaveData.delete_file
      pbMessage(_INTL("The saved data was deleted."))
    rescue SystemCallError
      pbMessage(_INTL("All saved data could not be deleted."))
    end
  end

  def pbStartLoadScreen
    commands = []
    cmd_continue     = -1
    cmd_load_game    = -1
    cmd_new_game     = -1
    cmd_options      = -1
    cmd_language     = -1
    cmd_mystery_gift = -1
    cmd_debug        = -1
    cmd_discord      = -1
    cmd_quit         = -1
    show_continue = !@save_data.empty?
    if show_continue
      commands[cmd_continue = commands.length] = _INTL("Continue")
      if @save_data[:player].mystery_gift_unlocked
        commands[cmd_mystery_gift = commands.length] = _INTL("Mystery Gift")
      end
    end
    commands[cmd_load_game = commands.length] = _INTL("Load Game") if show_continue
    commands[cmd_new_game = commands.length]  = _INTL("New Game") if !show_continue
    commands[cmd_options = commands.length]   = _INTL("Options")
    commands[cmd_language = commands.length]  = _INTL("Language") if Settings::LANGUAGES.length >= 2
    commands[cmd_debug = commands.length]     = _INTL("Debug") if $DEBUG
    commands[cmd_discord = commands.length]     = _INTL("Discord")
    commands[cmd_quit = commands.length]      = _INTL("Quit Game")
    map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
    pbCallSaul(commands, show_continue, map_id)
    loop do
      command = @scene.pbChoose(commands)
      pbPlayDecisionSE if command != cmd_quit
      case command
      when cmd_continue
        @scene.pbEndScene
        Game.load(@save_data)
        return
      when cmd_load_game
        $PokemonSystem.loadtransition = false
        pbFadeOutIn {
          @scene.pbCloseScene
          scene = MultipleSaves_Scene.new
          screen = MultipleSaves.new(scene)
          save_to_load = screen.pbStartScreen
          case save_to_load[0]
          when :debug
            saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game debug.rxdata" : ".Game debug.rxdata")
            if save_to_load[1] == 1
              @save_data = load_save_file(saveloc)
              Game.load(@save_data)
            else
              $PokemonSystem.loadtransition = false
              Game.start_new
            end
            return
          when :new
            case save_to_load[1]
            when 0
              saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game.rxdata" : ".Game.rxdata")
              $PokemonSystem.loadtransition = false
              Game.start_new
              return
            else
              saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game#{save_to_load[1]}.rxdata" : ".Game#{save_to_load[1]}.rxdata")
              $PokemonSystem.loadtransition = false
              Game.start_new
              return
            end
          when :new_plus
            case save_to_load[1]
            when 0
              saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game.rxdata" : ".Game.rxdata")
              $PokemonSystem.loadtransition = false
              Game.start_new_plus
              return
            else
              saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game#{save_to_load[1]}.rxdata" : ".Game#{save_to_load[1]}.rxdata")
              $PokemonSystem.loadtransition = false
              Game.start_new_plus
              return
            end
          else
            case save_to_load[1]
            when -1
            when 0
              saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game.rxdata" : ".Game.rxdata")
              @save_data = load_save_file(saveloc)
              Game.load(@save_data)
              return
            else
              saveloc = ((File.directory?(System.data_directory)) ? System.data_directory + "Game#{save_to_load[1]}.rxdata" : ".Game#{save_to_load[1]}.rxdata")
              @save_data = load_save_file(saveloc)
              Game.load(@save_data)
              return
            end
          end
          if SaveData.exists?
            @save_data = load_save_file(SaveData::FILE_PATH.gsub(".rxdata","#{$save_suffix}.rxdata"))
          else
            @save_data = {}
          end
          commands.delete(0) if show_continue && @save_data.empty?
          show_continue = !@save_data.empty?
          map_id = show_continue ? @save_data[:map_factory].map.map_id : 0
          pbCallSaul(commands, show_continue, map_id, true)
        }
      when cmd_new_game
        $PokemonSystem.loadtransition = false
        @scene.pbEndScene
        Game.start_new
        return
      when cmd_mystery_gift
        pbFadeOutIn { pbDownloadMysteryGift(@save_data[:player]) }
      when cmd_options
        pbFadeOutIn do
          scene = PokemonOption_Scene.new
          screen = PokemonOptionScreen.new(scene)
          screen.pbStartScreen(true)
        end
      when cmd_language
        @scene.pbEndScene
        $PokemonSystem.language = pbChooseLanguage
        pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
        if show_continue
          @save_data[:pokemon_system] = $PokemonSystem
          File.open(SaveData::FILE_PATH.gsub(".rxdata","#{$save_suffix}.rxdata"), "wb") { |file| Marshal.dump(@save_data, file) }
        end
        $scene = pbCallTitle
        return
      when cmd_debug
        pbFadeOutIn { pbDebugMenu(false) }
      when cmd_discord
        System.launch("https://discord.gg/rUq5FY5U6Z")
      when cmd_quit
        pbPlayCloseMenuSE
        @scene.pbEndScene
        $scene = nil
        return
      else
        pbPlayBuzzerSE
      end
    end
  end

  def pbCallSaul(commands, show_continue, map_id, backgroundinstant = false)
    @scene.pbStartScene(commands, show_continue, @save_data[:player],
      @save_data[:frame_count] || 0, @save_data[:stats], map_id)
    @scene.pbSetParty(@save_data[:player]) if show_continue
    @scene.pbStartScene2(backgroundinstant)
  end
end

class MultipleSaves_Scene
  MAX_SAVES = 2

  def initialize
    @returnval = [-1,-1]
    @index = indexFromString
    @commandsel = 0
    @sprites = {}
    setupSaveStuff
  end

  def pbStartScene
    # Viewport
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/" + lastsave(@index))
    drawSaulMenu
    # Start scene
    pbUpdate
    pbTransparentAndShow([{}, @sprites]) { pbUpdate }
  end

  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    meta = GameData::PlayerMetadata.get(trainer.character_ID)
    trainer.party.each_with_index do |pkmn, i|
      @sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @viewport)
      @sprites["party#{i}"].setOffset(PictureOrigin::TOP_LEFT)
      @sprites["party#{i}"].x = 60 + (66 * i)
      @sprites["party#{i}"].y = -4
      @sprites["party#{i}"].z = 99999
    end
  end

  def setupSaveStuff(refresh=true)
    refreshSaves if refresh
    if @save[@index] == {} || @save[@index].nil?
      @trainer = nil
      @frame_count = 0
      @stats = nil
      @map_id = 0
      @save_beaten = false
      @commands = ["New Game", "Cancel"]
    else
      @trainer = @save[@index][:player] || nil
      @frame_count = @save[@index][:frame_count] || 0
      @stats = @save[@index][:stats] || nil
      @map_id = @save[@index][:map_factory].map.map_id || 0
      @save_beaten = @save[@index][:switches][12]
      @commands = ["Continue"]
      @commands.push("New Game+") if @save_beaten || @index == MAX_SAVES+1
      @commands.push("Rename") unless @index == MAX_SAVES+1
      @commands += ["Delete", "Cancel"]
    end
  end

  def refreshSaves
    @save = [{}] * (MAX_SAVES + ($DEBUG ? 1 : 0))
    (MAX_SAVES + ($DEBUG ? 2 : 1)).times do |i|
      if checksave(i)
        @save[i] = load_save_file(savepath(i))
      else
        @save[i] = {}
      end
    end
  end

  def pbMain
    loop do
      # Generic update loop
      Graphics.update
      Input.update
      pbUpdate
      # Check player input
      if Input.trigger?(Input::LEFT) && @index > 0
        pbPlayCursorSE
        @index -= 1
        redraw
      elsif Input.trigger?(Input::RIGHT) && @index < MAX_SAVES + ($DEBUG ? 1 : 0)
        pbPlayCursorSE
        @index += 1
        redraw
      elsif Input.trigger?(Input::UP) && @commandsel > 0
        pbPlayCursorSE
        @commandsel -= 1
        changecommandsel
      elsif Input.trigger?(Input::DOWN) && @commandsel < @commands.length-1
        pbPlayCursorSE
        @commandsel += 1
        changecommandsel
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        if @commandsel == 0
          isDebug = ((@index == MAX_SAVES+1) ? :debug : checksave(@index) ? :load : :new)
          val2 = (checksave(MAX_SAVES+1) && isDebug == :debug ? 1 : @index)
          @returnval = [isDebug, val2]
          break
        else
          case @commands[@commandsel]
          when "Rename"
            oldsprites = pbFadeOutAndHide(@sprites) { pbUpdate }
            ret = pbEnterBoxName("Rename Save File", 1, 12, pbGetFileName)
            if ret.length > 0
              @trainer.save_file_name = ret
            end
            $TempFileName = ret
            pbMessage(_INTL("Save File renamed successfully. Open the game and click Save to ensure the changes are saved."))
            redraw
            pbFadeInAndShow(@sprites, oldsprites)
          when "Delete"
            if pbConfirmMessageSerious(_INTL("Are you sure you would like to delete this save file?"))
              begin
                SaveData.delete_file
                pbMessage(_INTL("The saved data was deleted."))
                File.delete("Graphics/Pictures/lastsave#{$save_suffix}.png") if safeExists?("Graphics/Pictures/lastsave#{$save_suffix}.png")
                setupSaveStuff
                resetlastsave
              rescue SystemCallError
                pbMessage(_INTL("The saved data could not be deleted."))
              end
              redraw
            end
          when "New Game+"
            @returnval = [:new_plus, @index]
            break
          when "Cancel"
            @returnval = [-1, -1]
            break
          end
        end
      elsif Input.trigger?(Input::BACK)
        @returnval = [-1,-1]
        pbPlayCloseMenuSE
        break
      end
    end
  end

  def changecommandsel
    10.times do |i|
      next unless @sprites["panel#{i}"]
      @sprites["panel#{i}"].selected = i == @commandsel
    end
  end

  def redraw
    @sprites["bg"].setBitmap("Graphics/Pictures/" + lastsave(@index))
    save_suffix
    setupSaveStuff(false)
    drawSaulMenu
    @commandsel = @commands.length-1 if @commandsel >= @commands.length
    changecommandsel
  end

  def resetlastsave
    File.delete(System.data_directory + "LastSave.rxdata") if safeExists?(System.data_directory + "LastSave.rxdata")
=begin
    MAX_SAVES+1.times do |i|
      next unless checksave(i)
      File.open(System.data_directory + "LastSave.rxdata", "wb") { |file| Marshal.dump("#{i}", file) }
    end
=end
  end

  def indexFromString
    case $save_suffix
    when " debug" then return MAX_SAVES+1
    when "", nil then return 0
    else return $save_suffix.to_i
    end
  end

  def savepath(suffix="")
    suffix = "" if suffix == 0
    suffix = " debug" if suffix == MAX_SAVES+1
    return (File.directory?(System.data_directory)) ? System.data_directory + "Game#{suffix}.rxdata" : ".Game#{suffix}.rxdata"
  end

  def checksave(suffix="")
    suffix = "" if suffix == 0
    suffix = " debug" if suffix == MAX_SAVES+1
    return safeExists?((File.directory?(System.data_directory)) ? System.data_directory + "Game#{suffix}.rxdata" : ".Game#{suffix}.rxdata")
  end

  def lastsave(suffix="")
    suffix = "" if suffix == 0
    suffix = " debug" if suffix == MAX_SAVES+1
    if safeExists?("./Graphics/Pictures/lastsave#{suffix}.png")
      return "lastsave#{suffix}"
    else
      return "loadbg"
    end
  end

  def drawSaulMenu
    # Cool animation
    @totalsec = (@frame_count || 0) / Graphics.frame_rate
    y = 80
    y += 24 if @commands.length == 4
    10.times { |i| @sprites["panel#{i}"].dispose if @sprites["panel#{i}"] }
    @commands.length.times do |i|
      @sprites["panel#{i}"] = PokemonLoadPanel.new(
        i, @commands[i], i == 0, @trainer,
        @frame_count, @stats, @map_id, @viewport
      )
      @sprites["panel#{i}"].x = 0
      @sprites["panel#{i}"].y = y
      @sprites["panel#{i}"].pbRefresh
      y += 48
    end
    showSaveInfo = (@save[@index] != {} && !@save[@index].nil?)
    6.times do |i|
      @sprites["party#{i}"].dispose if @sprites["party#{i}"]
    end
    pbSetParty(@save[@index][:player]) if showSaveInfo
    @sprites["partywindow"].dispose if @sprites["partywindow"]
    @sprites["partywindow"] = IconSprite.new(0,0, @viewport) if showSaveInfo
    @sprites["partywindow"].setBitmap("Graphics/Pictures/loadPartyBox") if showSaveInfo
    @sprites["partywindow"].viewport = @viewport if showSaveInfo
    #@sprites["partywindow"].visible = !@trainer.nil? && @trainer.party.count > 0 if @sprites["partywindow"]
    @sprites["infowindow"].dispose if @sprites["infowindow"]
    @sprites["infowindow"] = IconSprite.new(0,0, @viewport) if showSaveInfo
    @sprites["infowindow"].setBitmap("Graphics/Pictures/loadInfoBox") if showSaveInfo
    @sprites["infowindow"].viewport = @viewport if showSaveInfo
    @sprites["savewindow"].dispose if @sprites["savewindow"]
    @sprites["savewindow"] = IconSprite.new(0,0, @viewport)
    @sprites["savewindow"].setBitmap("Graphics/Pictures/loadSaveName")
    @sprites["savewindow"].viewport = @viewport
    @sprites["cmdwindow"].dispose if @sprites["cmdwindow"]
    @sprites["cmdwindow"] = Window_CommandPokemon.new([])
    @sprites["cmdwindow"].viewport = @viewport
    @sprites["cmdwindow"].visible  = false
    @sprites["leftarrow"].dispose if @sprites["leftarrow"]
    @sprites["leftarrow"] = AnimatedSprite.new("Graphics/Pictures/leftarrow", 8, 40, 28, 2, @viewport)
    @sprites["leftarrow"].x       = 6
    @sprites["leftarrow"].y       = 16
    @sprites["leftarrow"].visible = (@index > 0)
    @sprites["leftarrow"].play
    @sprites["rightarrow"].dispose if @sprites["rightarrow"]
    @sprites["rightarrow"] = AnimatedSprite.new("Graphics/Pictures/rightarrow", 8, 40, 28, 2, @viewport)
    @sprites["rightarrow"].x       = 464
    @sprites["rightarrow"].y       = 16
    @sprites["rightarrow"].visible = (@index < MAX_SAVES + ($DEBUG ? 1 : 0))
    @sprites["rightarrow"].play
    textpos = []
    textpos.push(["#{pbGetFileName}", 412, 350, 2, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
    pbSetSystemFont(@sprites["savewindow"].bitmap)
    pbDrawTextPositions(@sprites["savewindow"].bitmap, textpos)
    if showSaveInfo
      textpos = []
      textpos.push([_INTL("Badges:"), 16, 250, 0, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      textpos.push([@trainer.badge_count.to_s, 178, 250, 1, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      textpos.push([_INTL("Pokédex:"), 16, 282, 0, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      textpos.push([@trainer.pokedex.seen_count.to_s, 178, 282, 1, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      textpos.push([_INTL("Time:"), 16, 314, 0, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      hour = @totalsec / 60 / 60
      min  = @totalsec / 60 % 60
      if hour > 0
        textpos.push([_INTL("{1}h {2}m", hour, min), 178, 314, 1, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      else
        textpos.push([_INTL("{1}m", min), 178, 314, 1, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      end
      if @trainer.male?
        textpos.push([@trainer.name, 16, 218, 0, PokemonLoad_Scene::MALETEXTCOLOR, PokemonLoad_Scene::MALETEXTSHADOWCOLOR])
      elsif @trainer.female?
        textpos.push([@trainer.name, 16, 218, 0, PokemonLoad_Scene::FEMALETEXTCOLOR, PokemonLoad_Scene::FEMALETEXTSHADOWCOLOR])
      else
        textpos.push([@trainer.name, 16, 218, 0, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      end
      mapname = pbGetMapNameFromId(@sprites["panel0"].mapid)
      mapname.gsub!(/\\PN/, @trainer.name)
      textpos.push([mapname, 16, 354, 0, PokemonLoad_Scene::TEXTCOLOR, PokemonLoad_Scene::TEXTSHADOWCOLOR])
      pbSetSystemFont(@sprites["infowindow"].bitmap)
      pbDrawTextPositions(@sprites["infowindow"].bitmap, textpos)
    end
  end
  
  def pbGetFileName
    return "Debug" if @index == MAX_SAVES+1
    return "File #{@index+1}" if !@trainer || nil_or_empty?(@trainer.save_file_name)
    return @trainer.save_file_name
  end

  def save_suffix
    suffix = "#{@index}"
    suffix = "" if @index == 0
    suffix = " debug" if @index == MAX_SAVES+1
    $save_suffix = suffix
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    suffix = ""
    suffix = "" if suffix == 0
    suffix = " debug" if suffix == MAX_SAVES+1
    pbFadeOutAndHide(@sprites) { pbUpdate } unless (safeExists?("./Graphics/Pictures/lastsave#{suffix}.png") && @commandsel==0)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    return @returnval
  end

  def load_save_file(file_path)
    return {} unless safeExists?(file_path)
    save_data = SaveData.read_from_file(file_path)
    unless SaveData.valid?(save_data)
      if File.file?(file_path + ".bak")
        pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
        save_data = load_save_file(file_path + ".bak")
      else
        self.prompt_save_deletion
        return {}
      end
    end
    return save_data
  end
end

class MultipleSaves
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbMain
    return @scene.pbEndScene
  end
end