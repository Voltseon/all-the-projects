#==============================================================================#
#                              Pokémon Essentials                              #
#                                 Version 20.1                                 #
#                https://github.com/Maruno17/pokemon-essentials                #
#==============================================================================#

module Settings
  # The version of your game. It has to adhere to the MAJOR.MINOR.PATCH format.
  GAME_VERSION = "1.1.1"

  # The generation that the battle system follows. Used throughout the battle
  # scripts, and also by some other settings which are used in and out of battle
  # (you can of course change those settings to suit your game).
  # Note that this isn't perfect. Essentials doesn't accurately replicate every
  # single generation's mechanics. It's considered to be good enough. Only
  # generations 5 and later are reasonably supported.
  MECHANICS_GENERATION = 9

  #=============================================================================

  # The maximum amount of money the player can have.
  MAX_MONEY            = 999_999
  # The maximum number of Game Corner coins the player can have.
  MAX_COINS            = 99_999
  # The maximum number of Battle Points the player can have.
  MAX_BATTLE_POINTS    = 9_999
  # The maximum amount of soot the player can have.
  MAX_SOOT             = 9_999
  # The maximum length, in characters, that the player's name can be.
  MAX_PLAYER_NAME_SIZE = 10
  # The maximum number of Pokémon that can be in the party.
  MAX_PARTY_SIZE       = 6
  # The maximum level Pokémon can reach.
  MAXIMUM_LEVEL        = 100
  # The level of newly hatched Pokémon.
  EGG_LEVEL            = 1
  # The odds of a newly generated Pokémon being shiny (out of 65536).
  SHINY_POKEMON_CHANCE = 32
  # Whether super shininess is enabled (uses a different shiny animation).
  SUPER_SHINY          = true
  # The odds of a wild Pokémon/bred egg having Pokérus (out of 65536).
  POKERUS_CHANCE       = 3
  # Whether IVs and EVs are treated as 0 when calculating a Pokémon's stats.
  # IVs and EVs still exist, and are used by Hidden Power and some cosmetic
  # things as normal.
  DISABLE_IVS_AND_EVS  = false

  #=============================================================================

  # Whether outdoor maps should be shaded according to the time of day.
  TIME_SHADING                               = true
  # Whether the reflections of the player/events will ripple horizontally.
  ANIMATE_REFLECTIONS                        = true
  # Whether fishing automatically hooks the Pokémon (true), or whether there is
  # a reaction test first (false).
  FISHING_AUTO_HOOK                          = false
  # The ID of the common event that runs when the player starts fishing (runs
  # instead of showing the casting animation).
  FISHING_BEGIN_COMMON_EVENT                 = -1
  # The ID of the common event that runs when the player stops fishing (runs
  # instead of showing the reeling in animation).
  FISHING_END_COMMON_EVENT                   = -1
  # Whether you get 1 Premier Ball for every 10 of any kind of Poké Ball bought
  # at once (true), or 1 Premier Ball for buying 10+ Poké Balls (false).
  MORE_BONUS_PREMIER_BALLS                   = true
  # The number of steps allowed before a Safari Zone game is over (0=infinite).
  SAFARI_STEPS                               = 600
  # The number of seconds a Bug-Catching Contest lasts for (0=infinite).
  BUG_CONTEST_TIME                           = 20 * 60   # 20 minutes

  #=============================================================================

  # Whether the player can choose how many of an item to use at once on a
  # Pokémon. This applies to Exp-changing items (Rare Candy, Exp Candies) and
  # EV-changing items (vitamins, feathers, EV-lowering berries).
  USE_MULTIPLE_STAT_ITEMS_AT_ONCE      = true

  #=============================================================================

  # The default setting for Phone.rematches_enabled, which determines whether
  # trainers registered in the Phone can become ready for a rematch. If false,
  # Phone.rematches_enabled = true will enable rematches at any point you want.
  PHONE_REMATCHES_POSSIBLE_FROM_BEGINNING  = false
  # Whether the messages in a phone call with a trainer are colored blue or red
  # depending on that trainer's gender. Note that this doesn't apply to contacts
  # that are not trainers; they will need to be colored manually in their Common
  # Events.
  COLOR_PHONE_CALL_MESSAGES_BY_CONTACT_GENDER = true

  #=============================================================================

  # A set of arrays each containing a trainer type followed by a Game Variable
  # number. If the Variable isn't set to 0, then all trainers with the
  # associated trainer type will be named as whatever is in that Variable.
  RIVAL_NAMES = [
    [:RIVAL1,   12],
    [:RIVAL2,   12],
    [:CHAMPION, 12]
  ]

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
  BADGE_FOR_FLASH     = 1
  BADGE_FOR_SURF      = 2
  BADGE_FOR_ROCKSMASH = 3
  BADGE_FOR_FLY       = 4
  BADGE_FOR_CUT       = 5
  BADGE_FOR_STRENGTH  = 6
  BADGE_FOR_FIRELASH  = 7
  BADGE_FOR_DIVE      = 8

  #=============================================================================

  # The names of each pocket of the Bag.
  def self.bag_pocket_names
    return [
      _INTL("Items"),
      _INTL("Medicine"),
      _INTL("Poké Balls"),
      _INTL("TMs & HMs"),
      _INTL("Berries"),
      _INTL("Mail"),
      _INTL("Battle Items"),
      _INTL("Key Items")
    ]
  end
  # The maximum number of slots per pocket (-1 means infinite number).
  BAG_MAX_POCKET_SIZE  = [-1, -1, -1, -1, -1, -1, -1, -1]
  # Whether each pocket in turn auto-sorts itself by item ID number.
  BAG_POCKET_AUTO_SORT = [false, false, false, true, true, false, false, false]
  # The maximum number of items each slot in the Bag can hold.
  BAG_MAX_PER_SLOT     = 999

  #=============================================================================

  # The number of boxes in Pokémon storage.
  NUM_STORAGE_BOXES   = 40

  #=============================================================================

  # Whether the Pokédex list shown is the one for the player's current region
  # (true), or whether a menu pops up for the player to manually choose which
  # Dex list to view if more than one is available (false).
  USE_CURRENT_REGION_DEX = false
  # The names of the Pokédex lists, in the order they are defined in the PBS
  # file "regional_dexes.txt". The last name is for the National Dex and is
  # added onto the end of this array (remember that you don't need to use it).
  # This array's order is also the order of $player.pokedex.unlocked_dexes,
  # which records which Dexes have been unlocked (the first is unlocked by
  # default). If an entry is just a name, then the region map shown in the Area
  # page while viewing that Dex list will be the region map of the region the
  # player is currently in. The National Dex entry should always behave like
  # this. If an entry is of the form [name, number], then the number is a region
  # number, and that region's map will appear in the Area page while viewing
  # that Dex list, no matter which region the player is currently in.
  def self.pokedex_names
    return [
      [_INTL("Kanto Pokédex"), 0],
      [_INTL("Johto Pokédex"), 1],
      _INTL("Tepora Pokédex")
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
    [0, 51, 16, 15, "mapHiddenBerth", false],
    [0, 52, 20, 14, "mapHiddenFaraday", false]
  ]

  # Whether the player can use Fly while looking at the Town Map. This is only
  # allowed if the player can use Fly normally.
  CAN_FLY_FROM_TOWN_MAP = true

  #=============================================================================

  # Pairs of map IDs, where the location signpost isn't shown when moving from
  # one of the maps in a pair to the other (and vice versa). Useful for single
  # long routes/towns that are spread over multiple maps.
  #   e.g. [4,5,16,17,42,43] will be map pairs 4,5 and 16,17 and 42,43.
  # Moving between two maps that have the exact same name won't show the
  # location signpost anyway, so you don't need to list those maps here.
  NO_SIGNPOSTS = []

  #=============================================================================

  # A list of maps used by roaming Pokémon. Each map has an array of other maps
  # it can lead to.
  ROAMING_AREAS = {
    48  => [   81, 90, 166, 92, 99, 100, 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    81  => [48   , 90, 166, 92, 99, 100, 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    90  => [48, 81   , 166, 92, 99, 100, 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    166 => [48, 81, 90    , 92, 99, 100, 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    92  => [48, 81, 90, 166   , 99, 100, 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    99  => [48, 81, 90, 166, 92   , 100, 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    100 => [48, 81, 90, 166, 92, 99    , 121, 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    121 => [48, 81, 90, 166, 92, 99, 100    , 122, 123, 133, 134, 148, 149, 157, 172, 186], 
    122 => [48, 81, 90, 166, 92, 99, 100, 121    , 123, 133, 134, 148, 149, 157, 172, 186], 
    123 => [48, 81, 90, 166, 92, 99, 100, 121, 122    , 133, 134, 148, 149, 157, 172, 186], 
    133 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123    , 134, 148, 149, 157, 172, 186], 
    134 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123, 133    , 148, 149, 157, 172, 186], 
    148 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123, 133, 134    , 149, 157, 172, 186], 
    149 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123, 133, 134, 148    , 157, 172, 186], 
    157 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123, 133, 134, 148, 149    , 172, 186], 
    172 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123, 133, 134, 148, 149, 157    , 186], 
    186 => [48, 81, 90, 166, 92, 99, 100, 121, 122, 123, 133, 134, 148, 149, 157, 172    ]
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
    [:ARTICUNO, 45, 101, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:ZAPDOS, 45, 102, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:MOLTRES, 45, 103, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:RAIKOU, 45, 104, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:ENTEI, 45, 105, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:SUICUNE, 45, 106, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:UXIE, 45, 107, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:MESPRIT, 45, 108, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:AZELF, 45, 109, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:CRESSELIA, 45, 110, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:DARKRAI, 45, 111, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:COBALION, 45, 112, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:TERRAKION, 45, 113, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:VIRIZION, 45, 114, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:TORNADUS, 45, 115, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:THUNDURUS, 45, 116, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:LANDORUS, 45, 117, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:TINGLU, 45, 118, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:CHIENPAO, 45, 119, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:WOCHIEN, 45, 120, 0, "RSE 256 Classic Battle Theme (Unused)"],
    [:CHIYU, 45, 121, 0, "RSE 256 Classic Battle Theme (Unused)"]
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
  # The Game Switch which, while ON, disables the effect of the Pokémon Box Link
  # and prevents the player from accessing Pokémon storage via the party screen
  # with it.
  DISABLE_BOX_LINK_SWITCH   = 35

  #=============================================================================

  # ID of the animation played when the player steps on grass (grass rustling).
  GRASS_ANIMATION_ID           = 1
  # ID of the animation played when the player lands on the ground after hopping
  # over a ledge (shows a dust impact).
  DUST_ANIMATION_ID            = 2
  DUST_ANIMATION_DIVE_ID       = 22
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

  # The default screen width (at a scale of 1.0).
  SCREEN_WIDTH  = 512
  # The default screen height (at a scale of 1.0).
  SCREEN_HEIGHT = 384
  # The default screen scale factor. Possible values are 0.5, 1.0, 1.5 and 2.0.
  SCREEN_SCALE  = 1.0

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
    "speech em"
  ]

  # Available menu frames. These are graphic files in "Graphics/Windowskins/".
  MENU_WINDOWSKINS = [
    "choice 1"
  ]

  def self.pbGetGeneration
    return $player.generation if $player
    return MECHANICS_GENERATION
  end
end

# DO NOT EDIT THESE!
module Essentials
  VERSION = "20.1"
  ERROR_TEXT = "[v20.1 Hotfixes 1.0.7]\r\n"
end
