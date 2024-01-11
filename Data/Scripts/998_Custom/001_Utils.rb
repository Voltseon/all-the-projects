EventHandlers.add(:on_step_taken, :footstep_sound,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    next if $game_map.map_id == 8
    event.each_occupied_tile do |x, y|
      sound = $map_factory.getTerrainTagFromCoords(event.map.map_id, x, y, true).sound
      next if sound == :none
      dy = $game_player.y-y
      dx = $game_player.x-x
      volmod = [1, 0.9, 0.75, 0.5, 0.25, 0][[((Math.sqrt(dx*dx+dy*dy))/2).round, 5].min]
      play_footstep_se(sound, volmod)
    end
  }
)

def finished_sylvanor
  (76..79).each do |i|
    return false if !$game_switches[i]
  end
  [:AIPOM, :CARNIVINE, :TROPIUS, :CATERPIE, :BUTTERFREE].each do |pkmn|
    return false if !$player.seen?(pkmn)
  end
  return true
end

PLANET_POKEMON = {
  :SYLVANOR => [:AIPOM, :CARNIVINE, :TROPIUS, :CATERPIE, :BUTTERFREE],
  :GLINTERRA => [:BRONZOR, :DIGLETT, :SANDACONDA, :GRAVELER, :EISCUE],
  :VULKAMOS => [:TIRTOUGA, :SABLEYE, :DHELMISE, :CAMERUPT, :DWEBBLE],
  :LUSATIA => [:SOLROCK, :LUNATONE],
  :DIGIRELM => [:MISSINGNO, :PORYGON],
  :LUNIN => [:CLEFAIRY, :CLEFABLE]
}

def scanned_any_pokemon(planet = $player.planet.id)
  pokemon = PLANET_POKEMON[planet]
  return false if !pokemon
  pokemon.each do |pkmn|
    return true if $player.seen?(pkmn)
  end
  return false
end

def scanned_on_each_visited_planet
  $player.visited_planets.each do |planet|
    return false if !scanned_any_pokemon(planet)
  end
  return true
end

def check_act_three
  return if $game_switches[104]
  return if $player.visited_planets.include?($player.planet.id)
  return if $player.visited_planets.length != 6
  $player.planet = GameData::Planet.get(:SHUTTLE)
  $game_switches[101] = true
end


def play_opening(planet=:NONE)
  return if planet == :NONE || planet == :SYLVANOR
  if $player.visited_planets.include?(planet)
    souvenirs = []
    pokemon = PLANET_POKEMON[planet] || []
    items = []
    id = 1
    case planet
    when :GLINTERRA
      souvenirs = (80..83).to_a
      items = [:COMMUNICATIONSMODULE, :PICKAXE]
    when :VULKAMOS
      souvenirs = (84..87).to_a
      items = [:ROCKETBOOTS]
    when :LUSATIA
      souvenirs = [88, 89]
    when :DIGIRELM
      souvenirs = [90, 91]
      items = [:TEXTFILE]
    when :LUNIN
      souvenirs = (92..95).to_a
    end
    souvenirs.each do |s|
      next if $game_switches[s]
      id = 2
      break
    end
    if id == 1
      pokemon.each do |pkmn|
        next if $player.seen?(pkmn)
        id = 2
        break
      end
      if id == 1
        items.each do |item|
          next if has_item(item)
          id = 2
          break
        end
      end
    end
    pbMEPlay("PLA 022 A New Morning (#{id})")
  else
    $player.visited_planets << planet
    pbMEPlay("PLA 022 A New Morning (3)")
  end
  pbBGSFade(1.0)
  $game_map.autoplay
end

def get_desktop_directory
  return "" if !System.is_really_windows?
  dest = System.data_directory
  dest.gsub!("\\", "/")
  final_dest = ""
  split = dest.split("/")
  split.each_with_index do |sp, i|
    new_dest = split[0..i].join("/") + "/Desktop/"
    next if !File.directory?(new_dest)
    final_dest = new_dest
    break
  end
  destination = nil_or_empty?(final_dest) ? "" : final_dest
  return destination
end

