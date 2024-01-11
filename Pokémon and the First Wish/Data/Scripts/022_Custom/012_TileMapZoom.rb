module LastWish
	@@target_zoom_x = 1
	@@target_zoom_dx = 0
	@@target_zoom_y = 1
	@@target_zoom_dy = 0
	@@target_zoom_duration = -1

	def self.set_zoom(zoom_level)
		@@target_zoom_x = zoom_level
		@@target_zoom_y = zoom_level
		@@target_zoom_duration = -1
		return if !$scene.is_a?(Scene_Map)
		$scene.map_renderer.zoom_x = zoom_level
		$scene.map_renderer.zoom_y = zoom_level
	end
	
	def self.set_target_zoom(zoom_level, duration)
		@@target_zoom_x = zoom_level
		@@target_zoom_dx = (zoom_level - $scene.map_renderer.zoom_x).fdiv(duration)
		@@target_zoom_y = zoom_level
		@@target_zoom_dy = (zoom_level - $scene.map_renderer.zoom_y).fdiv(duration)
		@@target_zoom_duration = duration
	end

	def self.update_map_zoom
		return if @@target_zoom_duration < 0
		if (@@target_zoom_x - $scene.map_renderer.zoom_x).abs < 0.01
			$scene.map_renderer.zoom_x = @@target_zoom_x
		else
			$scene.map_renderer.zoom_x += @@target_zoom_dx
		end
		if (@@target_zoom_y - $scene.map_renderer.zoom_y).abs < 0.01
			$scene.map_renderer.zoom_y = @@target_zoom_y
		else
			$scene.map_renderer.zoom_y += @@target_zoom_dy
		end
		@@target_zoom_duration = 0 if @@target_zoom_x == $scene.map_renderer.zoom_x && @@target_zoom_y == $scene.map_renderer.zoom_y
	end
end

EventHandlers.add(:on_frame_update, :lw_map_zoom,
	proc {
		next if !$scene.is_a?(Scene_Map)
		LastWish.update_map_zoom
	}
)

class TilemapRenderer
	alias _TilemapZoom_initialize initialize unless private_method_defined?(:_TilemapZoom_initialize)
	alias _TilemapZoom_check_if_screen_moved check_if_screen_moved unless method_defined?(:_TilemapZoom_check_if_screen_moved)

	attr_reader :zoom_x
	attr_reader :zoom_y

	def initialize(viewport)
		_TilemapZoom_initialize(viewport)
		@zoom_x = 1
		@zoom_y = 1
	end

	def zoom_x=(value)
		value = [value, 1].max
		@zoom_x = value
		@need_refresh = true
	end
  
	def zoom_y=(value)
		value = [value, 1].max
		@zoom_y = value
		@need_refresh = true
	end 

	def self.zoom_x=(value)
		return $scene.map_renderer.zoom_x = value if $scene.is_a? Scene_Map
	end
  
	def self.zoom_y=(value)
		return $scene.map_renderer.zoom_y = value if $scene.is_a? Scene_Map
	end 
  
	def self.zoom_x
		return $scene.map_renderer.zoom_x if $scene.is_a? Scene_Map
	end

	def self.zoom_y
		return $scene.map_renderer.zoom_y if $scene.is_a? Scene_Map
	end

	def check_if_screen_moved
		return _TilemapZoom_check_if_screen_moved || @zoom_changed
	end
  
	# x and y are the positions of tile within @tiles, not a map x/y
	def refresh_tile_coordinates(tile, x, y)
		tile.x = ((x * DISPLAY_TILE_WIDTH) - @pixel_offset_x) * @zoom_x - (@zoom_x-1.0) * Graphics.width / 2
		tile.y = ((y * DISPLAY_TILE_HEIGHT) - @pixel_offset_y) * @zoom_y - (@zoom_y-1.0) * Graphics.height / 2
	end
  
	def refresh_tile_zoom(tile)
		tile.zoom_x = @zoom_x
		tile.zoom_x += 1.fdiv(DISPLAY_TILE_WIDTH) if !@zoom_x.integer?
		tile.zoom_y = @zoom_y
		tile.zoom_y += 1.fdiv(DISPLAY_TILE_HEIGHT) if !@zoom_y.integer?
	end
  
	def refresh_tile(tile, x, y, map, layer, tile_id)
		refresh_tile_bitmap(tile, map, tile_id)
		refresh_tile_zoom(tile)
		refresh_tile_coordinates(tile, x, y)
		refresh_tile_z(tile, map, y, layer, tile_id)
		tile.need_refresh = false
	end
