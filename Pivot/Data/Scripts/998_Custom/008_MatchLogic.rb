EventHandlers.add(:on_frame_update, :take_down_check,
  proc {
    next if !$player
    next if $game_map.map_id == 1
    next if $Partners.empty?
    $Partners.each do |partner|
      next unless partner.is_a?(Partner)
      if partner.graphic.include?("_hurt")
        next if partner.checked_for_downed
        next unless partner.last_hit_by == $Client_id
        partner.checked_for_downed = true
        $stats.total_take_downs += 1
        $game_temp.match_takedowns += 1
        check_for_challenge("Take Downs", $game_map.map_id, $player.character_id)
        $game_temp.match_exp = [$game_temp.match_exp+rand(10..15),100].min
        if $game_temp.in_a_match
          if partner.stocks == 0
            pbAnnounce(:down_and_out)
          else
            case rand(1..5)
            when 2
              pbAnnounce(:went_down)
            when 3
              pbAnnounce(:taken_down)
            when 4
              pbAnnounce(:slammed)
            end
          end
        end
      else
        partner.checked_for_downed = false
      end
    end
  }
)

EventHandlers.add(:on_frame_update, :damage_check,
  proc {
    next if !$player
    next if $game_map.map_id == 1
    next if $Partners.empty?
    $Partners.each_with_index do |partner, i|
      if partner.invulnerable
        next if partner.current_hp == partner.max_hp
        next if partner.checked_for_damage
        if partner.last_hit_by == $Client_id
          partner.checked_for_damage = true
          $stats.total_damage_dealt += partner.latest_damage_taken
          $player.melee_combo += 1 if partner.latest_move_type_taken == :MELEE
          detected_hit
          character = ($game_temp.spectating ? ($Partners[$game_temp.spectating_index] ? $Partners[$game_temp.spectating_index] : (AI.ais[$game_temp.spectating_index] ? AI.ais[$game_temp.spectating_index] : $game_player)) : $game_player)
          dx = partner.x.round - character.x
          dy = partner.y.round - character.y
          dist = Math.sqrt((dx**2) + (dy**2))
          pan = (dx * 7).clamp(-100, 100).to_i
          pbSEPlay("Anim/HitMarker", [100-dist,0].max, 100, pan)
          if partner.current_hp > 0
            case rand(1..7)
            when 2
              pbAnnounce(:brilliant_hit)
            when 3
              pbAnnounce(:solid_hit)
            when 4
              pbAnnounce(:bam)
            end
          end
        end
        $scene.spriteset.pbDamagePartner(i+1, partner.latest_damage_taken, partner.last_hit_by == $Client_id)
      else
        partner.checked_for_damage = false
      end
    end
  }
)

def detected_hit
  $game_temp.crit_counter += 1;
  $game_temp.match_exp = [$game_temp.match_exp+rand(1..5),100].min
end

EventHandlers.add(:on_frame_update, :match_loop,
  proc {
    next if !$player
    next if $game_map.map_id == 1
    next if $game_map.map_id == 2
    next if $game_map.map_id == 4
    if $Partners.empty? && !$game_temp.solo_mode
      next if $game_temp.training 
      pbEndMatch(true, false)
      next
    end
    if $player.transformed != :NONE
      $player.transformed_time -= Graphics.delta_s
      if $player.transformed_time <= 0
        $player.transformed_time = 0 
        $player.transformed = :NONE
      end
    end
    if $game_temp.match_ended && $Client_id != 0
      pbEndMatch
      next
    end
    next if $Client_id != 0 && !$game_temp.solo_mode
    next if !$game_temp.in_a_match
    $game_temp.match_time_current -= Graphics.delta_s
    if $game_temp.match_time_current <= 0
      pbEndMatch
      next
    end
    alive_players = []
    alive_players.push($player) if ($player.stocks>0 && $game_temp.max_stocks != -1)
    if $game_temp.solo_mode
      AI.ais.each do |aa|
        ai = aa[1]
        alive_players.push(ai) if (ai.stocks > 0 && $game_temp.max_stocks != -1)
      end
    else
      $Partners.each do |partner|
        alive_players.push(partner) if (partner.stocks > 0 && $game_temp.max_stocks != -1)
      end
    end
    if alive_players.count < 2
      pbEndMatch
      next
    end
  }
)

