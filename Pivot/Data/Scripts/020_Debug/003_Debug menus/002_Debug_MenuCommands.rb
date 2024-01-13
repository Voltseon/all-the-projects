#===============================================================================
# Field options
#===============================================================================
ListHandlers.add(:debug_menu, :field_menu, {
  "name"        => _INTL("Field Options..."),
  "parent"      => :main,
  "description" => _INTL("Warp to maps, edit switches/variables, use the PC, edit Day Care, etc."),
  "always_show" => false
})

ListHandlers.add(:debug_menu, :warp, {
  "name"        => _INTL("Warp to Map"),
  "parent"      => :field_menu,
  "description" => _INTL("Instantly warp to another map of your choice."),
  "effect"      => proc { |sprites, viewport|
    map = pbWarpToMap
    next false if !map
    pbFadeOutAndHide(sprites)
    pbDisposeMessageWindow(sprites["textbox"])
    pbDisposeSpriteHash(sprites)
    viewport.dispose
    if $scene.is_a?(Scene_Map)
      $game_temp.player_new_map_id    = map[0]
      $game_temp.player_new_x         = map[1]
      $game_temp.player_new_y         = map[2]
      $game_temp.player_new_direction = 2
      $scene.transfer_player
    else
      pbCancelVehicles
      $map_factory.setup(map[0])
      $game_player.moveto(map[1], map[2])
      $game_player.turn_down
      $game_map.update
      $game_map.autoplay
    end
    $game_map.refresh
    next true   # Closes the debug menu to allow the warp
  }
})

ListHandlers.add(:debug_menu, :refresh_map, {
  "name"        => _INTL("Refresh Map"),
  "parent"      => :field_menu,
  "description" => _INTL("Make all events on this map, and common events, refresh themselves."),
  "effect"      => proc {
    $game_map.need_refresh = true
    pbMessage(_INTL("The map will refresh."))
  }
})

ListHandlers.add(:debug_menu, :switches, {
  "name"        => _INTL("Switches"),
  "parent"      => :field_menu,
  "description" => _INTL("Edit all Game Switches (except Script Switches)."),
  "effect"      => proc {
    pbDebugVariables(0)
  }
})

ListHandlers.add(:debug_menu, :variables, {
  "name"        => _INTL("Variables"),
  "parent"      => :field_menu,
  "description" => _INTL("Edit all Game Variables. Can set them to numbers or text."),
  "effect"      => proc {
    pbDebugVariables(1)
  }
})

ListHandlers.add(:debug_menu, :skip_credits, {
  "name"        => _INTL("Skip Credits"),
  "parent"      => :field_menu,
  "description" => _INTL("Toggle whether credits can be ended early by pressing the Use input."),
  "effect"      => proc {
    $PokemonGlobal.creditsPlayed = !$PokemonGlobal.creditsPlayed
    pbMessage(_INTL("Credits can be skipped when played in future.")) if $PokemonGlobal.creditsPlayed
    pbMessage(_INTL("Credits cannot be skipped when next played.")) if !$PokemonGlobal.creditsPlayed
  }
})

#===============================================================================
# Player options
#===============================================================================
ListHandlers.add(:debug_menu, :player_menu, {
  "name"        => _INTL("Player Options..."),
  "parent"      => :main,
  "description" => _INTL("Set money, badges, Pokédexes, player's appearance and name, etc."),
  "always_show" => false
})

ListHandlers.add(:debug_menu, :set_badges, {
  "name"        => _INTL("Set Badges"),
  "parent"      => :player_menu,
  "description" => _INTL("Toggle possession of each Gym Badge."),
  "effect"      => proc {
    badgecmd = 0
    loop do
      badgecmds = []
      badgecmds.push(_INTL("Give all"))
      badgecmds.push(_INTL("Remove all"))
      24.times do |i|
        badgecmds.push(_INTL("{1} Badge {2}", $player.badges[i] ? "[Y]" : "[  ]", i + 1))
      end
      badgecmd = pbShowCommands(nil, badgecmds, -1, badgecmd)
      break if badgecmd < 0
      case badgecmd
      when 0   # Give all
        24.times { |i| $player.badges[i] = true }
      when 1   # Remove all
        24.times { |i| $player.badges[i] = false }
      else
        $player.badges[badgecmd - 2] = !$player.badges[badgecmd - 2]
      end
    end
  }
})

ListHandlers.add(:debug_menu, :set_money, {
  "name"        => _INTL("Set Money"),
  "parent"      => :player_menu,
  "description" => _INTL("Edit how much money you have."),
  "effect"      => proc {
    params = ChooseNumberParams.new
    params.setRange(0, Settings::MAX_MONEY)
    params.setDefaultValue($player.money)
    $player.money = pbMessageChooseNumber(_INTL("Set the player's money."), params)
    pbMessage(_INTL("You now have ${1}.", $player.money.to_s_formatted))
  }
})

