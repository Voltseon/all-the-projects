#-------------------------------------------------------------------------------
# Mach & Acro Bike Script
# By Rei
# Credits required
#
# bo4p5687 (update)
#-------------------------------------------------------------------------------
module NewBike
	# Add name of bitmap
	# Example:
	#   First trainer is POKEMONTRAINER_Red and you want to change bitmap.
	#   Then, find in lines below, there is # First trainer.
	#   Add words like "boy_acro" in "".
	#   Next, put image which has name "boy_acro" in folder 'Graphics\Characters'.
	#   Finally, enter game and test it.
	ACRO_BIKE = [
								"acro_b", # First trainer
								"acro_g", # Second trainer
								"acro_o", # Third trainer
								"", # Fourth trainer
								"", # Fifth trainer
								"" # Sixth trainer
							]
	# Like acro bike
	MACH_BIKE = [
								"mach_b", # First trainer
								"mach_g", # Second trainer
								"mach_o", # Third trainer
								"", # Fourth trainer
								"", # Fifth trainer
								"" # Sixth trainer
							]
	# When you want rails like bridge, set true
	def self.rail_like_bridge = true
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Add Terrain tag
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
module GameData
  class TerrainTag
		attr_reader :acro_bike
		attr_reader :acro_bike_L_R
		attr_reader :acro_bike_U_D
		attr_reader :acro_bike_hop
		attr_reader :mach_bike

		alias init_ab initialize
		def initialize(hash)
			init_ab(hash)
			@acro_bike     = hash[:acro_bike]     || false
			@acro_bike_L_R = hash[:acro_bike_L_R] || false
			@acro_bike_U_D = hash[:acro_bike_U_D] || false
			@acro_bike_hop = hash[:acro_bike_hop] || false
			@mach_bike     = hash[:mach_bike]     || false
		end
	end
end

# You can change id_number
# Here, I chose from 18 to 21.
GameData::TerrainTag.register({
  :id            => :acro_bike_up_down,
  :id_number     => 18,
	:acro_bike_U_D => true,
	:acro_bike     => true
})

GameData::TerrainTag.register({
  :id            => :acro_bike_left_right,
  :id_number     => 19,
	:acro_bike_L_R => true,
	:acro_bike     => true
})

GameData::TerrainTag.register({
  :id            => :acro_bike_hop,
  :id_number     => 20,
	:acro_bike_hop => true
})

GameData::TerrainTag.register({
  :id        => :mach_bike,
  :id_number => 21,
	:mach_bike => true
})
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_accessor :acro_bike
	attr_accessor :acro_bike_hop
  attr_accessor :mach_bike

  alias new_bike_ini initialize
  def initialize
    new_bike_ini
    @acro_bike = false
		@acro_bike_hop = false
    @mach_bike = false
  end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class Game_Map
  attr_accessor :mach_bike_speed
	attr_reader :acro_bike_priorities_0

  alias new_bike_init initialize
  def initialize
    new_bike_init
    @mach_bike_speed = 0
		@acro_bike_priorities_0 = false
  end

	def playerPassable?(x, y, d, self_event = nil)
		@acro_bike_priorities_0 = false # Acro bike is on ground (priority = 0)
    bit = (1 << ((d / 2) - 1)) & 0x0f
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      next if tile_id == 0
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      passage = @passages[tile_id]
      if terrain
        # Ignore bridge tiles if not on a bridge
        next if terrain.bridge && $PokemonGlobal.bridge == 0
        # Make water tiles passable if player is surfing
        return true if $PokemonGlobal.surfing && terrain.can_surf && !terrain.waterfall
        # Prevent cycling in really tall grass/on ice
        return false if $PokemonGlobal.bicycle && terrain.must_walk

				# Acro bike
				if terrain.acro_bike
					if NewBike.rail_like_bridge
						if $PokemonGlobal.bridge > 0
							return (passage & bit == 0 && passage & 0x0f != 0x0f) if $PokemonGlobal.acro_bike
							return false
						else
							if @priorities[tile_id] == 0
								if $PokemonGlobal.acro_bike
									@acro_bike_priorities_0 = true
									return (passage & bit == 0 && passage & 0x0f != 0x0f)
								end
								return false
							else
								next
							end
						end
					else
						return (passage & bit == 0 && passage & 0x0f != 0x0f) if $PokemonGlobal.acro_bike
						return false
					end
				end
				return $PokemonGlobal.acro_bike_hop if terrain.acro_bike_hop
				
				# Depend on passability of bridge tile if on bridge
        if terrain.bridge && $PokemonGlobal.bridge > 0
          return (passage & bit == 0 && passage & 0x0f != 0x0f)
        end
      end
      next if terrain&.ignore_passability
      # Regular passability checks
      return false if passage & bit != 0 || passage & 0x0f == 0x0f
      return true if @priorities[tile_id] == 0
    end
    return true
  end

	alias new_bike_update update
  def update
    new_bike_update
		# Mach bike
    if $PokemonGlobal.mach_bike
      if Input.dir4 > 0
        @mach_bike_speed += 0.1
        $game_player.move_speed = 5 + @mach_bike_speed.floor
				if $game_player.move_speed > 6
					$game_player.move_speed = 6
					@mach_bike_speed = 1
				end
      else
        @mach_bike_speed = 0
        $game_player.move_speed = 5
      end
    else
      @mach_bike_speed = 0
    end
  end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
