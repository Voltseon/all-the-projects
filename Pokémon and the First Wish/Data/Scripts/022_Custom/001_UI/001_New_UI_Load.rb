#===============================================================================
#
#===============================================================================
class PokemonLoad_Scene
  BASE_COLOR = Color.new(248,248,248)
  SHADOW_COLOR = Color.new(64,64,64)

  def pbStartScene(trainer, frame_count, stats, map_id, screen)
    @sprites = {}
    @backgroundsprites = {}
    @disposed = false
    @screen = screen
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    if safeExists?("./Graphics/Pictures/lastsave.png")
      RPG::Cache.load_bitmap("Graphics/Pictures/","lastsave.png")
      $PokemonSystem.loadtransition = true
      addBackgroundOrColoredPlane(@backgroundsprites, "background", "lastsave", Color.new(248, 248, 248), @viewport)
    else
      $PokemonSystem.loadtransition = true
      addBackgroundOrColoredPlane(@sprites, "background", "loadbg", Color.new(248, 248, 248), @viewport)
    end
    index = 0
    commands = []
    MenuHandlers.each_available(:load_screen, @screen) do |option, hash, name|
      next if name == nil
      commands.push(name)
      commands.push(hash)
      @sprites[name] = ButtonSprite.new(self,
                                        name,
                                        "Graphics/Pictures/Load Screen/load_button_bg",
                                        "Graphics/Pictures/Load Screen/load_button_bg_highlight",
                                        hash["effect"],
                                        Graphics.width-150, 64+index*50, @viewport)
      @sprites[name].setTextColor(BASE_COLOR, SHADOW_COLOR)
      @sprites[name].setTextOffset(0, 12)
      index += 1
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
    MenuHandlers.each_available(:load_screen, @screen) do |option, hash, name|
      next if name == nil
      break if @disposed
      if @sprites[name].highlighted
        @sprites[name].x = Graphics.width-160
      else
        @sprites[name].x = Graphics.width-150
      end
    end
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@backgroundsprites)
  end

  def screen; @screen; end
  def disposed; @disposed; end

  def pbEndScene
    @disposed = true
    15.times do
      MenuHandlers.each_available(:load_screen, @screen) do |option, hash, name|
        break if !@sprites[name]
        @sprites[name].x += 14
        @sprites[name].update
      end
      Graphics.update
    end
    pbTransparentAndHide(@sprites) { pbUpdate }
    pbFadeOutAndHide(@backgroundsprites) { pbUpdate }# if !$PokemonSystem.loadtransition
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
      @save_data = load_save_file(SaveData::FILE_PATH)
    else
      @save_data = {}
    end
  end

  def savedata; @save_data; end

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
    map_id = !@save_data&.empty? ? @save_data[:map_factory].map.map_id : 0
    @scene.pbStartScene(@save_data[:player], @save_data[:frame_count] || 0, @save_data[:stats], map_id, self)
    @scene.pbStartScene2
    loop do
      @scene.pbUpdate
      Graphics.update
      Input.update
      break if @scene.disposed
    end
    return
  end
end


#===============================================================================
# Load screen commands.
#===============================================================================
MenuHandlers.add(:load_screen, :continue, {
  "name"      => _INTL("Continue"),
  "order"     => 10,
  "condition" => proc { |menu| next !menu.savedata&.empty? },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    menu.pbEndScene
    Game.load(menu.screen.savedata)
  }
})

MenuHandlers.add(:load_screen, :mystery_gift, {
  "name"      => _INTL("Mystery Gift"),
  "order"     => 20,
  "condition" => proc { |menu| next menu.savedata && menu.savedata[:player] && menu.savedata[:player]&.mystery_gift_unlocked },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn { pbDownloadMysteryGift(menu.screen.savedata[:player]) }
  }
})

MenuHandlers.add(:load_screen, :new_game, {
  "name"      => _INTL("New Game"),
  "order"     => 30,
  "effect"    => proc { |menu|
    #$PokemonSystem.loadtransition = true
    pbPlayDecisionSE
    menu.pbEndScene
    Game.start_new
  }
})

MenuHandlers.add(:load_screen, :options, {
  "name"      => _INTL("Options"),
  "order"     => 40,
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn do
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen(true)
    end
  }
})

MenuHandlers.add(:load_screen, :language, {
  "name"      => _INTL("Language"),
  "order"     => 50,
  "condition" => proc { next Settings::LANGUAGES.length >= 2 },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    menu.pbEndScene
    $PokemonSystem.language = pbChooseLanguage
    pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
    if !menu.savedata&.empty?
      menu.savedata[:pokemon_system] = $PokemonSystem
      File.open(SaveData::FILE_PATH, "wb") { |file| Marshal.dump(menu.savedata, file) }
    end
    $scene = pbCallTitle
  }
})

MenuHandlers.add(:load_screen, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 60,
  "condition" => proc { next $DEBUG },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn { pbDebugMenu(false) }
  }
})

MenuHandlers.add(:load_screen, :quit_game, {
  "name"      => _INTL("Quit Game"),
  "order"     => 90,
  "effect"    => proc { |menu|
    pbPlayCloseMenuSE
    menu.pbEndScene
    $scene = nil
  }
})