ListHandlers.add(:debug_menu, :toggle_running_shoes, {
  "name"        => _INTL("Toggle Running Shoes"),
  "parent"      => :player_menu,
  "description" => _INTL("Toggle possession of running shoes."),
  "effect"      => proc {
    $player.has_running_shoes = !$player.has_running_shoes
    pbMessage(_INTL("Gave Running Shoes.")) if $player.has_running_shoes
    pbMessage(_INTL("Lost Running Shoes.")) if !$player.has_running_shoes
  }
})

ListHandlers.add(:debug_menu, :toggle_pokegear, {
  "name"        => _INTL("Toggle Pokégear"),
  "parent"      => :player_menu,
  "description" => _INTL("Toggle possession of the Pokégear."),
  "effect"      => proc {
    $player.has_pokegear = !$player.has_pokegear
    pbMessage(_INTL("Gave Pokégear.")) if $player.has_pokegear
    pbMessage(_INTL("Lost Pokégear.")) if !$player.has_pokegear
  }
})

ListHandlers.add(:debug_menu, :toggle_pokedex, {
  "name"        => _INTL("Toggle Pokédex and Dexes"),
  "parent"      => :player_menu,
  "description" => _INTL("Toggle possession of the Pokédex, and edit Regional Dex accessibility."),
  "effect"      => proc {
    dexescmd = 0
    loop do
      dexescmds = []
      dexescmds.push(_INTL("Have Pokédex: {1}", $player.has_pokedex ? "[YES]" : "[NO]"))
      dex_names = Settings.pokedex_names
      dex_names.length.times do |i|
        name = (dex_names[i].is_a?(Array)) ? dex_names[i][0] : dex_names[i]
        unlocked = $player.pokedex.unlocked?(i)
        dexescmds.push(_INTL("{1} {2}", unlocked ? "[Y]" : "[  ]", name))
      end
      dexescmd = pbShowCommands(nil, dexescmds, -1, dexescmd)
      break if dexescmd < 0
      dexindex = dexescmd - 1
      if dexindex < 0   # Toggle Pokédex ownership
        $player.has_pokedex = !$player.has_pokedex
      elsif $player.pokedex.unlocked?(dexindex)   # Toggle Regional Dex accessibility
        $player.pokedex.lock(dexindex)
      else
        $player.pokedex.unlock(dexindex)
      end
    end
  }
})

ListHandlers.add(:debug_menu, :toggle_box_link, {
  "name"        => _INTL("Toggle Pokémon Box Link's Effect"),
  "parent"      => :player_menu,
  "description" => _INTL("Toggle Box Link's effect of accessing Pokémon storage via the party screen."),
  "effect"      => proc {
    $player.has_box_link = !$player.has_box_link
    pbMessage(_INTL("Enabled Pokémon Box Link's effect.")) if $player.has_box_link
    pbMessage(_INTL("Disabled Pokémon Box Link's effect.")) if !$player.has_box_link
  }
})

ListHandlers.add(:debug_menu, :toggle_exp_all, {
  "name"        => _INTL("Toggle Exp. All's Effect"),
  "parent"      => :player_menu,
  "description" => _INTL("Toggle Exp. All's effect of giving Exp. to non-participants."),
  "effect"      => proc {
    $player.has_exp_all = !$player.has_exp_all
    pbMessage(_INTL("Enabled Exp. All's effect.")) if $player.has_exp_all
    pbMessage(_INTL("Disabled Exp. All's effect.")) if !$player.has_exp_all
  }
})

ListHandlers.add(:debug_menu, :set_player_character, {
  "name"        => _INTL("Set Player Character"),
  "parent"      => :player_menu,
  "description" => _INTL("Edit the player's character, as defined in \"metadata.txt\"."),
  "effect"      => proc {
    index = 0
    cmds = []
    ids = []
    GameData::PlayerMetadata.each do |player|
      index = cmds.length if player.id == $player.character_ID
      cmds.push(player.id.to_s)
      ids.push(player.id)
    end
    if cmds.length == 1
      pbMessage(_INTL("There is only one player character defined."))
      break
    end
    cmd = pbShowCommands(nil, cmds, -1, index)
    if cmd >= 0 && cmd != index
      pbChangePlayer(ids[cmd])
      pbMessage(_INTL("The player character was changed."))
    end
  }
})

