module GameData
  class TrainerType
    attr_reader :id
    attr_reader :real_name
    attr_reader :gender
    attr_reader :base_money
    attr_reader :skill_level
    attr_reader :flags
    attr_reader :intro_BGM
    attr_reader :battle_BGM
    attr_reader :victory_BGM

    DATA = {}
    DATA_FILENAME = "trainer_types.dat"

    SCHEMA = {
      "Name"       => [:name,        "s"],
      "Gender"     => [:gender,      "e", { "Male" => 0, "male" => 0, "M" => 0, "m" => 0, "0" => 0,
                                           "Female" => 1, "female" => 1, "F" => 1, "f" => 1, "1" => 1,
                                           "Unknown" => 2, "unknown" => 2, "Other" => 2, "other" => 2,
                                           "Mixed" => 2, "mixed" => 2, "X" => 2, "x" => 2, "2" => 2 }],
      "BaseMoney"  => [:base_money,  "u"],
      "SkillLevel" => [:skill_level, "u"],
      "Flags"      => [:flags,       "*s"],
      "IntroBGM"   => [:intro_BGM,   "s"],
      "BattleBGM"  => [:battle_BGM,  "s"],
      "VictoryBGM" => [:victory_BGM, "s"]
    }

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.check_file(tr_type, path, optional_suffix = "", suffix = "")
      tr_type_data = self.try_get(tr_type)
      return nil if tr_type_data.nil?
      # Check for files
      if optional_suffix && !optional_suffix.empty?
        ret = path + tr_type_data.id.to_s + optional_suffix + suffix
        return ret if pbResolveBitmap(ret)
      end
      ret = path + tr_type_data.id.to_s + suffix
      return (pbResolveBitmap(ret)) ? ret : nil
    end

    def self.charset_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Characters/trainer_")
    end

    def self.charset_filename_brief(tr_type)
      ret = self.charset_filename(tr_type)
      ret&.slice!("Graphics/Characters/")
      return ret
    end

    def self.charset_conv(tr_type)
      charsets = {
        :HIKER => "trchar018",
        :RUINMANIAC => "trchar018",
        :AROMALADY => "trchar006",
        :LADY => "trchar006_1",
        :BEAUTY => "trchar007",
        :PARASOLLADY => "trchar036",
        :CYCLIST_M => "trchar008",
        :CYCLIST_F => "trchar013",
        :BIRDKEEPER => "trchar009",
        :BUGCATCHER => "trchar010",
        :BURGLAR => "trchar009",
        :HEXMANIAC => "trchar012",
        :CUEBALL => "trchar008",
        :ENGINEER => "trchar009",
        :FISHERMAN => "trchar015",
        :GAMBLER => "trchar016",
        :GENTLEMAN => "trchar017",
        :JUGGLER => "trchar009",
        :PAINTER => "trchar047",
        :POKEMANIAC => "trchar014",
        :KINDLER => "trchar018",
        :POKEMONBREEDER_M => "trchar033",
        :POKEMONBREEDER_F => "trchar034",
        :POKEFAN_M => "trchar014",
        :POKEFAN_F => "trchar023",
        :ROCKER => "trchar009",
        :SAILOR => "trchar027",
        :SCIENTIST => "trchar028",
        :SUPERNERD => "trchar029",
        :TAMER => "trchar009",
        :COLLECTOR => "trchar011",
        :BLACKBELT => "trchar031",
        :CRUSHGIRL => "trchar020_1",
        :CAMPER => "trchar033",
        :PICNICKER => "trchar034",
        :SCHOOLKID_M => "trchar022",
        :SCHOOLKID_F => "trchar020_1",
        :COOLTRAINER_M => "trchar035",
        :COOLTRAINER_F => "trchar036",
        :VETERAN_M => "trchar016",
        :VETERAN_F => "trchar050",
        :NINJAKID => "NPC 01",
        :YOUNGSTER => "trchar037",
        :LASS => "trchar021",
        :RICHBOY => "trchar035",
        :POKEMONRANGER_M => "trchar033",
        :POKEMONRANGER_F => "trchar034",
        :PSYCHIC_M => "trchar041",
        :PSYCHIC_F => "trchar021",
        :TRIATHLETE_M => "trchar019",
        :TRIATHLETE_F => "trchar020",
        :TRIATHLETE2_M => "trchar019",
        :TRIATHLETE2_F => "trchar020",
        :SWIMMER_M => "trchar045_1",
        :SWIMMER_F => "trchar046_1",
        :SWIMMER2_M => "trchar045_1",
        :SWIMMER2_F => "trchar046_1",
        :TUBER_M => "trchar049_1",
        :TUBER_F => "trchar049_2",
        :TUBER2_M => "trchar049_1",
        :TUBER2_F => "trchar049_2"
      }
      return charsets[tr_type]
    end

    def self.front_sprite_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Trainers/")
    end

    def self.player_front_sprite_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit))
    end

    def self.back_sprite_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Trainers/", "", "_back")
    end

    def self.player_back_sprite_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/Trainers/", sprintf("_%d", outfit), "_back")
    end

    def self.map_icon_filename(tr_type)
      return self.check_file(tr_type, "Graphics/Pictures/mapPlayer")
    end

    def self.player_map_icon_filename(tr_type)
      outfit = ($player) ? $player.outfit : 0
      return self.check_file(tr_type, "Graphics/Pictures/mapPlayer", sprintf("_%d", outfit))
    end

    def initialize(hash)
      @id          = hash[:id]
      @real_name   = hash[:name]        || "Unnamed"
      @gender      = hash[:gender]      || 2
      @base_money  = hash[:base_money]  || 30
      @skill_level = hash[:skill_level] || @base_money
      @flags       = hash[:flags]       || []
      @intro_BGM   = hash[:intro_BGM]
      @battle_BGM  = hash[:battle_BGM]
      @victory_BGM = hash[:victory_BGM]
    end

    # @return [String] the translated name of this trainer type
    def name
      return pbGetMessageFromHash(MessageTypes::TrainerTypes, @real_name)
    end

    def male?;   return @gender == 0; end
    def female?; return @gender == 1; end

    def has_flag?(flag)
      return @flags.any? { |f| f.downcase == flag.downcase }
    end
  end
end
