module Compiler
  module_function

  #=============================================================================
  # Compile map connections
  #=============================================================================
  def compile_connections(path = "PBS/map_connections.txt")
    compile_pbs_file_message_start(path)
    records   = []
    pbCompilerEachPreppedLine(path) { |line, lineno|
      hashenum = {
        "N" => "N", "North" => "N",
        "E" => "E", "East"  => "E",
        "S" => "S", "South" => "S",
        "W" => "W", "West"  => "W"
      }
      record = []
      thisline = line.dup
      record.push(csvInt!(thisline, lineno))
      record.push(csvEnumFieldOrInt!(thisline, hashenum, "", sprintf("(line %d)", lineno)))
      record.push(csvInt!(thisline, lineno))
      record.push(csvInt!(thisline, lineno))
      record.push(csvEnumFieldOrInt!(thisline, hashenum, "", sprintf("(line %d)", lineno)))
      record.push(csvInt!(thisline, lineno))
      if !pbRgssExists?(sprintf("Data/Map%03d.rxdata", record[0]))
        print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}", record[0], FileLineData.linereport)
      end
      if !pbRgssExists?(sprintf("Data/Map%03d.rxdata", record[3]))
        print _INTL("Warning: Map {1}, as mentioned in the map connection data, was not found.\r\n{2}", record[3], FileLineData.linereport)
      end
      case record[1]
      when "N"
        raise _INTL("North side of first map must connect with south side of second map\r\n{1}", FileLineData.linereport) if record[4] != "S"
      when "S"
        raise _INTL("South side of first map must connect with north side of second map\r\n{1}", FileLineData.linereport) if record[4] != "N"
      when "E"
        raise _INTL("East side of first map must connect with west side of second map\r\n{1}", FileLineData.linereport) if record[4] != "W"
      when "W"
        raise _INTL("West side of first map must connect with east side of second map\r\n{1}", FileLineData.linereport) if record[4] != "E"
      end
      records.push(record)
    }
    save_data(records, "Data/map_connections.dat")
    process_pbs_file_message_end
  end

  #=============================================================================
  # Compile type data
  #=============================================================================
  def compile_types(path = "PBS/types.txt")
    compile_pbs_file_message_start(path)
    GameData::Type::DATA.clear
    type_names = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::Type::SCHEMA
      pbEachFileSection(f) { |contents, type_id|
        contents["InternalName"] = type_id if !type_id[/^\d+/]
        icon_pos = (type_id[/^\d+/]) ? type_id.to_i : nil
        # Go through schema hash of compilable data and compile this section
        schema.each_key do |key|
          FileLineData.setSection(type_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if ["Name", "InternalName"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, type_id)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.empty?
          contents[key] = value
          # Ensure weaknesses/resistances/immunities are in arrays and are symbols
          if value && ["Weaknesses", "Resistances", "Immunities"].include?(key)
            contents[key].map! { |x| x.to_sym }
            contents[key].uniq!
          end
        end
        # Construct type hash
        type_hash = {
          :id            => contents["InternalName"].to_sym,
          :name          => contents["Name"],
          :pseudo_type   => contents["IsPseudoType"],
          :special_type  => contents["IsSpecialType"],
          :flags         => contents["Flags"],
          :weaknesses    => contents["Weaknesses"],
          :resistances   => contents["Resistances"],
          :immunities    => contents["Immunities"],
          :icon_position => contents["IconPosition"] || icon_pos
        }
        # Add type's data to records
        GameData::Type.register(type_hash)
        type_names.push(type_hash[:name])
      }
    }
    # Ensure all weaknesses/resistances/immunities are valid types
    GameData::Type.each do |type|
      type.weaknesses.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Weaknesses).", other_type.to_s, path, type.id)
      end
      type.resistances.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Resistances).", other_type.to_s, path, type.id)
      end
      type.immunities.each do |other_type|
        next if GameData::Type.exists?(other_type)
        raise _INTL("'{1}' is not a defined type ({2}, section {3}, Immunities).", other_type.to_s, path, type.id)
      end
    end
    # Save all data
    GameData::Type.save
    MessageTypes.setMessagesAsHash(MessageTypes::Types, type_names)
    process_pbs_file_message_end
  end

  #=============================================================================
  # Compile trainer type data
  #=============================================================================
  def compile_trainer_types(path = "PBS/trainer_types.txt")
    compile_pbs_file_message_start(path)
    GameData::TrainerType::DATA.clear
    schema = GameData::TrainerType::SCHEMA
    tr_type_names = []
    tr_type_hash  = nil
    # Read each line of trainer_types.txt at a time and compile it into a trainer type
    pbCompilerEachPreppedLine(path) { |line, line_no|
      if line[/^\s*\[\s*(.+)\s*\]\s*$/]   # New section [tr_type_id]
        # Add previous trainer type's data to records
        GameData::TrainerType.register(tr_type_hash) if tr_type_hash
        # Parse trainer type ID
        tr_type_id = $~[1].to_sym
        if GameData::TrainerType.exists?(tr_type_id)
          raise _INTL("Trainer Type ID '{1}' is used twice.\r\n{2}", tr_type_id, FileLineData.linereport)
        end
        # Construct trainer type hash
        tr_type_hash = {
          :id => tr_type_id
        }
      elsif line[/^\s*(\w+)\s*=\s*(.*)\s*$/]   # XXX=YYY lines
        if !tr_type_hash
          raise _INTL("Expected a section at the beginning of the file.\r\n{1}", FileLineData.linereport)
        end
        # Parse property and value
        property_name = $~[1]
        line_schema = schema[property_name]
        next if !line_schema
        property_value = pbGetCsvRecord($~[2], line_no, line_schema)
        # Record XXX=YYY setting
        tr_type_hash[line_schema[0]] = property_value
        tr_type_names.push(tr_type_hash[:name]) if property_name == "Name"
      else   # Old format
        # Add previous trainer type's data to records
        GameData::TrainerType.register(tr_type_hash) if tr_type_hash
        # Parse trainer type
        line = pbGetCsvRecord(line, line_no,
                              [0, "snsUSSSeUS",
                               nil, nil, nil, nil, nil, nil, nil,
                               { "Male"   => 0, "M" => 0, "0" => 0,
                                 "Female" => 1, "F" => 1, "1" => 1,
                                 "Mixed"  => 2, "X" => 2, "2" => 2, "" => 2 },
                               nil, nil])
        tr_type_id = line[1].to_sym
        if GameData::TrainerType.exists?(tr_type_id)
          raise _INTL("Trainer Type ID '{1}' is used twice.\r\n{2}", tr_type_id, FileLineData.linereport)
        end
        # Construct trainer type hash
        tr_type_hash = {
          :id          => tr_type_id,
          :name        => line[2],
          :base_money  => line[3],
          :battle_BGM  => line[4],
          :victory_BGM => line[5],
          :intro_BGM   => line[6],
          :gender      => line[7],
          :skill_level => line[8],
          :flags       => line[9]
        }
        # Add trainer type's data to records
        GameData::TrainerType.register(tr_type_hash)
        tr_type_names.push(tr_type_hash[:name])
        tr_type_hash = nil
      end
    }
    # Add last trainer type's data to records
    GameData::TrainerType.register(tr_type_hash) if tr_type_hash
    # Save all data
    GameData::TrainerType.save
    MessageTypes.setMessagesAsHash(MessageTypes::TrainerTypes, tr_type_names)
    process_pbs_file_message_end
  end

  #=============================================================================
  # Compile metadata
  #=============================================================================
  def compile_metadata(path = "PBS/metadata.txt")
    compile_pbs_file_message_start(path)
    GameData::Metadata::DATA.clear
    GameData::PlayerMetadata::DATA.clear
    storage_creator = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      pbEachFileSectionNumbered(f) { |contents, section_id|
        schema = (section_id == 0) ? GameData::Metadata::SCHEMA : GameData::PlayerMetadata::SCHEMA
        # Go through schema hash of compilable data and compile this section
        schema.each_key do |key|
          FileLineData.setSection(section_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if section_id == 0 && ["Home"].include?(key)
              raise _INTL("The entry {1} is required in {2} section 0.", key, path)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
        end
        if section_id == 0   # Metadata
          # Construct metadata hash
          metadata_hash = {
            :id                  => section_id,
            :start_money         => contents["StartMoney"],
            :start_item_storage  => contents["StartItemStorage"],
            :home                => contents["Home"],
            :storage_creator     => contents["StorageCreator"],
            :wild_battle_BGM     => contents["WildBattleBGM"],
            :trainer_battle_BGM  => contents["TrainerBattleBGM"],
            :wild_victory_BGM    => contents["WildVictoryBGM"],
            :trainer_victory_BGM => contents["TrainerVictoryBGM"],
            :wild_capture_ME     => contents["WildCaptureME"],
            :surf_BGM            => contents["SurfBGM"],
            :bicycle_BGM         => contents["BicycleBGM"]
          }
          storage_creator[0] = contents["StorageCreator"]
          # Add metadata's data to records
          GameData::Metadata.register(metadata_hash)
        else   # Player metadata
          # Construct metadata hash
          metadata_hash = {
            :id                => section_id,
            :trainer_type      => contents["TrainerType"],
            :walk_charset      => contents["WalkCharset"],
            :run_charset       => contents["RunCharset"],
            :cycle_charset     => contents["CycleCharset"],
            :surf_charset      => contents["SurfCharset"],
            :dive_charset      => contents["DiveCharset"],
            :fish_charset      => contents["FishCharset"],
            :throw_charset     => contents["ThrowCharset"],
            :book_charset      => contents["BookCharset"],
            :surf_fish_charset => contents["SurfFishCharset"],
            :move_speed        => contents["MoveSpeed"],
            :attack            => contents["Attack"],
            :hp                => contents["HP"],
            :hurt_charset      => contents["HurtCharset"],
            :idle_charset      => contents["IdleCharset"],
            :physical_charset  => contents["PhysicalCharset"],
            :ranged_charset    => contents["RangedCharset"],
            :guard_charset     => contents["GuardCharset"],
            :ability_charset   => contents["AbilityCharset"],
            :evolution         => contents["Evolution"],
            :movement_type     => contents["MovementType"],
            :description       => contents["Description"],
            :unlocked_at       => contents["UnlockedAt"]
          }
          # Add metadata's data to records
          GameData::PlayerMetadata.register(metadata_hash)
        end
      }
    }
    if !GameData::PlayerMetadata.exists?(1)
      raise _INTL("Metadata for player character 1 in {1} is not defined but should be.", path)
    end
    # Save all data
    GameData::Metadata.save
    GameData::PlayerMetadata.save
    MessageTypes.setMessages(MessageTypes::StorageCreator, storage_creator)
    process_pbs_file_message_end
  end

  #=============================================================================
  # Compile map metadata
  #=============================================================================
  def compile_map_metadata(path = "PBS/map_metadata.txt")
    compile_pbs_file_message_start(path)
    GameData::MapMetadata::DATA.clear
    map_infos = pbLoadMapInfos
    map_names = []
    map_infos.each_key { |id| map_names[id] = map_infos[id].name }
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::MapMetadata::SCHEMA
      idx = 0
      pbEachFileSectionNumbered(f) { |contents, map_id|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        # Go through schema hash of compilable data and compile this section
        schema.each_key do |key|
          FileLineData.setSection(map_id, key, contents[key])   # For error reporting
          # Skip empty properties
          next if contents[key].nil?
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          value = nil if value.is_a?(Array) && value.length == 0
          contents[key] = value
        end
        # Construct map metadata hash
        metadata_hash = {
          :id                   => map_id,
          :name                 => contents["Name"],
          :outdoor_map          => contents["Outdoor"],
          :announce_location    => contents["ShowArea"],
          :can_bicycle          => contents["Bicycle"],
          :always_bicycle       => contents["BicycleAlways"],
          :teleport_destination => contents["HealingSpot"],
          :weather              => contents["Weather"],
          :dive_map_id          => contents["DiveMap"],
          :dark_map             => contents["DarkMap"],
          :safari_map           => contents["SafariMap"],
          :snap_edges           => contents["SnapEdges"],
          :random_dungeon       => contents["Dungeon"],
          :battle_background    => contents["BattleBack"],
          :wild_battle_BGM      => contents["WildBattleBGM"],
          :trainer_battle_BGM   => contents["TrainerBattleBGM"],
          :wild_victory_BGM     => contents["WildVictoryBGM"],
          :trainer_victory_BGM  => contents["TrainerVictoryBGM"],
          :wild_capture_ME      => contents["WildCaptureME"],
          :battle_environment   => contents["Environment"],
          :flags                => contents["Flags"]
        }
        # Add map metadata's data to records
        GameData::MapMetadata.register(metadata_hash)
        map_names[map_id] = metadata_hash[:name] if !nil_or_empty?(metadata_hash[:name])
      }
    }
    # Save all data
    GameData::MapMetadata.save
    MessageTypes.setMessages(MessageTypes::MapNames, map_names)
    process_pbs_file_message_end
  end
end