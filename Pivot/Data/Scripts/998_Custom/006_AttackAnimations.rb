class Game_Temp
  attr_accessor :character_lock
  attr_accessor :crit_counter
  def character_lock
    @character_lock = false if !@character_lock
    return @character_lock
  end
  def character_lock=(value)
    @character_lock = value
    return @character_lock
  end
  def crit_counter
    @crit_counter = 0 if !@crit_counter
    return @crit_counter
  end
  def crit_counter=(value)
    @crit_counter = value
  end
end

class AttackSprite < IconSprite
  attr_reader :user, :belonging_character, :hurtbox, :sound_playing, :unlocked, :current_frame
  attr_writer :hurtbox_active, :power
  attr_accessor :hits_detected, :current_id, :playing, :animation_type, :animation_offset, :move_type, :projectile_speed_modif, :is_projectile, :is_attached, :combo_move, :angles,
  :angle_step, :transform_radius, :sketch_radius, :can_crit, :crit_multiplier,
  :crit_condition, :cc_time, :cc_speed, :pattern_automation, :actions, :hitboxes, :hitbox_activity_array, :frame_count, :direction,
  :tile_x, :tile_y, :crits, :invulnerability_mult, :passive, :knockback, :move_direction, :power_multiplier, :on_hit
  def initialize(slowness=1, frame_width=128, frame_height=128, animation_name="!", user=nil, x=0, y=0, viewport=nil, frame_amount=1, cc_time=0)
    @hits_detected = []
    @current_id = 0
    @belonging_character = Character.get(:ZUBAT)
    @power = 0
    @invulnerability_mult = 1
    animation_type = :NORMAL
    @move_type = :MELEE
    @projectile_speed_modif = 1
    @is_projectile = false
    @is_attached = false
    @combo_move = false
    @angles = false
    @angle_step = 1
    @transform_radius = 0
    @sketch_radius = 0
    @passive = false
    @can_crit = false
    @crit_multiplier = 1
    @crit_condition = proc { next false }
    @cc_time = 0.2
    @cc_speed = 1
    @pattern_automation = true
    @actions = {}
    @hitboxes = {}
    @hitbox_activity_array = [true]
    @crits = false
    @cc_time = cc_time
    anim_name_formatted = animation_name.gsub("Crit","").gsub(/([a-z])([A-Z])/, '\1_\2').downcase
    @user = user
    @belonging_character = @user < 0 ? AI.get(@user)&.character : @user == $Client_id ? $player.character : Character.get(get_partner_by_id(@user)&.character_id || nil) 
    @slowness = slowness # Higher number means slower animation (1 = FPS)
    @frame_amount = frame_amount + @cc_time * 20 # Amount of frames in the animation (from index 0)
    @frame_width = frame_width # Width of a single frame
    @frame_height = frame_height # Height of a single frame
    @animation_name = animation_name # Name of the animation
    @direction = [0,0]
    @playing = false
    super(x, y, viewport)
    self.ox = @frame_width/2
    self.oy = @frame_height/2
    @sound_playing = false
    @attack_bitmap = Bitmap.new("Graphics/Animations/#{@animation_name}")
    @crit_bitmap = @attack_bitmap
    @sound = "Anim/#{@animation_name}"
    @frame_count = 0
    @current_frame = 0
    @previous_frame = 0
    @tile_x = 0
    @tile_y = 0
    @hurtbox = Rect.new(0,0,0,0)
    @hurtbox_active = false
    @returning = false
    @attack_outline = nil
    @knockback = 0
    @move_direction = 0
    @power_multiplier = proc { next 1 }
    @on_hit = proc { }
    self.bitmap = Bitmap.new(@frame_width, @frame_height * 2)
  end

  def set_move_values(attack)
    @animation_type = attack.animation_type
    @animation_offset = attack.animation_offset
    @move_type = attack.move_type
    @projectile_speed_modif = attack.speed
    @is_projectile = attack.is_projectile
    @is_attached = attack.is_attached
    @combo_move = attack.combo_move
    @angles = attack.angles
    @angle_step = attack.angle_step
    @transform_radius = attack.transform_radius
    @sketch_radius = attack.sketch_radius
    @can_crit = attack.can_crit
    @crit_multiplier = attack.crit_multiplier
    @crit_condition = attack.crit_condition
    @cc_speed = attack.cc_speed
    @pattern_automation = attack.pattern_automation
    @actions = attack.actions
    @hitboxes = attack.hitboxes
    @hitbox_activity_array = attack.hitbox_activity
    @invulnerability_mult = attack.invulnerability_mult
    @knockback = attack.knockback
    @power_multiplier = attack.power_multiplier
    @on_hit = attack.on_hit
  end

  def update 
    self.visible = @playing
    @crits = false if !@playing
    @sound_playing = false if !@playing
    @attack_outline&.dispose if @attack_outline
    return if !@playing
    if @user == $Client_id || @user < 0
      if @is_projectile && !@returning
        speed = 0.125 * @projectile_speed_modif
        @tile_x += @direction[0] * speed
        @tile_y += @direction[1] * speed
      elsif @is_attached
        if !@user_event
          if @user < 0
            @user_event = AI.get(@user).event
          else
            @user_event = (@user == $Client_id ? $game_player : get_partner_by_id(@user))
          end
        end
        offset = @user_event.directional_offset * 16
        #position = $game_map.screenPosToTile(@user_event.screen_x, @user_event.screen_y)
        position = [@user_event.x, @user_event.y]
        @tile_x = position[0] + offset[0]
        @tile_y = position[1] + offset[1]
      end
    end
    if !@unlocked
      if @user == $Client_id
        $game_temp.character_lock = @current_frame <= @frame_amount
        $game_player.lock_pattern = $game_temp.character_lock
        $game_player.pattern = [@current_frame/3,3].min if $game_temp.character_lock && $player.has_state && @pattern_automation
        if @combo_move
          if $game_temp.check_melee_combo != $player.melee_combo
            unlock(:MELEE)
            @playing = false
          elsif @current_frame == @frame_amount-1
            $player.melee_combo = 1
          end
        end
      elsif @user < 0
        my_ai = AI.get(@user)
        if !my_ai.nil?
          my_ai.character_lock = @current_frame <= @frame_amount
          my_ai.event.lock_pattern = my_ai.character_lock
          my_ai.event.pattern = [@current_frame/3,3].min if my_ai.character_lock && my_ai.has_state
        end
      end
    end
    @attack_outline&.bitmap&.clear if Settings::OUTLINES
    self.bitmap.clear
    self.bitmap.fill_rect(guardbox, ActiveHud::HITBOX_COLORS[4]) if $DEBUG && Input.press?(Input::CTRL) && @hurtbox_active
    self.bitmap.fill_rect(@hurtbox, ActiveHud::HITBOX_COLORS[(@passive ? 1 : 0)]) if $DEBUG && Input.press?(Input::CTRL) && @hurtbox_active
    refresh_hurtbox
    @frame_count+=1
    @current_frame = @frame_count / slowness
    @attack_outline = self.create_outline_sprite(2, [255,0,0]) if Settings::OUTLINES
    super
  end

  def turn_angle(angle)
    self.angle = (angle / @angle_step).round * @angle_step if @angles
  end

  def remaining_animation_length
    return (@frame_amount - @current_frame) * slowness * @invulnerability_mult
  end

  def dispose
    if Settings::OUTLINES
      @attack_outline&.dispose if @attack_outline
      @attack_outline = nil
    end
    super
  end

  def on_hit
    return if @user != $Client_id
    @on_hit.call(self)
  end

  def refresh_hurtbox
    case @animation_type
    when :REPEAT then anim_rect = Rect.new((@current_frame%4)*@frame_width,(@frame_height/@attack_bitmap.height > 0 ? (@current_frame/4 % (@frame_height/@attack_bitmap.height))*@frame_height : 0),@frame_width,@frame_height)
    when :STICKY
      bitmap_frame = (@current_frame%4)*@frame_width
      bitmap_frame = @frame_width*3 if @current_frame >= 4
      anim_rect = Rect.new(bitmap_frame,0,@frame_width,@frame_height)
    else
      anim_rect = Rect.new((@current_frame%4)*@frame_width,@current_frame/4*@frame_height,@frame_width,@frame_height)
    end
    self.bitmap.blt(0,0,(@crits ? crit_bitmap : @attack_bitmap),anim_rect)
    if @hitbox_activity_array.is_a?(Array)
      if @hitbox_activity_array[0]
        if @hitbox_activity_array[0] == true || @crits
          @hurtbox_active = @current_frame < @frame_amount
        else
          @hurtbox_active = @hitbox_activity_array.include?(@current_frame)
        end
      else
        @hurtbox_active = false
      end
    end
    if @transform_radius > 0
      transform(@transform_radius)
    end
    if @sketch_radius > 0
      sketch(@sketch_radius, @move_type)
    end
    return if @previous_frame == @current_frame
    @previous_frame = @current_frame
    @hitboxes.each do |key, value|
      next unless @current_frame > key
      @hurtbox = value.to_rect
      break
    end
    @actions.each do |key, value|
      next unless @current_frame > key
      value.call(self)
      break
    end
    if @current_frame > @frame_amount
      $game_temp.crit_counter = 0 if @user == $Client_id && @crits
      @hurtbox = Rect.new(0,0,0,0)
      unlock(@move_type) if [:RANGED,:MELEE].include?(@move_type)
      @attack_outline&.bitmap&.clear if Settings::OUTLINES
      self.bitmap.clear
      @playing = false
    end
  end
  
  def lock(type=:NONE, setter=true)
    if @user < 0
      my_ai = AI.get(@user)
      @unlocked = !setter
      my_ai.character_lock = setter
      my_ai.event.lock_pattern = setter
      my_ai.state = (setter ? type.to_s.downcase.to_sym : :idle)
    elsif @user == $Client_id
      $game_temp.character_lock = setter
      $game_player.lock_pattern = setter
      @unlocked = !setter
      case type
      when :MELEE then $player.using_melee = setter
      when :RANGED then $player.using_ranged = setter
      when :GUARD then $player.guarding = setter
      end
    end
  end

  def unlock(type=:NONE); lock(type, false); end

  def tile_x=(value)
    @tile_x = value + (@user == $Client_id ? $game_player.directional_offset[0] * @animation_offset[0] : 0)
  end

  def tile_y=(value)
    @tile_y = value + (@user == $Client_id ? $game_player.directional_offset[1] * @animation_offset[1] - (($game_player.sprite_size[1].to_f/32.0).round.to_f/4.0) : 0)
  end

  def hurtbox_real
    return Rect.new(0,0,0,0) if !@hurtbox_active
    ret_x = @hurtbox.x + self.x - self.ox
    ret_y = @hurtbox.y + self.y - self.ox
    return Rect.new(ret_x,ret_y,@hurtbox.width,@hurtbox.height)
  end

  def reset_sprite
    @hurtbox = Rect.new(0,0,0,0)
    @frame_count = 0
    @current_frame = 0
  end

  def play
    return if @playing
    if (@user == $Client_id || @user < 0) && [:RANGED,:MELEE].include?(@move_type)
      @hits_detected = []
      @current_id = rand(100000)
      @move_direction = (@user == $Client_id ? $game_player.direction : AI.get(@user).event)
      @unlocked = false
      lock(@move_type)
      @passive = @user == $Client_id || AI.get(@user).difficulty == 0
      if @combo_move && @user == $Client_id
        $game_temp.check_melee_combo = $player.melee_combo
      end
    end
    @returning = false
    @crits = @can_crit && @crit_condition.call(self)
    reset_sprite
    @playing = true
    play_sound
  end

  def power
    @power = (@move_type == :MELEE ? belonging_character.melee_damage : @move_type == :RANGED ? belonging_character.ranged_damage : 0) * @power_multiplier.call(self)
    return @power * [1,[$player.melee_combo,6].min].max if @combo_move && @user == $Client_id
    return @power * @crit_multiplier if @crits
    return @power
  end

  def play_sound(volume=80, pan=0)
    pbSEPlay("#{sound}", volume, 100, pan)
    @sound_playing = true
  end

  def sound
    @sound = (safeExists?("Audio/SE/Anim/#{@animation_name}Crit.ogg") && @crits == true ? @sound = "Anim/#{@animation_name}Crit" : "Anim/#{@animation_name}")
    return @sound
  end

  def crit_bitmap
    @crit_bitmap = (safeExists?("Graphics/Animations/#{@animation_name}Crit.png") ? Bitmap.new("Graphics/Animations/#{@animation_name}Crit") : @attack_bitmap)
    return @crit_bitmap
  end

  def return_to_user
    return if @user != $Client_id && @user >= 0
    @returning = true
    if !@user_event
      if @user < 0
        @user_event = AI.get(@user).event
      else
        @user_event = (@user == $Client_id ? $game_player : get_partner_by_id(@user))
      end
    end
    sx = @tile_x - @user_event.x
    sy = @tile_y - @user_event.y
    if sx.abs < 1 && sy.abs < 1
      @hurtbox = Rect.new(0,0,0,0)
      @attack_outline&.bitmap&.clear if Settings::OUTLINES
      self.bitmap.clear
      @playing = false
    else
      rang_direction = 0
      angle = sy.to_f/sx.to_f
      if angle.abs > 0.5 && angle.abs != Float::INFINITY
        if sx > 0
          (sy < 0) ? rang_direction = 7 : rang_direction = 1
        else
          (sy > 0) ? rang_direction = 9 : rang_direction = 3
        end
      else
        if sx.abs > sy.abs
          (sx < 0) ? rang_direction = 6 : rang_direction = 4
        else
          (sy > 0) ? rang_direction = 8 : rang_direction = 2
        end
      end
      if rang_direction == 0
        @hurtbox = Rect.new(0,0,0,0)
        @attack_outline&.bitmap&.clear if Settings::OUTLINES
        self.bitmap.clear
        @playing = false
      else
        @hurtbox = Rect.new(14,8,32,20)
        rang_speed = 0.25 * @projectile_speed_modif
        case rang_direction
        when 1 then @tile_x-=rang_speed; @tile_y-=rang_speed;
        when 2 then @tile_y+=rang_speed
        when 3 then @tile_x+=rang_speed; @tile_y+=rang_speed;
        when 4 then @tile_x-=rang_speed
        when 6 then @tile_x+=rang_speed
        when 7 then @tile_x-=rang_speed; @tile_y+=rang_speed;
        when 8 then @tile_y-=rang_speed
        when 9 then @tile_x+=rang_speed; @tile_y-=rang_speed;
        end
      end
    end
  end

  def belonging_character
    @belonging_character = @user < 0 ? AI.get(@user).character : @user == $Client_id ? $player.character : Character.get(get_partner_by_id(@user).character_id || nil) 
    return @belonging_character
  end

  def sketch(range=2, type=:MELEE)
    return unless $game_temp.in_a_match
    if @user == $Client_id
      if $player.current_hp > 0
        $Partners.each do |partner|
          next unless partner.is_a?(Partner)
          next if !partner.character.playable
          dx = (@tile_x - partner.x).abs
          dy = (@tile_y - partner.y).abs
          next unless dx + dy < range
          if type == :MELEE
            $player.character.sketched_melee = partner.character.melee
            $player.character.sketched_melee_damage = partner.character.melee_damage
          else
            $player.character.sketched_ranged = partner.character.ranged
            $player.character.sketched_ranged_damage = partner.character.ranged_damage
          end
          return
        end
        AI.each do |ai|
          next if !ai.character.playable
          dx = (@tile_x - ai.event.x).abs
          dy = (@tile_y - ai.event.y).abs
          next unless dx + dy < range
          if type == :MELEE
            $player.character.sketched_melee = ai.character.melee
            $player.character.sketched_melee_damage = ai.character.melee_damage
          else
            $player.character.sketched_ranged = ai.character.ranged
            $player.character.sketched_ranged_damage = ai.character.ranged_damage
          end
          return
        end
      end
    elsif @user < 0
      my_ai = AI.get(@user)
      @user_event = my_ai.event if !@user_event
      if !my_ai.died
        if $player.character.playable
          dx = (@tile_x - $game_player.x).abs
          dy = (@tile_y - $game_player.y).abs
          if dx + dy < range
            if type == :MELEE
              my_ai.character.sketched_melee = $player.character.melee
              my_ai.character.sketched_melee_damage = $player.character.melee_damage
            else
              my_ai.character.sketched_ranged = $player.character.ranged
              my_ai.character.sketched_ranged_damage = $player.character.ranged_damage
            end
            return
          end
        end
        $Partners.each do |partner|
          next unless partner.is_a?(Partner)
          next if !partner.character.playable
          dx = (@tile_x - partner.x).abs
          dy = (@tile_y - partner.y).abs
          next unless dx + dy < range
          if type == :MELEE
            my_ai.character.sketched_melee = partner.character.melee
            my_ai.character.sketched_melee_damage = partner.character.melee_damage
          else
            my_ai.character.sketched_ranged = partner.character.ranged
            my_ai.character.sketched_ranged_damage = partner.character.ranged_damage
          end
          return
        end
        AI.each do |ai|
          next if !ai.character.playable
          dx = (@tile_x - ai.event.x).abs
          dy = (@tile_y - ai.event.y).abs
          next unless dx + dy < range
          if type == :MELEE
            my_ai.character.sketched_melee = ai.character.melee
            my_ai.character.sketched_melee_damage = ai.character.melee_damage
          else
            my_ai.character.sketched_ranged = ai.character.ranged
            my_ai.character.sketched_ranged_damage = ai.character.ranged_damage
          end
          return
        end
      end
    end
  end

  def transform(range=5, transform_time=45)
    return unless $game_temp.in_a_match
    if @user == $Client_id
      if $player.transformed == :NONE && $player.current_hp > 0
        $Partners.each do |partner|
          next unless partner.is_a?(Partner)
          next if partner.character_id == :DITTO && partner.transformed == :NONE
          next if !partner.character.playable
          dx = (@tile_x - partner.x).abs
          dy = (@tile_y - partner.y).abs
          next unless dx + dy < range
          $player.transformed = partner.character_id
          $player.transformed_time = transform_time
          return
        end
        AI.each do |ai|
          next if ai.character_id == :DITTO && ai.transformed = :NONE
          next if !ai.character.playable
          dx = (@tile_x - ai.event.x).abs
          dy = (@tile_y - ai.event.y).abs
          next unless dx + dy < range
          $player.transformed = ai.character_id
          $player.transformed_time = transform_time
          return
        end
      end
    elsif @user < 0
      my_ai = AI.get(@user)
      @user_event = my_ai.event if !@user_event
      if my_ai.transformed == :NONE && !my_ai.died
        if $player.character.playable
          dx = (@tile_x - $game_player.x).abs
          dy = (@tile_y - $game_player.y).abs
          if dx + dy < range
            my_ai.transformed = $player.character_id
            my_ai.transformed_time = transform_time
            return
          end
        end
        $Partners.each do |partner|
          next unless partner.is_a?(Partner)
          next if partner.character_id == :DITTO && partner.transformed == :NONE
          next if !partner.character.playable
          dx = (@tile_x - partner.x).abs
          dy = (@tile_y - partner.y).abs
          next unless dx + dy < range
          my_ai.transformed = partner.character_id
          my_ai.transformed_time = transform_time
          return
        end
        AI.each do |ai|
          next if ai.character_id == :DITTO && ai.transformed = :NONE
          next if !ai.character.playable
          dx = (@tile_x - ai.event.x).abs
          dy = (@tile_y - ai.event.y).abs
          next unless dx + dy < range
          my_ai.transformed = ai.character_id
          my_ai.transformed_time = transform_time
          return
        end
      end
    end
  end
  def closest_opponent
    closest = [nil, 999]
    if @user == $Client_id || @user < 0
      checks = []
      checks.push([$game_player.x, $game_player.y, $game_player]) if @user < 0
      $Partners.each { |partner| next unless partner.is_a?(Partner); checks.push([partner.x, partner.y, partner]) }
      AI.each { |ai| next if ai.id == @user; checks.push([ai.event.x, ai.event.y, ai]) }
      checks.each do |check|
        x_plus = check[0] - @tile_x
        y_plus = check[1] - @tile_y
        dist = Math.sqrt((x_plus * x_plus) + (y_plus * y_plus))
        closest = [check[2], dist] if dist < closest[1]
      end
    end
    return closest
  end
  def slowness; return @slowness / 2 if @crits; return @slowness; end
  def hurtbox_active; return false if !@playing; return @hurtbox_active; end
  def guardbox; return Rect.new(@hurtbox.x - @hurtbox.width, @hurtbox.y - (@hurtbox.height/2), @hurtbox.width * 2.5, @hurtbox.height * 2); end
  def guardbox_real
    hbr = hurtbox_real
    return Rect.new(hbr.x - hbr.width, hbr.y - (hbr.height/2), hbr.width * 2.5, hbr.height * 2)
  end
end