EventHandlers.add(:on_frame_update, :tudee,
  proc {
    next unless $scene.is_a?(Scene_Map)
    next unless $game_player
    next unless $game_map.map_id == 23 || ($game_map.map_id == 5 && $player.planet.id == :DIGIRELM)
    next unless has_item(:TEXTFILE)
    state = 0
    if File.exist?("#{get_desktop_directory}tudee.txt")
      File.open("#{get_desktop_directory}tudee.txt", "r") { |f| state = f.read }
      state = state.to_i
      if (state == 0 && $player.character_ID == 6) || (state == 1 && $player.character_ID == 1)
        $game_player.animation_id = 11
        $player.character_ID = (state == 0 ? 1 : 6)
      end
      if state == 3 && $game_player.x != 50 && $game_player.y != 49 && $game_map.map_id != 5
        $game_player.moveto(50, 49)
      end
      if state == 2 && $game_player.pbTerrainTag.id != :DataPad
        tiles = []
        $game_map.width.times do |x|
          $game_map.height.times do |y|
            tiles << [x, y] if $map_factory.getTerrainTagFromCoords($game_map.map_id, x, y, true).id == :DataPad
          end
        end
        if tiles.length > 0
          closest = tiles[0]
          tiles.each do |tile|
            closest = tile if Math.sqrt((tile[0]-$game_player.x)**2 + (tile[1]-$game_player.y)**2) < Math.sqrt((closest[0]-$game_player.x)**2 + (closest[1]-$game_player.y)**2)
          end
          $game_player.moveto(closest[0], closest[1])
        end
      end
    else
      File.open("#{get_desktop_directory}tudee.txt", "ab") { |f| f.write(0) }
      #system("explorer.exe /select,\"#{get_desktop_directory.gsub("/","\\")}tudee.txt\"")
    end
  }
)

def play_footstep_se(terrain, volmod = 1)
  volume = ($PokemonSystem ? $PokemonSystem.footstepvolume : 50) * volmod
  case terrain
  when :grass
    val = rand(5)
    pbSEPlay("step_grass_#{val+1}", volume, 90+rand(20))
  when :metal
    val = rand(6)
    pbSEPlay("step_metal_#{val+1}", volume, 90+rand(20))
  when :puddle
    val = rand(6)
    pbSEPlay("step_water_#{val+1}", volume, 90+rand(20))
  when :sand
    val = rand(6)
    pbSEPlay("step_sand_#{val+1}", volume, 90+rand(20))
  when :default
    val = rand(6)
    pbSEPlay("step_default_#{val+1}", volume, 90+rand(20))
  end
end

def letterSound(name)
  if nil_or_empty?(name)
    # Do nothing
  else
    pbSEPlay("letterpop_#{name}",70,90+rand(20))
  end
end

def fix_suits(events)
  events.each_with_index do |event, i|
    pbSetSelfSwitch(event, "A", $player.suit == i+1)
  end
end

TREE_MESSAGES = {
  :SYLVEN => ["It's a small tree, would you like to cut it down?", "It's a small tree, you could probably cut it down if you had a hatchet."],
  :FERRICIODIDE => ["It's a rock with some ferric iodide on it, would you like to collect it?", "It's a rock with some ferric iodide on it, you could probably collect it if you had a pickaxe."],
  :SILICATECRYSTAL => ["It's a rock with a silicate crystal inside, would you like to collect it?", "It's a rock with a silicate crystal inside, you could probably collect it if you had a pickaxe."],
  :HAIR => ["It's a small tree, would you like to cut it down?", "It's a small tree, you could probably cut it down if you had a hatchet."],
  :PLATINUMINGOT => ["It's a rock with a platinum ingot inside, would you like to collect it?", "It's a rock with a platinum ingot inside, you could probably collect it if you had a pickaxe."]
}

