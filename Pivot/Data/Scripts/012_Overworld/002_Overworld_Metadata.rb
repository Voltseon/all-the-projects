#===============================================================================
# Global metadata not specific to a map.  This class holds field state data that
# span multiple maps.
#===============================================================================
class PokemonGlobalMetadata
  # Movement
  attr_accessor :bicycle
  attr_accessor :surfing
  attr_accessor :diving
  attr_accessor :sliding
  attr_accessor :fishing
  # Player data
  attr_accessor :startTime
  attr_accessor :stepcount
  attr_accessor :pcItemStorage
  attr_accessor :mailbox
  attr_accessor :phoneNumbers
  attr_accessor :phoneTime
  attr_accessor :partner
  attr_accessor :creditsPlayed
  # Pokédex
  attr_accessor :pokedexDex      # Dex currently looking at (-1 is National Dex)
  attr_accessor :pokedexIndex    # Last species viewed per Dex
  attr_accessor :pokedexMode     # Search mode
  attr_accessor :lastmon
  attr_accessor :lastquest
  # Special battle modes
  attr_accessor :safariState
  attr_accessor :bugContestState
  attr_accessor :challenge
  attr_accessor :lastbattle      # Saved recording of a battle
  # Events
  attr_accessor :eventvars
  # Affecting the map
  attr_accessor :bridge
  attr_accessor :repel
  attr_accessor :flashUsed
  attr_reader   :encounter_version
  # Map transfers
  attr_accessor :healingSpot
  attr_accessor :escapePoint
  attr_accessor :pokecenterMapId
  attr_accessor :pokecenterX
  attr_accessor :pokecenterY
  attr_accessor :pokecenterDirection
  # Movement history
  attr_accessor :visitedMaps
  attr_accessor :mapTrail
  # Counters
  attr_accessor :happinessSteps
  attr_accessor :pokerusTime
  # Save file
  attr_accessor :safesave
  # Audio Pack
  attr_accessor :audio_pack

  def initialize
    # Movement
    @bicycle              = false
    @surfing              = false
    @diving               = false
    @sliding              = false
    @fishing              = false
    # Player data
    @startTime            = Time.now
    @stepcount            = 0
    @pcItemStorage        = nil
    @mailbox              = nil
    @phoneNumbers         = []
    @phoneTime            = 0
    @partner              = nil
    @creditsPlayed        = false
    # Special battle modes
    @safariState          = nil
    @bugContestState      = nil
    @challenge            = nil
    @lastbattle           = nil
    # Events
    @eventvars            = {}
    # Affecting the map
    @bridge               = 0
    @repel                = 0
    @flashused            = false
    @encounter_version    = 0
    # Map transfers
    @healingSpot          = nil
    @escapePoint          = []
    @pokecenterMapId      = -1
    @pokecenterX          = -1
    @pokecenterY          = -1
    @pokecenterDirection  = -1
    # Movement history
    @visitedMaps          = []
    @mapTrail             = []
    # Counters
    @happinessSteps       = 0
    @pokerusTime          = nil
    # Save file
    @safesave             = false
    # Audio Pack
    @audio_pack           = :PIVOT
  end

  def audio_pack
    @audio_pack = :PIVOT if !@audio_pack
    if $player.equipped_collectibles[:audiopack]
      @audio_pack = Collectible.get($player.equipped_collectibles[:audiopack]).audio_pack
    end
    return @audio_pack
  end

  def encounter_version=(value)
    validate value => Integer
    return if @encounter_version == value
    @encounter_version = value
  end
end



#===============================================================================
# This class keeps track of erased and moved events so their position
# can remain after a game is saved and loaded.  This class also includes
# variables that should remain valid only for the current map.
#===============================================================================
class PokemonMapMetadata
  attr_reader :erasedEvents
  attr_reader :movedEvents
  attr_accessor :strengthUsed
  attr_accessor :blackFluteUsed
  attr_accessor :whiteFluteUsed

  def initialize
    clear
  end

  def clear
    @erasedEvents   = {}
    @movedEvents    = {}
    @strengthUsed   = false
    @blackFluteUsed = false
    @whiteFluteUsed = false
  end

  def addErasedEvent(eventID)
    key = [$game_map.map_id, eventID]
    @erasedEvents[key] = true
  end

  def addMovedEvent(eventID)
    key               = [$game_map.map_id, eventID]
    event             = $game_map.events[eventID] if eventID.is_a?(Integer)
    @movedEvents[key] = [event.x, event.y, event.direction, event.through] if event
  end

  def updateMap
    @erasedEvents.each do |i|
      $game_map.events[i[0][1]]&.erase if i[0][0] == $game_map.map_id && i[1]
    end
    @movedEvents.each do |i|
      if i[0][0] == $game_map.map_id && i[1]
        next if !$game_map.events[i[0][1]]
        $game_map.events[i[0][1]].moveto(i[1][0], i[1][1])
        case i[1][2]
        when 2 then $game_map.events[i[0][1]].turn_down
        when 4 then $game_map.events[i[0][1]].turn_left
        when 6 then $game_map.events[i[0][1]].turn_right
        when 8 then $game_map.events[i[0][1]].turn_up
        end
      end
      $game_map.events[i[0][1]].through = i[1][3] if i[1][3]
    end
  end
end
