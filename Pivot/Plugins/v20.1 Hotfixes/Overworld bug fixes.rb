#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for overworld bugs in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

#===============================================================================
# Fixed playing the credits/changing $scene leaving a ghost image of the old map
# behind.
#===============================================================================
class Scene_Map
  def dispose
    disposeSpritesets
    @map_renderer.dispose
    @map_renderer = nil
    @spritesetGlobal.dispose
    @spritesetGlobal = nil
  end

  def main
    createSpritesets
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      break if $scene != self
    end
    Graphics.freeze
    dispose
    if $game_temp.title_screen_calling
      pbMapInterpreter.command_end if pbMapInterpreterRunning?
      $game_temp.title_screen_calling = false
      Graphics.transition
      Graphics.freeze
    end
  end
end

def pbLoadRpgxpScene(scene)
  return if !$scene.is_a?(Scene_Map)
  oldscene = $scene
  $scene = scene
  Graphics.freeze
  oldscene.dispose
  visibleObjects = pbHideVisibleObjects
  Graphics.transition
  Graphics.freeze
  while $scene && !$scene.is_a?(Scene_Map)
    $scene.main
  end
  Graphics.transition
  Graphics.freeze
  $scene = oldscene
  $scene.createSpritesets
  pbShowObjects(visibleObjects)
  Graphics.transition
end

#===============================================================================
# Fixed SystemStackError when two events on connected maps have their backs to
# the other map.
#===============================================================================
class Game_Character
  def calculate_bush_depth
    if @tile_id > 0 || @always_on_top || jumping?
      @bush_depth = 0
      return
    end
    this_map = (self.map.valid?(@x, @y)) ? [self.map, @x, @y] : $map_factory&.getNewMap(@x, @y, self.map.map_id)
    if this_map && this_map[0].deepBush?(this_map[1], this_map[2])
      xbehind = @x + (@direction == 4 ? 1 : @direction == 6 ? -1 : 0)
      ybehind = @y + (@direction == 8 ? 1 : @direction == 2 ? -1 : 0)
      if moving?
        behind_map = (self.map.valid?(xbehind, ybehind)) ? [self.map, xbehind, ybehind] : $map_factory&.getNewMap(xbehind, ybehind, self.map.map_id)
        @bush_depth = Game_Map::TILE_HEIGHT if behind_map[0].deepBush?(behind_map[1], behind_map[2])
      else
        @bush_depth = Game_Map::TILE_HEIGHT
      end
    elsif this_map && this_map[0].bush?(this_map[1], this_map[2]) && !moving?
      @bush_depth = 12
    else
      @bush_depth = 0
    end
  end
end

#===============================================================================
# Fixed error when getting terrain tag when the player moves between connected
# maps.
#===============================================================================
class Game_Player < Game_Character
  def pbTerrainTag(countBridge = false)
    return $map_factory.getTerrainTagFromCoords(self.map.map_id, @x, @y, countBridge) if $map_factory
    return $game_map.terrain_tag(@x, @y, countBridge)
  end
end

#===============================================================================
# Fixed being unable to set the player's movement speed during a move route.
#===============================================================================
class Game_Player < Game_Character
  def set_movement_type(type)
    new_charset = nil
    case type
    when :hurt
      new_charset = "hurt"
    when :melee
      new_charset = "melee"
    when :ranged
      new_charset = "ranged"
    when :guard
      new_charset = "guard"
    when :ability
      self.move_speed = $player.speed
      new_charset = "ability"
    when :walking_stopped, :idle
      pbCameraSpeed(1)
      self.move_speed = $player.speed
      new_charset = "idle"
    else   # :walking, :jumping, :walking_stopped
      pbCameraSpeed(1)
      self.move_speed = $player.speed
      new_charset = "walking"
    end
    skin = Collectible.get($player.equipped_collectibles["skin_#{$player.character_id}".to_sym]).skin
    @character_name = "#{$player.character.internal}/#{skin}/#{new_charset}" if new_charset
  end
end

#===============================================================================
# Fixed crash when ending a Bug Catching Contest.
#===============================================================================
class BugContestState
  def pbJudge
  end
end

#===============================================================================
# Fixed being able to interact with a follower that is beneath the player.
#===============================================================================
class Game_FollowerFactory
  def update
    followers = $PokemonGlobal.followers
    return if followers.length == 0
    # Update all followers
    leader = $game_player
    player_moving = $game_player.moving? || $game_player.jumping?
    followers.each_with_index do |follower, i|
      event = @events[i]
      next if !@events[i]
      if follower.invisible_after_transfer && player_moving
        follower.invisible_after_transfer = false
        event.turn_towards_leader($game_player)
      end
      event.move_speed  = leader.move_speed
      event.transparent = !follower.visible?
      if $PokemonGlobal.sliding
        event.straighten
        event.walk_anime = false
      else
        event.walk_anime = true
      end
      if event.jumping? || event.moving? || !player_moving
        event.update
      elsif !event.starting
        event.set_starting
        event.update
        event.clear_starting
      end
      follower.direction = event.direction
      leader = event
    end
    # Check event triggers
    if Input.trigger?(Input::USE) && !$game_temp.in_menu && !$game_temp.in_battle &&
       !$game_player.move_route_forcing && !$game_temp.message_window_showing &&
       !pbMapInterpreterRunning?
      # Get position of tile facing the player
      facing_tile = $map_factory.getFacingTile
      # Assumes player is 1x1 tile in size
      each_follower do |event, follower|
        next if !facing_tile || event.map.map_id != facing_tile[0] ||
                !event.at_coordinate?(facing_tile[1], facing_tile[2])   # Not on facing tile
        next if event.jumping?
        follower.interact(event)
      end
    end
  end
end

#===============================================================================
# Fixed priority 1 tiles appearing below the player at larger screen sizes.
#===============================================================================
class TilemapRenderer
  def refresh_tile_z(tile, map, y, layer, tile_id)
    if tile.shows_reflection
      tile.z = -100
    elsif tile.bridge && $PokemonGlobal.bridge > 0
      tile.z = 0
    else
      priority = tile.priority
      tile.z = (priority == 0) ? 0 : (y * SOURCE_TILE_HEIGHT) + (priority * SOURCE_TILE_HEIGHT) + SOURCE_TILE_HEIGHT + 1
    end
  end
end