def tree(type=:SYLVEN)
  if ([:SYLVEN, :HAIR].include?(type) ? has_item(:HATCHET) : has_item(:PICKAXE))
    if $game_temp&.smashables&.include?(type) || pbConfirmMessage(TREE_MESSAGES[type][0])
      $game_temp.smashables = [type] if $game_temp.smashables.nil?
      $game_temp.smashables.push(type) unless $game_temp.smashables.include?(type)
      event = get_self
      dir = event.direction
      graphic = event.character_name
      pbSEPlay([:SYLVEN, :HAIR].include?(type) ? "Cut" : "Rock Smash")
      3.times do |i|
        pbMoveRoute(event, [PBMoveRoute::Graphic, graphic, 0, dir, i+1])
        pbWait(4)
      end
      $game_map.events[event.id]&.erase
      $PokemonMap&.addErasedEvent(event.id)
      case type
      when :SYLVEN
        add_item(:SYLVENBRANCH, rand(1..3)) if rand(3) != 1
        add_item(:TWINE, rand(1..2)) if rand(3) != 1
      when :FERRICIODIDE
        add_item(:FERRICIODIDE, rand(3..8))
        add_item(:SYLVENSTONES, rand(1..3)) if rand(3) != 1
      when :SILICATECRYSTAL
        add_item(:SILICATECRYSTAL, rand(1..3))
      when :HAIR
        add_item(:GOLDHAIR)
      when :PLATINUMINGOT
        add_item(:PLATINUMINGOT)
      end
    end
  else
    pbMessage(TREE_MESSAGES[type][1])
  end
end

def pbRocketBoots(x_offset, y_offset)
  if ($game_player.pbFacingTerrainTag.rocket || $game_player.pbFacingTerrainTag.ledge) && has_item(:ROCKETBOOTS)
    if pbRocketToward(true)
      $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID, $game_player.x, $game_player.y, true, 1)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1, 2])
    end
    return true
  end
  return false
end

def pbRocketToward(playSound = false)
  x = $game_player.x
  y = $game_player.y
  dist = 1
  x_offset = [0, -1, 0, 1, -1, 0, 1, -1, 0, 1][$game_player.direction]
  y_offset = [0, 1, 1, 1, 0, 0, 0, -1, -1, -1][$game_player.direction]
  12.times do |i|
    break unless $map_factory.getTerrainTag($game_map.map_id, $game_player.x + x_offset * (i+1), $game_player.y + y_offset * (i+1)).rocket || $map_factory.getTerrainTag($game_map.map_id, $game_player.x + x_offset * (i+1), $game_player.y + y_offset * (i+1)).ledge
    dist += 1
  end
  return false if !$game_map.passable?($game_player.x + x_offset * dist, $game_player.y + y_offset * dist, $game_player.direction)
  case $game_player.direction
  when 2 then $game_player.jump(0, dist)    # down
  when 4 then $game_player.jump(-dist, 0)   # left
  when 6 then $game_player.jump(dist, 0)    # right
  when 8 then $game_player.jump(0, -dist)   # up
  end
  if $game_player.x != x || $game_player.y != y
    pbSEPlay("Player jump") if playSound
    while $game_player.jumping?
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
    return true
  end
  return false
end

EventHandlers.add(:on_player_interact, :collect_luminar,
  proc {
    next if !has_item(:BUCKET)
    has_water = false
    facing = pbFacingTile($game_player.direction, $game_player)
    [2, 1, 0].each do |i|
      tile_id = $game_map.get_tile(facing[1], facing[2], i)
      terrain = GameData::TerrainTag.try_get($game_map.terrain_tags[tile_id])
      if terrain && terrain.can_surf_freely
        has_water = true
        break
      end
    end
    next if !has_water
    volume = $PokemonSystem ? $PokemonSystem.sevolume : 50
    case $game_map.tileset_id
    when 3
      item = :LUMINAR
    when 5
      item = :MOLTENMETAL
    when 6
      item = :WATER
    end
    if can_add_item(item, 1)
      pbSEPlay("BUCKET", volume, 90+rand(20))
      add_item(item, 1)
    else
      pbPlayBuzzerSE
    end
  }
)

