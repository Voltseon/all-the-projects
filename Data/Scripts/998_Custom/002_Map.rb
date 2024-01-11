def pbWorldMap
  pbFadeOutIn {
    scene = Map.new
    scene.pbStartScene
    scene.pbUpdate
  }
end

class Map
  PATH = "Graphics/Pictures/Map/"
  COLOR = [Color.new(248, 248, 248, 200), Color.new(30, 137, 35, 200)]
  CONSTELLATION_COLOR = [Color.new(248, 248, 248), Color.new("4E4B72")]
  CURSOR_SPEED = 0.25
  CURSOR_THRESHOLD = 3
  AVAILABLE_FROM_START = [:SYLVANOR, :GLINTERRA]
  
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 9999999
    @sprites = {}
    @star_count = 10
    @selected_star_count = 3
    @possible_intensities = [250, 200, 150, 100]
    @selected_stars = [[0, false, 250], [1, false, 150], [2, false, 100]]
    @shooting_star_pause = 5
    @planets = []
    @can_travel = true
    @index = 0
    pbMEStop(0.5)
    pbBGMPlay("PLA 060 Space-Time Distortion")
  end
  
  def pbStartScene
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = Bitmap.new(PATH + "background")
    @star_count.times do |i|
      @sprites["star#{i}"] = Sprite.new(@viewport)
      @sprites["star#{i}"].bitmap = Bitmap.new(PATH + "star")
      @sprites["star#{i}"].x = rand(Graphics.width - 32) + 16
      @sprites["star#{i}"].y = rand(Graphics.height - 32) + 16
      @sprites["star#{i}"].opacity = 0
      @sprites["star#{i}"].z = 1
    end
    @sprites["shooting_star"] = AnimatedSprite.create(PATH + "shooting_star_frames", 6, 0, @viewport)
    @sprites["shooting_star"].x = rand(Graphics.width - 32) + 16
    @sprites["shooting_star"].y = rand(Graphics.height - 32) + 16
    @sprites["shooting_star"].blend_type = 1
    @sprites["shooting_star"].start
    @sprites["shooting_star"].z = 2
    @sprites["constellation"] = BitmapSprite.new(Graphics.width/2, Graphics.height/2, @viewport)
    @sprites["constellation"].zoom_x = 2
    @sprites["constellation"].zoom_y = 2
    @sprites["constellation"].z = 3
    GameData::Planet.each do |planet|
      next unless planet.shows_on_map
      #next if !AVAILABLE_FROM_START.include?(planet.id) && !has_item(:COMMUNICATIONSMODULE)
      name = planet.id
      x = planet.map_x
      y = planet.map_y
      frame_count = planet.frame_count
      @sprites["planet_#{name}"] = AnimatedSprite.create(PATH + "planet_#{name}", frame_count, 0, @viewport)
      @sprites["planet_#{name}"].ox = @sprites["planet_#{name}"].bitmap.width / frame_count / 2
      @sprites["planet_#{name}"].oy = @sprites["planet_#{name}"].bitmap.height / 2
      @sprites["planet_#{name}"].x = x
      @sprites["planet_#{name}"].y = y
      @sprites["planet_#{name}"].start
      @sprites["planet_#{name}"].z = 5
      planet.connections.each do |connection|
        next if connection[0] == nil
        next if !AVAILABLE_FROM_START.include?(connection[0]) && !has_item(:COMMUNICATIONSMODULE)
        next if @sprites["planet_#{connection[0]}"]
        connected_planet = GameData::Planet.get(connection[0])
        x1 = @sprites["planet_#{name}"].x
        y1 = @sprites["planet_#{name}"].y
        x2 = connected_planet.map_x
        y2 = connected_planet.map_y
        draw_line(x1, y1+2, x2, y2+2, CONSTELLATION_COLOR[1])
        draw_line(x1, y1, x2, y2, CONSTELLATION_COLOR[0])
      end
      @planets.push(planet)
    end
    @index = @planets.find_index($player.planet) || 3
    @sprites["cursor"] = AnimatedSprite.create(PATH + "marker", 12, 1, @viewport)
    @sprites["cursor"].ox = @sprites["cursor"].bitmap.width / 24
    @sprites["cursor"].oy = @sprites["cursor"].bitmap.height / 2
    @sprites["cursor"].x = @sprites["planet_#{@planets[@index].id}"].x
    @sprites["cursor"].y = @sprites["planet_#{@planets[@index].id}"].y
    @sprites["cursor"].blend_type = 1
    @sprites["cursor"].start
    @sprites["cursor"].z = 10
    @sprites["button_travel"] = ChangelingSprite.new(8, 492, @viewport)
    @sprites["button_travel"].addBitmap(0, PATH + "button_travel")
    @sprites["button_travel"].addBitmap(1, PATH + "button_too_far")
    @sprites["button_travel"].changeBitmap(0)
    @sprites["button_travel"].z = 13
    @sprites["button_back"] = Sprite.new(@viewport)
    @sprites["button_back"].bitmap = Bitmap.new(PATH + "button_back")
    @sprites["button_back"].x = 8
    @sprites["button_back"].y = 544
    @sprites["button_back"].z = 14
    @sprites["info"] = AnimatedSprite.create(PATH + "info", 3, 3, @viewport)
    @sprites["info"].start
    @sprites["info"].z = 15
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 20
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbFadeInAndShow(@sprites)
    if rand(100) == 1
      meteor_shower
    end
  end
  
  def pbMain
    return if @viewport.disposed?
    Graphics.update
    pbUpdateSpriteHash(@sprites)
    @selected_star_count.times do |i|
      selected_star = @selected_stars[i][0]
      dimming = @selected_stars[i][1]
      intensity = @selected_stars[i][2]
      @sprites["star#{selected_star}"].opacity += 10 if rand(6) == 1 && !dimming
      if @sprites["star#{selected_star}"].opacity >= intensity || dimming
        @sprites["star#{selected_star}"].opacity -= 10 if rand(6) == 1
        @selected_stars[i][1] = true
      end
      if @sprites["star#{selected_star}"].opacity <= 50 && dimming && rand(5) == 1
        possible_stars = []
        impossible_stars = []
        @selected_stars.each { |j| impossible_stars.push(j[0])}
        @star_count.times { |k| possible_stars.push(k) if !impossible_stars.include?(k) }
        @selected_stars[i][0] = possible_stars.sample
        @selected_stars[i][1] = false
        @selected_stars[i][2] = @possible_intensities.sample
      end
    end
    if @sprites["shooting_star"].frame == 0
      if @shooting_star_pause <= 0
        @sprites["shooting_star"].opacity = 255
        @sprites["shooting_star"].x = rand(Graphics.width - 64) + 32
        @sprites["shooting_star"].y = rand(Graphics.height - 64) + 32
        @sprites["shooting_star"].frame = 0
        @sprites["shooting_star"].start
        @shooting_star_pause = rand(5) + 5
      elsif @sprites["shooting_star"].played_once
        @shooting_star_pause -= Graphics.delta
        if @sprites["shooting_star"].playing?
          @sprites["shooting_star"].stop
          @sprites["shooting_star"].opacity = 0
        end
      end
    else
      @sprites["shooting_star"].x -= 1
      @sprites["shooting_star"].y += 1
    end
  end

  def pbDrawText
    return if @viewport.disposed?
    @sprites["overlay"].bitmap.clear
    textpos = []
    [@planets[@index].name, @planets[@index].description, "Gravity: #{@planets[@index].gravity}G"].each_with_index do |text, i|
      textpos.push([text, 496, 420 + i * 32, 0, COLOR[0], COLOR[1]])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
  end

  def pbUpdateInput
    return if @viewport.disposed?
    Input.update
    if Input.trigger?(Input::BACK)
      pbEndScene
    elsif Input.trigger?(Input::USE)
      if @can_travel && $player.planet != @planets[@index].id
        pbMEPlay("PLA 061 Exiting the Space-Time Distortion")
        $game_variables[1] = $game_map.map_id
        $game_variables[2] = $game_player.x
        $game_variables[3] = $game_player.y
        $game_temp.player_transferring = true
        $game_temp.player_new_map_id = 19
        $game_temp.player_new_x = 13
        $game_temp.player_new_y = 7
        $player.planet = @planets[@index].id
        $game_player.update_move
      end
      pbEndScene
    elsif Input.trigger?(Input::UP)
      connection = @planets[@index].connection_top
      if connection[0] != nil && (AVAILABLE_FROM_START.include?(connection[0]) || has_item(:COMMUNICATIONSMODULE))
        @index = @planets.index(GameData::Planet.get(connection[0]))
        move_cursor(@sprites["planet_#{connection[0]}"].x, @sprites["planet_#{connection[0]}"].y)
        #@can_travel = connection[1] <= 
      end
    elsif Input.trigger?(Input::DOWN)
      connection = @planets[@index].connection_bottom
      if connection[0] != nil && (AVAILABLE_FROM_START.include?(connection[0]) || has_item(:COMMUNICATIONSMODULE))
        @index = @planets.index(GameData::Planet.get(connection[0]))
        move_cursor(@sprites["planet_#{connection[0]}"].x, @sprites["planet_#{connection[0]}"].y)
      end
    elsif Input.trigger?(Input::LEFT)
      connection = @planets[@index].connection_left
      if connection[0] != nil && (AVAILABLE_FROM_START.include?(connection[0]) || has_item(:COMMUNICATIONSMODULE))
        @index = @planets.index(GameData::Planet.get(connection[0]))
        move_cursor(@sprites["planet_#{connection[0]}"].x, @sprites["planet_#{connection[0]}"].y)
      end
    elsif Input.trigger?(Input::RIGHT)
      connection = @planets[@index].connection_right
      if connection[0] != nil && (AVAILABLE_FROM_START.include?(connection[0]) || has_item(:COMMUNICATIONSMODULE))
        @index = @planets.index(GameData::Planet.get(connection[0]))
        move_cursor(@sprites["planet_#{connection[0]}"].x, @sprites["planet_#{connection[0]}"].y)
      end
    end
  end
  
  def pbUpdate
    while !@viewport.disposed? do
      pbMain
      pbDrawText
      pbUpdateInput
      pbDrawText
    end
  end

  def move_cursor(x, y)
    @sprites["overlay"].bitmap.clear
    move_do_lerp(@sprites["cursor"].x, @sprites["cursor"].y, x, y, CURSOR_THRESHOLD, CURSOR_SPEED) do |x, y|
      @sprites["cursor"].x = x
      @sprites["cursor"].y = y
      pbMain
    end
  end

  def move_do_lerp(start_x, start_y, end_x, end_y, threshold, speed, &block)
    while (start_x - end_x).abs > threshold || (start_y - end_y).abs > threshold
      if start_x != end_x
        start_x = lerp(start_x, end_x, speed)
      end
      if start_y != end_y
        start_y = lerp(start_y, end_y, speed)
      end
      yield(start_x, start_y)
    end
    yield(end_x, end_y)
  end

  def draw_line(x1, y1, x2, y2, color)
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
      @sprites["constellation"].bitmap.set_pixel(x1, y1, color)
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
  
  def meteor_shower
    return if @viewport.disposed?
    200.times do |i|
      return if @viewport.disposed?
      @sprites["meteor_shower_#{i}"] = AnimatedSprite.create(PATH + "shooting_star_frames", 6, 0, @viewport)
      @sprites["meteor_shower_#{i}"].x = rand(Graphics.width - 32) + 16
      @sprites["meteor_shower_#{i}"].y = rand(Graphics.height - 32) + 16
      @sprites["meteor_shower_#{i}"].blend_type = 1
      @sprites["meteor_shower_#{i}"].opacity = 0
      @sprites["meteor_shower_#{i}"].z = 2
    end
    200.times do |i|
      return if @viewport.disposed?
      if i < 100
        2.times do |j|
          if @sprites["meteor_shower_#{i * 2 + j}"] && !@sprites["meteor_shower_#{i * 2 + j}"].playing?
            @sprites["meteor_shower_#{i * 2 + j}"].start
            @sprites["meteor_shower_#{i * 2 + j}"].opacity = 255
          end
        end
      end
      pbMain
      return if @viewport.disposed?
      200.times do |j|
        return if @viewport.disposed?
        if @sprites["meteor_shower_#{j}"]
          if @sprites["meteor_shower_#{j}"].played_once
            @sprites["meteor_shower_#{j}"].opacity = 0
            @sprites["meteor_shower_#{j}"].stop
          elsif @sprites["meteor_shower_#{j}"].playing?
            @sprites["meteor_shower_#{j}"].x -= 1
            @sprites["meteor_shower_#{j}"].y += 1
          end
        end
      end
    end
  end
  
  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbBGMFade(1.0)
  end
end