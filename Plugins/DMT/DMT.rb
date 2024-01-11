#===============================================================================
# Deep Marsh Tiles - Base and concept By Vendily [v17]
# Version for v20.1 by  Kotaro
#==============================================================================
#Config	
module Deep_Marsh_Tiles
  # set this to false if you don't want the features from Always inside Bushes
  # other stuff related to AiB can be configured in the module bellow
  Always_inside_Bush = true
  MARSH_DEPTH     = 7
  DEEPMARSH_DEPTH = 15
  #Amount of turns needed to break free from being stuck in the ground.
  MARSHTILES_TURN_TIMES = 5
  #Name of the SoundFile that should be played when the Player gets "unstuck". 
  MARSHTILES_JUMP_SOUND = "Player jump"
  #Set to true if you want double battles inside of marsh tiles
  DOUBLE_BATTLE = false
  #Set the Numbers bellow to a number that hasn't been used as a Terrain ID
  MARSH_ID 	              = 22
  DEEPMARSH_ID 	          = 23
  MARSHGRASS_ID           = 24
  DEEPMARSHGRASS_ID       = 25
  TALLMARSHGRASS_ID       = 26
  TALLDEEPMARSHGRASS_ID   = 27
  #Chance for the player to sink into the ground the base 3 would mean 1/3 and so on.
  CHANCE = 3
end  

module Always_in_Bush_in_Water
  # Constants to disable either AiB or AiW if you only want 1 of them to be active
  # Bush
  AIB_ACTIVE  = true
  # Water
  AIW_ACTIVE  = true
  # Sand
  AIS_ACTIVE  = true
  # Configurable constants for bush depth and water depth
  BUSH_DEPTH     = 12
  WATER_DEPTH    = 15
  SAND_DEPTH     = 7
  # List of event IDs that are allowed to be submerged in water. Note that by default events are not allowed in water.
  EVENTS_ALLOWED_IN_WATER = [6]
  # List of event IDs not allowed in bush. In general, all events aer allowed to be in bush, except ones added to the list below.
  EVENTS_NOT_ALLOWED_IN_GRASS = [8]
  # List of event IDs that are allowed to sink into the sand.
  EVENTS_NOT_ALLOWED_IN_SAND = [8]
  # Note that the following Pokémon Event is handled in code already
  FOLLOWING_POKEMON = false
end
#==============================================================================
module GameData
  class TerrainTag
    attr_accessor :stuck
    attr_accessor :mudfree
    attr_reader   :marsh
	  attr_reader   :deep_marsh
    alias __stuckfreemud initialize
    def initialize(hash)
      __stuckfreemud(hash)
        @stuck         	= hash[:stuck]       		|| false
        @mudfree       	= hash[:mudfree]      	|| false
        @marsh  	      = hash[:marsh]   	      || false
		    @deep_marsh 	  = hash[:deep_marsh]    	|| false
    end
  end
end  

GameData::Environment.register({
  :id          => :Mud,
  :name        => _INTL("Mud"),
  :battle_base => "mud"
})

GameData::TerrainTag.register({
  :id                     => :Marsh,
  :id_number              => Deep_Marsh_Tiles::MARSH_ID,
  :marsh                  => true,
  :must_walk              => true
}) 

GameData::TerrainTag.register({
  :id                     => :DeepMarsh,
  :id_number              => Deep_Marsh_Tiles::DEEPMARSH_ID,
  :deep_marsh             => true,
  :must_walk              => true
}) 