def make_shadows
  tileset = $game_map.tileset_id
  echoln "Loading shadows for tileset ##{tileset}..."
  shadows = {}
  Dir.chdir("Dev Stuff/TilesetShadows/#{tileset}") do
    Dir.glob("*.png") do |file|
      filename = file.gsub(/\.png/i, "")
      echoln "Loading shadow at '#{"Dev Stuff/TilesetShadows/#{tileset}/#{filename}"}'..."
      bitmap = "Dev Stuff/TilesetShadows/#{tileset}/#{filename}"
      shadows[filename.to_i] = bitmap
    end
  end
  echoln "Checking tiles for shadows..."
  shadow_bitmap = Bitmap.new($game_map.width*32, $game_map.height*32)
  $game_map.width.times do |x|
    $game_map.height.times do |y|
      [2,1,0].each do |layer|
        tile_id = $game_map.get_tile(x, y, layer)
        next unless shadows.has_key?(tile_id)
        shadow = Bitmap.new(shadows[tile_id])
        next if shadow.nil?
        x_offset = shadow.width / 2
        y_offset = shadow.height / 2
        x_offset = (x_offset / 32.0).floor * 32
        y_offset = (y_offset / 32.0).floor * 32
        shadow_bitmap.blt(x*32 - x_offset, y*32 - y_offset, shadow, shadow.rect)
        echoln "Adding shadow at X: #{x}, Y: #{y}!"
      end
    end
  end
  echoln "Saving shadows to 'Graphics/Shadows/#{$game_map.name}.png'"
  shadow_bitmap.to_file("Graphics/Shadows/#{$game_map.name}.png")
end

module Graphics
  unless defined?(g_update)
    class << Graphics
      alias g_update update
    end
  end

  def self.update
    if $game_temp
      if $game_temp.alarms
        if $game_temp.alarm_counter >= 50 && !$game_screen.tone_changing
          random = rand(-10..10)
          if $game_temp.alarm_on
            $game_screen.start_tone_change(Tone.new(0 + random, 0 + random, 0 + random, 0 + rand(-10..10)), 10)
            $game_temp.alarm_on = false
          else
            pbSEPlay("siren", 80)
            $game_screen.start_tone_change(Tone.new(50 + rand(-10..10) + random.abs, -30 + random, -30 + random, -30 + random), 10)
            $game_temp.alarm_on = true
          end
          $game_temp.alarm_counter = 0
        else
          $game_temp.alarm_counter += 1
        end
      end
    end
    g_update
  end
end

def create_minimap(scale = 3)
  result = Bitmap.new($game_map.width * 32, $game_map.height * 32)
  final = Bitmap.new($game_map.width * scale, $game_map.height * scale)
  tilesetdata = load_data("Data/Tilesets.rxdata")
  data = load_data("Data/Map#{$game_map.map_id.to_digits}.rxdata")
  tilesetname = tilesetdata[data.tileset_id].tileset_name
  tileset = Bitmap.new("Graphics/Tilesets/#{tilesetname}")
  autotiles = tilesetdata[data.tileset_id].autotile_names.filter { |e| e && e.size > 0 }.map { |e| Bitmap.new("Graphics/Autotiles/#{e}") }
  tiles = data.data
  for z in 0..2
    for y in 0...tiles.ysize
      for x in 0...tiles.xsize
        id = tiles[x, y, z]
        next if id == 0
        if id < 384 # Autotile
          build_autotile(result, x * 32, y * 32, id, autotiles)
        else # Normal tile
          result.blt(x * 32, y * 32, tileset, Rect.new(32 * ((id - 384) % 8),32 * ((id - 384) / 8).floor,32,32))
        end
      end
    end
  end
  (result.width/32).times do |x|
    (result.height/32).times do |y|
      get = Bitmap.new(32, 32)
      get.blt(0, 0, result, Rect.new(x*32, y*32, 32, 32))
      color = get_average_color(get)
      final.fill_rect(x*scale, y*scale, scale, scale, color) if color.alpha > 0
    end
  end
  final.to_file("Graphics/Minimaps/#{$game_map.map_id}.png")
end

def get_average_color(bitmap)
  r = 0
  g = 0
  b = 0
  a = 0
  count = 0
  bitmap.width.times do |x|
    bitmap.height.times do |y|
      color = bitmap.get_pixel(x, y)
      next if color.alpha == 0
      r += color.red
      g += color.green
      b += color.blue
      a += color.alpha
      count += 1
    end
  end
  return Color.new(r, g, b, a) if count == 0
  return Color.new(r / count, g / count, b / count, a / count)
end

def build_autotile(bitmap, x, y, id, autotiles)
  autotile = autotiles[id / 48 - 1]
  return unless autotile
  if autotile.height == 32
    bitmap.blt(x,y,autotile,Rect.new(0,0,32,32))
  else
    id %= 48
    tiles = TileDrawingHelper::AUTOTILE_PATTERNS[id >> 3][id & 7]
    src = Rect.new(0,0,0,0)
    halfTileWidth = halfTileHeight = halfTileSrcWidth = halfTileSrcHeight = 32 >> 1
    for i in 0...4
      tile_position = tiles[i] - 1
      src.set((tile_position % 6) * halfTileSrcWidth,
         (tile_position / 6) * halfTileSrcHeight, halfTileSrcWidth, halfTileSrcHeight)
      bitmap.blt(i % 2 * halfTileWidth + x, i / 2 * halfTileHeight + y,
          autotile, src)
    end
  end