ListHandlers.add(:debug_menu, :change_outfit, {
  "name"        => _INTL("Set Player Outfit"),
  "parent"      => :player_menu,
  "description" => _INTL("Edit the player's outfit number."),
  "effect"      => proc {
    oldoutfit = $player.outfit
    params = ChooseNumberParams.new
    params.setRange(0, 99)
    params.setDefaultValue(oldoutfit)
    $player.outfit = pbMessageChooseNumber(_INTL("Set the player's outfit."), params)
    pbMessage(_INTL("Player's outfit was changed.")) if $player.outfit != oldoutfit
  }
})

ListHandlers.add(:debug_menu, :rename_player, {
  "name"        => _INTL("Set Player Name"),
  "parent"      => :player_menu,
  "description" => _INTL("Rename the player."),
  "effect"      => proc {
    trname = pbEnterPlayerName("Your name?", 0, Settings::MAX_PLAYER_NAME_SIZE, $player.name)
    if nil_or_empty?(trname) && pbConfirmMessage(_INTL("Give yourself a default name?"))
      trainertype = $player.trainer_type
      gender      = pbGetTrainerTypeGender(trainertype)
      trname      = pbSuggestTrainerName(gender)
    end
    if nil_or_empty?(trname)
      pbMessage(_INTL("The player's name remained {1}.", $player.name))
    else
      $player.name = trname
      pbMessage(_INTL("The player's name was changed to {1}.", $player.name))
    end
  }
})

ListHandlers.add(:debug_menu, :random_id, {
  "name"        => _INTL("Randomize Player ID"),
  "parent"      => :player_menu,
  "description" => _INTL("Generate a random new ID for the player."),
  "effect"      => proc {
    $player.id = rand(2**16) | (rand(2**16) << 16)
    pbMessage(_INTL("The player's ID was changed to {1} (full ID: {2}).", $player.public_ID, $player.id))
  }
})

#===============================================================================
# Information editors
#===============================================================================
ListHandlers.add(:debug_menu, :editors_menu, {
  "name"        => _INTL("Information Editors..."),
  "parent"      => :main,
  "description" => _INTL("Edit information in the PBS files, terrain tags, battle animations, etc.")
})

ListHandlers.add(:debug_menu, :set_metadata, {
  "name"        => _INTL("Edit Metadata"),
  "parent"      => :editors_menu,
  "description" => _INTL("Edit global metadata and player character metadata."),
  "effect"      => proc {
    pbMetadataScreen
  }
})

ListHandlers.add(:debug_menu, :set_map_metadata, {
  "name"        => _INTL("Edit Map Metadata"),
  "parent"      => :editors_menu,
  "description" => _INTL("Edit map metadata."),
  "effect"      => proc {
    pbMapMetadataScreen(pbDefaultMap)
  }
})

ListHandlers.add(:debug_menu, :set_map_connections, {
  "name"        => _INTL("Edit Map Connections"),
  "parent"      => :editors_menu,
  "description" => _INTL("Connect maps using a visual interface. Can also edit map encounters/metadata."),
  "effect"      => proc {
    pbFadeOutIn { pbConnectionsEditor }
  }
})

ListHandlers.add(:debug_menu, :set_terrain_tags, {
  "name"        => _INTL("Edit Terrain Tags"),
  "parent"      => :editors_menu,
  "description" => _INTL("Edit the terrain tags of tiles in tilesets. Required for tags 8+."),
  "effect"      => proc {
    pbFadeOutIn { pbTilesetScreen }
  }
})

ListHandlers.add(:debug_menu, :set_trainer_types, {
  "name"        => _INTL("Edit Trainer Types"),
  "parent"      => :editors_menu,
  "description" => _INTL("Edit the properties of trainer types."),
  "effect"      => proc {
    pbFadeOutIn { pbTrainerTypeEditor }
  }
})

ListHandlers.add(:debug_menu, :set_items, {
  "name"        => _INTL("Edit Items"),
  "parent"      => :editors_menu,
  "description" => _INTL("Edit item data."),
  "effect"      => proc {
    pbFadeOutIn { pbItemEditor }
  }
})

ListHandlers.add(:debug_menu, :animation_editor, {
  "name"        => _INTL("Battle Animation Editor"),
  "parent"      => :editors_menu,
  "description" => _INTL("Edit the battle animations."),
  "effect"      => proc {
    pbFadeOutIn { pbAnimationEditor }
  }
})

ListHandlers.add(:debug_menu, :animation_organiser, {
  "name"        => _INTL("Battle Animation Organiser"),
  "parent"      => :editors_menu,
  "description" => _INTL("Rearrange/add/delete battle animations."),
  "effect"      => proc {
    pbFadeOutIn { pbAnimationsOrganiser }
  }
})

