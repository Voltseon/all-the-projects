#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for miscellaneous bugs in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

Essentials::ERROR_TEXT += "[v20.1 Hotfixes 1.0.7]\r\n"

#===============================================================================
# Fixed play time carrying over to new games.
#===============================================================================
module SaveData
  class Value
    def reset_on_new_game
      @reset_on_new_game = true
    end

    def reset_on_new_game?
      return @reset_on_new_game
    end
  end

  def self.unregister(id)
    validate id => Symbol
    @values.delete_if { |value| value.id == id }
  end

  def self.mark_values_as_unloaded
    @values.each do |value|
      value.mark_as_unloaded if !value.load_in_bootup? || value.reset_on_new_game?
    end
  end

  def self.load_new_game_values
    @values.each do |value|
      value.load_new_game_value if value.has_new_game_proc? && (!value.loaded? || value.reset_on_new_game?)
    end
  end
end

SaveData.unregister(:stats)
SaveData.unregister(:bag)
SaveData.unregister(:storage_system)

SaveData.register(:stats) do
  load_in_bootup
  ensure_class :GameStats
  save_value { $stats }
  load_value { |value| $stats = value }
  new_game_value { GameStats.new }
  reset_on_new_game
end

#===============================================================================
# Fixed def pbShowCommandsWithHelp not properly deactivating showing a message
# window if it created one.
#===============================================================================
def pbShowCommandsWithHelp(msgwindow, commands, help, cmdIfCancel = 0, defaultCmd = 0)
  msgwin = msgwindow
  msgwin = pbCreateMessageWindow(nil) if !msgwindow
  oldlbl = msgwin.letterbyletter
  msgwin.letterbyletter = false
  if commands
    cmdwindow = Window_CommandPokemonEx.new(commands)
    cmdwindow.z = 99999
    cmdwindow.visible = true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height = msgwin.y if cmdwindow.height > msgwin.y
    cmdwindow.index = defaultCmd
    command = 0
    msgwin.text = help[cmdwindow.index]
    msgwin.width = msgwin.width   # Necessary evil to make it use the proper margins
    loop do
      Graphics.update
      Input.update
      oldindex = cmdwindow.index
      cmdwindow.update
      if oldindex != cmdwindow.index
        msgwin.text = help[cmdwindow.index]
      end
      msgwin.update
      yield if block_given?
      if Input.trigger?(Input::BACK)
        if cmdIfCancel > 0
          command = cmdIfCancel - 1
          break
        elsif cmdIfCancel < 0
          command = cmdIfCancel
          break
        end
      end
      if Input.trigger?(Input::USE) || Mouse.trigger?
        command = cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret = command
    cmdwindow.dispose
    Input.update
  end
  msgwin.letterbyletter = oldlbl
  pbDisposeMessageWindow(msgwin) if !msgwindow
  return ret
end

#===============================================================================
# Fixed text underline/strikethrough lines being mispositioned. Also added
# shadows to them.
#===============================================================================
def drawSingleFormattedChar(bitmap, ch)
  if ch[5]   # If a graphic
    graphic = Bitmap.new(ch[0])
    graphicRect = ch[15]
    bitmap.blt(ch[1], ch[2], graphic, graphicRect, ch[8].alpha)
    graphic.dispose
    return
  end
  bitmap.font.size = ch[13] if bitmap.font.size != ch[13]
  if ch[9]   # shadow
    if ch[10]   # underline
      bitmap.fill_rect(ch[1], ch[2] + ch[4] - [(ch[4] - bitmap.font.size) / 2, 0].max - 2, ch[3], 4, ch[9])
    end
    if ch[11]   # strikeout
      bitmap.fill_rect(ch[1], ch[2] + 2 + (ch[4] / 2), ch[3], 4, ch[9])
    end
  end
  if ch[0] == "\n" || ch[0] == "\r" || ch[0] == " " || isWaitChar(ch[0])
    bitmap.font.color = ch[8] if bitmap.font.color != ch[8]
  else
    bitmap.font.bold = ch[6] if bitmap.font.bold != ch[6]
    bitmap.font.italic = ch[7] if bitmap.font.italic != ch[7]
    bitmap.font.name = ch[12] if bitmap.font.name != ch[12]
    offset = 0
    if ch[9]   # shadow
      bitmap.font.color = ch[9]
      if (ch[16] & 1) != 0   # outline
        offset = 1
        bitmap.draw_text(ch[1], ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 1, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 1, ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 1, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 1, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
      elsif (ch[16] & 2) != 0   # outline 2
        offset = 2
        bitmap.draw_text(ch[1], ch[2], ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 4, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 4, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 4, ch[2], ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 4, ch[2] + 2, ch[3] + 4, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 4, ch[2] + 4, ch[3] + 4, ch[4], ch[0])
      else
        bitmap.draw_text(ch[1] + 2, ch[2], ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1], ch[2] + 2, ch[3] + 2, ch[4], ch[0])
        bitmap.draw_text(ch[1] + 2, ch[2] + 2, ch[3] + 2, ch[4], ch[0])
      end
    end
    bitmap.font.color = ch[8] if bitmap.font.color != ch[8]
    bitmap.draw_text(ch[1] + offset, ch[2] + offset, ch[3], ch[4], ch[0])
  end
  if ch[10]   # underline
    bitmap.fill_rect(ch[1], ch[2] + ch[4] - [(ch[4] - bitmap.font.size) / 2, 0].max - 2, ch[3] - 2, 2, ch[8])
  end
  if ch[11]   # strikeout
    bitmap.fill_rect(ch[1], ch[2] + 2 + (ch[4] / 2), ch[3] - 2, 2, ch[8])
  end
end

#===============================================================================
# Fixed the Interpreter not resetting if the game was saved in the middle of an
# event and then you start a new game.
#===============================================================================
module Game
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
    $game_map.autoplay
    $game_map.update
  end
end

#===============================================================================
# Fixed roaming Pokémon not remembering whether they have been caught.
#===============================================================================
class PokemonGlobalMetadata
  def roamPokemonCaught
    @roamPokemonCaught = [] if !@roamPokemonCaught
    return @roamPokemonCaught
  end
end

#===============================================================================
# Fixed entering a map always restarting the BGM if that map's BGM has a night
# version, even if it ends up playing the same music.
#===============================================================================
class Scene_Map
  def autofade(mapid)
    playingBGM = $game_system.playing_bgm
    playingBGS = $game_system.playing_bgs
    return if !playingBGM && !playingBGS
    map = load_data(sprintf("Data/Map%03d.rxdata", mapid))
    if playingBGM && map.autoplay_bgm
      test_filename = map.bgm.name
      test_filename += "_n" if PBDayNight.isNight? && FileTest.audio_exist?("Audio/BGM/" + test_filename + "_n")
      pbBGMFade(0.8) if playingBGM.name != test_filename
    end
    if playingBGS && map.autoplay_bgs && playingBGS.name != map.bgs.name
      pbBGMFade(0.8)
    end
    Graphics.frame_reset
  end
end
