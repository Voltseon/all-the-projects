TOFFSET = 320

TILEGROUND = 389 + TOFFSET
TILEUP = 393 + TOFFSET
TILEDOWN = 409 + TOFFSET
TILELEFT = 400 + TOFFSET
TILERIGHT = 402 + TOFFSET
TILENEUT = 401 + TOFFSET
TILEUL = 392 + TOFFSET
TILEUR = 394 + TOFFSET
TILEDL = 408 + TOFFSET
TILEDR = 410 + TOFFSET
TILECORUL = 416 + TOFFSET
TILECORUR = 417 + TOFFSET
TILECORDL = 424 + TOFFSET
TILECORDR = 425 + TOFFSET
DETILE = 388 + TOFFSET
ROCKS = [384 + TOFFSET,385 + TOFFSET,386 + TOFFSET,387 + TOFFSET]

class CaveMaker_MapTile
  attr_accessor :tile
  attr_accessor :position
  attr_accessor :layer
  attr_accessor :neighbours

  def initialize(tile, position, layer, neighbours)
    @tile = tile
    @position = position
    @layer = layer
    @neighbours = neighbours
  end

  def x; return @position[0]; end
  def y; return @position[1]; end
  def tile; return @tile; end
  def position; return @position; end
  def layer; return @layer; end
  def neighbours; return @neighbours; end
  def n_up; return @neighbours[0]; end
  def n_down; return @neighbours[1]; end
  def n_left; return @neighbours[2]; end
  def n_right; return @neighbours[3]; end
end