module NewBike
	def self.mach_bike
		return if pbMapInterpreterRunning?
		terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
		return if !terrain.mach_bike
		# Go down
		if $game_player.direction == 2 || $game_player.direction == 4 || $game_player.direction == 6
			pbMoveRoute($game_player, [PBMoveRoute::WalkAnimeOff,PBMoveRoute::ChangeSpeed,6,PBMoveRoute::Down,PBMoveRoute::ChangeSpeed,3,PBMoveRoute::WalkAnimeOn], true)
			# Reset speed
			$game_map.mach_bike_speed = 0
		end
		return if $game_map.mach_bike_speed > 0.4
		# Can't go up
		if $game_player.direction == 8
			pbMoveRoute($game_player, [PBMoveRoute::WalkAnimeOff,PBMoveRoute::ChangeSpeed,6,PBMoveRoute::Backward,PBMoveRoute::ChangeSpeed,3,PBMoveRoute::WalkAnimeOn], true)
			# Reset speed
			$game_map.mach_bike_speed = 0
		end
	end

	def self.acro_bike
		return if pbMapInterpreterRunning?
  	return if !$PokemonGlobal.acro_bike
		# Prevent player turn an other direction
		terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
		if (NewBike.rail_like_bridge && ($PokemonGlobal.bridge > 0 || ($game_map.acro_bike_priorities_0 && $PokemonGlobal.bridge <= 0))) || !NewBike.rail_like_bridge
			if terrain.acro_bike_L_R && ($game_player.direction == 8 || $game_player.direction == 2)
				$game_player.turn_right
			elsif terrain.acro_bike_U_D && ($game_player.direction == 4 || $game_player.direction == 6)
				$game_player.turn_down
			end
		end
		# Press button
		if Input.press?(Input::BACK)			
			$game_player.jump(0, 0) if Input.dir4 == 0 && Input.count(Input::BACK) == 1
			direction = nil if !direction
			case 1
			when Input.count(Input::DOWN)
				x = $game_player.x
				y = $game_player.y + 1
				d = $game_player.direction
				terrain = $game_map.terrain_tag(x, y)
				direction = terrain.mach_bike ? nil : 2
			when Input.count(Input::UP)
				x = $game_player.x
				y = $game_player.y - 1
				d = $game_player.direction
				terrain = $game_map.terrain_tag(x, y)
				direction = terrain.mach_bike ? nil : 8
			when Input.count(Input::LEFT)
				x = $game_player.x - 1
				y = $game_player.y
				d = $game_player.direction
				terrain = $game_map.terrain_tag(x, y)
				direction = terrain.mach_bike ? nil : 4
			when Input.count(Input::RIGHT)
				x = $game_player.x + 1
				y = $game_player.y
				d = $game_player.direction
				terrain = $game_map.terrain_tag(x, y)
				direction = terrain.mach_bike ? nil : 6
			end
			if !direction.nil? && !$game_player.pbFacingEvent && ($game_map.passable?(x, y, d, $game_player) || terrain.acro_bike || terrain.acro_bike_hop)
				case direction
				when 2; x = 0;  y = 1  # down
				when 4; x = -1; y = 0  # left
				when 6; x = 1;  y = 0  # right
				when 8; x = 0;  y = -1 # up
				end
				$PokemonGlobal.acro_bike_hop = true
				pbMoveRoute($game_player, [PBMoveRoute::Jump, x, y], true)
				while $game_player.jumping?
					Graphics.update
					Input.update
					pbUpdateSceneMap
				end
				direction = nil
				$PokemonGlobal.acro_bike_hop = false
			end
		end
	end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class Scene_Map
  alias new_bike_update update
  def update
    new_bike_update
    NewBike.acro_bike
    NewBike.mach_bike
  end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
