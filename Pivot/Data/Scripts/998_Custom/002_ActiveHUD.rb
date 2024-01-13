class Game_Temp
  attr_accessor :attack_data, :sprite_color
  def attack_data; @attack_data = {} if !@attack_data; return @attack_data; end
  def attack_data=(value); @attack_data = value; end
  def sprite_color; @sprite_color = [0,0,0,0,255] if !@sprite_color; return @sprite_color; end
  def sprite_color=(value); @sprite_color = value; end
end


class Game_Map
  def screenPosToTile(x,y)
    return [((x.to_f-Graphics.width/2.0)/32.0).floor + $game_player.x, ((y.to_f-Graphics.height/2.0)/32.0).floor + $game_player.y]
  end

  def tileToScreenPos(x,y)
    ret_x = (((x.to_f*128.00).to_f - self.display_x) / Game_Map::X_SUBPIXELS).round + Game_Map::TILE_WIDTH / 2
    ret_y = (((y.to_f*128.00).to_f - self.display_y) / Game_Map::Y_SUBPIXELS).round + Game_Map::TILE_HEIGHT / 2
    return ret_x, ret_y
  end
end

class ActiveHud
  attr_reader :sprites
  attr_reader :overlay
  
  PATH = "Graphics/Pictures/Active HUD/"
  BASE_COLOR = Color.new(248,248,248)
  SHADOW_COLOR = Color.new(64,64,64)

  HITBOX_OPACITY = 128
  # Damaging to player, Damaging to opponent, Player's hitbox, Opponent's hitbox, Guardbox
  HITBOX_COLORS = [Color.new(255,0,0,HITBOX_OPACITY),Color.new(0,0,255,HITBOX_OPACITY),Color.new(255,128,0,HITBOX_OPACITY),Color.new(128,0,255,HITBOX_OPACITY),Color.new(0,128,255,HITBOX_OPACITY)]

  def initialize
    @sprites = {}
    @viewport = nil
    @overlay = nil
    @hitboxes = [Rect.new(0,0,0,0)] * 4
    @dummy = Rect.new(0,0,32,46)
    @dummy_offset = [18,50]
    @dummy_event = nil
    @aiming = false
    @aim_offset = [0,0]
    @disposed = false
    @game_fade_type = 0
    @pause_menu_showing = false
    pbStartScene
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlay.z = 99999
    pbSetSmallFont(@overlay.bitmap)
    @sprites["aim_marker"] = IconSprite.new(0, 0, @viewport)
    # Match attacks
    4.times do |i|
      Move.each do |attack|
        name = "#{attack.internal.to_s}#{i}"
        @sprites[name] = AttackSprite.new(attack.animation_slowness, attack.width,
          attack.height, attack.filename, i, Graphics.width/2, Graphics.height/2, @viewport, attack.duration, attack.cc_time)
        @sprites[name].set_move_values(attack)
      end
    end
    # AI Attacks
    AI::MAX_PER_MAP.times do |i|
      Move.each do |attack|
        name = "AI#{attack.internal.to_s}#{i}"
        @sprites[name] = AttackSprite.new(attack.animation_slowness, attack.width,
          attack.height, attack.filename, -(i+1), Graphics.width/2, Graphics.height/2, @viewport, attack.duration, attack.cc_time)
        @sprites[name].set_move_values(attack)
      end
    end
    # Initialize attack data
    Move.each do |attack|
      $game_temp.attack_data[attack.internal] = [0, 0, false, false, 0, 0]
    end
    @sprites["game_end_state"] = IconSprite.new(0,0,@viewport)
    @sprites["game_end_state"].setBitmap(PATH+"Win")
    @sprites["game_end_state"].visible = false
    Character.each do |char|
      next unless char.playable
      @sprites["stock_#{char.internal.to_s}"] = Bitmap.new("Graphics/Characters/#{char.internal.to_s}/icon")
      next if char.internal == :DITTO
      @sprites["stock_#{char.internal.to_s}_DITTO"] = Bitmap.new("Graphics/Characters/#{char.internal.to_s}/icon_DITTO")
    end
    @sprites["dummy_damage"] = RPG::Sprite.new(@viewport)
    # Pause
    @sprites["pause_resume"] = ButtonSprite.new(self,"Resume Game",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; @pause_menu_showing = false},0,32,32,@viewport)
    @sprites["pause_resume"].visible = false
    @sprites["pause_resume"].setTextOffset(0,24)
    @sprites["pause_forfeit"] = ButtonSprite.new(self,"Forfeit Match",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; if pbConfirmMessage("You are about to forfeit the match, are you sure?"); pbForfeitMatch; else @pause_menu_showing = false; end;},0,32,128,@viewport)
    @sprites["pause_forfeit"].visible = false
    @sprites["pause_forfeit"].setTextOffset(0,24)
    @sprites["pause_leave"] = ButtonSprite.new(self,"Leave Game",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; pbReturnToMainMenu},0,32,128,@viewport)
    @sprites["pause_leave"].visible = false
    @sprites["pause_leave"].setTextOffset(0,24)
    pbUpdate
    redraw
  end

  def redraw
    return if @disposed
    @sprites["aim_marker"].setBitmap(PATH+"aim_marker")
    @sprites["aim_marker"].ox = @sprites["aim_marker"].width/2
    @sprites["aim_marker"].oy = @sprites["aim_marker"].height
  end

  def pbUpdate
    return if @disposed
    makePacket
    @overlay.bitmap.clear
    textpos = []
    # Pause
    @sprites["pause_resume"].visible = @pause_menu_showing
    @sprites["pause_forfeit"].visible = @pause_menu_showing && $game_temp.in_a_match && !$game_temp.training
    @sprites["pause_leave"].visible = @pause_menu_showing && $game_temp.training
    @sprites["pause_resume"].enabled = @sprites["pause_resume"].visible
    @sprites["pause_forfeit"].enabled = @sprites["pause_forfeit"].visible
    @sprites["pause_leave"].enabled = @sprites["pause_leave"].visible
    if Input.trigger?(Input::ACTION) && !$game_switches[59]
      pbPlayDecisionSE
      @pause_menu_showing = !@pause_menu_showing
    end
    # Fade in/out win game state
    case @game_fade_type
    when 0
      @sprites["game_end_state"].opacity = 0
    when 1
      @sprites["game_end_state"].opacity += 5 if @sprites["game_end_state"].opacity < 255
    when 2
      @sprites["game_end_state"].opacity -= 5 if @sprites["game_end_state"].opacity >0
    end
    if $game_temp.in_a_match && !$game_temp.training
      # Draw time left
      match_time = $game_temp.match_time_current.floor
      match_seconds = match_time%60
      match_mins = match_time/60
      textpos.push(["#{sprintf("%02d:%02d",match_mins,match_seconds)}", Graphics.width-16, 16, 1, BASE_COLOR, SHADOW_COLOR])
      # Stocks
      unless $Client_id > 3
        textpos.push(["#{$player.name}", 128, Graphics.height-82, 2, BASE_COLOR, SHADOW_COLOR])
        bitmap_width = [$player.stocks, 3].min * 64
        distance = bitmap_width / [$player.stocks, 1].max
        $player.stocks.times do |i|
          x = ((i+1) * distance - (bitmap_width / 2)) + ($player.stocks > 4 ? 65+$player.stocks-2 : 64)
          @overlay.bitmap.blt(x, Graphics.height-64, @sprites["stock_#{$player.character_id.to_s}#{$player.transformed!=:NONE ? "_DITTO" : ""}"], Rect.new(0,0,64,64))
        end
      end
      $Partners.each_with_index do |partner, i|
        next if partner.nil?
        next if partner.client_id > 3
        bitmap_width = [partner.stocks, 3].min * 64
        distance = bitmap_width / [partner.stocks, 1].max
        initialX = (($Client_id > 3) ? -128 : 128)
        textpos.push([partner.name, 256*(i+1)+initialX, Graphics.height-82, 2, BASE_COLOR, SHADOW_COLOR])
        partner.stocks.times do |j|
          x = (j * distance - (bitmap_width / 2)) + (partner.stocks > 4 ? 257*(i+1)+partner.stocks-2 : 256*(i+1)) + initialX
          @overlay.bitmap.blt(x, Graphics.height-64, @sprites["stock_#{partner.character_id.to_s}#{partner.transformed!=:NONE ? "_DITTO" : ""}"], Rect.new(0,0,64,64))
        end
      end
      AI.ais.each_with_index do |ai, i|
        next if $game_temp.training
        next if ai.nil?
        next if i > 3
        ai = ai[1]
        bitmap_width = [ai.stocks, 3].min * 64
        distance = bitmap_width / [ai.stocks, 1].max
        initialX = (($Client_id > 3) ? -128 : 128)
        textpos.push([ai.name, 256*(i+1)+initialX, Graphics.height-82, 2, BASE_COLOR, SHADOW_COLOR])
        ai.stocks.times do |j|
          x = (j * distance - (bitmap_width / 2)) + (ai.stocks > 4 ? 257*(i+1)+ai.stocks-2 : 256*(i+1)) + initialX
          @overlay.bitmap.blt(x, Graphics.height-64, @sprites["stock_#{ai.character_id.to_s}#{ai.transformed!=:NONE ? "_DITTO" : ""}"], Rect.new(0,0,64,64))
        end
      end
    end
    # Evolve
    if $game_temp.has_evolved
      $game_temp.has_evolved = false
      @sprites["EVOLUTION#{$Client_id}"].tile_x = $game_player.x
      @sprites["EVOLUTION#{$Client_id}"].tile_y = $game_player.y
      @sprites["EVOLUTION#{$Client_id}"].play
    end
    # Get dummy event
    case $game_map.map_id
    when 22
      @dummy_event = pbMapInterpreter.get_event(6)
    when 43
      @dummy_event = pbMapInterpreter.get_event(5)
    else
      @dummy_event = nil
    end
    # Character Hitboxes
    player_hitbox = $player.character.hitbox.to_rect
    @hitboxes[$Client_id] = Rect.new($game_player.screen_x-16-player_hitbox.x/2,$game_player.screen_y-48-player_hitbox.y/2, player_hitbox.width, player_hitbox.height)
    $Partners.each_with_index do |partner, i|
      next unless partner.is_a?(Partner)
      partner_event = $Partners[i].client_id ? pbMapInterpreter.get_character_by_name("partner#{i+1}") : nil
      next if partner_event.nil?
      @hitboxes[partner.client_id] = partner.character.hitbox.to_rect
      @hitboxes[partner.client_id].x /= 2
      @hitboxes[partner.client_id].y /= 2
      @hitboxes[partner.client_id].x += partner_event.screen_x-16
      @hitboxes[partner.client_id].y += partner_event.screen_y-48
    end
    if $player.being_hit
      $player.hurt_frame += 1
      $player.unhit if $player.hurt_frame > $player.invulnerable_frames
    else
      $player.hitbox_active = !$player.guarding
    end
    if $player.slowed
      $player.slow_frame += 1
      $player.unslow if $player.slow_frame > $player.slow_duration
    end
    # Draw hitboxes
    if $DEBUG && Input.press?(Input::CTRL)
      4.times do |i|
        @overlay.bitmap.fill_rect(@hitboxes[i],HITBOX_COLORS[(i==$Client_id ? 2 : 3)])
      end
      @overlay.bitmap.fill_rect(@dummy,HITBOX_COLORS[3]) if @dummy_event
    end
    # All hit detections
    if $player&.hitbox_active && $player&.current_hp > 0
      4.times do |i|
        next if i == $Client_id # Can't be hit by your own attacks
        partner = get_partner_by_id(i)
        next if partner.nil?
        Move.each do |attack|
          attack = attack.internal
          if @hitboxes[$Client_id].over?(@sprites["#{attack}#{i}"].hurtbox_real) && @sprites["#{attack}#{i}"].hurtbox_active
            get_hit(partner, @sprites["#{attack}#{i}"], i)
          end
        end
      end
      AI.ais.each_with_index do |ai, i|
        ai = AI.get(-(i+1))
        next if ai.nil?
        next if ai.difficulty == 0
        Move.each do |attack|
          name = "AI#{attack.internal.to_s}#{i}"
          get_hit(ai, @sprites[name], i, true) if @hitboxes[$Client_id].over?(@sprites[name].hurtbox_real) && @sprites[name].hurtbox_active
        end
      end
    end
    # Check if user's attacks have hit anyone
    if $Client_id < 4
      Move.each do |attack|
        sprite = @sprites["#{attack.internal}#{$Client_id}"]
        $Partners.each do |partner|
          next unless partner.is_a?(Partner)
          next if partner.last_hit_id != sprite.current_id
          sprite.on_hit
          sprite.hits_detected.push(partner) unless sprite.hits_detected.include?(partner)
        end
        AI.ais.each_with_index do |ai, i|
          ai = AI.get(-(i+1))
          next if ai.last_hit_id != sprite.current_id
          sprite.on_hit
          sprite.hits_detected.push(ai) unless sprite.hits_detected.include?(ai)
        end
      end
    end
    # Aiming
    @sprites["aim_marker"].visible = @aiming
    # Attack positioning
    4.times do |i|
      attack_positions(i)
    end
    AI.ais.each_with_index do |ai, i|
      attack_positions_ai(i)
    end
    # Player attacks
    if $player.using_melee
      pos = [$game_player.x, $game_player.y]
      offset = $game_player.directional_offset
      pos[0] += offset[0]
      pos[1] += offset[1]
      my_attack = $player.character.melee
      sprite = @sprites["#{my_attack}#{$Client_id}"]
      if sprite && !sprite.playing
        sprite.tile_x = pos[0]
        sprite.tile_y = pos[1]
        attack_positions($Client_id)
        if sprite.is_projectile
          angle = Math.atan2(Mouse.y - $game_player.screen_y, Mouse.x - $game_player.screen_x)
          sprite.direction = [Math.cos(angle), Math.sin(angle)]
        end
        sprite.play
      end
    end
    if @aiming
      Input.update
      if pbMapInterpreterRunning? || $game_player.moving? || $PokemonGlobal.sliding ||
        $PokemonGlobal.fishing || $game_player.on_middle_of_stair? || Input.dir8!=0 || $player.current_hp < 1
        stopAiming
      else
        mousepos = Mouse.getMousePos(true)
        max_range = $player.character.aim_range
        case $player.character.aim_type
        when :EIGHTS
          # Define the center of the screen
          center_x = Graphics.width / 2
          center_y = Graphics.height / 2

          # Define the threshold distance from the center for snapping to a line
          threshold = 0 # Change this value as needed

          # Snap the mouse position to a line if it's within the threshold distance
          if (mousepos[0] - center_x).abs < threshold
            mousepos[0] = center_x # Snap to horizontal line
          elsif (mousepos[1] - center_y).abs < threshold
            mousepos[1] = center_y # Snap to vertical line
          elsif (mousepos[0] - center_x).abs == (mousepos[1] - center_y).abs && (mousepos[0] - center_x).abs < threshold
            # Snap to diagonal line
            mousepos[0] = center_x + (mousepos[0] - center_x).sign * ((mousepos[0] - center_x).abs + (mousepos[1] - center_y).abs) / 2
            mousepos[1] = center_y + (mousepos[1] - center_y).sign * ((mousepos[0] - center_x).abs + (mousepos[1] - center_y).abs) / 2
          end
        end
        @sprites["aim_marker"].x = (((mousepos[0]+16) / 32).floor * 32 - @aim_offset[0]/4).clamp(Graphics.width/2-max_range[0]*32, max_range[0]*32+Graphics.width/2)
        @sprites["aim_marker"].y = (((mousepos[1]+8) / 32).floor * 32 - @aim_offset[1]/4 + 24).clamp(Graphics.height/2-(max_range[1]-1)*32, (max_range[1]+1)*32+Graphics.height/2)
        mousepos[0] -= Graphics.width/2
        mousepos[1] -= Graphics.height/2
        mousepos[0] /= 10
        mousepos[1] /= 10
        $game_player.direction = (mousepos[0].abs>3 && mousepos[1].abs>3 ? (mousepos[0]> 0 ? mousepos[1]>0 ? 3 : 9 : mousepos[1]>0 ? 1 : 7) : (mousepos[0].abs > mousepos[1].abs ? mousepos[0]>0 ? 6 : 4 : mousepos[1]>0 ? 2 : 8))
        target = [(mousepos[0]).clamp(-64, 64), (mousepos[1]).clamp(-64, 64)]
        @aim_offset = target
        pbCameraSpeed(1.5) if $game_temp.camera_speed < 1.5
        $game_temp.real_camera_pos = [target[0] + ($game_player.x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X, target[1] + ($game_player.y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y]
        #$game_map.display_x = lerp($game_map.display_x, target[0] + ($game_player.x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X, 0.2)
        #$game_map.display_y = lerp($game_map.display_y, target[1] + ($game_player.y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y, 0.2)
        if !@pause_menu_showing
          use_ranged if Mouse.press?(nil,:left)
        end
      end
    end
    # Partner attacks
    4.times do |i|
      next if i == $Client_id
      partner = get_partner_by_id(i)
      next if partner.nil?
      Move.each do |attack|
        attack = attack.internal
        sprite = @sprites["#{attack}#{i}"]
        sprite.tile_x = partner.attack_data[attack][0].to_f/100.00
        sprite.tile_y = partner.attack_data[attack][1].to_f/100.00
        sprite.playing = partner.attack_data[attack][2]
        sprite.hurtbox_active = partner.attack_data[attack][3]
        sprite.frame_count = partner.attack_data[attack][4]
        sprite.angle = partner.attack_data[attack][5]
        sprite.crits = partner.attack_data[attack][6]
        sprite.move_direction = partner.attack_data[attack][7]
        sprite.current_id = partner.attack_data[attack][8]
        character = ($game_temp.spectating ? ($Partners[$game_temp.spectating_index] ? $Partners[$game_temp.spectating_index] : (AI.ais[$game_temp.spectating_index] ? AI.ais[$game_temp.spectating_index] : $game_player)) : $game_player)
        dx = sprite.tile_x.round - character.x
        dy = sprite.tile_y.round - character.y
        dist = Math.sqrt((dx**2) + (dy**2))
        pan = (dx * 7).clamp(-100, 100).to_i
        sprite.play_sound([80-dist*4,0].max, pan) if sprite.playing && !sprite.sound_playing && sprite.frame_count < 8
        sprite.reset_sprite if !sprite.playing
      end
    end
    # Update own attack data
    if $Client_id < 4
      Move.each do |attack|
        attack = attack.internal
        sprite = @sprites["#{attack}#{$Client_id}"]
        $game_temp.attack_data[attack] = [(sprite.tile_x*100).round, (sprite.tile_y*100).round, sprite.playing, sprite.hurtbox_active, sprite.frame_count, sprite.angle, sprite.crits, sprite.move_direction, sprite.current_id, sprite.hurtbox_real.x, sprite.hurtbox_real.y, sprite.hurtbox_real.width, sprite.hurtbox_real.height, sprite.power]
      end
    end
    # Update dummy position
    if @dummy_event
      @dummy.x = (@dummy_event.screen_x(false).to_f - @dummy_offset[0].to_f).floor
      @dummy.y = (@dummy_event.screen_y(false).to_f - @dummy_offset[1].to_f).floor
      @sprites["dummy_damage"].x = @dummy_event.screen_x
      @sprites["dummy_damage"].y = @dummy_event.screen_y - 64
    end
    # Spectating
    if $game_temp.in_a_match
      $game_temp.spectating = $player.current_hp < 1 || $Client_id > 3
      $game_temp.spectating_index = ($game_temp.spectating_index + Input::scroll_v) % ($Partners.length > 1 ? ([$Partners.length, 3].min + 1) : ([AI.ais.length, 3].min + 1)) if $game_temp.spectating
    end
    # Respawning
    if $game_temp.in_a_match
      if $player.current_hp < 1
        if $player.stocks > 0
          if $game_temp.downed_time < 5.0
            $game_temp.downed_time += Graphics.delta_s
            textpos.push(["Respawning in: #{([5.0-$game_temp.downed_time,0.0].max.round(1))}s", Graphics.width/2, Graphics.height-104, 2, BASE_COLOR, SHADOW_COLOR])
          elsif $game_temp.downed_time >= 5.0 && $game_temp.downed_time < 6.0
            $game_temp.downed_time += Graphics.delta_s
            $game_player.turn_generic(pbGet(47))
            $game_player.moveto(pbGet(49),pbGet(50))
            $game_temp.spectating = false
            $game_player.transparent = true
            #$game_player.center_smooth($game_player.x, $game_player.y)
            #$game_map.display_x = $game_player.real_x - Game_Player::SCREEN_CENTER_X
            #$game_map.display_y = $game_player.real_y - Game_Player::SCREEN_CENTER_Y
            @sprites["#{Collectible.get($player.equipped_collectibles[:beam]).beam.to_s}#{$Client_id}"].tile_x = $game_player.x
            @sprites["#{Collectible.get($player.equipped_collectibles[:beam]).beam.to_s}#{$Client_id}"].tile_y = $game_player.y
            @sprites["#{Collectible.get($player.equipped_collectibles[:beam]).beam.to_s}#{$Client_id}"].play
          elsif $game_temp.downed_time >= 6.0
            if $player.transformed == :NONE
              prevo = $player.character.prevo
              $player.character_id = prevo if $game_temp.match_exp > Character.get(prevo).evolution_exp
            end
            $player.hurt_frame = 0
            $player.hitbox_active = false
            $player.invulnerable_frames = 180
            $player.being_hit = true
            $player.current_hp = $player.character.hp
            $game_player.transparent = false
            $game_temp.downed_time = 0.0
          end
        else
          textpos.push(["Out of stocks... You won't respawn...", Graphics.width/2, Graphics.height-104, 2, BASE_COLOR, SHADOW_COLOR]) unless $Client_id > 3
        end
        spectating_name = ($Partners[$game_temp.spectating_index] ? $Partners[$game_temp.spectating_index].name : (AI.get(-($game_temp.spectating_index+1)) ? Character.get(AI.get(-($game_temp.spectating_index+1)).character_id).name : $player.name))
        textpos.push(["Spectating: #{spectating_name} (scroll to swap)", Graphics.width/2, Graphics.height-128, 2, BASE_COLOR, SHADOW_COLOR])
      end
    end
    pbDrawTextPositions(@overlay.bitmap, textpos) unless @overlay.bitmap.disposed?
    pbUpdateSpriteHash(@sprites)
  end
  
  def pbRefresh
    pbUpdate
  end

  def use_ranged
    return if $game_temp.character_lock
    my_attack = $player.character.ranged
    sprite = @sprites["#{my_attack}#{$Client_id}"]
    return if sprite.playing || sprite.disposed?
    $player.reset_state
    $player.using_ranged = true
    angle = Math.atan2((@sprites["aim_marker"].y) - $game_player.screen_y, (@sprites["aim_marker"].x) - $game_player.screen_x)
    if sprite.angles
      reangle = 360 - (angle * 180 / Math::PI)
      case $player.character.aim_type
      when :EIGHTS
        case $game_player.direction_real
        when 1 then reangle = 225
        when 2 then reangle = 270
        when 3 then reangle = 315
        when 4 then reangle = 180
        when 6 then reangle = 0
        when 7 then reangle = 135
        when 8 then reangle = 90
        when 9 then reangle = 45
        end
      end
      sprite.turn_angle(reangle)
    end
    if sprite.is_projectile || sprite.is_attached
      sprite.direction = [Math.cos(angle), Math.sin(angle)]
      pos = [$game_player.x, $game_player.y]
      if sprite.is_projectile
        offset = $game_player.directional_offset * 16
        pos[0] += offset[0]
        pos[1] += offset[1]
      end
    else
      pos = $game_map.screenPosToTile(@sprites["aim_marker"].x+16, @sprites["aim_marker"].y)
    end
    sprite.tile_x = pos[0]
    sprite.tile_y = pos[1]
    attack_positions($Client_id)
    sprite.play
    stopAiming
  end

  def attack_positions(index)
    Move.each do |attack|
      attack = attack.internal
      sprite = @sprites["#{attack}#{index}"]
      sprite.x, sprite.y = $game_map.tileToScreenPos(sprite.tile_x, sprite.tile_y)
    end
  end

  def attack_positions_ai(index)
    Move.each do |attack|
      attack = attack.internal
      sprite = @sprites["AI#{attack}#{index}"]
      sprite.x, sprite.y = $game_map.tileToScreenPos(sprite.tile_x, sprite.tile_y)
    end
  end

  def pbForfeitMatch
    $game_temp.character_lock = true
    @pause_menu_showing = false
    @sprites["pause_resume"].visible = false
    @sprites["pause_forfeit"].visible = false
    @sprites["pause_leave"].visible = false
    pbEndMatch(true, false)
  end

  def pbReturnToMainMenu
    $game_temp.character_lock = true
    @pause_menu_showing = false
    @sprites["pause_resume"].visible = false
    @sprites["pause_forfeit"].visible = false
    @sprites["pause_leave"].visible = false
    pbGlobalFadeOut(24, true)
    pbCommonEvent(9)
  end

  def get_hit(user, attack, i, by_ai=false)
    damage = attack.power
    return if damage < 1
    if $player.transformed != :NONE && $player.current_hp - damage <= 0
      $player.transformed_time = 0 
      $player.transformed = :NONE
    end
    $game_temp.latest_move_type_taken = attack.move_type
    $player.current_hp -= damage
    $player.invulnerable_frames = [Player::BASE_INVULNERABLE_FRAMES, attack.remaining_animation_length].max
    $player.hit
    $scene.spritesetGlobal.playersprite.damage(damage, false, true, 2)
    if attack.knockback > 0
      ret = [0,0]
      case attack.move_direction
      when 1 then ret[0]-=1; ret[1]-=1;
      when 2 then ret[1]+=1
      when 3 then ret[0]+=1; ret[1]+=1;
      when 4 then ret[0]-=1
      when 6 then ret[0]+=1
      when 7 then ret[0]-=1; ret[1]+=1;
      when 8 then ret[1]-=1
      when 9 then ret[0]+=1; ret[1]-=1;
      end
      $game_player.jump(ret[0] * attack.knockback, ret[1] * attack.knockback)
    end
    $player.slow(attack.cc_time, attack.cc_speed)
    $game_temp.latest_damage_taken = damage
    $game_temp.last_hit_id = attack.current_id
    if true#!by_ai
      $game_temp.last_hit_by = i
      $game_temp.spectating_index = ($Partners.index(user) ? $Partners.index(user) : (by_ai ? i : 0))
    end
  end

  def aiming; @aiming; end
  def aiming=(value); @aiming = value; end
  def aim_offset=(value); @aim_offset = value; end
  def overlay; @overlay; end
  def game_end_state_visible; return @sprites["game_end_state"].visible; end
  def game_end_state_visible=(value); @sprites["game_end_state"].visible = value; end
  def game_end_state_setBitmap(value); @sprites["game_end_state"].setBitmap(value); end
  def game_fade_type=(value); @game_fade_type = value; end
  def dummy_damage(value); @sprites["dummy_damage"].damage(value, false); end
  def pause_menu_showing; @pause_menu_showing; end
  def pause_menu_showing=(value); @pause_menu_showing = value; end
  def get_sprite(id); return @sprites[id]; end

  def attacks
    attacks = []
    4.times do |i|
      if i != $Client_id
        partner = get_partner_by_id(i)
        next if partner.nil?
      end
      Move.each do |attack|
        attacks.push(@sprites["#{attack.internal}#{i}"])
      end
    end
    return attacks
  end

  def dummy
    @dummy
  end

  def pbEndScene
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
  end
end