def pbMakeCave(layers=0)
  mapData = Compiler::MapData.new
  id = $game_map.map_id
  map = mapData.getMap(id)
  skiptiles = []
  tiles = []
  map.data.xsize.times do |x|
    map.data.ysize.times do |y|
      map.data.zsize.times do |i|
        tile_id = map.data[x, y, i]
        n_up = map.data[x, y-1, i]
        n_down = map.data[x, y+1, i]
        n_left = map.data[x-1, y, i]
        n_right = map.data[x+1, y, i]
        tiles.push(CaveMaker_MapTile.new(tile_id, [x,y], i, [n_up,n_down,n_left,n_right]))
      end
    end
  end
  for lay in 0..layers
    if lay == 0
      tiles.each do |tile|
        if tile.tile == TILEGROUND
          u = tile.n_up == TILENEUT
          d = tile.n_down == TILENEUT
          l = tile.n_left == TILENEUT
          r = tile.n_right == TILENEUT

          if u
            finaltile = TILEDOWN
            if map.data[tile.x+1, tile.y-1, tile.layer] == TILEGROUND
              finaltile = TILEGROUND
              pbSetTile(map,tile.x, tile.y-1, tile.layer+1, TILEDR)
            elsif map.data[tile.x-1, tile.y-1, tile.layer] == TILEGROUND
              finaltile = TILEGROUND
              pbSetTile(map,tile.x, tile.y-1, tile.layer+1, TILEDL)
            end
            pbSetTile(map,tile.x, tile.y-1, tile.layer, TILEDOWN)
            skiptiles.push([tile.x, tile.y-1, tile.layer]) if finaltile == TILEGROUND
          elsif d
            finaltile = TILEUP
            if map.data[tile.x+1, tile.y+1, tile.layer] == TILEGROUND
              finaltile = TILEGROUND
              pbSetTile(map,tile.x, tile.y+1, tile.layer+1, TILEUR)
            elsif map.data[tile.x-1, tile.y+1, tile.layer] == TILEGROUND
              finaltile = TILEGROUND
              pbSetTile(map,tile.x, tile.y+1, tile.layer+1, TILEUL)
            end
            pbSetTile(map,tile.x, tile.y+1, tile.layer, TILEUP)
            skiptiles.push([tile.x, tile.y+1, tile.layer]) if finaltile == TILEGROUND
          end
          pbSetTile(map,tile.x-1, tile.y, tile.layer, TILERIGHT) if l
          pbSetTile(map,tile.x+1, tile.y, tile.layer, TILELEFT) if r

          
          pbSetTile(map,tile.x-1, tile.y-1, tile.layer, TILECORUL) if u && l
          pbSetTile(map,tile.x+1, tile.y-1, tile.layer, TILECORUR) if u && r
          pbSetTile(map,tile.x-1, tile.y+1, tile.layer, TILECORDL) if d && l
          pbSetTile(map,tile.x+1, tile.y+1, tile.layer, TILECORDR) if d && r
        end
      end
    else
      multiple_layers = []
      map.data.xsize.times do |x|
        map.data.ysize.times do |y|
          map.data.zsize.times do |i|
            multiple_layers.push([x, y-1, i, TILEDOWN]) if map.data[x,y,i] == TILEDOWN
            multiple_layers.push([x, y+1, i, TILEUP]) if map.data[x,y,i] == TILEUP
            multiple_layers.push([x-1, y, i, TILERIGHT]) if map.data[x,y,i] == TILERIGHT
            multiple_layers.push([x+1, y, i, TILELEFT]) if map.data[x,y,i] == TILELEFT
          end
        end
      end
      map.data.xsize.times do |x|
        map.data.ysize.times do |y|
          map.data.zsize.times do |i|
            if map.data[x,y,i] == TILECORUL
              multiple_layers.push([x-1, y-1, i, TILECORUL])
              multiple_layers.push([x, y-1, i, TILEDOWN])
              multiple_layers.push([x-1, y, i, TILERIGHT])
            elsif map.data[x,y,i] == TILECORUR 
              multiple_layers.push([x+1, y-1, i, TILECORUR])
              multiple_layers.push([x, y-1, i, TILEDOWN])
              multiple_layers.push([x+1, y, i, TILELEFT])
            elsif map.data[x,y,i] == TILECORDL
              multiple_layers.push([x-1, y+1, i, TILECORDL])
              multiple_layers.push([x, y+1, i, TILEUP])
              multiple_layers.push([x-1, y, i, TILERIGHT])
            elsif map.data[x,y,i] == TILECORDR
              multiple_layers.push([x+1, y+1, i, TILECORDR])
              multiple_layers.push([x, y+1, i, TILEUP])
              multiple_layers.push([x+1, y, i, TILELEFT])
            end
          end
        end
      end
      map.data.xsize.times do |x|
        map.data.ysize.times do |y|
          if map.data[x,y,1] == TILEDL
            multiple_layers.push([x+1, y-1, 1, TILEDL])
            multiple_layers.push([x+1, y-1, 0, TILENEUT, true])
          elsif map.data[x,y,1] == TILEUR
            multiple_layers.push([x-1, y+1, 1, TILEUR])
            multiple_layers.push([x-1, y+1, 0, TILENEUT, true])
          elsif map.data[x,y,1] == TILEUL
            multiple_layers.push([x+1, y+1, 1, TILEUL])
            multiple_layers.push([x+1, y+1, 0, TILENEUT, true])
          elsif map.data[x,y,1] == TILEDR
            multiple_layers.push([x-1, y-1, 1, TILEDR])
            multiple_layers.push([x-1, y-1, 0, TILENEUT, true])
          end
        end
      end
      multiple_layers.each do |t|
        erase = t.length > 4 ? true : false
        pbSetTile(map,t[0], t[1], t[2], t[3], erase)
      end
    end
  end
  skiptiles.each do |tile|
    pbSetTile(map,tile[0], tile[1], tile[2], TILEGROUND, true)
  end
  rocks = []
  map.data.xsize.times do |x|
    map.data.ysize.times do |y|
      nb = get_neighbors(map,x,y,0)
      next unless nb.count(TILEGROUND) + nb.count(DETILE) < 6
      rocks.push([x, y]) if (map.data[x,y,0] == TILEGROUND || map.data[x,y,0] == TILENEUT) && rand(10)==3 && map.data[x,y,1] == 0
    end
  end
  rocks.each do |r|
    pbSetTile(map,r[0], r[1], 1, ROCKS.sample, true)
  end
  map.data.xsize.times do |x|
    map.data.ysize.times do |y|
      next if get_neighbors(map,x,y,0).include?(DETILE)
      pbSetTile(map,x, y, 0, DETILE, true) if map.data[x,y,0] == TILEGROUND && rand(8)==5
    end
  end
  mapData.saveMap(id)
  pbMessage(_INTL("Close RPG Maker XP to ensure the changes are applied properly."))
end

def pbSetTile(map,x,y,i,tile,erase=false)
  return false unless x >= 0 && x < map.data.xsize
  return false unless y >= 0 && y < map.data.ysize
  return false unless map.data[x,y,i] == TILENEUT || map.data[x,y,i] == 0 || erase
  return false unless map.data[x,y,i+1] == 0 || erase
  $game_map.set_tile(x,y,i,tile)
  map.data[x,y,i] = tile
  return true
end

def get_neighbors(map,x,y,layer)
  ret = []
  [-1,0,1].each do |i|
    [-1,0,1].each do |j|
      next if i == 0 && j == 0
      unless (x+i >= 0 && x+i < map.data.xsize) || (y+j >= 0 && y+j < map.data.ysize)
        ret.push(0)
        next
      end
      ret.push(map.data[x+i,y+j,layer])
    end
  end
  return ret
end