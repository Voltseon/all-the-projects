EventHandlers.add(:on_leave_map, :recount_ai,
  proc { |new_map_id|
    next unless $map_factory
    count = 0
    $game_map.events.each_value do |event|
      next unless event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
      AI.ais.delete(event.id) if AI.ais.key?(event.id)
    end
    $map_factory.getMapNoAdd(new_map_id).events.each_value do |event|
      next unless event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
      AI.ais.delete(event.id) if AI.ais.key?(event.id)
      count += 1
    end
    AI.count = [count, AI::MAX_PER_MAP].min
  }
)

class AI
  # Maximum amount of AI per map
  MAX_PER_MAP = 20

  # Distance at which AI starts actually doing shit
  AI_UPDATE_DISTANCE = 16

  # Distance at which AI can move
  AI_MOVE_DISTANCE = 10

  # Identifier for this AI (Used for attacks)
  attr_reader :id
  # The event for this AI
  attr_accessor :event
  # Same thing as Character_id for players
  attr_accessor :character_id
  attr_accessor :skin
  # 0-5 (0 = Companion, 1 = Super Easy, 5 = Very Hard)
  attr_accessor :difficulty
  # A reference to the event it is trying to attack
  attr_accessor :target
  # The position it is trying to reach
  attr_accessor :destination
  # :APPROACH - Try to stay in melee range of the target
  # :AVOID - Try to stay near the edge of the active range of the target
  # :IDLE - Just move at random
  # :DUMMY - Does nothing
  # :PIVOT - Emulates a pivot match instead
  attr_accessor :movement_type
  # State for character name and movement
  # :idle, :walking, :hurt, :melee, :ranged, :guard, :ability
  attr_accessor :state
  # The range at which the character will be active, otherwise it will stay idle
  attr_accessor :active_range
  # Character stats
  attr_accessor :stocks
  attr_accessor :current_hp
  attr_accessor :max_hp
  attr_accessor :attack
  attr_accessor :speed
  # Used for matches
  attr_accessor :name
  # Hitbox activity
  attr_accessor :being_hit
  attr_accessor :hitbox_active
  attr_accessor :hurt_frame
  attr_accessor :last_hit_id
  # Blocking character movement
  attr_accessor :character_lock
  # For ditto
  attr_accessor :transformed
  attr_accessor :transformed_time
  # Guarding
  attr_accessor :guard_timer
  attr_accessor :dash_location
  attr_accessor :dash_distance
  # Death
  attr_accessor :died

  @@ais = {}
  def self.ais
    return @@ais
  end

  @@count = 0
  # The amount of AI on this map
  def self.count
    return @@count
  end

  # Set the amount of AI on this map
  def self.count=(value)
    @@count = value
  end

  # Called every frame, determines the movement of the AI
  def self.move(event)
    if !@@ais.key?(event.id)
      event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
      @@ais[event.id] = self.new(event, $1.to_sym, $4.to_i, $2.to_sym, $3.to_i)
    end
    my_ai = @@ais[event.id]
    distance_to_player = my_ai.distance_to($game_player)
    # Don't do shit if AI is too far away
    if distance_to_player > AI_UPDATE_DISTANCE && my_ai.movement_type != :PIVOT
      return if my_ai.difficulty > 0
      offset = $game_player.directional_offset
      event.moveto($game_player.x + offset[0] * -1, $game_player.y + offset[1] * -1)
    end
    # Update the AI
    my_ai.update
    return unless $game_temp.match_started
    # Pivoting is necessary
    if !event.moving? && my_ai.movement_type == :PIVOT && !my_ai.character_lock
      # 10% chance to just not move at all
      return if rand(10)==1
      my_ai.pivot
      return
    end
    # Don't move if too far away
    return if distance_to_player > AI_MOVE_DISTANCE
    # Don't move if character is locked
    return if my_ai.character_lock
    # Movement is only done if not already moving
    return if event.moving?
    # 10% chance to just not move at all
    return if rand(10)==1
    # get distance from target
    distance = my_ai.distance_to_target
    # actually move
    type_to_move = (distance > my_ai.active_range ? :IDLE : my_ai.movement_type)
    case type_to_move
    when :APPROACH
      my_ai.approach
    when :AVOID
      my_ai.avoid(distance)
    when :IDLE
      my_ai.idle
    end
  end

  # Return the event with this id
  def self.get(id)
    $game_map.events.each_value do |event|
      next unless event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
      this_ai = @@ais[event.id]
      next unless this_ai.is_a?(AI)
      next unless this_ai.id == id
      return this_ai
    end
    return nil
  end

  # Return an array of all the AIs on this map
  def self.get_all
    ret = []
    $game_map.events.each_value do |event|
      next unless event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
      this_ai = @@ais[event.id]
      next unless this_ai.is_a?(AI)
      ret.push(this_ai)
    end
    return ret
  end

  # Iterate through ever AI on this map
  def self.each
    self.get_all.each { |ai| yield ai }
  end

  # Iterate through ever AI on this map with index
  def self.each_with_index
    self.get_all.each_with_index { |ai, i| yield ai, i }
  end

  # Get a random name from the `ai names.txt` file
  def self.generate_name
    names = []
    File.foreach("ai_names.txt") do |line|
      next if @@ais.any? { |id, ai| ai.name == line }
      names << line
    end
    return names.sample
  end

  def initialize(event, character_id, difficulty, movement_type, active_range)
    # Setters
    @event = event
    @character_id = character_id
    @skin = "default"
    if character_id == :WOBBUFFET && rand(100) < 2
      @skin = "shiny"
    end
    @difficulty = difficulty
    @movement_type = movement_type
    @active_range = active_range
    # Defaults
    @stocks = $game_temp.max_stocks
    @target_check_counter = 0
    @id = -(AI.get_all.length+1) # -1, -2, -3, ...
    @character = Character.get(@character_id)
    @max_hp = @character.hp
    @current_hp = @max_hp
    @attack = @character.attack
    @speed = @character.speed
    @hitbox_active = true
    @invulnerable_frames = 0
    @hurt_frame = 0
    @being_hit = false
    @destination = [@event.x, @event.y]
    @died = false
    @character_lock = false
    @transformed = :NONE
    @transformed_time = 0
    @dash_location = [0,0]
    @dash_distance = 0
    @target = nil
    find_new_target
    @event.through = false
    @last_hit_id = -1
    @name = ""#"CPU #{@id.abs}"
    @start_position = [@event.x, @event.y, @event.direction_real]
    # States
    @state = :idle
    @slowed = false
    @slow_duration = 0
    @slow_frame = 0
    @slow_speed = 1
    @unhit_frames = 0
    @guard_timer = 0
    @guard_timer_stamp = 0
    @guard_cooldown = 0
    @should_guard = false
    @death_timer = 0
    @paused = false
    @route = nil
    @last_tile = [@event.x, @event.y]
  end

  def can_attack
    sprites = $scene.active_hud.sprites
    return (@state == :idle || @state == :ability || @state == :walking) && alive?
  end

  def distance_to_target
    return 999 if @target.nil?
    return distance_to(@target)
  end

  def distance_to(event)
    return distance_to_point(event.x, event.y)
  end

  def distance_to_point(x, y)
    dx = x - @event.x
    dy = y - @event.y
    return Math.sqrt((dx**2) + (dy**2))
  end

  def hit_detection
    sprites = $scene.active_hud.sprites
    screen_hitbox = character.hitbox.to_rect
    screen_hitbox.x /= 2
    screen_hitbox.y /= 2
    screen_hitbox.x += @event.screen_x-16
    screen_hitbox.y += @event.screen_y-48
    # Draw hitbox
    $scene.active_hud.overlay.bitmap.fill_rect(screen_hitbox,ActiveHud::HITBOX_COLORS[(@difficulty == 0 ? 2 : 3)]) if $DEBUG && Input.press?(Input::CTRL)
    # Actual hit detection
    return unless @hitbox_active
    Move.each do |move|
      attack = move.internal
      if @difficulty == 0
        AI.ais.each_with_index do |ai, i|
          this_ai = AI.get(-(i+1))
          next if this_ai.nil?
          next if this_ai.difficulty == 0
          sprite = sprites["AI#{attack.to_s}#{i}"]
          next unless sprite.hurtbox_active
          @should_guard = screen_hitbox.over?(sprite.guardbox_real) && rand(100) < (@difficulty==0 ? 5 : @difficulty)
          if @should_guard && can_guard
            use_guard
          elsif screen_hitbox.over?(sprite.hurtbox_real)
            @last_hit_id = sprite.current_id
            damage = sprite.power
            @current_hp -= damage if @movement_type != :DUMMY
            return if damage <= 0
            @invulnerable_frames = [Player::BASE_INVULNERABLE_FRAMES, sprite.remaining_animation_length].max
            $scene.spriteset.pbDamageEvent(@event.id, damage, true)
            hit
            slow(sprite.cc_time, sprite.cc_speed)
            return
          end
        end
      else
        (0...4).each do |i|
          sprite = sprites["#{attack.to_s}#{i}"]
          next unless sprite.hurtbox_active
          if screen_hitbox.over?(sprite.guardbox_real) && rand(100) < (@difficulty==0 ? 5 : @difficulty) && can_guard
            use_guard
          elsif screen_hitbox.over?(sprite.hurtbox_real)
            @last_hit_id = sprite.current_id
            damage = sprite.power
            @current_hp -= damage if @movement_type != :DUMMY
            return if damage <= 0
            detected_hit if i == $Client_id && !$game_switches[59]
            @invulnerable_frames = [Player::BASE_INVULNERABLE_FRAMES, sprite.remaining_animation_length].max
            $scene.spriteset.pbDamageEvent(@event.id, damage, true)
            $player.melee_combo += 1 if i == $Client_id && move.move_type == :MELEE
            hit
            slow(sprite.cc_time, sprite.cc_speed)
            return
          end
        end
        AI.ais.each_with_index do |ai, i|
          this_ai = AI.get(-(i+1))
          next if this_ai.nil?
          next if this_ai.id == @id
          next if this_ai.difficulty > 0 && @movement_type != :PIVOT
          sprite = sprites["AI#{attack.to_s}#{i}"]
          next unless sprite.hurtbox_active
          if screen_hitbox.over?(sprite.guardbox_real) && rand(100) < (@difficulty==0 ? 5 : @difficulty) && can_guard
            use_guard
          elsif screen_hitbox.over?(sprite.hurtbox_real)
            @last_hit_id = sprite.current_id
            damage = sprite.power
            @current_hp -= damage if @movement_type != :DUMMY
            return if damage <= 0
            @invulnerable_frames = [Player::BASE_INVULNERABLE_FRAMES, sprite.remaining_animation_length].max
            $scene.spriteset.pbDamageEvent(@event.id, damage, true)
            hit
            slow(sprite.cc_time, sprite.cc_speed)
            return
          end
        end
      end
    end
  end

  def update_speed
    return if is_dummy?
    if @event.moving?
      @state = :walking if @state == :idle
    else
      @state = :idle if @state == :walking
    end
    current_speed = @speed
    current_speed = @slow_speed if @slowed
    @event.move_speed = current_speed
  end

  def hit
    pbSEPlay("Cries/" + @character_id.to_s) if is_dummy?
    @being_hit = true
    @hitbox_active = false
    @hurt_frame = 0
    death if @current_hp < 0
  end

  def death
    @death_timer = 5
    unhit
    unslow
    @stocks -= 1
    @transformed = :NONE
    @transformed_time = 0
    @hitbox_active = false
    @event.through = true
    @current_hp = 0
    @died = true
    @state = :hurt
  end

  def slow(duration, speed)
    @slowed = true
    @slow_duration = duration*60
    @slow_frame = 0
    case speed
    when -1
      @slow_speed = @speed
    when 0
      @slow_speed = 0
      @character_lock = true
    else
      @slow_speed = speed
    end
    update_speed
  end

  def unhit
    @being_hit = false
    @hurt_frame = 0
    @hitbox_active = true
    @unhit_frames = 0
  end

  def unslow
    @slowed = false
    @slow_duration = 0
    @slow_frame = 0
    @slow_speed = 1
    @character_lock = false if @character_lock
  end

  def destination_reached
    return @event.x == @destination[0] && @event.y == @destination[1]
  end

  def find_new_destination(range=5)
    20.times do
      @destination = [@event.x + rand(-range, range), @event.y + rand(-range, range)]
      break if $game_map.passable?(@destination[0], @destination[1], 0, @event)
    end
  end

  def pivot
    return if @paused
    return if !$game_temp.in_a_match
    return if !alive?
    return if @state == :guard
    if distance_to_target > 10
      approach($game_map.width/2, $game_map.height/2)
    elsif @being_hit || @target.nil?
      idle
      possible_targets = []
      if $player.current_hp > 0 && $player.stocks > 0
        distance = distance_to($game_player)
        count = 100-distance
        count = 0 if count < 0
        count.round.times { possible_targets.push($game_player) }
      end
      $game_map.events.each_value do |event|
        if event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
          ai = @@ais[event.id]
          next if !ai.is_a?(AI)
          next if ai.id == @id
          next if ai.died
          distance = distance_to(event)
          count = 100-distance
          count = 0 if count < 0
          count.round.times { possible_targets.push(event) }
        end
      end
      @target = (possible_targets.empty?) ? $game_player : possible_targets.sample
    else
      approach
    end
  end

  def approach(approach_x = nil, approach_y = nil)
    return if @paused
    return if !alive?
    return if @state == :guard
    return if @target.nil?
    if (@being_hit || @target.nil?) && approach_x.nil? && approach_y.nil?
      idle
    else
      @state = :walking
      $game_map.events.each_value do |event|
        next unless event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
        next if event.id == @event.id
        next unless distance_to(event) < 3
        @event.move_away_from_event(event)
        return
      end
      char = character
      if can_guard && @transformed == :NONE && char.dash_distance > 0 && distance_to(@target) > char.dash_distance + 2
        use_guard
      else
        if approach_x.nil? || approach_y.nil?
          approach_x = @target.x
          approach_y = @target.y
        end
        destination_scores = {
          1 => 0,
          2 => 0,
          3 => 0,
          4 => 0,
          6 => 0,
          7 => 0,
          8 => 0,
          9 => 0
        }
        destination_scores.each_key do |i|
          offset = Game_Character.directional_offset(i)
          new_x = @event.x + offset[0]
          new_y = @event.y + offset[1]
          if !$game_map.passable?(new_x, new_y, i, @event) || $game_map.check_event(new_x, new_y) || @last_tile == [new_x, new_y]
            destination_scores[i] = 100
            next
          end
          destination_scores[i] = Math.sqrt((new_x-approach_x)**2 + (new_y-approach_y)**2)
        end
        desired_direction = destination_scores.min_by { |k,v| v }[0]
        if rand(10) < 2 # 20% chance to move in a random direction
          desired_direction = [1,2,3,4,6,7,8,9].sample
        end
        @last_tile = [@event.x, @event.y]
        @event.direction = desired_direction
        @event.move_forward
      end
    end
  end

  def avoid(distance=nil)
    return if @paused
    return if !alive?
    return if @state == :guard
    return if @target.nil? && !distance.nil?
    distance = distance_to(@target) if distance.nil?
    @last_tile = [@event.x, @event.y]
    if distance < @active_range-1
      @event.move_away_from_event(@target)
    else
      @event.turn_toward_event(@target, true)
    end
  end

  def idle
    return if @paused
    return if is_dummy?
    return if !alive?
    return if @event.move_route_forcing
    return if @state == :guard
    if distance_to_point(@start_position[0], @start_position[1]) > 10
      follow_closest_companion if @difficulty == 0
      if destination_reached
        @state = :idle
        find_new_destination if rand(100) == 1 || @being_hit
      else
        @state = :walking
        my_loc = SimpleTile.new($game_map.map_id, @event.x, @event.y)
        target_loc = SimpleTile.new($game_map.map_id, @destination[0], @destination[1])
        @route = SimpleTile.path(my_loc,target_loc) if !@route || @route.empty?
        possible_with_target = (@route.length > 0 && !@route[1].empty? ? (@target.nil? ? true : @target.x != @route[1][0] && @target.y != @route[1][0]) : false)
        @last_tile = [@event.x, @event.y]
        if @route && @route.length > 0
          if !@route[1].empty? && @route[1][0] > -1 && @route[1][1] > -1 && @route[1][0] < $game_map.width && @route[1][1] < $game_map.height && $game_map.passable?(@route[1][0], @route[1][1], SimpleTile.get_dir(my_loc,target_loc), @event) && $game_map.check_event(@route[1][0], @route[1][1]).nil? && possible_with_target
            pbMoveRoute(@event, [@route[0]])
            @route.shift
          else
            @event.move_towards_location(@destination[0], @destination[1])
          end
        else
          @event.move_towards_location(@destination[0], @destination[1])
        end
        find_new_destination if rand(100) == 1
      end
    else
      approach_x = Arena.get($game_map.map_id).spawn_points[4][0]
      approach_y = Arena.get($game_map.map_id).spawn_points[4][1]
      approach(approach_x, approach_y)
    end
  end

  def attack_target
    return if @paused
    return false if @movement_type == :PIVOT && !$game_temp.in_a_match
    return false if is_dummy?
    return false unless target_alive
    return false if @character_lock
    return false unless can_attack
    return false if rand(20) > 1 || @state == :guard
    if rand(20) < 2 # 10% chance to avoid
      avoid
      return true
    end
    dist = distance_to_target
    range_for_melee = 2
    range_for_ranged = character.aim_range.min
    case @difficulty
    when 0

    when 1
      range_for_melee += 1
      range_for_ranged -= 2
    when 2
      range_for_melee += 1
      range_for_ranged -= 1
    when 3

    when 4
      range_for_melee -= 1
      range_for_ranged += 1
    when 5
      range_for_melee -= 1
      range_for_ranged += 2
    end
    return false if [range_for_melee,range_for_ranged].max < dist
    # Prefer the stronger attack or melee and prefer melee if distance to the target is less than 2
    if character.melee_damage >= character.ranged_damage || dist < 2
      use_ranged(range_for_ranged) if !use_melee(range_for_melee)
    else
      use_melee(range_for_melee) if !use_ranged(range_for_ranged)
    end
    return true
  end

  def transparent=(value)
    @event.transparent = value
  end

  def can_guard
    return false if is_dummy?
    return false if @character_lock
    return false if has_state
    return false if @guard_cooldown > 0
    return false if @guard_timer > 0
    return true
  end

  def dash(tiles=2, speed=100)
    @dash_location = [0,0]
    @dash_distance = 0
    new_x = @event.x
    new_y = @event.y
    pbSEPlay("Teleport")
    tiles.times do |i|
      new_x_temp = 0
      new_y_temp = 0
      case @event.direction_real
      when 1 then new_x_temp -= 1; new_y_temp -= 1
      when 2 then new_y_temp += 1
      when 3 then new_x_temp += 1; new_y_temp += 1
      when 4 then new_x_temp -= 1
      when 6 then new_x_temp += 1
      when 7 then new_x_temp -= 1; new_y_temp += 1
      when 8 then new_y_temp -= 1
      when 9 then new_x_temp += 1; new_y_temp -= 1
      end
      break if new_x_temp+new_x < 0 || new_x_temp+new_x > $game_map.width || new_y_temp+new_y < 0 || new_y_temp+new_y > $game_map.height
      break unless $game_map.passable?(new_x_temp+new_x, new_y_temp+new_y, @event.direction_real, @event)
