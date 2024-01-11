class Game_Temp
  attr_accessor :swinging
end

def pbPowerWhip(destination, grapple)
  return if $game_temp.swinging || $game_player.move_route_forcing || $game_player.moving?
  frames = 50.0
  hframe = (frames/2).round
  qframe = (frames/4).round
  grapple_event = get_character(grapple)
  destination_event = get_character(destination)
  distance = Math.sqrt(($game_player.x - destination_event.x)**2 + ($game_player.y - destination_event.y)**2)
  return unless pbEventFacesPlayer?($game_player, destination_event, 10)
  $game_temp.swinging = true
  $game_player.through = true
  bitmap = BitmapSprite.new(Graphics.width/2, Graphics.height/2, Spriteset_Map.viewport)
  bitmap.zoom_x = 2
  bitmap.zoom_y = 2
  qframe.times { |i| next if i == 0; swing(bitmap, grapple_event.screen_x, grapple_event.screen_y, (i-1).to_f/qframe.to_f) }
  case $game_player.direction
  when 2 then x_plus = 0; y_plus = 1
  when 4 then x_plus = -1; y_plus = 0
  when 6 then x_plus = 1; y_plus = 0
  when 8 then x_plus = 0; y_plus = -1
  end
  $game_player.jump(x_plus, y_plus)
  old_toggled = $PokemonGlobal.follower_toggled
  FollowingPkmn.toggle_off
  if [2,8].include?($game_player.direction)
    dy = (destination_event.real_y - $game_player.real_y).to_f / frames
    frames.round.times do |i|
      $game_player.y_offset = -(hframe-(i+1)).abs + hframe
      swing(bitmap, grapple_event.screen_x, grapple_event.screen_y)
      $game_player.real_y += dy
    end
  else
    dx = (destination_event.real_x - $game_player.real_x).to_f / frames
    frames.round.times do |i|
      $game_player.y_offset = -(hframe-(i+1)).abs + hframe
      swing(bitmap, grapple_event.screen_x, grapple_event.screen_y)
      $game_player.real_x += dx
    end
  end
  $game_player.jump(destination_event.x - $game_player.x, destination_event.y - $game_player.y)
  qframe.times { |i| next if i == 0; swing(bitmap, grapple_event.screen_x, grapple_event.screen_y, (qframe-i-1).to_f/qframe.to_f) }
  bitmap.bitmap.clear
  bitmap.dispose
  $game_player.through = false
  $game_temp.followers.put_followers_on_player
  FollowingPkmn.toggle(old_toggled, true)
  $game_temp.swinging = false
end

def swing(bmp, origin_x, origin_y, length=1)
  bmp.bitmap.clear
  draw_line(bmp.bitmap, $game_player.screen_x+2, $game_player.screen_y - 32, origin_x+2, origin_y - 16, Color.new("1F5B33"), length)
  draw_line(bmp.bitmap, $game_player.screen_x, $game_player.screen_y - 30, origin_x, origin_y - 14, Color.new("1F5B33"), length)
  draw_line(bmp.bitmap, $game_player.screen_x+2, $game_player.screen_y - 30, origin_x+2, origin_y - 14, Color.new("1F5B33"), length)
  draw_line(bmp.bitmap, $game_player.screen_x, $game_player.screen_y - 32, origin_x, origin_y - 16, Color.new("3B9948"), length)
  Graphics.update
  pbUpdateSceneMap
end

def draw_line(bitmap, x1, y1, x2, y2, color, length=1)
  x2 = x1 + length * (x2 - x1)
  y2 = y1 + length * (y2 - y1)
  x1 = (x1/2).to_i
  y1 = (y1/2).to_i
  x2 = (x2/2).to_i
  y2 = (y2/2).to_i
  w = (x1 - x2).abs
  h = (y1 - y2).abs
  sx = 0
  sy = 0
  sx = (x1 < x2) ? 1 : -1
  sy = (y1 < y2) ? 1 : -1
  err = (w - h).to_f
  while true
    bitmap.set_pixel(x1, y1, color)
    break if ((x1 == x2) && (y1 == y2))
    e2 = (2 * err).to_f
    if (e2 > -h)
      err -= h
      x1 += sx
    end
    if (e2 < w)
      err += w
      y1 += sy
    end
  end
end