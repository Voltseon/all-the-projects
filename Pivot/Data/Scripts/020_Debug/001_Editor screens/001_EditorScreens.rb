#===============================================================================
# Metadata editor
#===============================================================================
def pbMetadataScreen
  sel_player = -1
  loop do
    sel_player = pbListScreen(_INTL("SET METADATA"), MetadataLister.new(sel_player, true))
    break if sel_player == -1
    case sel_player
    when -2   # Add new player
      pbEditPlayerMetadata(-1)
    when 0   # Edit global metadata
      pbEditMetadata
    else   # Edit player character
      pbEditPlayerMetadata(sel_player) if sel_player >= 1
    end
  end
end

def pbEditMetadata
  data = []
  metadata = GameData::Metadata.get
  properties = GameData::Metadata.editor_properties
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(_INTL("Global Metadata"), data, properties, true)
    # Construct metadata hash
    metadata_hash = {
      :id                  => 0,
      :start_money         => data[0],
      :start_item_storage  => data[1],
      :home                => data[2],
      :storage_creator     => data[3],
      :wild_battle_BGM     => data[4],
      :trainer_battle_BGM  => data[5],
      :wild_victory_BGM    => data[6],
      :trainer_victory_BGM => data[7],
      :wild_capture_ME     => data[8],
      :surf_BGM            => data[9],
      :bicycle_BGM         => data[10]
    }
    # Add metadata's data to records
    GameData::Metadata.register(metadata_hash)
    GameData::Metadata.save
    Compiler.write_metadata
  end
end

def pbEditPlayerMetadata(player_id = 1)
  metadata = nil
  if player_id < 1
    # Adding new player character; get lowest unused player character ID
    ids = GameData::PlayerMetadata.keys
    1.upto(ids.max + 1) do |i|
      next if ids.include?(i)
      player_id = i
      break
    end
    metadata = GameData::PlayerMetadata.new({ :id => player_id })
  elsif !GameData::PlayerMetadata.exists?(player_id)
    pbMessage(_INTL("Metadata for player character {1} was not found.", player_id))
    return
  end
  data = []
  metadata = GameData::PlayerMetadata.try_get(player_id) if metadata.nil?
  properties = GameData::PlayerMetadata.editor_properties
  properties.each do |property|
    data.push(metadata.property_from_string(property[0]))
  end
  if pbPropertyList(_INTL("Player {1}", metadata.id), data, properties, true)
    # Construct player metadata hash
    metadata_hash = {
      :id                    => player_id,
      :trainer_type          => data[0],
      :walk_charset          => data[1],
      :run_charset           => data[2],
      :cycle_charset         => data[3],
      :surf_charset          => data[4],
      :dive_charset          => data[5],
      :fish_charset          => data[6],
      :surf_fish_charset     => data[7],
      :throw_charset         => data[8],
      :book_charset          => data[9],
      :move_speed            => data[10],
      :attack                => data[11],
      :hp                    => data[12],
      :hurt_charset          => data[13],
      :idle_charset          => data[14],
      :physical_charset      => data[15],
      :ranged_charset        => data[16],
      :guard_charset         => data[17],
      :ability_charset       => data[18],
      :evolution             => data[19],
      :movement_type         => data[20],
      :description           => data[21],
      :unlocked_at           => data[22]
    }
    # Add player metadata's data to records
    GameData::PlayerMetadata.register(metadata_hash)
    GameData::PlayerMetadata.save
    Compiler.write_metadata
  end
end



#===============================================================================
# Map metadata editor
#===============================================================================
def pbMapMetadataScreen(map_id = 0)
  loop do
    map_id = pbListScreen(_INTL("SET METADATA"), MapLister.new(map_id))
    break if map_id < 0
    (map_id == 0) ? pbEditMetadata : pbEditMapMetadata(map_id)
  end
end