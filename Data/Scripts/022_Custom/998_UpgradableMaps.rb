#===============================================================================
# * Upgradeable Maps - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It copies tiles of map chunks from a
# map into other map when a switch is ON.
#
#== INSTALLATION ===============================================================
#
# Put it above main OR convert into a plugin. Before first line 
# 'tileset = $data_tilesets[@map.tileset_id]' at Game_Map script section, add 
# line 'UpgradeableMaps.process(@map, map_id)'
#
#=== HOW TO USE ================================================================
#
# Add more entries following the examples at 'def self.getAllChunks' below.
#
#===============================================================================

if defined?(PluginManager) && !PluginManager.installed?("Upgradeable Maps")
  PluginManager.register({                                                 
    :name    => "Upgradeable Maps",                                        
    :version => "1.2",                                                     
    :link    => "https://www.pokecommunity.com/showthread.php?t=496862",             
    :credits => "FL"
  })
end

module UpgradeableMaps
  # Add map entries here
  def self.getAllChunks
    return [
      # Entry.new(map id, increment version map id, switch, x range, y range),
      # The below code line means Oak Lab will be copied into Daisy's House when 
      # switch 80 was ON.
      Chunk.new(DAISY_HOUSE, OAK_LAB, 80, 0..1, 0..2),
      # The below code line means same thing, but using other coordinates
      Chunk.new(DAISY_HOUSE, OAK_LAB, 80, 11..12, 0..2),
      # The below code line means same thing, but using different coordinates 
      # for copy/paste maps (first is destiny, then source). I suggest this only 
      # for more advanced users.
      Chunk.new(DAISY_HOUSE, OAK_LAB, 80, 12...13, 7...9, 12...13, 11...13),
    ]
  end

  # I suggest putting the Map IDs here, to make easier to edit but this is
  # optional
  OAK_LAB = 4
  DAISY_HOUSE = 8

  class Chunk
    attr_reader :to_paste_map_id
    attr_reader :to_copy_map_id
    attr_reader :switch_number

    # created for performance reasons
    def to_paste_map_x_array
      @to_paste_map_x_array ||= @to_paste_map_x_range.to_a
      return @to_paste_map_x_array
    end

    def to_paste_map_y_array
      @to_paste_map_y_array ||= @to_paste_map_y_range.to_a
      return @to_paste_map_y_array
    end

    def to_copy_map_x_array
      @to_copy_map_x_array ||= @to_copy_map_x_range.to_a
      return @to_copy_map_x_array
    end

    def to_copy_map_y_array
      @to_copy_map_y_array ||= @to_copy_map_y_range.to_a
      return @to_copy_map_y_array
    end

    def initialize(
      to_paste_map_id, to_copy_map_id, switch_number, 
      to_paste_map_x_range, to_paste_map_y_range, 
      to_copy_map_x_range=nil, to_copy_map_y_range=nil
    )
      @to_paste_map_id = to_paste_map_id
      @to_copy_map_id = to_copy_map_id
      @switch_number = switch_number
      @to_paste_map_x_range = to_paste_map_x_range
      @to_paste_map_y_range = to_paste_map_y_range
      @to_copy_map_x_range = to_copy_map_x_range || to_paste_map_x_range
      @to_copy_map_y_range = to_copy_map_y_range || to_paste_map_y_range
      validate_range
    end

    def validate_range
      if (
        @to_paste_map_x_range.size == @to_copy_map_x_range.size &&
        @to_paste_map_y_range.size == @to_copy_map_y_range.size
      )
        return
      end
      raise ArgumentError.new(sprintf(
        "Chunk for maps %d-%d should have %s ranges with same sizes.",
        @to_paste_map_id, @to_copy_map_id, 
        @to_paste_map_x_range.size == @to_copy_map_x_range.size ? "y" : "x"
      ))
    end

    def add_tiles(to_paste_map, to_copy_map)
      validate_maps(to_paste_map, to_copy_map)
      for x_index in 0...to_paste_map_x_array.size
        for y_index in 0...to_paste_map_y_array.size
          for l in [2, 1, 0]
            to_paste_x = to_paste_map_x_array[x_index]
            to_paste_y = to_paste_map_y_array[y_index]
            to_copy_x = to_copy_map_x_array[x_index]
            to_copy_y = to_copy_map_y_array[y_index]
            to_paste_map.data[to_paste_x, to_paste_y, l] = (
              to_copy_map.data[to_copy_x, to_copy_y, l]
            )
          end
        end
      end
    end

    def validate_maps(to_paste_map, to_copy_map)
      validate_map_size(
        to_paste_map,to_paste_map_id,to_paste_map_x_array,to_paste_map_y_array
      ) 
      validate_map_size(
        to_copy_map,to_copy_map_id,to_copy_map_x_array,to_copy_map_y_array
      ) 
    end

    def validate_map_size(map, map_id, x_array, y_array)
      raise ArgumentError.new(sprintf(
        "Map %d has width %d, but chunk range is out of bounds (%d).",
        map_id, map.width, x_array[-1]
      )) if map.width <= x_array[-1]
      raise ArgumentError.new(sprintf(
        "Map %d has height %d, but chunk range is out of bounds (%d).",
        map_id, map.height, y_array[-1]
      )) if map.height <= y_array[-1]
    end
  end

  def self.process(map, map_id)
    extra_map_hash = {}
    for chunk in getAllChunks
      next if map_id != chunk.to_paste_map_id
      next if !$game_switches[chunk.switch_number]
      if !extra_map_hash.has_key?(chunk.to_copy_map_id)
        extra_map_hash[chunk.to_copy_map_id] = load_data(
          sprintf("Data/Map%03d.rxdata", chunk.to_copy_map_id)
        )
      end
      chunk.add_tiles(map, extra_map_hash[chunk.to_copy_map_id])
    end
  end
end