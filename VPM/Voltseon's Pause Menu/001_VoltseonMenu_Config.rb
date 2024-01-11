#-------------------------------------------------------------------------------
# Voltseon's Pause Menu
# Pause with style 😎
#-------------------------------------------------------------------------------
#
# Original Script by Yankas
# Updated compatablilty by Cony
# Edited and modified by Voltseon, Golisopod User and ENLS
#
# Made for people who dont want
# to have ugly pause menus
# so here's a really cool one!
# Version: 1.8
#
#
#-------------------------------------------------------------------------------
# Menu Options
#-------------------------------------------------------------------------------
# Main file path for the menu
MENU_FILE_PATH = "Graphics/UI/VPM/"

# An array of aLL the Menu Component Classes from 004_VoltseonMenu_Components
# that need to be loaded
MENU_COMPONENTS = [
  :VPM_SafariHud, :VPM_BugContestHud, :VPM_PokemonPartyHud, :VPM_DateAndTimeHud, :VPM_NewQuestHud
]

# The default theme for the menu screen
DEFAULT_MENU_THEME = 0

# Change Theme in the Options Menu
CHANGE_THEME_IN_OPTIONS = true

#-------------------------------------------------------------------------------
# Look and Feel
#-------------------------------------------------------------------------------
# Background options
BACKGROUND_TINT = Color.new(-30, -30, -30, 130) # Tone (Red, Green, Blue, Grey) applied to the background/map.

SHOW_MENU_NAMES = true # Whether or not the Menu option Names show on screen (true = show names)

# Icon options
ACTIVE_SCALE = 1.5

MENU_TEXTCOLOR = [
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248)
]

MENU_TEXTOUTLINE = [
  Color.new(64, 64, 64),
  Color.new(64, 64, 64),
  Color.new(68, 96, 0),
  Color.new(96, 18, 0),
  Color.new(0, 102, 137),
  Color.new(137, 0, 100),
  Color.new(38, 22, 91),
  Color.new(12, 37, 24),
  Color.new(0, 58, 76)
]

LOCATION_TEXTCOLOR = [
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248),
  Color.new(248, 248, 248)
]

LOCATION_TEXTOUTLINE = [
  Color.new(64, 64, 64),
  Color.new(64, 64, 64),
  Color.new(68, 96, 0),
  Color.new(96, 18, 0),
  Color.new(0, 102, 137),
  Color.new(137, 0, 100),
  Color.new(38, 22, 91),
  Color.new(12, 37, 24),
  Color.new(0, 58, 76)
]

# Sound Options
MENU_OPEN_SOUND   = "GUI menu open"
MENU_CLOSE_SOUND  = "GUI menu close"
MENU_CURSOR_SOUND = "GUI sel cursor"