class Game_Temp
  attr_accessor :spectating
  attr_accessor :spectating_index
  attr_accessor :last_hit_by
  attr_accessor :last_hit_id
  attr_accessor :check_melee_combo
  attr_accessor :latest_damage_taken
  attr_accessor :latest_move_type_taken
  attr_accessor :downed_time
  attr_accessor :match_ended
  attr_accessor :match_time
  attr_accessor :match_time_current
  attr_accessor :max_stocks
  attr_accessor :cpus
  attr_accessor :ready
  attr_accessor :set
  attr_accessor :in_a_match
  attr_accessor :match_takedowns
  attr_accessor :gained_exp
  attr_accessor :end_match_called
  attr_accessor :has_evolved
  attr_accessor :match_exp
  attr_accessor :ping
  attr_accessor :received_ping
  attr_accessor :match_started

  def match_started
    @match_started = false if !@match_started
    return @match_started
  end
  def check_melee_combo; @check_melee_combo = 0 if !@check_melee_combo; return @check_melee_combo; end
  def match_ended
    @match_ended = false if !@match_ended
    return @match_ended
  end
  def end_match_called=(value)
    @end_match_called = value
  end
  def match_ended=(value)
    @match_ended = value
  end
  def spectating
    @spectating = false if !@spectating
    return @spectating
  end
  def spectating=(value)
    @spectating = value
  end
  def spectating_index
    @spectating_index = 4 if !@spectating_index
    return @spectating_index
  end
  def spectating_index=(value)
    @spectating_index = value
  end
  def match_takedowns=(value)
    @match_takedowns = value
  end
  def gained_exp=(value)
    @gained_exp = value
  end
  def has_evolved
    @has_evolved = false if !@has_evolved
    return @has_evolved
  end
  def has_evolved=(value)
    @has_evolved = value
  end
  def match_exp
    @match_exp = 0 if !@match_exp
    return @match_exp
  end
  def match_exp=(value)
    @match_exp = value
    if $player.transformed == :NONE
      if $player.character.evolution && $player.character.evolution_exp <= @match_exp
        check_for_challenge("Evolutions", $game_map.map_id, $player.character_id)
        $player.character_id = $player.character.evolution
        @has_evolved = true
      end
    end
  end
  def end_match_called; @end_match_called = false if !@end_match_called; return @end_match_called; end
  def gained_exp; @gained_exp = 0 if !@gained_exp; return @gained_exp; end
  def match_takedowns; @match_takedowns = 0 if !@match_takedowns; return @match_takedowns; end
  def last_hit_by; @last_hit_by = -1 if !@last_hit_by; return @last_hit_by; end
  def last_hit_by=(value); @last_hit_by = value; end
  def last_hit_id; @last_hit_id = -1 if !@last_hit_id; return @last_hit_id; end
  def latest_move_type_taken; @latest_move_type_taken = :NONE if !@latest_move_type_taken; return @latest_move_type_taken; end
  def latest_damage_taken; @latest_damage_taken = 0 if !@latest_damage_taken; return @latest_damage_taken; end
  def latest_damage_taken=(value); @latest_damage_taken = value; end
  def downed_time; @downed_time = 0.0 if !@downed_time; return @downed_time; end
  def downed_time=(value); @downed_time = value; end
  def match_time; @match_time = 480.0 if !@match_time; return @match_time; end
  def match_time=(value); @match_time = value; end
  def match_time_current; @match_time_current = 480.0 if !@match_time_current; return @match_time_current; end
  def match_time_current=(value); @match_time_current = value; end
  def cpus; @cpus = 1 if !@cpus; return @cpus; end
  def max_stocks; @max_stocks = 3 if !@max_stocks; return @max_stocks; end
  def max_stocks=(value); @max_stocks = value; end
  def in_a_match; @in_a_match = false if !@in_a_match; return @in_a_match; end
  def in_a_match=(value); @in_a_match = value; end
  def ping; @ping = 0 if !@ping; return @ping; end
  def received_ping; @received_ping = 0 if !@received_ping; return @received_ping; end
  def ready
    @ready = false if !@ready
    return @ready
  end
  def ready=(value)
    @ready = value
  end
  def set
    @set = false if !@set
    return @set
  end
  def set=(value)
    @set = value
  end

  def match_time_formatted
    match_time = self.match_time.floor
    match_seconds = match_time%60
    match_mins = match_time/60
    return "#{sprintf("%02d:%02d",match_mins,match_seconds)}"
  end
