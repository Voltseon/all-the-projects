module GameData
  class Planet
    attr_reader :id, :name, :map_id, :description, :shows_on_map, :map_x, :map_y, :frame_count, :gravity
    attr_reader :connection_top, :connection_bottom, :connection_left, :connection_right

    DATA = {}
    DATA_FILENAME = "planets.dat"

    SCHEMA = {
      "Name"              => [:name,               "s"],
      "MapID"             => [:map_id,             "U"],
      "Description"       => [:description,        "S"],
      "ShowsOnMap"        => [:shows_on_map,       "B"],
      "MapX"              => [:map_x,              "U"],
      "MapY"              => [:map_y,              "U"],
      "FrameCount"        => [:frame_count,        "U"],
      "Gravity"           => [:gravity,            "F"],
      "ConnectionTop"     => [:connection_top,     "*S"],
      "ConnectionBottom"  => [:connection_bottom,  "*S"],
      "ConnectionLeft"    => [:connection_left,    "*S"],
      "ConnectionRight"   => [:connection_right,   "*S"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.exists?(planet)
      return true if planet.is_a?(Planet)
      return false if !planet || planet == :NONE
      planet = get_planet(planet)
      return DATA.keys.include?(planet)
    end

    def self.get_planet(planet)
      return planet if planet.is_a?(Planet)
      return nil if !planet || planet == :NONE
      planet = planet.id if planet.respond_to?(:id)
      return nil if !planet || planet == :NONE
      return planet
    end

    def self.try_get(planet)
      return nil if !planet || planet == :NONE
      planet = planet.id if planet.respond_to?(:id)
      return DATA[planet]
    end

    def self.get(planet)
      planet_data = try_get(planet)
      return planet_data if planet_data
      raise _INTL("planet does not exist: {1}", planet.inspect)
    end

    def self.load
      super
      self.each { |p| p.check_connections }
    end

    def self.editor_properties
      return [
        ["Name",              StringProperty,          _INTL("The name of the planet.")],
        ["MapID",             MapProperty,             _INTL("The ID of the map the planet is on.")],
        ["Description",       StringProperty,          _INTL("The description of the planet.")],
        ["ShowsOnMap",        BooleanProperty,         _INTL("Whether the planet shows on the map.")],
        ["MapX",              IntegerProperty,         _INTL("The X coordinate of the planet on the map.")],
        ["MapY",              IntegerProperty,         _INTL("The Y coordinate of the planet on the map.")],
        ["FrameCount",        IntegerProperty,         _INTL("The number of frames in the planet's animation.")],
        ["Gravity",           FloatProperty,           _INTL("The gravity of the planet.")],
        ["ConnectionTop",     StringArrayProperty,     _INTL("The planets connected to the top of this planet.")],
        ["ConnectionBottom",  StringArrayProperty,     _INTL("The planets connected to the bottom of this planet.")],
        ["ConnectionLeft",    StringArrayProperty,     _INTL("The planets connected to the left of this planet.")],
        ["ConnectionRight",   StringArrayProperty,     _INTL("The planets connected to the right of this planet.")]
      ]
    end

    def initialize(hash)
      @id           = hash[:id].to_sym
      @name         = hash[:name]
      @map_id       = hash[:map_id].to_i
      @description  = hash[:description]
      @shows_on_map = hash[:shows_on_map] || hash[:shows_on_map] == "true"
      @map_x        = hash[:map_x] ? hash[:map_x].to_i : 0
      @map_y        = hash[:map_y] ? hash[:map_y].to_i : 0
      @frame_count  = hash[:frame_count] ? hash[:frame_count].to_i : 1
      @gravity      = hash[:gravity] ? hash[:gravity].to_f : 1.0
      @connection_top     = hash[:connection_top] ? [hash[:connection_top][0].to_sym, hash[:connection_top][1].to_i] : []
      @connection_bottom  = hash[:connection_bottom] ? [hash[:connection_bottom][0].to_sym, hash[:connection_bottom][1].to_i] : []
      @connection_left    = hash[:connection_left] ? [hash[:connection_left][0].to_sym, hash[:connection_left][1].to_i] : []
      @connection_right   = hash[:connection_right] ? [hash[:connection_right][0].to_sym, hash[:connection_right][1].to_i] : []
    end

    def check_connections
      GameData::Planet.each do |planet|
        next if planet.id == @id
        if planet.connection_bottom[0] == @id
          @connection_top = [planet.id, planet.connection_top[1]]
        end
        if planet.connection_top[0] == @id
          @connection_bottom = [planet.id, planet.connection_bottom[1]]
        end
        if planet.connection_right[0] == @id
          @connection_left = [planet.id, planet.connection_left[1]]
        end
        if planet.connection_left[0] == @id
          @connection_right = [planet.id, planet.connection_right[1]]
        end
      end
    end

    def connections
      return [@connection_top, @connection_bottom, @connection_left, @connection_right]
    end
  end
end