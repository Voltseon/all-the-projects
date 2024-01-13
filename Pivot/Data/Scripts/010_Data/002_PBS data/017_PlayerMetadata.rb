module GameData
  class PlayerMetadata
    attr_reader :id
    attr_reader :trainer_type
    attr_reader :walk_charset
    attr_reader :home

    DATA = {}
    DATA_FILENAME = "player_metadata.dat"

    SCHEMA = {
      "TrainerType"     => [1, "e", :TrainerType],
      "WalkCharset"     => [2, "s"],
      "RunCharset"      => [3, "s"],
      "CycleCharset"    => [4, "s"],
      "SurfCharset"     => [5, "s"],
      "DiveCharset"     => [6, "s"],
      "FishCharset"     => [7, "s"],
      "SurfFishCharset" => [8, "s"],
      "Home"            => [9, "vuuu"],
      "ThrowCharset"    => [10, "s"],
      "BookCharset"     => [11, "s"],
      "MoveSpeed"       => [12, "u"],
      "Attack"          => [13, "u"],
      "HP"              => [14, "u"],
      "HurtCharset"     => [15, "s"],
      "IdleCharset"     => [16, "s"],
      "PhysicalCharset" => [17, "s"],
      "RangedCharset"   => [18, "s"],
      "GuardCharset"    => [19, "s"],
      "AbilityCharset"  => [20, "s"],
      "MovementType"    => [21, "u"],
      "Evolution"       => [22, "s"],
      "Description"     => [23, "s"],
      "UnlockedAt"      => [24, "u"]
    }

    extend ClassMethodsIDNumbers
    include InstanceMethods

    def self.editor_properties
      return [
        ["TrainerType",     TrainerTypeProperty,     _INTL("Trainer type of this player.")],
        ["WalkCharset",     CharacterProperty,       _INTL("Charset used while the player is still or walking.")],
        ["RunCharset",      CharacterProperty,       _INTL("Charset used while the player is running. Uses WalkCharset if undefined.")],
        ["CycleCharset",    CharacterProperty,       _INTL("Charset used while the player is cycling. Uses RunCharset if undefined.")],
        ["SurfCharset",     CharacterProperty,       _INTL("Charset used while the player is surfing. Uses CycleCharset if undefined.")],
        ["DiveCharset",     CharacterProperty,       _INTL("Charset used while the player is diving. Uses SurfCharset if undefined.")],
        ["FishCharset",     CharacterProperty,       _INTL("Charset used while the player is fishing. Uses WalkCharset if undefined.")],
        ["SurfFishCharset", CharacterProperty,       _INTL("Charset used while the player is fishing while surfing. Uses FishCharset if undefined.")],
        ["Home",            MapCoordsFacingProperty, _INTL("Map ID and X/Y coordinates of where the player goes after a loss if no Pokémon Center was visited.")],
        ["ThrowCharset",    CharacterProperty,       _INTL("Charset used while the player is throwing. Uses WalkCharset if undefined.")],
        ["BookCharset",     CharacterProperty,       _INTL("Charset used while the player is reading. Uses WalkCharset if undefined.")],
        ["MoveSpeed",       LimitProperty.new(10),   _INTL("The speed of the character out of 10.")],
        ["Attack",          LimitProperty.new(10),   _INTL("The speed of the character out of 10.")],
        ["HP",              LimitProperty.new(100),  _INTL("The speed of the character out of 100.")],
        ["HurtCharset",     CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["IdleCharset",     CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["PhysicalCharset", CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["RangedCharset",   CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["GuardCharset",    CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["AbilityCharset",  CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["MovementType",    LimitProperty.new(10),   _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["Evolution",       CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["Description",     CharacterProperty,       _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")],
        ["UnlockedAt",      LimitProperty.new(100),  _INTL("Charset used while the player is walking diagonally. Uses WalkCharset if undefined.")]
      ]
    end

    # @param player_id [Integer]
    # @return [self, nil]
    def self.get(player_id = 1)
      validate player_id => Integer
      return self::DATA[player_id] if self::DATA.has_key?(player_id)
      return self::DATA[1]
    end

    def initialize(hash)
      @id                = hash[:id]
      @trainer_type      = hash[:trainer_type]
      @walk_charset      = hash[:walk_charset]
      @run_charset       = hash[:run_charset]
      @cycle_charset     = hash[:cycle_charset]
      @surf_charset      = hash[:surf_charset]
      @dive_charset      = hash[:dive_charset]
      @fish_charset      = hash[:fish_charset]
      @throw_charset     = hash[:throw_charset]
      @book_charset      = hash[:book_charset]
      @surf_fish_charset = hash[:surf_fish_charset]
      @home              = hash[:home]
      @hurt_charset      = hash[:hurt_charset]
      @idle_charset      = hash[:idle_charset]
      @physical_charset  = hash[:physical_charset]
      @ranged_charset    = hash[:ranged_charset]
      @guard_charset     = hash[:guard_charset]
      @ability_charset   = hash[:ability_charset]
      @evolution         = hash[:evolution]
      @movement_type     = hash[:movement_type]
      @unlocked_at       = hash[:unlocked_at]
      @description       = hash[:description]
      @move_speed        = hash[:move_speed]
      @attack            = hash[:attack]
      @hp                = hash[:hp]
    end

    def run_charset
      return @run_charset || @walk_charset
    end

    def hurt_charset
      return @hurt_charset
    end

    def idle_charset
      return @idle_charset
    end

    def physical_charset
      return @physical_charset
    end

    def ranged_charset
      return @ranged_charset
    end

    def guard_charset
      return @guard_charset
    end

    def ability_charset
      return @ability_charset || @walk_charset
    end

    def evolution
      return @evolution
    end

    def movement_type
      return @movement_type.to_i || 0
    end

    def unlocked_at
      return @unlocked_at.to_i || 0
    end

    def description
      return @description || ""
    end

    def real_trainer_type
      return GameData::TrainerType.get(@trainer_type)
    end

    def name
      return real_trainer_type.name
    end

    def move_speed
      return $player.slow_speed if $player.slowed
      return @move_speed
    end

    def attack
      return @attack
    end

    def hp
      return @hp
    end

    def cycle_charset
      return @cycle_charset || run_charset
    end

    def surf_charset
      return @surf_charset || cycle_charset
    end

    def dive_charset
      return @dive_charset || surf_charset
    end

    def fish_charset
      return @fish_charset || @walk_charset
    end

    def throw_charset
      return @throw_charset || @walk_charset
    end

    def book_charset
      return @book_charset || @walk_charset
    end

    def surf_fish_charset
      return @surf_fish_charset || fish_charset
    end

    def property_from_string(str)
      case str
      when "TrainerType"     then return @trainer_type
      when "WalkCharset"     then return @walk_charset
      when "RunCharset"      then return @run_charset
      when "CycleCharset"    then return @cycle_charset
      when "SurfCharset"     then return @surf_charset
      when "DiveCharset"     then return @dive_charset
      when "FishCharset"     then return @fish_charset
      when "ThrowCharset"    then return @throw_charset
      when "BookCharset"     then return @book_charset
      when "SurfFishCharset" then return @surf_fish_charset
      when "HurtCharset"     then return @hurt_charset
      when "IdleCharset"     then return @idle_charset
      when "MoveSpeed"       then return @move_speed
      when "Attack"          then return @attack
      when "HP"              then return @hp
      when "Home"            then return @home
      when "PhysicalCharset" then return @physical_charset
      when "RangedCharset"   then return @ranged_charset
      when "GuardCharset"    then return @guard_charset
      when "AbilityCharset"  then return @ability_charset
      when "Evolution"       then return @evolution
      when "MovementType"    then return @movement_type
      when "UnlockedAt"      then return @unlocked_at
      when "Description"     then return @description
      end
      return nil
    end
  end
end