end

class Numeric
  # Formats the number nicely (e.g. 1234567890 -> format() -> 1,234,567,890)
  def format(separator = ',')
    a = self.to_s.split('').reverse.breakup(3)
    return a.map { |e| e.join('') }.join(separator).reverse
  end
  
  # Makes sure the returned string is at least n characters long
  # (e.g. 4   -> to_digits -> "004")
  # (e.g. 19  -> to_digits -> "019")
  # (e.g. 123 -> to_digits -> "123")
  def to_digits(n = 3)
    str = self.to_s
    return str if str.size >= n
    ret = ""
    (n - str.size).times { ret += "0" }
    return ret + str
  end
end

def name_creature
  loop do
    default = pbGet(26)
    default = "" if default.is_a?(Integer) || default.nil?
    window = Window_TextEntry_Keyboard.new(default, 130, 382, 650, 64) # (text, x, y, width, height, heading = nil, usedarkercolor = false)
    window.maxlength = 16
    message = "\\capI'm gonna call you..."
    msgwindow = pbCreateMessageWindow(nil, nil, ["\\cap","\\sonar","\\pavo","\\dr","\\luna","\\gng"].any? { |word| message.downcase.include?(word) })
    pbMessageDisplay(msgwindow, message, false)
    gang = Sprite.new(msgwindow.viewport)
    gang.bitmap = Bitmap.new("Graphics/Pictures/Speak/cap")
    gang.ox = gang.bitmap.width / 2
    gang.oy = gang.bitmap.height / 2 - 32
    gang.x = msgwindow.x + msgwindow.skinrect.x / 2 + 2
    gang.y = msgwindow.y + msgwindow.height / 2 - gang.bitmap.height / 2
    gang.z = msgwindow.z
    charname = BitmapSprite.new(80, 32, msgwindow.viewport)
    charname.ox = charname.bitmap.width / 2
    charname.oy = charname.bitmap.height / 2 - 32
    charname.x = msgwindow.x + msgwindow.skinrect.x / 2 + 2
    charname.y = msgwindow.y + msgwindow.height / 2 - charname.bitmap.height / 2 - 48
    charname.z = msgwindow.z + 1
    pbSetSystemFont(charname.bitmap)
    pbDrawShadowText(charname.bitmap, 0, 0, 80, 32, "Cap", MessageConfig::DARK_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_SHADOW_COLOR, 1)
    Input.text_input = true
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      if Input.triggerex?(:ESCAPE)
        break
      elsif Input.triggerex?(:RETURN)
        pbSet(26, window.text)
        break
      end
      window.update
      yield if block_given?
    end
    Input.text_input = false
    window.dispose
    gang.dispose
    charname.dispose
    pbDisposeMessageWindow(msgwindow)
    Input.update
    if pbGet(26) == ""
      pbMessage("\\capI can't call you nothing!")
    else
      break
    end
  end
end

EventHandlers.add(:on_frame_update, :glitch_title,
  proc {
    next if !$scene.is_a?(Scene_Map)
    next if $game_map.map_id != 23
    next unless rand(100) == 1
    title = System.game_title
    weird = "S̵͉͝p̶͓͋a̸͍̽c̷͓̊e̶̬̽ ̷̬̆T̶̫̍r̷̙̋ȃ̷̲ḯ̶̞n̶̯̑e̷̗͠ȑ̶ͅŝ̴̝"
    jibberish = title.split("").map { |c| rand(2) == 1 ? c : rand(2) == 1 ? c.upcase : c.downcase }.join
    rand(1..5).times do
      index = rand(jibberish.size)
      jibberish[index] = weird[index]
    end
    jibberish = "LET ME OUT" if rand(200) == 1
    System.set_window_title(jibberish)
    rand(5..20).times do
      Graphics.update
      Input.update
      $scene.update
    end
    System.set_window_title(title)
  }
)
  