GameData::TerrainTag.register({
  :id                     => :MarshGrass,
  :id_number              => Deep_Marsh_Tiles::MARSHGRASS_ID,
  :shows_grass_rustle     => true,  
  :marsh                  => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => Deep_Marsh_Tiles::DOUBLE_BATTLE,
  :battle_environment     => :Mud,  
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :DeepMarshGrass,
  :id_number              => Deep_Marsh_Tiles::DEEPMARSHGRASS_ID,
  :shows_grass_rustle     => true,  
  :deep_marsh             => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => Deep_Marsh_Tiles::DOUBLE_BATTLE,
  :battle_environment     => :Mud,  
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :TallMarshGrass,
  :id_number              => Deep_Marsh_Tiles::TALLMARSHGRASS_ID,
  :deep_bush              => true, 
  :marsh                  => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => Deep_Marsh_Tiles::DOUBLE_BATTLE,
  :battle_environment     => :Mud,  
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :TallDeepMarshGrass,
  :id_number              => Deep_Marsh_Tiles::TALLDEEPMARSHGRASS_ID,
  :deep_bush              => true, 
  :deep_marsh             => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => Deep_Marsh_Tiles::DOUBLE_BATTLE,
  :battle_environment     => :Mud,  
  :must_walk              => true
})
#==============================================================================
class PokemonGlobalMetadata
  attr_accessor :stuck
  attr_accessor :mudfree
  
  def stuck
    @stuck=false if !@stuck
    return @stuck
  end
end

#==============================================================================
EventHandlers.add(:on_step_taken,:on_player_change_direction,
	proc { |event|
	if $scene.is_a?(Scene_Map)
		chance = (1..Deep_Marsh_Tiles::CHANCE).to_a.sample  
		currentTag = $game_player.pbTerrainTag
		if event==$game_player && currentTag.deep_marsh && !$PokemonGlobal.mudfree
			pbStuckTile(event)
		elsif event==$game_player && currentTag.marsh && !$PokemonGlobal.mudfree && chance==3
			pbStuckTile(event)
		end
	end
	}
)
#==============================================================================
def pbOnStepTaken(eventTriggered)
  if $game_player.move_route_forcing || pbMapInterpreterRunning?
    EventHandlers.trigger(:on_step_taken, $game_player)
    return
  end
  $PokemonGlobal.stepcount = 0 if !$PokemonGlobal.stepcount
  $PokemonGlobal.stepcount += 1
  $PokemonGlobal.stepcount &= 0x7FFFFFFF
  repel_active = ($PokemonGlobal.repel > 0)
  EventHandlers.trigger(:on_player_step_taken)
  handled = [nil]
  EventHandlers.trigger(:on_player_step_taken_can_transfer, handled)
  return if handled[0]
  pbBattleOnStepTaken(repel_active) if !eventTriggered && !$game_temp.in_menu && $PokemonGlobal.stuck #by Kota
  $game_temp.encounter_triggered = false   # This info isn't needed here
end
#==============================================================================
def pbStuckTile(event=nil)
  event = $game_player if !event
  return if !event
  $PokemonGlobal.stuck=true
  event.straighten
  event.calculate_bush_depth
  olddir=event.direction
  dir=olddir
  turntimes=0
  loop do
    break if turntimes>=Deep_Marsh_Tiles::MARSHTILES_TURN_TIMES
    Graphics.update
    Input.update
    pbUpdateSceneMap
    key=Input.dir4
    dir=key if key>0
    if dir!=olddir
      case dir
        when 2 then $game_player.turn_down
        when 4 then $game_player.turn_left
        when 6 then $game_player.turn_right
        when 8 then $game_player.turn_up
      end
      olddir=dir
      turntimes+=1
    end
  end
  event.center(event.x,event.y)
  event.straighten
  $PokemonGlobal.stuck=false
  $PokemonGlobal.mudfree=true
  event.jump(0,0)
  pbSEPlay(Deep_Marsh_Tiles::MARSHTILES_JUMP_SOUND)
  20.times do
    Graphics.update
    Input.update
    pbUpdateSceneMap
  end
  $PokemonGlobal.mudfree=false
end
#==============================================================================
# AiB stuff
#==============================================================================