ListHandlers.add(:debug_menu, :import_animations, {
  "name"        => _INTL("Import All Battle Animations"),
  "parent"      => :editors_menu,
  "description" => _INTL("Import all battle animations from the \"Animations\" folder."),
  "effect"      => proc {
    pbImportAllAnimations
  }
})

ListHandlers.add(:debug_menu, :export_animations, {
  "name"        => _INTL("Export All Battle Animations"),
  "parent"      => :editors_menu,
  "description" => _INTL("Export all battle animations individually to the \"Animations\" folder."),
  "effect"      => proc {
    pbExportAllAnimations
  }
})

#===============================================================================
# Other options
#===============================================================================
ListHandlers.add(:debug_menu, :other_menu, {
  "name"        => _INTL("Other Options..."),
  "parent"      => :main,
  "description" => _INTL("Mystery Gifts, translations, compile data, etc.")
})

ListHandlers.add(:debug_menu, :mystery_gift, {
  "name"        => _INTL("Manage Mystery Gifts"),
  "parent"      => :other_menu,
  "description" => _INTL("Edit and enable/disable Mystery Gifts."),
  "effect"      => proc {
    pbManageMysteryGifts
  }
})

ListHandlers.add(:debug_menu, :extract_text, {
  "name"        => _INTL("Extract Text"),
  "parent"      => :other_menu,
  "description" => _INTL("Extract all text in the game to a single file for translating."),
  "effect"      => proc {
    pbExtractText
  }
})

ListHandlers.add(:debug_menu, :compile_text, {
  "name"        => _INTL("Compile Text"),
  "parent"      => :other_menu,
  "description" => _INTL("Import text and converts it into a language file."),
  "effect"      => proc {
    pbCompileTextUI
  }
})

ListHandlers.add(:debug_menu, :compile_data, {
  "name"        => _INTL("Compile Data"),
  "parent"      => :other_menu,
  "description" => _INTL("Fully compile all data."),
  "effect"      => proc {
    msgwindow = pbCreateMessageWindow
    Compiler.compile_all(true)
    pbMessageDisplay(msgwindow, _INTL("All game data was compiled."))
    pbDisposeMessageWindow(msgwindow)
  }
})

ListHandlers.add(:debug_menu, :create_pbs_files, {
  "name"        => _INTL("Create PBS File(s)"),
  "parent"      => :other_menu,
  "description" => _INTL("Choose one or all PBS files and create it."),
  "effect"      => proc {
    cmd = 0
    cmds = [
      _INTL("[Create all]"),
      "items.txt",
      "map_connections.txt",
      "map_metadata.txt",
      "metadata.txt",
      "trainer_types.txt",
      "types.txt"
    ]
    loop do
      cmd = pbShowCommands(nil, cmds, -1, cmd)
      case cmd
      when 0  then Compiler.write_all
      when 4  then Compiler.write_encounters
      when 5  then Compiler.write_items
      when 6  then Compiler.write_connections
      when 7  then Compiler.write_map_metadata
      when 8  then Compiler.write_metadata
      when 9  then Compiler.write_moves
      when 11 then Compiler.write_pokemon
      when 12 then Compiler.write_pokemon_forms
      when 13 then Compiler.write_pokemon_metrics
      when 18 then Compiler.write_trainer_types
      when 19 then Compiler.write_trainers
      when 20 then Compiler.write_types
      else break
      end
      pbMessage(_INTL("File written."))
    end
  }
})

ListHandlers.add(:debug_menu, :fix_invalid_tiles, {
  "name"        => _INTL("Fix Invalid Tiles"),
  "parent"      => :other_menu,
  "description" => _INTL("Scans all maps and erases non-existent tiles."),
  "effect"      => proc {
    pbDebugFixInvalidTiles
  }
})

ListHandlers.add(:debug_menu, :rename_files, {
  "name"        => _INTL("Rename Outdated Files"),
  "parent"      => :other_menu,
  "description" => _INTL("Check for files with outdated names and rename/move them. Can alter map data."),
  "effect"      => proc {
    if pbConfirmMessage(_INTL("Are you sure you want to automatically rename outdated files?"))
      FilenameUpdater.rename_files
      pbMessage(_INTL("Done."))
    end
  }
})

ListHandlers.add(:debug_menu, :reload_system_cache, {
  "name"        => _INTL("Reload System Cache"),
  "parent"      => :other_menu,
  "description" => _INTL("Refreshes the system's file cache. Use if you change a file while playing."),
  "effect"      => proc {
    System.reload_cache
    pbMessage(_INTL("Done."))
  }
})