end

class SpriteAnimation
	def ox=(x)
		sx = x - self.ox
		return if sx == 0
		if @_animation_sprites
		  16.times { |i| @_animation_sprites[i].ox += sx }
		end
		if @_loop_animation_sprites
		  16.times { |i| @_loop_animation_sprites[i].ox += sx }
		end
	  end
	
	  def oy=(y)
		sy = y - self.oy
		return if sy == 0
		if @_animation_sprites
		  16.times { |i| @_animation_sprites[i].oy += sy }
		end
		if @_loop_animation_sprites
		  16.times { |i| @_loop_animation_sprites[i].oy += sy }
		end
	  end
end


class Sprite_Character < RPG::Sprite
	alias _TilemapZoom_update update unless method_defined?(:_TilemapZoom_update)

	def update
		return if @character.is_a?(Game_Event) && !@character.should_update?
		_TilemapZoom_update
		self.zoom_x = TilemapRenderer.zoom_x
		self.zoom_y = TilemapRenderer.zoom_y
		self.x = self.x * TilemapRenderer.zoom_x - (TilemapRenderer.zoom_x-1)*Graphics.width/2
		self.y = self.y * TilemapRenderer.zoom_y - (TilemapRenderer.zoom_y-1)*Graphics.height/2
		# behold this utterly horrible evil snippet of code <3
		# you dumbass, @cloak hasn't been initialized yet here
		# I added this line here and Continue now works at least but New Game doesn't, for some reason.
		return if @cloak.nil? || @pants.nil? || @clip.nil?
		@cloak.zoom_x = TilemapRenderer.zoom_x
		@cloak.zoom_y = TilemapRenderer.zoom_y
		@cloak.x = self.x
		@cloak.y = self.y
		@pants.zoom_x = TilemapRenderer.zoom_x
		@pants.zoom_y = TilemapRenderer.zoom_y
		@pants.x = self.x
		@pants.y = self.y
		@clip.zoom_x = TilemapRenderer.zoom_x
		@clip.zoom_y = TilemapRenderer.zoom_y
		@clip.x = self.x
		@clip.y = self.y
	end
end

class Spriteset_Map
	alias _TilemapZoom_update update unless method_defined?(:_TilemapZoom_update)

	def update
		_TilemapZoom_update
		zoom_x_offset = (TilemapRenderer.zoom_x-1)*Graphics.width/2
		zoom_y_offset = (TilemapRenderer.zoom_y-1)*Graphics.height/2
			
		@panorama.ox = @panorama.ox * TilemapRenderer.zoom_x - zoom_x_offset
		@panorama.oy = @panorama.oy * TilemapRenderer.zoom_y - zoom_y_offset
		@panorama.zoom_x *= TilemapRenderer.zoom_x
		@panorama.zoom_y *= TilemapRenderer.zoom_y

		@fog.ox = @fog.ox * TilemapRenderer.zoom_x - zoom_x_offset
		@fog.oy = @fog.oy * TilemapRenderer.zoom_y - zoom_y_offset
		@fog.zoom_x *= TilemapRenderer.zoom_x
		@fog.zoom_y *= TilemapRenderer.zoom_y

		@weather.ox = @weather.ox * TilemapRenderer.zoom_x - zoom_x_offset
		@weather.oy = @weather.oy * TilemapRenderer.zoom_y - zoom_y_offset
	end	
end