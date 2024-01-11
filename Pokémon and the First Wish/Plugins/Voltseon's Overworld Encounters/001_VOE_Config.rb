# IMPORTANT!!
# If you are using Roaming Pokémon, it is necessary to add
# next if $game_temp.overworld_encounter
# after each mention of: next if $PokemonGlobal.roamedAlready
# otherwise Overworld Encounters can trigger Roaming Battles

class VoltseonsOverworldEncounters
  # The animation that plays when an encounter spawns / flees.
  SPAWN_ANIMATION = [2, 21]
  # Sound Effect that plays when an encounter flees.
  FLEE_SOUND = "Door exit"
  # Terrain Tag ids for grass tiles.
  GRASS_TILES = [:Grass, :TallGrass, :DeepSand]
  # Animation that plays for a shiny encounter.
  SHINY_ANIMATION = 7
  # Sound Effect that plays for a shiny encounter.
  SHINY_SOUND = "Mining reveal full"
  # Chance at which the Pokémon is shiny. Use 0 to disable overworld shinies. Set to (SETTINGS::SHINY_POKEMON_CHANCE / 65536) for normal odds.
  SHINY_RATE = 512
  # Whether the game should log when an encounter is being spawned / despawned (this can only be seen in Debug Mode).
  LOG_SPAWNS = false
  # If the option is enabled for the player to disable Overworld Encounters in the game settings.
  DISABLE_SETTINGS = true # This is $game_switches[100]
  # How many tiles the encounters can be away from the player (shiny Pokémon are ignored)
  MAX_DISTANCE = 12
  # How many encounters will be spawned on each map (mapId => numberOfEvents) (0 = default)
  MAX_PER_MAP = {
    # 42 => {:Land => 0, :Water => 0},
    # 57 => {:Land => 5, :Water => 3},
    0 => {:Land => 4, :Water => 6}
  }
  # Whether the events used for encounters should be deleted after they disappear (if set to false could cause lag after a while)
  DELETE_EVENTS = true

  # The amount of encounters currently on the map
  def self.current_encounters
    return 0 if !$game_map
    if !@current_encounters
      count = 0
      $game_map.events.each_value { |event| next unless event.name[/OverworldPkmn/i]; count += 1 }
      @current_encounters = count
    end
    return @current_encounters
  end

  # Setter for the current encounters
  def self.current_encounters=(value)
    @current_encounters = value
  end

  # The amount of encounters currently on the map
  def self.current_encounters_land
    return 0 if !$game_map
    if !@current_encounters_land
      count = 0
      $game_map.events.each_value { |event| next unless event.name[/OverworldPkmn/i]; next unless event.variable; next unless event.variable.terrain == :Land; count += 1 }
      @current_encounters_land = count
    end
    return @current_encounters_land
  end

  # Setter for the current encounters
  def self.current_encounters_land=(value)
    @current_encounters_land = value
  end

  # The amount of encounters currently on the map
  def self.current_encounters_water
    return 0 if !$game_map
    if !@current_encounters_water
      count = 0
      $game_map.events.each_value { |event| next unless event.name[/OverworldPkmn/i]; next unless event.variable; next unless event.variable.terrain == :Water; count += 1 }
      @current_encounters_water = count
    end
    return @current_encounters_water
  end

  # Setter for the current encounters
  def self.current_encounters_water=(value)
    @current_encounters_water = value
  end

  # Get the max amount of encounters for this map
  def self.get_max(enc_type=nil)
    if MAX_PER_MAP[$game_map.map_id]
      return MAX_PER_MAP[$game_map.map_id][:Land] + MAX_PER_MAP[$game_map.map_id][:Water] if enc_type.nil?
      return MAX_PER_MAP[$game_map.map_id][enc_type]
    end
    return MAX_PER_MAP[0][enc_type] if enc_type
    return MAX_PER_MAP[0][:Land] + MAX_PER_MAP[0][:Water]
  end

  # Check if the encounter is possible
  def self.check_encounter_possibility(enc_type)
    case enc_type
    when :Land
      return false if @current_encounters_land >= get_max(enc_type)
    when :Water
      return false if @current_encounters_water >= get_max(enc_type)
    else
      return false if @current_encounters >= get_max
    end
    return true
  end
end

MenuHandlers.add(:options_menu, :owpkmnenabled, {
  "name"        => _INTL("Overworld Encounters"),
  "order"       => 100,
  "type"        => EnumOption,
  "parameters"  => [_INTL("On"), _INTL("Off")],
  "description" => _INTL("Enable/disable overworld encounters."),
  "condition"   => proc { next $game_switches && $game_switches[100] },
  "get_proc"    => proc { next $PokemonSystem.owpkmnenabled },
  "set_proc"    => proc { |value, _scene| $PokemonSystem.owpkmnenabled = value }
})

class PokemonSystem
  attr_accessor :owpkmnenabled # Whether Overworld Pokémon appear (0=on, 1=off)

  def owpkmnenabled
    @owpkmnenabled = 1 if !@owpkmnenabled
    return @owpkmnenabled
  end
end

class PokemonOption_Scene
  alias owpkmn_pbEndScene pbEndScene unless method_defined?(:owpkmn_pbEndScene)

  def pbEndScene
    owpkmn_pbEndScene
    if $PokemonSystem.owpkmnenabled==1 && $PokemonEncounters
      $game_map.events.each_value do |event|
        next unless event.name[/OverworldPkmn/i]
        pbDestroyOverworldEncounter(event, true, false)
      end
    end
  end
end