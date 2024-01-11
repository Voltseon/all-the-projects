class Player < Trainer
  attr_accessor :pursuit
end

def pbSpacePursuit
  scene = ($player.pursuit ? $player.pursuit : SpacePursuit.new)
  show_pursuit(scene)
  $player.pursuit = scene if scene.pause
end

def show_pursuit(scene)
  should_start = !scene.pause
  scene.unpause
  pbFadeOutIn {
    scene.pbStartScreen if should_start
    loop do
      scene.pbMain
      break if scene.pause || scene.disposed
    end
    if scene.pause
      $game_player.moveto(54, 70)
      $player.character_ID = 5
    else
      $player.pursuit = nil
      $player.character_ID = 1
      $game_temp.player_transferring = true
      $game_temp.player_new_map_id = 21
      $game_temp.player_new_x = 26
      $game_temp.player_new_y = 26
      $game_temp.player_new_direction = 2
      $game_player.update_move
    end
    $scene.updateSpritesets(true)
  }
  pbMessage(_INTL("\\lunaThe engine is down! I should fix it before we lose them!")) if scene.pause
end

class SpacePursuit
  PATH = "Graphics/Pictures/SpacePursuit/"

  def pause; return @pause; end
  def disposed; return @disposed; end

  def unpause
    @pause = false
    @health = 100
    @sprites.each_value { |sprite| sprite.visible = true }
  end

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 9999999
    @sprites = {}
    @frame = 0
    @speeds = [3, 10]
    @speed = @speeds[0]
    @ufo_speed = @speed
    @staggered_frames = 60
    @asteroid_speed = [2,6]
    @diagonal_multiplier = 0.75
    @forward_multiplier = 1.5
    @scroll_speed = 8
    @movement_type = 0
    @velocity = [0,0]
    @ufo_velocity = [0,0]
    @asteroids = []
    @awake_asteroids = []
    @asteroid_chance = 30
    @staggered = false
    @stagger_frame = 0
    @teleport_frame = 0
    @boarding_frames = 0
    @pause = false
    @disposed = false
    @health = 100
    2.times do |i|
      @asteroids[i] = Bitmap.new(PATH + "asteroid_#{i}")
    end
    @splosion = Bitmap.new(PATH + "splosion")
  end

  def pbStartScreen
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = Bitmap.new(PATH + "background")
    5.times do |i|
      @sprites["stars_#{i}"] = Sprite.new(@viewport)
      @sprites["stars_#{i}"].bitmap = Bitmap.new(PATH + "stars")
      @sprites["stars_#{i}"].x = 0
      @sprites["stars_#{i}"].y = i*200
      @sprites["stars_#{i}"].mirror = rand(2) == 0
    end
    @sprites["ufo"] = ChangelingSprite.new(400, 100, @viewport)
    @sprites["ufo"].addBitmap(0, PATH + "ufo_0")
    @sprites["ufo"].addBitmap(1, PATH + "ufo_1")
    @sprites["ufo"].changeBitmap(0)
    @sprites["ufo"].ox = 16
    @sprites["ufo"].oy = 16
    @sprites["player"] = ChangelingSprite.new(400, 400, @viewport)
    @sprites["player"].addBitmap(0, PATH + "player")
    @sprites["player"].addBitmap(1, PATH + "player_forward")
    @sprites["player"].addBitmap(2, PATH + "player_staggered")
    @sprites["player"].changeBitmap(0)
    @sprites["player"].ox = 16
    @sprites["player"].oy = 16
    10.times do |i|
      @sprites["asteroid_#{i}"] = Sprite.new(@viewport)
      @sprites["asteroid_#{i}"].bitmap = @asteroids[rand(@asteroids.length)]
      @sprites["asteroid_#{i}"].x = rand(Graphics.width)
      @sprites["asteroid_#{i}"].y = -100
    end
    @sprites["boarding"] = Sprite.new(@viewport)
    @sprites["boarding"].bitmap = Bitmap.new(PATH + "boarding_background")
    @sprites["boarding"].opacity = 30
    @sprites["boarding"].x = 200
    @sprites["boarding"].y = 468
    @sprites["boarding_fill"] = Sprite.new(@viewport)
    @sprites["boarding_fill"].bitmap = Bitmap.new(PATH + "boarding_fill")
    @sprites["boarding_fill"].opacity = 0
    @sprites["boarding_fill"].x = 200
    @sprites["boarding_fill"].y = 468
    @sprites["health_background"] = Sprite.new(@viewport)
    @sprites["health_background"].bitmap = Bitmap.new(PATH + "health_background")
    @sprites["health_background"].x = 754
    @sprites["health_background"].y = 458
    @sprites["health_fill"] = Sprite.new(@viewport)
    @sprites["health_fill"].bitmap = Bitmap.new(PATH + "health_fill")
    @sprites["health_fill"].x = 756
    @sprites["health_fill"].y = 460
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    textpos = []
    ["C: Brake", "X: Boost", "Catch the UFO", "Avoid Asteroids"].each_with_index do |text, i|
      textpos.push([text, 8, 8+i*32, 0, Color.new(248,248,248), Color.new(0,0,0)])
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    return if @pause
    pbUpdate
    @sprites["overlay"].opacity -= 8 if @sprites["overlay"].opacity > 0 && @frame > 500
    @boarding_frames += 1 if check_overlap(@sprites["player"], @sprites["ufo"]) && @sprites["ufo"].visible
    @sprites["boarding"].opacity = @boarding_frames/30.0*130+30
    @sprites["boarding_fill"].opacity = @boarding_frames/30.0*160
    @sprites["boarding_fill"].src_rect.width = @boarding_frames/30.0*400
    @sprites["health_fill"].src_rect.height = @health/100.0*124
    @sprites["health_fill"].src_rect.y = 124-@sprites["health_fill"].src_rect.height
    @sprites["health_fill"].y = 460+@sprites["health_fill"].src_rect.y
    @sprites["ufo"].changeBitmap(@frame / 8 % 2)
    @sprites["ufo"].visible = @frame > 200
    @ufo_speed = @speed * ((@frame / 1000.0)+1.0).clamp(1.0, 2.0)
    if @health <= 0
      @sprites.each_value { |sprite| sprite.visible = false }
      @pause = true
    end
    if !@staggered
      @movement_type = 0
      case Input.dir8
      when 1
        @velocity[0] -= @speed*@diagonal_multiplier
        @velocity[1] += @speed*@diagonal_multiplier
      when 2
        @velocity[1] += @speed
      when 3
        @velocity[0] += @speed*@diagonal_multiplier
        @velocity[1] += @speed*@diagonal_multiplier
      when 4
        @velocity[0] -= @speed
      when 6
        @velocity[0] += @speed
      when 7
        @velocity[0] -= @speed*@diagonal_multiplier
        @velocity[1] -= @speed*@diagonal_multiplier*@forward_multiplier
        @movement_type = 1
      when 8
        @velocity[1] -= @speed*@forward_multiplier
        @movement_type = 1
      when 9
        @velocity[0] += @speed*@diagonal_multiplier
        @velocity[1] -= @speed*@diagonal_multiplier*@forward_multiplier
        @movement_type = 1
      end
      @speed = (Input.press?(Input::BACK) ? @speeds[1] : @speeds[0])
    else
      @movement_type = 2
      if @frame-@stagger_frame > @staggered_frames
        @staggered = false
      end
    end
    if @boarding_frames < 30
      @sprites["player"].x = (@sprites["player"].x+@velocity[0]).clamp(16, Graphics.width-16)
      @sprites["player"].y = (@sprites["player"].y+@velocity[1]).clamp(16, Graphics.height-16)
      @sprites["ufo"].x = (@sprites["ufo"].x+@ufo_velocity[0]).clamp(16, Graphics.width-16)
      @sprites["ufo"].y = (@sprites["ufo"].y+@ufo_velocity[1]).clamp(16, Graphics.height-16)
    end
    if Graphics.width - @sprites["ufo"].x < 32
      @ufo_velocity[0] -= @ufo_speed * 4
    elsif @sprites["ufo"].x < 32
      @ufo_velocity[0] += @ufo_speed * 4
    end
    if Graphics.height - @sprites["ufo"].y < 32
      @ufo_velocity[1] -= @ufo_speed * 4
    elsif @sprites["ufo"].y < 32
      @ufo_velocity[1] += @ufo_speed * 4
    end
    if distance(@sprites["player"], @sprites["ufo"]) < 128
      if @ufo_velocity[0] < 2
        if @sprites["ufo"].x < Graphics.width/2 || @sprites["ufo"].x < @sprites["player"].x
          @ufo_velocity[0] -= @ufo_speed
        else
          @ufo_velocity[0] += @ufo_speed
        end
      end
      if @ufo_velocity[1] < 2
        if @sprites["ufo"].y < Graphics.height/2 || @sprites["ufo"].y < @sprites["player"].y
          @ufo_velocity[1] -= @ufo_speed
        else
          @ufo_velocity[1] += @ufo_speed
        end
      end
    end
    if @frame-@teleport_frame > 20
      @sprites["ufo"].opacity = 255
    end
    if ((distance(@sprites["player"], @sprites["ufo"]) < 32 && rand(10) == 1) || rand((100000/@frame).clamp(100,1000)) == 1) && @boarding_frames < 30
      @sprites["ufo"].x = rand(Graphics.width)
      @sprites["ufo"].y = rand(Graphics.height)
      @sprites["ufo"].opacity = 0
      @teleport_frame = @frame - rand(20)
    end
    if @ufo_velocity == [0,0]
      @ufo_velocity = [rand(2) == 0 ? -@ufo_speed*3 : @ufo_speed*3, rand(2) == 0 ? -@ufo_speed*3 : @ufo_speed*3]
    end
    [@ufo_velocity, @velocity].each do |v|
      v[0] = ease_in_out(v[0], 0, 0.3)
      v[1] = ease_in_out(v[1], 0, 0.3)
      v[0] = 0 if v[0].abs < 0.2
      v[1] = 0 if v[1].abs < 0.2
    end
    @velocity = [0,0] if Input.press?(Input::USE) && Input.dir8==0
    @sprites["player"].changeBitmap(@movement_type)
    5.times do |i|
      @sprites["stars_#{i}"].y += @scroll_speed
      if @sprites["stars_#{i}"].y >= Graphics.height
        @sprites["stars_#{i}"].y = -200
        @sprites["stars_#{i}"].mirror = rand(2) == 0
      end
    end
    if rand(@asteroid_chance) == 0 && @awake_asteroids.length < 6 && @frame > 360
      asteroid = -1
      10.times do |i|
        next if @awake_asteroids.any? { |a| a[0] == i }
        asteroid = i
        break
      end
      @awake_asteroids.push([asteroid, rand(@asteroid_speed[1]-@asteroid_speed[0])+@asteroid_speed[0], 0]) if asteroid != -1
    end
    @awake_asteroids.each do |asteroid|
      id = asteroid[0]
      speed = asteroid[1]
      exploded_frames = asteroid[2]
      exploded_frames += 1 if exploded_frames > 0
      if check_overlap(@sprites["asteroid_#{id}"], @sprites["player"]) && exploded_frames == 0 && @boarding_frames < 30
        pbSEPlay("pursuit_hit", 100, 100)
        @staggered = true
        @stagger_frame = @frame
        @velocity[0] *= -1.5
        @velocity[1] += @speed
        @sprites["asteroid_#{id}"].bitmap = @splosion
        @sprites["asteroid_#{id}"].x -= 16
        @sprites["asteroid_#{id}"].y -= 16
        exploded_frames = 1
        @health -= rand(10)+5
      end
      @sprites["asteroid_#{id}"].y += speed
      if @sprites["asteroid_#{id}"].y >= Graphics.height || exploded_frames > 10
        @sprites["asteroid_#{id}"].y = -100
        @sprites["asteroid_#{id}"].x = rand(Graphics.width)
        @sprites["asteroid_#{id}"].bitmap = @asteroids[rand(@asteroids_length)]
        @awake_asteroids.delete(asteroid)
      end
      asteroid[2] = exploded_frames
    end
    pbEndScreen if (@boarding_frames >= 60) || ($DEBUG && @boarding_frames == 2)
  end

  def pbUpdate
    Graphics.update
    Input.update
    @frame += 1
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScreen
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    2.times do |i|
      @asteroids[i].dispose
    end
    @splosion.dispose
    @disposed = true
  end

  def check_overlap(sprite1, sprite2)
    return false if sprite1.x > sprite2.x + sprite2.bitmap.width - sprite2.ox
    return false if sprite1.x + sprite1.bitmap.width - sprite1.ox < sprite2.x
    return false if sprite1.y > sprite2.y + sprite2.bitmap.height - sprite2.oy
    return false if sprite1.y + sprite1.bitmap.height - sprite1.oy < sprite2.y
    return true
  end

  def distance(sprite1, sprite2)
    return Math.sqrt((sprite1.x-sprite2.x)**2 + (sprite1.y-sprite2.y)**2)
  end
end