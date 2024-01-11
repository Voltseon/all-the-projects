#-------------------------------------------------------------------------------
# Boon's Terrain Tag Side Stairs
# v1.3
# By Boonzeet
#-------------------------------------------------------------------------------
# Sideways stairs with pseudo 'depth' effect. Please credit if used
#-------------------------------------------------------------------------------
# v1.3 - Updated for v19
# v1.2 - Fixed bugs with ledges, surfing and map transfers
# v1.1 - Added v18 support
#-------------------------------------------------------------------------------
PluginManager.register({
  :name => "Terrain Tag Side Stairs",
  :version => "1.3",
  :credits => ["Boonzeet"],
  :link => "https://reliccastle.com/resources/397/",
})
#-------------------------------------------------------------------------------
# Config
#-------------------------------------------------------------------------------
GameData::TerrainTag.register({
  :id                     => :StairLeft,
  :id_number              => 17
})
GameData::TerrainTag.register({
  :id                     => :StairRight,
  :id_number              => 18
})
#-------------------------------------------------------------------------------
# Existing Class Extensions
#-------------------------------------------------------------------------------
def pbTurnTowardEvent(event, otherEvent)
  sx = 0; sy = 0
  if $MapFactory
    relativePos = $MapFactory.getThisAndOtherEventRelativePos(otherEvent, event)
    sx = relativePos[0]
    sy = relativePos[1]
  else
    sx = event.x - otherEvent.x
    sy = event.y - otherEvent.y
  end
  return if sx == 0 and sy == 0
  if sx.abs >= sy.abs #added
    (sx > 0) ? event.turn_left : event.turn_right
  else
    (sy > 0) ? event.turn_up : event.turn_down
  end
end
class Game_Character
  alias initialize_stairs initialize
  attr_accessor :offset_x
  attr_accessor :offset_y
  attr_accessor :real_offset_x
  attr_accessor :real_offset_y
  def initialize(*args)
    @offset_x = 0
    @offset_y = 0
    @real_offset_x = 0
    @real_offset_y = 0
    initialize_stairs(*args)
  end
  alias screen_x_stairs screen_x
  def screen_x
    @real_offset_x = 0 if @real_offset_x == nil
    return screen_x_stairs + @real_offset_x
  end
  alias screen_y_stairs screen_y
  def screen_y
    @real_offset_y = 0 if @real_offset_y == nil
    return screen_y_stairs + @real_offset_y
  end
  alias updatemovestairs update_move
  def update_move
    # compatibility with existing saves
    if @real_offset_x == nil || @real_offset_y == nil || @offset_y == nil || @offset_x == nil
      @real_offset_x = 0
      @real_offset_y = 0
      @offset_x = 0
      @offset_y = 0
    end
    if @real_offset_x != @offset_x || @real_offset_y != @offset_y
      @real_offset_x = @real_offset_x - 2 if @real_offset_x > @offset_x
      @real_offset_x = @real_offset_x + 2 if @real_offset_x < @offset_x
      @real_offset_y = @real_offset_y + 2 if @real_offset_y < @offset_y
      @real_offset_y = @real_offset_y - 2 if @real_offset_y > @offset_y
    end
    updatemovestairs
  end
  alias movetostairs moveto
  def moveto(x, y)
    @real_offset_x = 0
    @real_offset_y = 0
    @offset_x = 0
    @offset_y = 0
    movetostairs(x, y)
  end
  alias move_generic_stairs move_generic
  def move_generic(dir, turn_enabled = true)
    move_generic_stairs(dir, turn_enabled)
    if self.map.terrain_tag(@x, @y) == :StairLeft || self.map.terrain_tag(@x, @y) == :StairRight
      @offset_y = -16
    else
      @offset_y = 0
    end
  end
end
class Game_Player
  alias move_generic_stairs move_generic
  def move_generic(dir, turn_enabled = true)
    old_tag = self.map.terrain_tag(@x, @y).id
    old_through = self.through
    old_x = @x
    if dir == 4
      if old_tag == :StairLeft
        if passable?(@x - 1, @y + 1, 4) && self.map.terrain_tag(@x - 1, @y + 1) == :StairLeft
          @y += 1
          self.through = true
        end
      elsif old_tag == :StairRight
        if passable?(@x - 1, @y - 1, 6)
          @y -= 1
          self.through = true
        end
      end
    elsif dir == 6
      if old_tag == :StairLeft && passable?(@x + 1, @y - 1, 4)
        @y -= 1
        self.through = true
      elsif old_tag == :StairRight && passable?(@x + 1, @y + 1, 6) && self.map.terrain_tag(@x + 1, @y + 1) == :StairRight
        @y += 1
        self.through = true
      end
    end
    move_generic_stairs(dir, turn_enabled)
    new_tag = self.map.terrain_tag(@x, @y)
    if old_x != @x
      if old_tag != :StairLeft && new_tag == :StairLeft ||
         old_tag != :StairRight && new_tag == :StairRight
        self.offset_y = -16
        @y += 1 if (new_tag == :StairLeft && dir == 4) || (new_tag == :StairRight && dir == 6)
      elsif old_tag == :StairLeft && new_tag != :StairLeft ||
            old_tag == :StairRight && new_tag != :StairRight
        self.offset_y = 0
      end
    end
    self.through = old_through
  end
  alias center_stairs center
  def center(x, y)
    center_stairs(x, y)
    self.map.display_x = self.map.display_x + (@offset_x || 0)
    self.map.display_y = self.map.display_y + (@offset_y || 0)
  end

  def passable?(x, y, d, strict = false)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    return false if !$game_map.validLax?(new_x, new_y)
    if !$game_map.valid?(new_x, new_y)
      return false if !$MapFactory
      return $MapFactory.isPassableFromEdge?(new_x, new_y)
    end
    # If debug mode is ON and Ctrl key was pressed
    return true if $DEBUG && Input.press?(Input::CTRL)
    # insertion from this script
    if d == 8 && new_y > 0 # prevent player moving up past the top of the stairs
      if $game_map.terrain_tag(new_x, new_y) == :StairLeft &&
         $game_map.terrain_tag(new_x, new_y - 1) != :StairLeft
        return false
      elsif $game_map.terrain_tag(new_x, new_y) == :StairRight &&
            $game_map.terrain_tag(new_x, new_y - 1) != :StairRight
        return false
      end
    end
    #end
    return super
  end
end