=begin
      oldthrough = @event.through
      @event.through = true
      @event.move_speed = speed
      if new_x_temp != 0
        # left or right
        if new_y_temp != 0
          # diagonal up and down
          if new_y_temp > 0
            # moves down
            new_x_temp > 0 ? @event.move_lower_right : @event.move_lower_left
          else
            # moves up
            new_x_temp > 0 ? @event.move_upper_right : @event.move_upper_left
          end
        else
          # left and right
          new_x_temp > 0 ? @event.move_right : @event.move_left
        end
      else
        # up and down
        new_y_temp > 0 ? @event.move_down : @event.move_up
      end
=end
      @event.moveto(new_x_temp+new_x, new_y_temp+new_y)
      @last_tile = [@event.x, @event.y]
      new_x_temp += new_x
      new_y_temp += new_y
      @dash_location = [new_x-new_x_temp, new_y-new_y_temp]
      @dash_distance += 1
      new_x = new_x_temp
      new_y = new_y_temp
=begin
      while @event.moving?
        Graphics.update
        $scene.update
      end
      @event.through = oldthrough
=end
    end
  end

  def guarded_minimum
    return @guard_timer_stamp-@guard_timer > 0.5
  end

  def unguard
    @state = :idle
    @should_guard = false
    @character_lock = false
    @hitbox_active = true
    @guard_cooldown = -character.guard_cooldown
  end

  def use_guard
    return unless can_guard
    char = character
    @state = :guard
    update_graphic
    @transformed = :NONE
    @guard_timer = rand(char.guard_time)
    @guard_timer_stamp = @guard_timer
    @hitbox_active = false
    if char.dash_distance > 0
      dash(char.dash_distance,char.dash_speed)
    else
      pbSEPlay("Anim/Guard")
    end
    @character_lock = true
  end
  
  def use_melee(range_for_melee)
    return false if @target.nil?
    return false if range_for_melee < distance_to_target
    sprites = $scene.active_hud.sprites
    sprite = sprites["AI#{character.melee}#{@id.abs-1}"]
    return false if sprite.playing
    pause(rand(1..5))
    @state = :melee
    @event.turn_toward_event(@target, true)
    pos = [@event.x, @event.y]
    offset = @event.directional_offset
    pos[0] += offset[0]
    pos[1] += offset[1]
    sprite.tile_x = pos[0]
    sprite.tile_y = pos[1]
    sprite.x, sprite.y = $game_map.tileToScreenPos(sprite.tile_x, sprite.tile_y)
    sprite.play
  end

  def use_ranged(range_for_ranged)
    return false if @target.nil?
    return false if range_for_ranged < distance_to_target
    sprites = $scene.active_hud.sprites
    sprite = sprites["AI#{character.ranged}#{@id.abs-1}"]
    return false if sprite.playing || sprite.disposed?
    @state = :ranged
    @event.turn_toward_event(@target, true)
    pause(rand(10..30))
    if sprite.is_projectile
      angle = Math.atan2(@target.screen_y - (@event.screen_y+@target.height*16), @target.screen_x - (@event.screen_x+@target.width*16)).to_f * (rand(7..13).to_f * 0.1)
      sprite.direction = [Math.cos(angle), Math.sin(angle)]
      reangle = angle * 180 / Math::PI
      sprite.turn_angle(360 - reangle)
      pos = [@event.x, @event.y]
      offset = @event.directional_offset
      pos[0] += offset[0]
      pos[1] += offset[1]
    else
      pos = $game_map.screenPosToTile(@target.screen_x+@target.width*16, @target.screen_y-@target.height*16)
    end
    sprite.tile_x = pos[0]
    sprite.tile_y = pos[1]
    sprite.x, sprite.y = $game_map.tileToScreenPos(sprite.tile_x, sprite.tile_y)
    sprite.play
  end

  def pause(time)
    @paused = true
    time.times do
      Input.update
      Graphics.update
      $scene.update
    end
    @paused = false
  end

  def update
    if !@died
      # Check target availability
      find_new_target if @target.nil? || !target_alive || distance_to_target > @active_range
      # Being Damaged
      if @being_hit
        @hurt_frame += 1
        unhit if @invulnerable_frames <= @hurt_frame
      end
      if @slowed
        @slow_frame += 1
        unslow if @slow_duration <= @slow_frame
      end
      # Other
      attack_target
      update_speed
      hit_detection
      if @transformed != :NONE
        @transformed_time -= Graphics.delta_s
        if @transformed_time <= 0
          @transformed_time = 0 
          @transformed = :NONE
        end
      end
      if @guard_cooldown > 0
        @guard_cooldown -= Graphics.delta_s
      end
      if @state == :guard
        @guard_timer -= Graphics.delta_s
        char = character
        if guarded_minimum && (@guard_timer <= char.unguard_time || !@should_guard && rand(500) < (@difficulty==0 ? 5 : @difficulty) || rand((@difficulty==0 ? 5 : @difficulty)*50)==1)
          unguard
        end
      end
      @state = :ability if character.movement_type == :PHASE && $map_factory && $map_factory.getTerrainTag($game_map.map_id, @event.x, @event.y).can_phase && !has_state
    else
      @state = :hurt
      @death_timer -= Graphics.delta_s
      if @death_timer <= 0 && @stocks > 0
        @died = false
        @current_hp = @max_hp
        @event.moveto(@start_position[0],@start_position[1])
        @last_tile = [@event.x, @event.y]
        @event.direction = @start_position[2]
        @event.through = false
        @state = :idle
        @being_hit = true
        @hurt_frame = 0
        @invulnerable_frames = 180
        @hitbox_active = false
      end
    end
    if (is_dummy?)
      look_at_closest_companion
      if @being_hit
        @state = :walking
      else
        if @unhit_frames < 40
          @unhit_frames += 1
          @state = :guard
          @event.pattern = (@unhit_frames.to_f/10.0).floor%4
        else
          @state = :idle
        end
      end
    end
    update_graphic
  end

  def update_graphic
    @event.step_anime = [:walking, :idle, :ability, :guard].include?(@state)
    @event.character_name = "#{character_id.to_s}/#{@skin}/#{@state.to_s}" unless @event.character_name.include?(@state.to_s) && @event.character_name.include?(character_id.to_s)
  end

  def is_dummy?
    return @movement_type == :DUMMY
  end

  def has_state
    return [:melee, :ranged, :guard].include?(@state)
  end

  def character_id
    return @transformed if @transformed != :NONE
    return @character_id
  end

  def character
    return Character.get(@transformed) if @transformed != :NONE
    return @character
  end

  def target_alive
    return false if @target.nil?
    return $player.current_hp > 0 if @target == $game_player
    if @target.name[/partner(\d)/i]
      partner_number = $1.to_i
      return false if !$Partners[partner_number-1].is_a?(Partner)
      return $Partners[partner_number-1].current_hp > 0
    elsif @target.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
      return false if !@@ais[@target.id].is_a?(AI)
      return !@@ais[@target.id].died
    end
    return false
  end

  def alive?
    return false if @died
    return false if @stocks <= 0
    return false if @current_hp <= 0
    return false if @state == :hurt
    return true
  end

  def find_new_target
    @target_check_counter += 1
    return unless @target_check_counter % 50 == 0
    if @difficulty > 0
      if distance_to($game_player) <= @active_range
        @target = $game_player
        return
      end
    end
    $game_map.events.each_value do |event|
      if event.name[/partner(\d)/i] && @difficulty > 0
        partner_number = $1.to_i
        next if !$Partners[partner_number-1].is_a?(Partner)
        if distance_to(event) <= @active_range
          @target = event
          return
        end
      elsif event.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
        ai = @@ais[event.id]
        next if !ai.is_a?(AI)
        next if ai.id == @id
        if @movement_type != :PIVOT
          if @difficulty > 0
            next if ai.difficulty > 0
          else
            next if ai.difficulty == 0
          end
        end
        if distance_to(event) <= @active_range
          @target = event
          return
        end
      end
    end
  end

  def look_at_closest_companion
    closest_companion = $game_player
    (0...4).each do |i|
      next if $Partners.length <= i
      event = pbMapInterpreter.get_character_by_name("partner#{i+1}")
      closest_companion = event if distance_to(event) < distance_to(closest_companion)
    end
    @event.turn_toward_event(closest_companion, false)
  end

  def follow_closest_companion
    closest_companion = $game_player
    (0...4).each do |i|
      next if $Partners.length <= i
      event = pbMapInterpreter.get_character_by_name("partner#{i+1}")
      closest_companion = event if distance_to(event) < distance_to(closest_companion)
    end
    return if distance_to(closest_companion) <= 1
    offset = closest_companion.directional_offset
    @destination = [closest_companion.x + offset[0] * -1, closest_companion.y + offset[1] * -1]
  end

  def character=(value); @character = value; end

  def state=(value)
    if @state == :guard
      return unless guarded_minimum
      unguard
    end
    @state = value
  end
end