end

def pbStartMatch
  return if $game_temp.in_a_match
  $game_temp.in_a_match = true
  if $game_temp.solo_mode
    ai_events = []
    $game_temp.cpus.times do |i|
      char = Character.sample_playable_unlocked
      spawn_location = Arena.get(pbGet(46)).spawn_points[i+1]
      rEvent = Rf.create_event do |event|
        event.x = spawn_location[0]
        event.y = spawn_location[1]
        event.pages[0].graphic.direction = spawn_location[2]
        event.name = "ai_character(:#{char.internal},:PIVOT,100,#{rand(5)+1})"
      end
      ai_events.push(rEvent[:event])
    end
  else
    $Partners.each_with_index do |partner, i|
      next unless partner.is_a?(Partner)
      Rf.create_event do |event|
        event.name = "partner#{i+1}"
        event.x = 0
        event.y = 0
        c = event.pages[0].condition
        c.variable_id = 27
        c.variable_value = i+1
        c.variable_valid = true
      end
    end
  end
  if $game_temp.solo_mode
    ai_events.each_with_index do |player, i|
      player.transparent = true
    end
  else
    players = [$game_player]
    players = [] if $Client_id > 3
    players += $Partners
    players.each_with_index do |player, i|
      break if i > 3
      player.transparent = true
    end
  end
  $game_player.transparent = true
  $game_player.moveto(Arena.get(pbGet(46)).spawn_points[4][0],Arena.get(pbGet(46)).spawn_points[4][1]) if $Client_id > 3
  $player.stocks = ($Client_id > 3) ? 0 : $game_temp.max_stocks
  $game_temp.crit_counter = 0
  $game_temp.match_takedowns = 0
  $game_temp.match_time_current = $game_temp.match_time
  $game_temp.spectating = $Client_id > 3
  $game_temp.character_lock = $Client_id > 3
  pbZoomMap(1,1,"out")
  $game_temp.end_match_called = false
  $game_temp.match_ended = false
  $game_temp.ready = false
  $game_temp.spectating_index = ($Client_id > 3) ? 0 : 4
  $game_temp.last_hit_by = -1
  $game_temp.last_hit_id = -1
  $game_temp.latest_move_type_taken = :NONE
  $game_temp.latest_damage_taken = -1
  $game_temp.downed_time = 0
  $game_temp.has_evolved = false
  $game_temp.match_exp = 0
  $player.melee_combo = 1
  $player.transformed_time = 0
  $player.transformed = :NONE
  $player.reset_state
  $player.current_hp = ($Client_id > 3) ? 0 : $player.max_hp
  $game_temp.sprite_color = [0,0,0,0,255]
  $game_temp.guard_timer = 0
  $player.hurt_frame = 0
  $player.hitbox_active = true
  $game_temp.set = true
  if $game_temp.solo_mode
    ai_events.each_with_index do |player, i|
      player.transparent = true
      sprite = $scene.active_hud.get_sprite("AISPAWNPURPLE#{i}")
      sprite.tile_x = player.x
      sprite.tile_y = player.y - 2
      #$game_player.center_smooth(player.x, player.y)
      pbCameraScrollTo(player.x, player.y, 1)
      #$game_map.display_x = player.real_x - Game_Player::SCREEN_CENTER_X
      #$game_map.display_y = player.real_y - Game_Player::SCREEN_CENTER_Y
      10.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $scene.active_hud.pbUpdate
      end
      pbUpdateSceneMap
      sprite.play
      30.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $scene.active_hud.pbUpdate
      end
      player.transparent = false
      30.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $scene.active_hud.pbUpdate
      end
    end
    sprite = $scene.active_hud.get_sprite("#{Collectible.get($player.equipped_collectibles[:beam]).beam}#{$Client_id}")
    sprite.tile_x = $game_player.x
    sprite.tile_y = $game_player.y - 2
    #$game_player.center_smooth($game_player.x, $game_player.y)
    pbCameraReset
    #$game_map.display_x = $game_player.real_x - Game_Player::SCREEN_CENTER_X
    #$game_map.display_y = $game_player.real_y - Game_Player::SCREEN_CENTER_Y
    10.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      $scene.active_hud.pbUpdate
    end
    pbUpdateSceneMap
    sprite.play
    30.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      $scene.active_hud.pbUpdate
    end
    $game_player.transparent = false
    30.times do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      $scene.active_hud.pbUpdate
    end
  else
    players = [$game_player]
    players = [] if $Client_id > 3
    players += $Partners
    players.each_with_index do |player, i|
      break if i > 3
      player.transparent = true
      sprite = $scene.active_hud.get_sprite("#{Collectible.get($player.equipped_collectibles[:beam]).beam}#{i}")
      sprite.tile_x = player.x
      sprite.tile_y = player.y - 2
      #$game_player.center_smooth(player.x, player.y)
      pbCameraScrollTo(player.x, player.y, 1)
      #$game_map.display_x = player.real_x - Game_Player::SCREEN_CENTER_X
      #$game_map.display_y = player.real_y - Game_Player::SCREEN_CENTER_Y
      10.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $scene.active_hud.pbUpdate
      end
      pbUpdateSceneMap
      sprite.play
      30.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $scene.active_hud.pbUpdate
      end
      player.transparent = false
      30.times do
        Graphics.update
        Input.update
        pbUpdateSceneMap
        $scene.active_hud.pbUpdate
      end
    end
  end
  #$game_player.center_smooth($game_player.x, $game_player.y)
  pbCameraReset
  #$game_map.display_x = $game_player.real_x - Game_Player::SCREEN_CENTER_X
  #$game_map.display_y = $game_player.real_y - Game_Player::SCREEN_CENTER_Y
  pbUpdateSceneMap
  if pbGet(48) == 48 # Training Room
    # tutorial stuff if haven't done it
  else
    $game_temp.training = false
    pbMEPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).battle_start_complex, AudioPack.get($PokemonGlobal.audio_pack)), 80, 100)
    pbAnnounce(:generic_2)
    pbWait(155)
    pbAnnounce(:start)
    pbWait(110)
    Game.save
    pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).get_arena(Arena.get(pbGet(46))), AudioPack.get($PokemonGlobal.audio_pack)), 80, 100)
  end
  $game_temp.match_started = true
  $game_temp.set = false
