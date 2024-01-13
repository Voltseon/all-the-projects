#==============================================================================#
#                              Pokémon Essentials                              #
#                                 Version 20.1                                 #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#

module Settings
  GAME_VERSION = "1.0.2".freeze
  OUTLINES = false

  #=============================================================================

  MAX_MONEY            = 999_999
  MAX_PLAYER_NAME_SIZE = 10

  TIME_SHADING         = false

  NO_SIGNPOSTS         = []

  STARTING_OVER_SWITCH = 1

  #=============================================================================

  GRASS_ANIMATION_ID           = 1
  DUST_ANIMATION_ID            = 2
  EXCLAMATION_ANIMATION_ID     = 3
  RUSTLE_NORMAL_ANIMATION_ID   = 1
  RUSTLE_VIGOROUS_ANIMATION_ID = 5
  RUSTLE_SHINY_ANIMATION_ID    = 6
  PLANT_SPARKLE_ANIMATION_ID   = 7

  #=============================================================================

  SCREEN_WIDTH  = 1024
  SCREEN_HEIGHT = 576
  SCREEN_SCALE  = 1.0

  #=============================================================================

  LANGUAGES = [
  #  ["English", "english.dat"],
  #  ["Deutsch", "deutsch.dat"]
  ]

  #=============================================================================
end

# DO NOT EDIT THESE!
module Essentials
  VERSION = "20.1"
  ERROR_TEXT = ""
end