class Game_Player
	def new_bike_s_bitmap
		id = $player&.character_ID || 1
		graphic = if $PokemonGlobal.acro_bike
								NewBike::ACRO_BIKE[id-1]
							elsif $PokemonGlobal.mach_bike
								NewBike::MACH_BIKE[id-1]
							else
								nil
							end
		exist = pbResolveBitmap("Graphics/Characters/#{graphic}") if graphic
		@character_name = pbGetPlayerCharset(graphic) if exist
	end

	alias new_bike_set_movement_type set_movement_type
	def set_movement_type(type)
		new_bike_set_movement_type(type)
		return if !$PokemonGlobal.acro_bike && !$PokemonGlobal.mach_bike
		new_bike_s_bitmap
	end

	alias new_bike_refresh_charset refresh_charset
	def refresh_charset
		new_bike_refresh_charset
		return if !$PokemonGlobal.acro_bike && !$PokemonGlobal.mach_bike
		new_bike_s_bitmap
	end

	alias new_bike_command_new update_command_new
  def update_command_new
    dir = Input.dir4
    unless pbMapInterpreterRunning? || $game_temp.message_window_showing || $game_temp.in_mini_update || $game_temp.in_menu
			terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
			return if (dir == 4 || dir == 6) && terrain.mach_bike
			if $PokemonGlobal.acro_bike
				if (NewBike.rail_like_bridge && ($PokemonGlobal.bridge > 0 || ($game_map.acro_bike_priorities_0 && $PokemonGlobal.bridge <= 0))) || !NewBike.rail_like_bridge
					return if (dir == 4 || dir == 6) && terrain.acro_bike_U_D
					return if (dir == 2 || dir == 8) && terrain.acro_bike_L_R
				end
			end
    end
    new_bike_command_new
  end

	def is_on_rails?(x, y)
		terrain = $game_map.terrain_tag(x, y).acro_bike
		return false if !terrain
		return false if !$PokemonGlobal.acro_bike
		if NewBike.rail_like_bridge
			return true if $PokemonGlobal.bridge > 0 || $game_map.acro_bike_priorities_0
			return false
		else
			return true
		end
	end

	alias new_bike_jump jump
	def jump(x_plus, y_plus)
		if !is_on_rails?(x_plus, y_plus)
			new_bike_jump(x_plus, y_plus)
			return
		end
		# Can't turn when player is on rails
		terrain = $game_map.terrain_tag(x_plus, y_plus)
    if x_plus != 0 || y_plus != 0
			if x_plus.abs > y_plus.abs
				if terrain.acro_bike_L_R
        	(x_plus < 0) ? turn_left : turn_right
				end
      else
				if terrain.acro_bike_U_D
        	(y_plus < 0) ? turn_up : turn_down
				end
      end
      each_occupied_tile { |i, j| return if !passable?(i + x_plus, j + y_plus, 0) }
    end
    @x = @x + x_plus
    @y = @y + y_plus
    real_distance = Math.sqrt((x_plus * x_plus) + (y_plus * y_plus))
    distance = [1, real_distance].max
    @jump_peak = distance * Game_Map::TILE_HEIGHT * 3 / 8   # 3/4 of tile for ledge jumping
    @jump_distance = [x_plus.abs * Game_Map::REAL_RES_X, y_plus.abs * Game_Map::REAL_RES_Y].max
    @jump_distance_left = 1   # Just needs to be non-zero
    if real_distance > 0   # Jumping to somewhere else
      if $PokemonGlobal&.diving || $PokemonGlobal&.surfing
        $stats.distance_surfed += x_plus.abs + y_plus.abs
      elsif $PokemonGlobal&.bicycle
        $stats.distance_cycled += x_plus.abs + y_plus.abs
      else
        $stats.distance_walked += x_plus.abs + y_plus.abs
      end
      @jump_count = 0
    else   # Jumping on the spot
      @jump_speed_real = nil   # Reset jump speed
      @jump_count = Game_Map::REAL_RES_X / jump_speed_real   # Number of frames to jump one tile
    end
    @stop_count = 0
    triggerLeaveTile
  end
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
def pbCancelVehicles(destination = nil, cancel_swimming = true)
  $PokemonGlobal.surfing = false if cancel_swimming
  $PokemonGlobal.diving  = false if cancel_swimming
	if !destination || !pbCanUseBike?(destination)
  	$PokemonGlobal.bicycle = false
		$PokemonGlobal.mach_bike = false
    $PokemonGlobal.acro_bike = false
	end
  pbUpdateVehicle