end

def pbEndMatch(force_draw = false, gain_exp = true)
  return if $game_temp.end_match_called
  $game_temp.match_started = false
  $player.transformed_time = 0 
  $player.transformed = :NONE
  $game_player.turn_down if $player.current_hp > 0
  $game_temp.match_ended = true
  $game_temp.end_match_called = true
  $game_temp.in_a_match = false
  $game_temp.match_time_current = 0
  $game_temp.character_lock = true
  $scene.active_hud.game_fade_type = 0
  pbZoomMap(1.2,0.0005,"in")
  50.times do
    Graphics.frame_rate -= 1
    Graphics.update
    Input.update
    $scene.update
  end
  Graphics.frame_rate = 60
  # Determine who won or if it was a draw
  players = [[4, $player.stocks, $player.current_hp.to_f/$player.max_hp.to_f, $player, $Client_id]]
  if $game_temp.solo_mode
    AI.ais.each_with_index do |aa, i|
      ai = aa[1]
      players.push([i, ai.stocks, ai.current_hp.to_f/ai.max_hp.to_f, ai, ai.id])
    end
  else
    $Partners.each_with_index do |partner, i|
      next unless partner.is_a?(Partner)
      next if partner.client_id > 3
      players.push([i, partner.stocks, partner.current_hp.to_f/partner.max_hp.to_f, partner, partner.client_id])
    end
  end
  won_players = []
  winner = nil
  if !force_draw
    players.each do |player|
      next if player[1] == 0
      won_players.push(player)
    end
    if won_players.length > 1
      won_players.sort! { |a,b| a[2] <=> b[2] }
      if won_players[0][2] < won_players[1][2]
        winner = won_players[0][3]
      end
    elsif won_players.length > 0
      winner = won_players[0][3]
    end
  end
  check_for_challenge("Matches", $game_map.map_id, $player.character_id)
  pbAnnounce(:end) # "Game, set, and... match!"
  pbWait(250,true)
  pbAnnounce(:results) # "The results are in!"
  pbWait(50,true)
    # Display results
  pbZoomMap(2,0.005,"in")
  $scene.active_hud.game_end_state_visible = true
  multiplier = 1.0
  if !winner.nil?
    $game_temp.spectating = true
    $game_temp.spectating_index = won_players[0][0]
    if won_players[0][4] == $Client_id && !force_draw
      pbMEPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).win_fanfare, AudioPack.get($PokemonGlobal.audio_pack)), 80, 100)
      $scene.active_hud.game_end_state_setBitmap("Graphics/Pictures/Active HUD/Win")
      $stats.games_won += 1
      check_for_challenge("Win", $game_map.map_id, $player.character_id)
      multiplier = 2.0
    else
      pbMEPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).lose_fanfare, AudioPack.get($PokemonGlobal.audio_pack)), 80, 100)
      $scene.active_hud.game_end_state_setBitmap("Graphics/Pictures/Active HUD/Lose")
    end
  else
    $stats.games_drawn += 1
    pbMEPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).win_fanfare, AudioPack.get($PokemonGlobal.audio_pack)), 80, 100)
    $scene.active_hud.game_end_state_setBitmap("Graphics/Pictures/Active HUD/Draw")
    $game_temp.spectating = true
    $game_temp.spectating_index = 4
    multiplier = 1.5
  end
  $stats.games_played += 1
  $stats.takedown_record = $game_temp.match_takedowns if $game_temp.match_takedowns > $stats.takedown_record
  $scene.active_hud.game_fade_type = 1
  # Announce who won
  if !winner.nil? && !force_draw
    pbAnnounce(:won, winner.character_id)
  else
    pbAnnounce(:draw)
  end
  # Calculate EXP
  exp = 0
  if gain_exp
    players.each do |player|
      next unless player[1] == 0
      exp += 1.0
    end
    exp += $game_temp.match_takedowns
    exp = (exp * multiplier)
  end
  $game_temp.gained_exp = exp
  # HUD Stuff
  pbWait(150,true)
  $scene.active_hud.game_fade_type = 2
  pbWait(50,true)
  $scene.active_hud.game_end_state_visible = false
  $scene.active_hud.game_fade_type = 0
  # Reset everything
  pbGlobalFadeOut(24, true)
  pbCommonEvent(9)
  $Connections.each do |connection|
    connection.dispose
  end
  $Partners=[]
  $Client_id = 0
  $game_temp.spectating = false
  $game_temp.character_lock = false
  $game_temp.match_takedowns = 0
  pbZoomMap(1,1,"out")
  $game_temp.end_match_called = false
  $game_temp.match_ended = false
  $game_temp.ready = false
  $game_temp.spectating_index = 4
  $game_temp.last_hit_by = -1
  $game_temp.last_hit_id = -1
  $game_temp.latest_move_type_taken = :NONE
  $game_temp.latest_damage_taken = -1
  $game_temp.downed_time = 0
  $game_temp.match_time_current = 480
  $game_temp.in_a_match = false
  $game_temp.has_evolved = false
  $game_temp.match_exp = 0
  $game_temp.training = false
  $player.melee_combo = 1
  $player.transformed_time = 0
  $player.transformed = :NONE
  $player.reset_state
  $player.current_hp = $player.max_hp
  $game_player.transparent = false
  $game_temp.sprite_color = [0,0,0,0,255]
  $game_temp.guard_timer = 0
  $player.hurt_frame = 0
  $game_temp.crit_counter = 0
  $player.hitbox_active = true
  Game.save
