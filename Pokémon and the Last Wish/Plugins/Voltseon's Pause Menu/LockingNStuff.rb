def pbUnlockTheme(theme, show_message = true)
  theme_name = pbGetThemeName(theme)
  if !$game_variables[51].is_a?(Array)
    $game_variables[51]=[[0,"Light Theme"]]
  end
  return false if $game_variables[51].include?([theme,theme_name])
  unlocked_themes = $game_variables[51]
  ids = []
  for i in 0...unlocked_themes.length
    if unlocked_themes[i].is_a?(Array)
      ids.push(unlocked_themes[i][0])
    end
  end
  if !ids.include?(theme)
    unlocked_themes.push([theme,theme_name])
    if show_message
      pbMessage(_INTL("\\me[{1}]You unlocked the \\c[1]{2}\\c[0]!\\wtnp[60]","DPPT 103 Get Accessory",theme_name))
      pbMessage(_INTL("You can change your pause menu theme in the PC."))
      $PokemonSystem.unlocked_menu_themes = unlocked_themes.length
    end
    return true
  end
  return false
end

def pbGetThemeName(theme)
    case theme
    when 0 then return _INTL("Light Theme")
    when 1 then return _INTL("Dark Theme")
    when 2 then return _INTL("Overgrow Theme")
    when 3 then return _INTL("Blaze Theme")
    when 4 then return _INTL("Torrent Theme")
    when 5 then return _INTL("Wishmaker Theme")
    when 6 then return _INTL("Heliotrope Theme")
    when 7 then return _INTL("Wiki Theme")
    when 8 then return _INTL("Bolt Theme")
    when 9 then return _INTL("Impression Theme")
    else return _INTL("Unknown Theme")
    end
end

def pbChooseTheme
  current_theme = $PokemonSystem.current_menu_theme
  current_theme_name = pbGetThemeName(current_theme)
  commands = []
  ids = []
  if $game_variables[51].is_a?(Array) && $game_variables[51].length > 1
    unlocked_themes = $game_variables[51]
    for i in 0...unlocked_themes.length
      if unlocked_themes[i].is_a?(Array)
        commands.push(unlocked_themes[i][1])
        ids.push(unlocked_themes[i][0])
      end
    end
    commands.push("Cancel")
    command = pbMessage(_INTL("Which theme would you like to use? (\\c[2]{1}\\c[0] is being used)",current_theme_name), commands)
    if command == commands.length-1
      return
    end
    if $PokemonSystem.current_menu_theme != ids[command]
      $PokemonSystem.current_menu_theme = ids[command]
      pbMessage(_INTL("\\se[{1}]Changed theme to \\c[1]{2}\\c[0]!\\wtnp[10]", "GUI naming confirm", pbGetThemeName(ids[command])))
    else
      pbMessage(_INTL("\\se[{1}]You are already using this theme!\\wtnp[10]", "GUI sel buzzer"))
    end
  else
    pbMessage(_INTL("\\se[{1}]You do not have any themes unlocked!\\wtnp[10]", "GUI sel buzzer"))
  end
end

#-------------------------------------------------------------------------------
# Attribute in PokemonSystem to save the current menu theme in the save file
#-------------------------------------------------------------------------------
class PokemonSystem
	attr_writer :unlocked_menu_themes

	def unlocked_menu_themes
		@unlocked_menu_themes = $game_variables[51] if !@unlocked_menu_themes
		return @unlocked_menu_themes
	end
end