end
def pbDismountBike
  return if !$PokemonGlobal.bicycle
  $PokemonGlobal.bicycle = false
	$PokemonGlobal.mach_bike = false
  $PokemonGlobal.acro_bike = false
  pbUpdateVehicle
  $game_map.autoplayAsCue
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
alias acro_bike_surf pbSurf
def pbSurf
  terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
  return false if terrain.acro_bike && $PokemonGlobal.acro_bike
  return acro_bike_surf
end
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
ItemHandlers::UseInField.add(:BICYCLE, proc { |item|
  if pbBikeCheck
    if $PokemonGlobal.bicycle
      pbDismountBike
    else
      pbMountBike
    end
    next true
  end
  next false
})

ItemHandlers::UseInField.add(:ACROBIKE, proc { |item|
  if pbBikeCheck
		used = false
		if $PokemonGlobal.mach_bike
			$PokemonGlobal.mach_bike = false
			used = true
		end
		terrain = $game_map.terrain_tag($game_player.x, $game_player.y)
    if $PokemonGlobal.acro_bike && !terrain.acro_bike
      pbDismountBike
    else
			$PokemonGlobal.acro_bike = true
      pbMountBike
			if used
				$stats.cycle_count += 1
				pbUpdateVehicle
				bike_bgm = GameData::Metadata.get.bicycle_BGM
				pbCueBGM(bike_bgm, 0.5) if bike_bgm
			end
    end
    next true
  end
  next false
})

ItemHandlers::UseText.add(:ACROBIKE, proc { |item|
  next ($PokemonGlobal.acro_bike) ? _INTL("Walk") : _INTL("Use")
})

ItemHandlers::UseInField.add(:MACHBIKE, proc { |item|
  if pbBikeCheck
		used = false
		if $PokemonGlobal.acro_bike
			$PokemonGlobal.acro_bike = false
			used = true
		end
    if $PokemonGlobal.mach_bike
      pbDismountBike
    else
			$PokemonGlobal.mach_bike = true
      pbMountBike
			if used
				$stats.cycle_count += 1
				pbUpdateVehicle
				bike_bgm = GameData::Metadata.get.bicycle_BGM
				pbCueBGM(bike_bgm, 0.5) if bike_bgm
			end
    end
    next true
  end
  next false
})

ItemHandlers::UseText.add(:MACHBIKE, proc { |item|
  next ($PokemonGlobal.mach_bike) ? _INTL("Walk") : _INTL("Use")
})