end

def pbCameruptDummy(event)
  case event.direction
  when 2
    my_hitbox = $scene.active_hud.dummy
    attacks = $scene.active_hud.attacks
    attacks.each do |attack|
      next unless attack.hurtbox_active
      next unless my_hitbox.over?(attack.hurtbox_real)
      pbMoveRoute(event, [PBMoveRoute::StepAnimeOff])
      event.pattern = 0
      event.direction = 4
    end
  when 4,6
    event.pattern += 1
    if event.pattern == 3
      event.pattern = 0
      event.direction += 2
    end
  when 8
    pbSetSelfSwitch(event.id, "A", true)
  end
end

def pbCaterpieDummy(event)
  case event.direction
  when 2
    my_hitbox = $scene.active_hud.dummy
    attacks = $scene.active_hud.attacks
    attacks.each do |attack|
      next unless attack.hurtbox_active
      next unless my_hitbox.over?(attack.hurtbox_real)
      pbMoveRoute(event, [PBMoveRoute::StepAnimeOff])
      event.pattern = 0
      event.direction = 4
    end
  when 4,6
    event.pattern += 1
    if event.pattern == 3
      event.pattern = 0
      event.direction += 2
    end
  when 8
    pbSetSelfSwitch(event.id, "A", true)
  end
end