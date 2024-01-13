module Compiler
  module_function

  def add_PBS_header_to_file(file)
    file.write(0xEF.chr)
    file.write(0xBB.chr)
    file.write(0xBF.chr)
    file.write("\# " + _INTL("See the documentation on the wiki to learn how to edit this file.") + "\r\n")
  end

  #=============================================================================
  # Save map connections to PBS file
  #=============================================================================
  def normalize_connection(conn)
    ret = conn.clone
    if conn[1].negative? != conn[4].negative?   # Exactly one is negative
      ret[4] = -conn[1]
      ret[1] = -conn[4]
    end
    if conn[2].negative? != conn[5].negative?   # Exactly one is negative
      ret[5] = -conn[2]
      ret[2] = -conn[5]
    end
    return ret
  end

  def get_connection_text(map1, x1, y1, map2, x2, y2)
    dims1 = MapFactoryHelper.getMapDims(map1)
    dims2 = MapFactoryHelper.getMapDims(map2)
    if x1 == 0 && x2 == dims2[0]
      return sprintf("%d,West,%d,%d,East,%d", map1, y1, map2, y2)
    elsif y1 == 0 && y2 == dims2[1]
      return sprintf("%d,North,%d,%d,South,%d", map1, x1, map2, x2)
    elsif x1 == dims1[0] && x2 == 0
      return sprintf("%d,East,%d,%d,West,%d", map1, y1, map2, y2)
    elsif y1 == dims1[1] && y2 == 0
      return sprintf("%d,South,%d,%d,North,%d", map1, x1, map2, x2)
    end
    return sprintf("%d,%d,%d,%d,%d,%d", map1, x1, y1, map2, x2, y2)
  end

  def write_connections(path = "PBS/map_connections.txt")
    conndata = load_data("Data/map_connections.dat")
    return if !conndata
    write_pbs_file_message_start(path)
    mapinfos = pbLoadMapInfos
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      f.write("\#-------------------------------\r\n")
      conndata.each do |conn|
        if mapinfos
          # Skip if map no longer exists
          next if !mapinfos[conn[0]] || !mapinfos[conn[3]]
          f.write(sprintf("# %s (%d) - %s (%d)\r\n",
                          (mapinfos[conn[0]]) ? mapinfos[conn[0]].name : "???", conn[0],
                          (mapinfos[conn[3]]) ? mapinfos[conn[3]].name : "???", conn[3]))
        end
        if conn[1].is_a?(String) || conn[4].is_a?(String)
          f.write(sprintf("%d,%s,%d,%d,%s,%d", conn[0], conn[1], conn[2],
                          conn[3], conn[4], conn[5]))
        else
          ret = normalize_connection(conn)
          f.write(get_connection_text(ret[0], ret[1], ret[2], ret[3], ret[4], ret[5]))
        end
        f.write("\r\n")
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save type data to PBS file
  #=============================================================================
  def write_types(path = "PBS/types.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      # Write each type in turn
      GameData::Type.each do |type|
        f.write("\#-------------------------------\r\n")
        f.write("[#{type.id}]\r\n")
        f.write("Name = #{type.real_name}\r\n")
        f.write("IconPosition = #{type.icon_position}\r\n")
        f.write("IsSpecialType = true\r\n") if type.special?
        f.write("IsPseudoType = true\r\n") if type.pseudo_type
        f.write(sprintf("Flags = %s\r\n", type.flags.join(","))) if type.flags.length > 0
        f.write("Weaknesses = #{type.weaknesses.join(',')}\r\n") if type.weaknesses.length > 0
        f.write("Resistances = #{type.resistances.join(',')}\r\n") if type.resistances.length > 0
        f.write("Immunities = #{type.immunities.join(',')}\r\n") if type.immunities.length > 0
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save trainer type data to PBS file
  #=============================================================================
  def write_trainer_types(path = "PBS/trainer_types.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      GameData::TrainerType.each do |t|
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%s]\r\n", t.id))
        f.write(sprintf("Name = %s\r\n", t.real_name))
        gender = GameData::TrainerType::SCHEMA["Gender"][2].key(t.gender)
        f.write(sprintf("Gender = %s\r\n", gender))
        f.write(sprintf("BaseMoney = %d\r\n", t.base_money))
        f.write(sprintf("SkillLevel = %d\r\n", t.skill_level)) if t.skill_level != t.base_money
        f.write(sprintf("Flags = %s\r\n", t.flags.join(","))) if t.flags.length > 0
        f.write(sprintf("IntroBGM = %s\r\n", t.intro_BGM)) if !nil_or_empty?(t.intro_BGM)
        f.write(sprintf("BattleBGM = %s\r\n", t.battle_BGM)) if !nil_or_empty?(t.battle_BGM)
        f.write(sprintf("VictoryBGM = %s\r\n", t.victory_BGM)) if !nil_or_empty?(t.victory_BGM)
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save metadata data to PBS file
  #=============================================================================
  def write_metadata(path = "PBS/metadata.txt")
    write_pbs_file_message_start(path)
    File.open(path, "wb") { |f|
      add_PBS_header_to_file(f)
      # Write metadata
      f.write("\#-------------------------------\r\n")
      f.write("[0]\r\n")
      metadata = GameData::Metadata.get
      schema = GameData::Metadata::SCHEMA
      keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
      keys.each do |key|
        record = metadata.property_from_string(key)
        next if record.nil? || (record.is_a?(Array) && record.empty?)
        f.write(sprintf("%s = ", key))
        pbWriteCsvRecord(record, f, schema[key])
        f.write("\r\n")
      end
      # Write player metadata
      schema = GameData::PlayerMetadata::SCHEMA
      keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
      GameData::PlayerMetadata.each do |player_data|
        f.write("\#-------------------------------\r\n")
        f.write(sprintf("[%d]\r\n", player_data.id))
        keys.each do |key|
          record = player_data.property_from_string(key)
          next if record.nil? || (record.is_a?(Array) && record.empty?)
          f.write(sprintf("%s = ", key))
          pbWriteCsvRecord(record, f, schema[key])
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save map metadata data to PBS file
  #=============================================================================
  def write_map_metadata(path = "PBS/map_metadata.txt")
    write_pbs_file_message_start(path)
    map_infos = pbLoadMapInfos
    schema = GameData::MapMetadata::SCHEMA
    keys = schema.keys.sort { |a, b| schema[a][0] <=> schema[b][0] }
    File.open(path, "wb") { |f|
      idx = 0
      add_PBS_header_to_file(f)
      GameData::MapMetadata.each do |map_data|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        f.write("\#-------------------------------\r\n")
        map_name = (map_infos && map_infos[map_data.id]) ? map_infos[map_data.id].name : nil
        if map_name
          f.write(sprintf("[%03d]   # %s\r\n", map_data.id, map_name))
          f.write("Name = #{map_name}\r\n") if nil_or_empty?(map_data.real_name)
        else
          f.write(sprintf("[%03d]\r\n", map_data.id))
        end
        keys.each do |key|
          record = map_data.property_from_string(key)
          next if record.nil? || (record.is_a?(Array) && record.empty?)
          f.write(sprintf("%s = ", key))
          pbWriteCsvRecord(record, f, schema[key])
          f.write("\r\n")
        end
      end
    }
    process_pbs_file_message_end
  end

  #=============================================================================
  # Save all data to PBS files
  #=============================================================================
  def write_all
    Console.echo_h1 _INTL("Writing all PBS files")
    write_connections
    write_trainer_types
    write_metadata
    write_map_metadata
    echoln ""
    Console.echo_h2("Successfully rewrote all PBS files", text: :green)
  end
end
