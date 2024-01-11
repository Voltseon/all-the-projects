#===============================================================================
# ■ Always on bush by KleinStudio
# https://wahpokemon.com
# http://pokemonfangames.com
#===============================================================================
class Game_Character
  def bush_depth
    if @tile_id > 0 or @always_on_top
      return 0
    end
    xnext=(@direction==4) ? @x-1 : (@direction==6) ? @x+1 : @x
    ynext=(@direction==8) ? @y-1 : (@direction==2) ? @y+1 : @y

    xbehind=(@direction==4) ? @x+1 : (@direction==6) ? @x-1 : @x
    ybehind=(@direction==8) ? @y+1 : (@direction==2) ? @y-1 : @y

    if @jump_count <= 0 and self.map.bush?(@x, @y) and 
      !self.map.bush?(xbehind, ybehind) and !moving?
      return 12 
    elsif @jump_count <= 0 and self.map.bush?(@x, @y) and
      self.map.bush?(xbehind, ybehind)
      return 12
    else
      return 0
    end
  end
end