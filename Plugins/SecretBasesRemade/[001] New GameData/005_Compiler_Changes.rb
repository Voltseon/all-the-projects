module GameData
  class << self
    alias _secretbase_load_all load_all
    def load_all
      _secretbase_load_all
      SecretBase.load
      SecretBaseDecoration.load
    end
  end
end

module Compiler
  module_function
  
  #=============================================================================
  # Compile Secret Bases data
  #=============================================================================
  def compile_secret_bases(path = "PBS/secret_bases.txt")
    compile_pbs_file_message_start(path)
    GameData::SecretBase::DATA.clear
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::SecretBase::SCHEMA
      idx = 0
      pbEachFileSection(f) { |contents, base_id|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        contents["InternalName"] = base_id
        # Go through schema hash of compilable data and compile this section
        schema.each_key do |key|
          FileLineData.setSection(base_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if ["InternalName","MapTemplate","Location"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, base_id)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          contents[key] = value
      
        end
        # Construct type hash
        base_hash = {
          :id            => contents["InternalName"].to_sym,
          :map_template  => contents["MapTemplate"],
          :location      => contents["Location"]
        }
        # Add type's data to records
        GameData::SecretBase.register(base_hash)
      }
    }
    # Save all data
    GameData::SecretBase.save
    process_pbs_file_message_end
  end
  
  def compile_secret_base_decorations(path = "PBS/secret_decorations.txt")
    compile_pbs_file_message_start(path)
    GameData::SecretBaseDecoration::DATA.clear
    decor_names        = []
    decor_descriptions = []
    # Read from PBS file
    File.open(path, "rb") { |f|
      FileLineData.file = path   # For error reporting
      # Read a whole section's lines at once, then run through this code.
      # contents is a hash containing all the XXX=YYY lines in that section, where
      # the keys are the XXX and the values are the YYY (as unprocessed strings).
      schema = GameData::SecretBaseDecoration::SCHEMA
      idx = 0
      pbEachFileSection(f) { |contents, decor_id|
        echo "." if idx % 50 == 0
        idx += 1
        Graphics.update if idx % 250 == 0
        contents["InternalName"] = decor_id
        # Go through schema hash of compilable data and compile this section
        schema.each_key do |key|
          FileLineData.setSection(decor_id, key, contents[key])   # For error reporting
          # Skip empty properties, or raise an error if a required property is
          # empty
          if contents[key].nil?
            if ["InternalName","Name","Pocket"].include?(key)
              raise _INTL("The entry {1} is required in {2} section {3}.", key, path, decor_id)
            end
            next
          end
          # Compile value for key
          value = pbGetCsvRecord(contents[key], key, schema[key])
          contents[key] = value
        end
        # Construct type hash
        decor_hash = {
          :id            => contents["InternalName"].to_sym,
          :name          => contents["Name"],
          :pocket        => contents["Pocket"],
          :price         => contents["Price"],
          :sell_price    => contents["SellPrice"],
          :description   => contents["Description"],
          :tile_offset   => contents["TileOffset"],
          :tile_size     => contents["TileSize"],
          :permission    => contents["PlacingPerms"],
          :event_id      => contents["EventID"]
        }
        # Add type's data to records
        GameData::SecretBaseDecoration.register(decor_hash)
        decor_names.push(decor_hash[:name])
        decor_descriptions.push(decor_hash[:description])
      }
    }
    # Save all data
    GameData::SecretBaseDecoration.save
    MessageTypes.setMessagesAsHash(MessageTypes::SecretBaseDecorations, decor_names)
    MessageTypes.setMessagesAsHash(MessageTypes::SecretBaseDecorationDescriptions, decor_descriptions)
    process_pbs_file_message_end
  end
  
  class << self
    alias _secretbase_compile_pbs_files compile_pbs_files
    def compile_pbs_files
      _secretbase_compile_pbs_files
      compile_secret_bases
      compile_secret_base_decorations
    end
  end
end