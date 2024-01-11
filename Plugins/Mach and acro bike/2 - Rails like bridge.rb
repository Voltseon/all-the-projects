class Game_Map
	alias acro_bike_bush bush?
	def bush?(x, y)
		if NewBike.rail_like_bridge
			[2, 1, 0].each do |i|
				tile_id = data[x, y, i]
				next if tile_id == 0
				if $PokemonGlobal.bridge > 0
					return false if GameData::TerrainTag.try_get(@terrain_tags[tile_id]).bridge || GameData::TerrainTag.try_get(@terrain_tags[tile_id]).acro_bike
				end
				return true if @passages[tile_id] & 0x40 == 0x40
			end
			return false
		end
		return acro_bike_bush(x, y)
  end

	alias acro_bike_deepBush deepBush?
  def deepBush?(x, y)
		if NewBike.rail_like_bridge
			[2, 1, 0].each do |i|
				tile_id = data[x, y, i]
				next if tile_id == 0
				terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
				return false if (terrain.bridge || terrain.acro_bike) && $PokemonGlobal.bridge > 0
				return true if terrain.deep_bush && @passages[tile_id] & 0x40 == 0x40
			end
			return false
		end
		return acro_bike_deepBush(x, y)
  end

	alias acro_bike_terrain_tag terrain_tag
	def terrain_tag(x, y, countBridge = false)
		if NewBike.rail_like_bridge
			if valid?(x, y)
				[2, 1, 0].each do |i|
					tile_id = data[x, y, i]
					next if tile_id == 0
					terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
					next if terrain.id == :None || terrain.ignore_passability
					next if !countBridge && (terrain.bridge || terrain.acro_bike) && $PokemonGlobal.bridge == 0
					return terrain
				end
			end
			return GameData::TerrainTag.get(:None)
		end
		return acro_bike_terrain_tag(x, y, countBridge)
  end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class Game_Follower
	private

	alias acro_bike_location_passable location_passable?
	def location_passable?(x, y, direction)
		if NewBike.rail_like_bridge
			this_map = self.map
			return false if !this_map || !this_map.valid?(x, y)
			return true if @through
			passed_tile_checks = false
			bit = (1 << ((direction / 2) - 1)) & 0x0f
			# Check all events for ones using tiles as graphics, and see if they're passable
			this_map.events.each_value do |event|
				next if event.tile_id < 0 || event.through || !event.at_coordinate?(x, y)
				tile_data = GameData::TerrainTag.try_get(this_map.terrain_tags[event.tile_id])
				next if tile_data.ignore_passability
				next if (tile_data.bridge || tile_data.acro_bike) && $PokemonGlobal.bridge == 0
				return false if tile_data.ledge
				passage = this_map.passages[event.tile_id] || 0
				return false if passage & bit != 0
				passed_tile_checks = true if ((tile_data.bridge || tile_data.acro_bike) && $PokemonGlobal.bridge > 0) ||
																		 (this_map.priorities[event.tile_id] || -1) == 0
				break if passed_tile_checks
			end
			# Check if tiles at (x, y) allow passage for follower
			if !passed_tile_checks
				[2, 1, 0].each do |i|
					tile_id = this_map.data[x, y, i] || 0
					next if tile_id == 0
					tile_data = GameData::TerrainTag.try_get(this_map.terrain_tags[tile_id])
					next if tile_data.ignore_passability
					next if (tile_data.bridge || tile_data.acro_bike) && $PokemonGlobal.bridge == 0
					return false if tile_data.ledge
					passage = this_map.passages[tile_id] || 0
					return false if passage & bit != 0
					break if (tile_data.bridge || tile_data.acro_bike) && $PokemonGlobal.bridge > 0
					break if (this_map.priorities[tile_id] || -1) == 0
				end
			end
			# Check all events on the map to see if any are in the way
			this_map.events.each_value do |event|
				next if !event.at_coordinate?(x, y)
				return false if !event.through && event.character_name != ""
			end
			return true
		end
		return acro_bike_location_passable(x, y, direction)
	end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class TilemapRenderer
	class TilesetBitmaps
		alias acro_bike_init initialize
		def initialize
			acro_bike_init
			@acro_bike = 0
		end
	end

	class TileSprite
		attr_accessor :acro_bike

		alias acro_bike_set_bitmap set_bitmap
		def set_bitmap(filename, tile_id, autotile, animated, priority, bitmap)
			acro_bike_set_bitmap(filename, tile_id, autotile, animated, priority, bitmap)
			@acro_bike = false
		end
	end

	alias acro_bike_refresh_tile_bitmap refresh_tile_bitmap
	def refresh_tile_bitmap(tile, map, tile_id)
		if !NewBike.rail_like_bridge
			acro_bike_refresh_tile_bitmap(tile, map, tile_id)
			return
		end
		# Set rails of acrobike
    tile.tile_id = tile_id
    if tile_id < TILES_PER_AUTOTILE
      tile.set_bitmap("", tile_id, false, false, 0, nil)
      tile.shows_reflection = false
      tile.bridge           = false
			tile.acro_bike        = false # Acro bike
    else
      terrain_tag = map.terrain_tags[tile_id] || 0
      terrain_tag_data = GameData::TerrainTag.try_get(terrain_tag)
      priority = map.priorities[tile_id] || 0
      single_autotile_start_id = TILESET_START_ID
      true_tileset_start_id = TILESET_START_ID
      extra_autotile_arrays = EXTRA_AUTOTILES[map.tileset_id]
      if extra_autotile_arrays
        large_autotile_count = extra_autotile_arrays[0].length
        single_autotile_count = extra_autotile_arrays[1].length
        single_autotile_start_id += large_autotile_count * TILES_PER_AUTOTILE
        true_tileset_start_id += large_autotile_count * TILES_PER_AUTOTILE
        true_tileset_start_id += single_autotile_count
      end
      if tile_id < true_tileset_start_id
        filename = ""
        if tile_id < TILESET_START_ID   # Real autotiles
          filename = map.autotile_names[(tile_id / TILES_PER_AUTOTILE) - 1]
        elsif tile_id < single_autotile_start_id   # Large extra autotiles
          filename = extra_autotile_arrays[0][(tile_id - TILESET_START_ID) / TILES_PER_AUTOTILE]
        else   # Single extra autotiles
          filename = extra_autotile_arrays[1][tile_id - single_autotile_start_id]
        end
        tile.set_bitmap(filename, tile_id, true, @autotiles.animated?(filename),
                        priority, @autotiles[filename])
      else
        filename = map.tileset_name
        tile.set_bitmap(filename, tile_id, false, false, priority, @tilesets[filename])
      end
      tile.shows_reflection = terrain_tag_data&.shows_reflections
      tile.bridge           = terrain_tag_data&.bridge
			tile.acro_bike        = terrain_tag_data&.acro_bike # Acro bike
    end
    refresh_tile_src_rect(tile, tile_id)
  end

	alias acro_bike_refresh_tile_z refresh_tile_z
	def refresh_tile_z(tile, map, y, layer, tile_id)
		if NewBike.rail_like_bridge
			if tile.acro_bike && $PokemonGlobal.bridge > 0
				tile.z = 0
			else
				acro_bike_refresh_tile_z(tile, map, y, layer, tile_id)
			end
			return
		end
		acro_bike_refresh_tile_z(tile, map, y, layer, tile_id)
  end

	alias acro_bike_update update
	def update
		if !NewBike.rail_like_bridge
			acro_bike_update
			return
		end
    # Update tone
    if @old_tone != @tone
      @tiles.each do |col|
        col.each do |coord|
          coord.each { |tile| tile.tone = @tone }
        end
      end
      @old_tone = @tone.clone
    end
    # Update color
    if @old_color != @color
      @tiles.each do |col|
        col.each do |coord|
          coord.each { |tile| tile.color = @tone }
        end
      end
      @old_color = @color.clone
    end
    # Recalculate autotile frames
    @tilesets.update
    @autotiles.update
    do_full_refresh = @need_refresh
    if @viewport.ox != @old_viewport_ox || @viewport.oy != @old_viewport_oy
      @old_viewport_ox = @viewport.ox
      @old_viewport_oy = @viewport.oy
      do_full_refresh = true
    end
    # Check whether the screen has moved since the last update
    @screen_moved = false
    @screen_moved_vertically = false
    if $PokemonGlobal.bridge != @bridge
			@acro_bike = $PokemonGlobal.bridge # Acro bike
      @bridge = $PokemonGlobal.bridge
      @screen_moved_vertically = true   # To update bridge tiles' z values
    end
    do_full_refresh = true if check_if_screen_moved
    # Update all tile sprites
    visited = []
    @tiles_horizontal_count.times do |i|
      visited[i] = []
      @tiles_vertical_count.times { |j| visited[i][j] = false }
    end
    $map_factory.maps.each do |map|
      # Calculate x/y ranges of tile sprites that represent them
      map_display_x = (map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      map_display_x = ((map_display_x + (Graphics.width / 2)) * ZOOM_X) - (Graphics.width / 2) if ZOOM_X != 1
      map_display_y = (map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      map_display_y = ((map_display_y + (Graphics.height / 2)) * ZOOM_Y) - (Graphics.height / 2) if ZOOM_Y != 1
      map_display_x_tile = map_display_x / DISPLAY_TILE_WIDTH
      map_display_y_tile = map_display_y / DISPLAY_TILE_HEIGHT
      start_x = [-map_display_x_tile, 0].max
      start_y = [-map_display_y_tile, 0].max
      end_x = @tiles_horizontal_count - 1
      end_x = [end_x, map.width - map_display_x_tile - 1].min
      end_y = @tiles_vertical_count - 1
      end_y = [end_y, map.height - map_display_y_tile - 1].min
      next if start_x > end_x || start_y > end_y || end_x < 0 || end_y < 0
      # Update all tile sprites representing this map
      (start_x..end_x).each do |i|
        tile_x = i + map_display_x_tile
        (start_y..end_y).each do |j|
          tile_y = j + map_display_y_tile
          @tiles[i][j].each_with_index do |tile, layer|
            tile_id = map.data[tile_x, tile_y, layer]
            if do_full_refresh || tile.need_refresh || tile.tile_id != tile_id
              refresh_tile(tile, i, j, map, layer, tile_id)
            else
              refresh_tile_frame(tile, tile_id) if tile.animated && @autotiles.changed
              # Update tile's x/y coordinates
              refresh_tile_coordinates(tile, i, j) if @screen_moved
              # Update tile's z value
              refresh_tile_z(tile, map, j, layer, tile_id) if @screen_moved_vertically
            end
          end
          # Record x/y as visited
          visited[i][j] = true
        end
      end
    end
    # Clear all unvisited tile sprites
    @tiles.each_with_index do |col, i|
      col.each_with_index do |coord, j|
        next if visited[i][j]
        coord.each do |tile|
          tile.set_bitmap("", 0, false, false, 0, nil)
          tile.shows_reflection = false
          tile.bridge           = false
					tile.acro_bike        = false
        end
      end
    end
    @need_refresh = false
    @autotiles.changed = false
  end
end