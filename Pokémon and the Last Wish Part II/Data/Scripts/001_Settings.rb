#==============================================================================#
#                              Pokémon Essentials                              #
#                                 Version 19.1                                 #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#

module Settings
  # The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
  GAME_VERSION = '1.0.7'

  # The generation that the battle system follows. Used throughout the battle
  # scripts, and also by some other settings which are used in and out of battle
  # (you can of course change those settings to suit your game).
  # Note that this isn't perfect. Essentials doesn't accurately replicate every
  # single generation's mechanics. It's considered to be good enough. Only
  # generations 5 and later are reasonably supported.
  MECHANICS_GENERATION = 7

  #=============================================================================

  # The default screen width (at a scale of 1.0).
  SCREEN_WIDTH  = 512
  # The default screen height (at a scale of 1.0).
  SCREEN_HEIGHT = 384
  # The default screen scale factor. Possible values are 0.5, 1.0, 1.5 and 2.0.
  SCREEN_SCALE  = 1.0

  #=============================================================================

  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL        = 100
  # The level of newly hatched Pokémon.
  EGG_LEVEL            = 1
  # The odds of a newly generated Pokémon being shiny (out of 65536).
  SHINY_POKEMON_CHANCE = 420 # (0.64%)
  # The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
  POKERUS_CHANCE       = 3
  # Whether a bred baby Pokémon can inherit any TM/HM moves from its father. It
  # can never inherit TM/HM moves from its mother.
  BREEDING_CAN_INHERIT_MACHINE_MOVES         = (MECHANICS_GENERATION <= 5)
  # Whether a bred baby Pokémon can inherit egg moves from its mother. It can
  # always inherit egg moves from its father.
  BREEDING_CAN_INHERIT_EGG_MOVES_FROM_MOTHER = (MECHANICS_GENERATION >= 6)

  #=============================================================================

  # The amount of money the player starts the game with.
  INITIAL_MONEY        = 3000
  # The maximum amount of money the player can have.
  MAX_MONEY            = 999_999
  # The maximum number of Game Corner coins the player can have.
  MAX_COINS            = 99_999
  # The maximum number of Battle Points the player can have.
  MAX_BATTLE_POINTS    = 9_999
  # The maximum amount of soot the player can have.
  MAX_SOOT             = 9_999
  # The maximum length, in characters, that the player's name can be.
  MAX_PLAYER_NAME_SIZE = 16
  # The maximum number of Pokémon that can be in the party.
  MAX_PARTY_SIZE       = 6

  #=============================================================================

  # A set of arrays each containing a trainer type followed by a Global Variable
  # number. If the variable isn't set to 0, then all trainers with the
  # associated trainer type will be named as whatever is in that variable.
  RIVAL_NAMES = [
    [:RIVAL1,   12],
    [:RIVAL2,   12],
    [:RIVAL1_1,   12],
    [:RIVAL2_1,   12],
    [:RIVAL1_2,   12],
    [:RIVAL2_2,   12],
    [:RIVAL1_3,   12],
    [:RIVAL2_3,   12],
    [:RIVAL1_4,   12],
    [:RIVAL2_4,   12],
    [:CHAMPION, 12],
    [:LEADER_Cris_M, 27],
    [:LEADER_Cris_F, 27]
  ]

  #=============================================================================

  # Whether outdoor maps should be shaded according to the time of day.
  TIME_SHADING = false

  #=============================================================================

  # Whether poisoned Pokémon will lose HP while walking around in the field.
  POISON_IN_FIELD       = (MECHANICS_GENERATION <= 4)
  # Whether poisoned Pokémon will faint while walking around in the field
  # (true), or survive the poisoning with 1 HP (false).
  POISON_FAINT_IN_FIELD = (MECHANICS_GENERATION <= 3)
  # Whether planted berries grow according to Gen 4 mechanics (true) or Gen 3
  # mechanics (false).
  NEW_BERRY_PLANTS      = (MECHANICS_GENERATION >= 4)
  # Whether fishing automatically hooks the Pokémon (true), or whether there is
  # a reaction test first (false).
  FISHING_AUTO_HOOK     = false
  # The ID of the common event that runs when the player starts fishing (runs
  # instead of showing the casting animation).
  FISHING_BEGIN_COMMON_EVENT = -1
  # The ID of the common event that runs when the player stops fishing (runs
  # instead of showing the reeling in animation).
  FISHING_END_COMMON_EVENT   = -1

  #=============================================================================

  # The number of steps allowed before a Safari Zone game is over (0=infinite).
  SAFARI_STEPS     = 600
  # The number of seconds a Bug Catching Contest lasts for (0=infinite).
  BUG_CONTEST_TIME = 20 * 60   # 20 minutes

  #=============================================================================

  # Pairs of map IDs, where the location signpost isn't shown when moving from
  # one of the maps in a pair to the other (and vice versa). Useful for single
  # long routes/towns that are spread over multiple maps.
  #   e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
  # Moving between two maps that have the exact same name won't show the
  # location signpost anyway, so you don't need to list those maps here.
  NO_SIGNPOSTS = [127,98,90,103,103,105,91,105,200,201]

  #=============================================================================

  # Whether you need at least a certain number of badges to use some hidden
  # moves in the field (true), or whether you need one specific badge to use
  # them (false). The amounts/specific badges are defined below.
  FIELD_MOVES_COUNT_BADGES = true
  # Depending on FIELD_MOVES_COUNT_BADGES, either the number of badges required
  # to use each hidden move in the field, or the specific badge number required
  # to use each move. Remember that badge 0 is the first badge, badge 1 is the
  # second badge, etc.
  #   e.g. To require the second badge, put false and 1.
  #        To require at least 2 badges, put true and 2.
  BADGE_FOR_CUT       = 1
  BADGE_FOR_FLASH     = 2
  BADGE_FOR_ROCKSMASH = 3
  BADGE_FOR_SURF      = 4
  BADGE_FOR_FLY       = 5
  BADGE_FOR_STRENGTH  = 6
  BADGE_FOR_DIVE      = 7
  BADGE_FOR_WATERFALL = 8

  #=============================================================================

  # If a move taught by a TM/HM/TR replaces another move, this setting is
  # whether the machine's move retains the replaced move's PP (true), or whether
  # the machine's move has full PP (false).
  TAUGHT_MACHINES_KEEP_OLD_PP          = (MECHANICS_GENERATION == 5)
  # Whether the Black/White Flutes will raise/lower the levels of wild Pokémon
  # respectively (true), or will lower/raise the wild encounter rate
  # respectively (false).
  FLUTES_CHANGE_WILD_ENCOUNTER_LEVELS  = (MECHANICS_GENERATION >= 6)
  # Whether Repel uses the level of the first Pokémon in the party regardless of
  # its HP (true), or it uses the level of the first unfainted Pokémon (false).
  REPEL_COUNTS_FAINTED_POKEMON         = (MECHANICS_GENERATION >= 6)
  # Whether Rage Candy Bar acts as a Full Heal (true) or a Potion (false).
  RAGE_CANDY_BAR_CURES_STATUS_PROBLEMS = (MECHANICS_GENERATION >= 7)

  #=============================================================================

  # The name of the person who created the Pokémon storage system.
  def self.storage_creator_name
    return _INTL("Steve")
  end
  # The number of boxes in Pokémon storage.
  NUM_STORAGE_BOXES = 16

  #=============================================================================

  # The names of each pocket of the Bag. Ignore the first entry ("").
  def self.bag_pocket_names
    return ["",
      _INTL("Items"),
      _INTL("Medicine"),
      _INTL("Poké Balls"),
      _INTL("TMs & HMs"),
      _INTL("Berries"),
      _INTL("Outfits"),
      _INTL("Battle Items"),
      _INTL("Key Items")
    ]
  end
  # The maximum number of slots per pocket (-1 means infinite number). Ignore
  # the first number (0).
  BAG_MAX_POCKET_SIZE  = [0, -1, -1, -1, -1, -1, -1, -1, -1]
  # The maximum number of items each slot in the Bag can hold.
  BAG_MAX_PER_SLOT     = 999
  # Whether each pocket in turn auto-sorts itself by item ID number. Ignore the
  # first entry (the 0).
  BAG_POCKET_AUTO_SORT = [0, false, false, false, true, true, false, false, false]

  #=============================================================================

  # Whether the Pokédex list shown is the one for the player's current region
  # (true), or whether a menu pops up for the player to manually choose which
  # Dex list to view if more than one is available (false).
  USE_CURRENT_REGION_DEX = false
  # The names of the Pokédex lists, in the order they are defined in the PBS
  # file "regionaldexes.txt". The last name is for the National Dex and is added
  # onto the end of this array (remember that you don't need to use it). This
  # array's order is also the order of $Trainer.pokedex.unlocked_dexes, which
  # records which Dexes have been unlocked (the first is unlocked by default).
  # If an entry is just a name, then the region map shown in the Area page while
  # viewing that Dex list will be the region map of the region the player is
  # currently in. The National Dex entry should always behave like this.
  # If an entry is of the form [name, number], then the number is a region
  # number. That region's map will appear in the Area page while viewing that
  # Dex list, no matter which region the player is currently in.
  def self.pokedex_names
    return [
      [_INTL("North Peskan Pokédex"), 0],
      [_INTL("South Peskan Pokédex"), 1],
      [_INTL("Peskan Pokédex"), 2],
      _INTL("National Pokédex")
    ]
  end
  # Whether all forms of a given species will be immediately available to view
  # in the Pokédex so long as that species has been seen at all (true), or
  # whether each form needs to be seen specifically before that form appears in
  # the Pokédex (false).
  DEX_SHOWS_ALL_FORMS = false
  # An array of numbers, where each number is that of a Dex list (in the same
  # order as above, except the National Dex is -1). All Dex lists included here
  # will begin their numbering at 0 rather than 1 (e.g. Victini in Unova's Dex).
  DEXES_WITH_OFFSETS  = []

  #=============================================================================

  # A set of arrays, each containing details of a graphic to be shown on the
  # region map if appropriate. The values for each array are as follows:
  #   * Region number.
  #   * Game Switch; the graphic is shown if this is ON (non-wall maps only).
  #   * X coordinate of the graphic on the map, in squares.
  #   * Y coordinate of the graphic on the map, in squares.
  #   * Name of the graphic, found in the Graphics/Pictures folder.
  #   * The graphic will always (true) or never (false) be shown on a wall map.
  REGION_MAP_EXTRAS = [
    [0, 51, 13, 11, "mapHiddenBerth", false],
    [0, 52, 23, 15, "mapHiddenFaraday", false]
  ]

  #=============================================================================

  # A list of maps used by roaming Pokémon. Each map has an array of other maps
  # it can lead to.
  ROAMING_AREAS = {
    48   => [    78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    78   => [48,     79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    79   => [48, 78,     84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    84   => [48, 78, 79,     91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    91   => [48, 78, 79, 84,     99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    99   => [48, 78, 79, 84, 91,     102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    102  => [48, 78, 79, 84, 91, 99,      103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    103  => [48, 78, 79, 84, 91, 99, 102,      104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    104  => [48, 78, 79, 84, 91, 99, 102, 103,      117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    117  => [48, 78, 79, 84, 91, 99, 102, 103, 104,      133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    133  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117,      135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    135  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133,      145, 150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    145  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135,      150, 151, 169, 171, 172, 194, 195, 200, 222, 225],
    150  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145,      151, 169, 171, 172, 194, 195, 200, 222, 225],
    151  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150,      169, 171, 172, 194, 195, 200, 222, 225],
    169  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151,      171, 172, 194, 195, 200, 222, 225],
    171  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169,      172, 194, 195, 200, 222, 225],
    172  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171,      194, 195, 200, 222, 225],
    194  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172,      195, 200, 222, 225],
    195  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194,      200, 222, 225],
    200  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195,      222, 225],
    222  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200,      225],
    225  => [48, 78, 79, 84, 91, 99, 102, 103, 104, 117, 133, 135, 145, 150, 151, 169, 171, 172, 194, 195, 200, 222     ]
  }
  # A set of arrays, each containing the details of a roaming Pokémon. The
  # information within each array is as follows:
  #   * Species.
  #   * Level.
  #   * Game Switch; the Pokémon roams while this is ON.
  #   * Encounter type (0=any, 1=grass/walking in cave, 2=surfing, 3=fishing,
  #     4=surfing/fishing). See the bottom of PField_RoamingPokemon for lists.
  #   * Name of BGM to play for that encounter (optional).
  #   * Roaming areas specifically for this Pokémon (optional).
  ROAMING_SPECIES = [
    [:RAIKOU, 75, 55, 1, "HGSS 168 Battle! (Raikou)"],
    [:SUICUNE, 75, 55, 1, "HGSS 213 Battle! (Suicune)"],
    [:ENTEI, 75, 55, 1, "HGSS 183 Battle! (Entei)", ]
  ]

  #=============================================================================

  # A set of arrays, each containing the details of a wild encounter that can
  # only occur via using the Poké Radar. The information within each array is as
  # follows:
  #   * Map ID on which this encounter can occur.
  #   * Probability that this encounter will occur (as a percentage).
  #   * Species.
  #   * Minimum possible level.
  #   * Maximum possible level (optional).
  POKE_RADAR_ENCOUNTERS = [
    [5,  20, :STARLY,     12, 15],
    [21, 10, :STANTLER,   14],
    [28, 20, :BUTTERFREE, 15, 18],
    [28, 20, :BEEDRILL,   15, 18]
  ]

  #=============================================================================

  # The Game Switch that is set to ON when the player blacks out.
  STARTING_OVER_SWITCH      = 1
  # The Game Switch that is set to ON when the player has seen Pokérus in the
  # Poké Center (and doesn't need to be told about it again).
  SEEN_POKERUS_SWITCH       = 2
  # The Game Switch which, while ON, makes all wild Pokémon created be shiny.
  SHINY_WILD_POKEMON_SWITCH = 31
  # The Game Switch which, while ON, makes all Pokémon created considered to be
  # met via a fateful encounter.
  FATEFUL_ENCOUNTER_SWITCH  = 32
  # The Game Switch which, while ON, blocks access to the Pokemon Box Link
  # Storage functionality. Set this to -1 to always have Pokemon Box Link access.
  POKEMON_BOX_LINK_SWITCH   = -1

  #=============================================================================

  # ID of the animation played when the player steps on grass (grass rustling).
  GRASS_ANIMATION_ID           = 1
  # ID of the animation played when the player lands on the ground after hopping
  # over a ledge (shows a dust impact).
  DUST_ANIMATION_ID            = 2
  # ID of the animation played when a trainer notices the player (an exclamation
  # bubble).
  EXCLAMATION_ANIMATION_ID     = 3
  # ID of the animation played when a patch of grass rustles due to using the
  # Poké Radar.
  RUSTLE_NORMAL_ANIMATION_ID   = 1
  # ID of the animation played when a patch of grass rustles vigorously due to
  # using the Poké Radar. (Rarer species)
  RUSTLE_VIGOROUS_ANIMATION_ID = 5
  # ID of the animation played when a patch of grass rustles and shines due to
  # using the Poké Radar. (Shiny encounter)
  RUSTLE_SHINY_ANIMATION_ID    = 6
  # ID of the animation played when a berry tree grows a stage while the player
  # is on the map (for new plant growth mechanics only).
  PLANT_SPARKLE_ANIMATION_ID   = 7

  #=============================================================================

  # An array of available languages in the game, and their corresponding message
  # file in the Data folder. Edit only if you have 2 or more languages to choose
  # from.
  LANGUAGES = [
  #  ["English", "english.dat"],
  #  ["Deutsch", "deutsch.dat"]
  ]

  #=============================================================================

  # Available speech frames. These are graphic files in "Graphics/Windowskins/".
  SPEECH_WINDOWSKINS = [
    "last wish 1",
    "last wish 2",
    "last wish 3",
    "last wish 4",
    "last wish 5",
    "last wish 6",
    "last wish 7",
    "last wish 8",
    "last wish 9",
    "last wish 10",
    "last wish 11",
    "last wish 12",
    "last wish 13",
    "last wish 14",
    "last wish 15"
  ]

  # Available menu frames. These are graphic files in "Graphics/Windowskins/".
  MENU_WINDOWSKINS = [
    "choice 1",
    "choice 2",
    "choice 3",
    "choice 4",
    "choice 5",
    "choice 6",
    "choice 7",
    "choice 8",
    "choice 9",
    "choice 10",
    "choice 11",
    "choice 12",
    "choice 13",
    "choice 14",
    "choice 15"
  ]
end

# DO NOT EDIT THESE!
module Essentials
  VERSION = "19.1"
  ERROR_TEXT = ""
end
