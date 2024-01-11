# The Game module contains methods for saving and loading the game.
module Game
  # Initializes various global variables and loads the game data.
  def self.initialize
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $data_animations    = load_data("Data/Animations.rxdata")
    $data_tilesets      = load_data("Data/Tilesets.rxdata")
    $data_common_events = load_data("Data/CommonEvents.rxdata")
    $data_system        = load_data("Data/System.rxdata")
    pbLoadBattleAnimations
    GameData.load_all
    map_file = sprintf("Data/Map%03d.rxdata", $data_system.start_map_id)
    if $data_system.start_map_id == 0 || !pbRgssExists?(map_file)
      raise _INTL("No starting position was set in the map editor.")
    end
  end

  # Loads bootup data from save file (if it exists) or creates bootup data (if
  # it doesn't).
  def self.set_up_system
    SaveData.move_old_windows_save if System.platform[/Windows/]
    $save_suffix = SaveData.load_last_save
    save_data = (SaveData.exists?) ? SaveData.read_from_file(SaveData::FILE_PATH.gsub(".rxdata","#{$save_suffix}.rxdata")) : {}
    if save_data.empty?
      SaveData.initialize_bootup_values
    else
      SaveData.load_bootup_values(save_data)
    end
    # Set resize factor
    pbSetResizeFactor([$PokemonSystem.screensize, 4].min)
    # Set language (and choose language if there is no save file)
    if Settings::LANGUAGES.length >= 2
      $PokemonSystem.language = pbChooseLanguage if save_data.empty?
      pbLoadMessages("Data/" + Settings::LANGUAGES[$PokemonSystem.language][1])
    end
  end

  # Called when starting a new game. Initializes global variables
  # and transfers the player into the map scene.
  #===============================================================================
  # Fixed the Interpreter not resetting if the game was saved in the middle of an
  # event and then you start a new game.
  #===============================================================================
  def self.start_new
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $game_temp.begun_new_game = true
    pbMapInterpreter&.clear
    pbMapInterpreter&.setup(nil, 0, 0)
    $scene = Scene_Map.new
    SaveData.load_new_game_values
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
  end

  # Called when starting a new game. Initializes global variables
  # and transfers the player into the map scene.
  def self.start_new_plus
    if $game_map&.events
      $game_map.events.each_value { |event| event.clear_starting }
    end
    $game_temp.common_event_id = 0 if $game_temp
    $game_temp.begun_new_game = true
    pbMapInterpreter&.clear
    pbMapInterpreter&.setup(nil, 0, 0)
    $scene = Scene_Map.new
    old_save = SaveData.read_from_file(SaveData::FILE_PATH.gsub(".rxdata","#{$save_suffix}.rxdata"))
    SaveData.load_new_game_values
    $stats.play_sessions += 1
    $map_factory = PokemonMapFactory.new($data_system.start_map_id)
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    $game_player.refresh
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    $game_map.autoplay
    $game_map.update
    $player.name = old_save[:player].name
    $PokemonGlobal.pokedexDex = old_save[:global_metadata].pokedexDex
    $player.trainer_type = old_save[:player].trainer_type
    $player.money = old_save[:player].money
    $player.coins = old_save[:player].coins
    $player.battle_points = old_save[:player].battle_points
    $player.has_box_link = true
    $player.has_pdaplus = true
    $bag.add(:CHIPCLEAR)
    $bag.add(:CHIPRAIN)
    $bag.add(:CHIPSUNNY)
    $bag.add(:CHIPHAIL)
    $bag.add(:CHIPSAND)
    $PokemonGlobal.visitedMaps[209] = true
    $PokemonGlobal.visitedMaps[210] = true
    [:HMEMULATOR, :OLDROD, :GOODROD, :SUPERROD, :BESTROD, :POKEMONBOXLINK,:AUDINITE,:VENUSAURITE,:SCEPTILITE,:CHARIZARDITEX,:CHARIZARDITEY,:BLAZIKENITE,:BLASTOISINITE,:SWAMPERTITE,:MEGABRACELET, :SLEEPINGGEAR, :ACROBIKE, :MACHBIKE, :SHINYCHARM, :OVALCHARM, :CATCHINGCHARM, :EXPCHARM].each { |coi| $bag.add(coi) if old_save[:bag].has?(coi) }
    [64, 75, 80, 82].each {|gs| $game_switches[gs] = true }
    oldPkmn = getAllPokemon(old_save[:player], old_save[:storage_system], old_save[:global_metadata])
    oldPkmn.each do |pkmn|
      next if pkmn.shadowPokemon?
      pkmn.level = [pkmn.level, 5].min
      pkmn.level = 1 if $player.levelone
      prevoSpecies = nil
      until pkmn.species_data.get_previous_species == prevoSpecies
        prevoSpecies = pkmn.species_data.get_previous_species
        pkmn.species = prevoSpecies
      end
      pkmn.item = nil
      pkmn.calc_stats
      pkmn.reset_moves
      pkmn.giveRibbon(:SOUVENIR)
      $PokemonStorage.pbStoreCaught(pkmn)
      $PokemonGlobal.pcItemStorage = PCItemStorage.new
      $PokemonGlobal.mailbox = [Mail.new(:SPACEMAIL, "Congratulations on your New Game+ profile! You will find some special items in your PC Storage!", "New Game+")]
      [[:MAXREPEL,10], [:MASTERBALL, 1], [:RARECANDY, 5], [:ABILITYCAPSULE, 10], [:ABILITYPATCH, 5]].each { |arr| $PokemonGlobal.pcItemStorage.add(arr[0], arr[1]) }
    end
  end

  # Loads the game from the given save data and starts the map scene.
  # @param save_data [Hash] hash containing the save data
  # @raise [SaveData::InvalidValueError] if an invalid value is being loaded
  def self.load(save_data)
    validate save_data => Hash
    SaveData.load_all_values(save_data)
    $stats.play_sessions += 1
    self.load_map
    pbAutoplayOnSave
    $game_map.update
    $PokemonMap.updateMap
    $scene = Scene_Map.new
  end

  # Loads and validates the map. Called when loading a saved game.
  def self.load_map
    $game_map = $map_factory.map
    magic_number_matches = ($game_system.magic_number == $data_system.magic_number)
    if !magic_number_matches || $PokemonGlobal.safesave
      if pbMapInterpreterRunning?
        pbMapInterpreter.setup(nil, 0)
      end
      begin
        $map_factory.setup($game_map.map_id)
      rescue Errno::ENOENT
        if $DEBUG
          pbMessage(_INTL("Map {1} was not found.", $game_map.map_id))
          map = pbWarpToMap
          exit unless map
          $map_factory.setup(map[0])
          $game_player.moveto(map[1], map[2])
        else
          raise _INTL("The map was not found. The game cannot continue.")
        end
      end
      $game_player.center($game_player.x, $game_player.y)
    else
      $map_factory.setMapChanged($game_map.map_id)
    end
    if $game_map.events.nil?
      raise _INTL("The map is corrupt. The game cannot continue.")
    end
    $PokemonEncounters = PokemonEncounters.new
    $PokemonEncounters.setup($game_map.map_id)
    pbUpdateVehicle
  end

  # Saves the game. Returns whether the operation was successful.
  # @param save_file [String] the save file path
  # @param safe [Boolean] whether $PokemonGlobal.safesave should be set to true
  # @return [Boolean] whether the operation was successful
  # @raise [SaveData::InvalidValueError] if an invalid value is being saved
  def self.save(save_file = SaveData::FILE_PATH.gsub(".rxdata","#{$save_suffix}.rxdata"), safe: false)
    validate save_file => String, safe => [TrueClass, FalseClass]
    $PokemonGlobal.safesave = safe
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    $stats.set_time_last_saved
    begin
      SaveData.save_to_file(save_file)
      SaveData.save_last_save
      Graphics.frame_reset
    rescue IOError, SystemCallError
      $game_system.save_count -= 1
      return false
    end
    return true
  end
end
