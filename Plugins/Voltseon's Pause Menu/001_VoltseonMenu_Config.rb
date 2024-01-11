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
MENU_FILE_PATH = "Graphics/Pictures/Voltseon's Pause Menu/"

# An array of aLL the Menu Entry Classes from 005_VoltseonMenu_Entries that
# need to be loaded
MENU_ENTRIES = [
  "MenuEntryPokemon", "MenuEntryPokedex", "MenuEntryBag", "MenuEntryPokegear",
  "MenuEntryTrainer", "MenuEntryMap", "MenuEntryExitBugContest",
  "MenuEntryExitSafari", "MenuEntrySave", "MenuEntryDebug", "MenuEntryOptions",
  "MenuEntryEncounterList", "MenuEntryQuests", "MenuEntryQuit"
]

# An array of aLL the Menu Component Classes from 004_VoltseonMenu_Components
# that need to be loaded
MENU_COMPONENTS = [
  "SafariHud", "BugContestHud", "PokemonPartyHud", "DateAndTimeHud", "NewQuestHud"
]

# The default theme for the menu screen
DEFAULT_MENU_THEME = 0

# Change Theme in the Options Menu
CHANGE_THEME_IN_OPTIONS = false

#-------------------------------------------------------------------------------
# Look and Feel
#-------------------------------------------------------------------------------
# Background options
BACKGROUND_TINT = Color.new(-30,-30,-30,130) # Tone (Red, Green, Blue, Grey) applied to the background/map.

SHOW_MENU_NAMES = true # Whether or not the Menu option Names show on screen (true = show names)

# Icon options
ACTIVE_SCALE = 1.5

MENU_TEXTCOLOR = [
            Color.new(168,168,168), # 0
            Color.new(168,168,168), # 1
            Color.new(248,248,248), # 2
            Color.new(248,248,248), # 3
            Color.new(248,248,248), # 4
            Color.new(248,248,248), # 5
            Color.new(28, 28, 28 ), # 6
            Color.new(248,248,248), # 7
            Color.new(248,248,248), # 8
            Color.new(248,248,248)  # 9
          ]
MENU_TEXTOUTLINE = [
            Color.new(28, 28, 28 ), # 0
            Color.new(28, 28, 28 ), # 1
            Color.new(84, 48, 26 ), # 2
            Color.new(9 , 61, 37 ), # 3
            Color.new(73, 40, 13 ), # 4
            Color.new(26, 12, 73 ), # 5
            Color.new(248,248,248), # 6
            Color.new(24, 13, 56 ), # 7
            Color.new(86, 12, 32 ), # 8
            Color.new(38, 22, 91 )  # 9
          ]
LOCATION_TEXTCOLOR = [
            
            Color.new(168,168,168), # 0
            Color.new(168,168,168), # 1
            Color.new(248,248,248), # 2
            Color.new(248,248,248), # 3
            Color.new(248,248,248), # 4
            Color.new(248,248,248), # 5
            Color.new(28, 28, 28 ), # 6
            Color.new(248,248,248), # 7
            Color.new(248,248,248), # 8
            Color.new(248,248,248)  # 9
          ]
LOCATION_TEXTOUTLINE = [
            Color.new(28, 28, 28 ), # 0
            Color.new(28, 28, 28 ), # 1
            Color.new(84, 48, 26 ), # 2
            Color.new(9 , 61, 37 ), # 3
            Color.new(73, 40, 13 ), # 4
            Color.new(26, 12, 73 ), # 5
            Color.new(248,248,248), # 6
            Color.new(24, 13, 56 ), # 7
            Color.new(86, 12, 32 ), # 8
            Color.new(38, 22, 91 )  # 9
          ]

# Sound Options
MENU_OPEN_SOUND   = "GUI menu open"
MENU_CLOSE_SOUND  = "GUI menu close"
MENU_CURSOR_SOUND = "GUI sel cursor"