class Game_Character
  if Deep_Marsh_Tiles::Always_inside_Bush
    def calculate_bush_depth
      if @tile_id > 0 || @always_on_top || jumping?
        @bush_depth = 0
      else
        xbehind = @x + (@direction == 4 ? 1 : @direction == 6 ? -1 : 0)
        ybehind = @y + (@direction == 8 ? 1 : @direction == 2 ? -1 : 0)
        this_map = (self.map.valid?(@x, @y)) ? [self.map, @x, @y] : $map_factory&.getNewMap(@x, @y, self.map.map_id)
        behind_map = (self.map.valid?(xbehind, ybehind)) ? [self.map, xbehind, ybehind] : $map_factory&.getNewMap(xbehind, ybehind, self.map.map_id)
        if this_map[0].deepBush?(this_map[1], this_map[2]) && behind_map[0].deepBush?(behind_map[1], behind_map[2])
          @bush_depth = Game_Map::TILE_HEIGHT
        elsif !moving? && this_map[0].bush?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIB_ACTIVE #|| (self==$game_player && $PokemonGlobal.stuck)
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_GRASS.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::BUSH_DEPTH
          end
        elsif moving? && this_map[0].bush?(this_map[1], this_map[2]) && behind_map[0].bush?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIB_ACTIVE #|| (self==$game_player && $PokemonGlobal.stuck)
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_GRASS.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::BUSH_DEPTH
          end

        #added for tall grass
        elsif !moving? && this_map[0].tallgrass?(this_map[1], this_map[2]) && !$PokemonGlobal.stuck
          @bush_depth = 16
        elsif moving? && this_map[0].tallgrass?(this_map[1], this_map[2]) && behind_map[0].tallgrass?(behind_map[1], behind_map[2]) && !$PokemonGlobal.stuck
          @bush_depth = 16

        #added for marsh
        elsif !moving? && this_map[0].marsh?(this_map[1], this_map[2]) && !$PokemonGlobal.stuck
          @bush_depth = Deep_Marsh_Tiles::MARSH_DEPTH
        elsif moving? && this_map[0].marsh?(this_map[1], this_map[2]) && behind_map[0].marsh?(behind_map[1], behind_map[2]) && !$PokemonGlobal.stuck
          @bush_depth = Deep_Marsh_Tiles::MARSH_DEPTH

        #added for deepmarsh
        elsif !moving? && this_map[0].marsh?(this_map[1], this_map[2]) && (self==$game_player && $PokemonGlobal.stuck)
          @bush_depth = Deep_Marsh_Tiles::DEEPMARSH_DEPTH

        elsif moving? && this_map[0].marsh?(this_map[1], this_map[2]) && behind_map[0].marsh?(behind_map[1], behind_map[2]) && (self==$game_player && $PokemonGlobal.stuck)
          @bush_depth = Deep_Marsh_Tiles::DEEPMARSH_DEPTH  

        # added for sand 
        elsif !moving? && this_map[0].sand?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIS_ACTIVE
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_SAND.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::SAND_DEPTH
          end
        elsif moving? && this_map[0].sand?(this_map[1], this_map[2]) && behind_map[0].sand?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIS_ACTIVE
          if !Always_in_Bush_in_Water::EVENTS_NOT_ALLOWED_IN_SAND.include?(@id)
            @bush_depth = Always_in_Bush_in_Water::SAND_DEPTH
          end 

        # added for water
        elsif !moving? && this_map[0].water?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
          if self == $game_player && $PokemonGlobal.surfing
            @bush_depth = 0
          elsif !Always_in_Bush_in_Water::EVENTS_ALLOWED_IN_WATER.include?(@id)
            @bush_depth = 0
          else
            @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH   
          end
          
        elsif moving? && this_map[0].water?(this_map[1], this_map[2]) && behind_map[0].water?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
          if self == $game_player && $PokemonGlobal.surfing
            @bush_depth = 0
          elsif !Always_in_Bush_in_Water::EVENTS_ALLOWED_IN_WATER.include?(@id)
            @bush_depth = 0
          else
            @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH   
          end
        else
          @bush_depth = 0
        end
        
        
        if Always_in_Bush_in_Water::FOLLOWING_POKEMON
          if FollowingPkmn.active?
            if self == FollowingPkmn.get_event
              if FollowingPkmn.airborne_follower?
                @bush_depth = 0
              elsif !moving? && this_map[0].water?(this_map[1], this_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
                @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH
              elsif moving? && this_map[0].water?(this_map[1], this_map[2]) && behind_map[0].water?(behind_map[1], behind_map[2]) && Always_in_Bush_in_Water::AIW_ACTIVE
                @bush_depth = Always_in_Bush_in_Water::WATER_DEPTH
              end
            end   
          end
        end       
      end
    end
  else
    def calculate_bush_depth
      if @tile_id > 0 || @always_on_top || jumping?
        @bush_depth = 0
        return
      end
      xbehind = @x + (@direction == 4 ? 1 : @direction == 6 ? -1 : 0)
      ybehind = @y + (@direction == 8 ? 1 : @direction == 2 ? -1 : 0)
      this_map = (self.map.valid?(@x, @y)) ? [self.map, @x, @y] : $map_factory&.getNewMap(@x, @y)
      behind_map = (self.map.valid?(xbehind, ybehind)) ? [self.map, xbehind, ybehind] : $map_factory&.getNewMap(xbehind, ybehind)
      if this_map && this_map[0].deepBush?(this_map[1], this_map[2]) &&
         (!behind_map || behind_map[0].deepBush?(behind_map[1], behind_map[2]))
        @bush_depth = Game_Map::TILE_HEIGHT
      elsif this_map && this_map[0].bush?(this_map[1], this_map[2]) && !moving?
        @bush_depth = 12
      elsif this_map && this_map[0].marsh?(this_map[1], this_map[2]) && !moving? && (self==$game_player && $PokemonGlobal.stuck)
        @bush_depth = 12  
      else
        @bush_depth = 0
      end
    end 
  end   
end
#===================================================================================================================
# Adds new method water?(x,y) + sand?(x,y) to the class Game_Map
#===================================================================================================================
class Game_Map
  def water?(x,y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.bridge && $PokemonGlobal.bridge > 0
      return false if terrain.id_number == 17
      #return false if terrain.id_number == 3
      return true if terrain.shows_puddle
      return true if terrain.can_surf && @passages[tile_id]
    end
    return false
  end

  def sand?(x,y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return false if terrain.id_number == 17
      #return true if terrain.id_number == 3
    end
    return false
  end 

  def tallgrass?(x,y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return true if terrain.id_number == 10
    end
    return false
  end

  def marsh?(x,y)
    [2, 1, 0].each do |i|
      tile_id = data[x, y, i]
      terrain = GameData::TerrainTag.try_get(@terrain_tags[tile_id])
      return true if terrain.id_number == Deep_Marsh_Tiles::MARSH_ID
      return true if terrain.id_number == Deep_Marsh_Tiles::DEEPMARSH_ID
      return true if terrain.id_number == Deep_Marsh_Tiles::MARSHGRASS_ID
      return true if terrain.id_number == Deep_Marsh_Tiles::DEEPMARSHGRASS_ID
      return true if terrain.id_number == Deep_Marsh_Tiles::TALLMARSHGRASS_ID
      return true if terrain.id_number == Deep_Marsh_Tiles::TALLDEEPMARSHGRASS_ID
    end
    return false
  end  
end


#===================================================================================================================
# Overrides the Script Command to toggle Following Pokemon
# This is in order to recalculate bush depth when following Pokemon are toggled
#===================================================================================================================
if Always_in_Bush_in_Water::FOLLOWING_POKEMON
  module FollowingPkmn

    def self.toggle(forced = nil, anim = nil)
      return if !FollowingPkmn.can_check? || !FollowingPkmn.get
      return if !FollowingPkmn.get_pokemon
      anim_1 = FollowingPkmn.active?
      if !forced.nil?
        # This may seem redundant but it keeps follower_toggled a boolean always
        $PokemonGlobal.follower_toggled = !(!forced)
      else
        $PokemonGlobal.follower_toggled = !($PokemonGlobal.follower_toggled)
      end
      anim_2 = FollowingPkmn.active?
      anim = anim_1 != anim_2 if anim.nil?
      FollowingPkmn.refresh(anim)
      $game_temp.followers.move_followers
      $game_temp.followers.turn_followers
      
      #additions
      even=FollowingPkmn.get_event
      even.calculate_bush_depth
    end
  end
end

#===================================================================================================================