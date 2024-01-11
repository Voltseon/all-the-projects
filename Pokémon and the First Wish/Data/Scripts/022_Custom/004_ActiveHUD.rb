class ActiveHud
  BASE_COLOR = Color.new(248,248,248)
  SHADOW_COLOR = Color.new(64,64,64)
  BALL_OFFSETS = [-12,0]
  THROWN_BALL_GRAPHIC = {
    :POKEBALL => Rect.new(0,0,32,32),
    :GREATBALL => Rect.new(32,0,32,32),
    :ULTRABALL => Rect.new(64,0,32,32),
    :ORIGINBALL => Rect.new(96,0,32,32),
    :FEATHERBALL => Rect.new(0,32,32,32),
    :WINGBALL => Rect.new(32,32,32,32),
    :JETBALL => Rect.new(64,32,32,32),
    :HEAVYBALL => Rect.new(0,64,32,32),
    :LEADENBALL => Rect.new(32,64,32,32),
    :GIGATONBALL => Rect.new(64,64,32,32),
    :PREMIERBALL => Rect.new(0,96,32,32),
    :BAIT => Rect.new(32,96,32,32),
    :MUD => Rect.new(64,96,32,32)
  }
  THROWN_BALL_STATS = { # Range, Time to reach
    :POKEBALL => [4, 10],
    :GREATBALL => [4, 10],
    :ULTRABALL => [4, 10],
    :ORIGINBALL => [4, 10],
    :FEATHERBALL => [6, 10],
    :WINGBALL => [7, 10],
    :JETBALL => [9, 10],
    :HEAVYBALL => [2, 3],
    :LEADENBALL => [4, 3],
    :GIGATONBALL => [1, 3],
    :PREMIERBALL => [4, 10],
    :BAIT => [10, 10],
    :MUD => [10, 10],
    :NONE => [16, 0]
  }

  def initialize
    @sprites = {}
    @viewport = nil
    @command_list = []
    @commands = []
    @autosave_frame = 0
    @overlay = nil
    @background = nil
    @balls = []
    @ball_count = 0
    @aiming = false
    @aim_offset = [0,0]
    @disposed = false
    @balls_hidden = false
    @pause_hidden = false
    @spoofing = false
    @should_redraw_party = true
    @party_hidden = false
    pbStartScene
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlay.z = 99999
    @background = Sprite.new(@viewport)
    @background.z = 0
    pbSetSmallFont(@overlay.bitmap)
    @command_list = [] if @command_list != []
    @commands = [] if @commands != []
    index = 0
    MenuHandlers.each_no_check(:pause_menu) do |option, hash, name|
      next if name == nil
      @command_list.push(name)
      @commands.push(hash)
      @sprites[name] = ButtonSprite.new(self,
                                        name,
                                        "Graphics/Pictures/Active HUD/pause_bg",
                                        "Graphics/Pictures/Active HUD/pause_bg_highlight",
                                        hash["effect"],
                                        Graphics.width-128, 64+index*32, @viewport)
      @sprites[name].setTextColor(MessageConfig::DARK_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_SHADOW_COLOR)
      @sprites[name].setTextHighlightColor(MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR)
      @sprites[name].setTextOffset(0, 6)
      index += 1
    end
    @sprites["ball_bg"] = IconSprite.new(Graphics.width-128-8, Graphics.height-64, @viewport)
    3.times do |i|
      @sprites["ball_#{i}"] = IconSprite.new(Graphics.width-32*(i+1)+BALL_OFFSETS[0], Graphics.height-32+BALL_OFFSETS[1], @viewport)
    end
    @sprites["aim_marker"] = IconSprite.new(0, 0, @viewport)
    @sprites["thrown_pokeball"] = IconSprite.new(0, 0, @viewport)
    @sprites["thrown_pokeball"].setBitmap("Graphics/Characters/[FW] Balls")
    @sprites["thrown_pokeball"].ox = 16
    @sprites["thrown_pokeball"].oy = 16
    @sprites["thrown_pokeball"].visible = false
    12.times do |i|
      @sprites["partner#{i}_ball"] = IconSprite.new(0, 0, @viewport)
      @sprites["partner#{i}_ball"].setBitmap("Graphics/Characters/[FW] Balls")
      @sprites["partner#{i}_ball"].ox = 16
      @sprites["partner#{i}_ball"].oy = 16
      @sprites["partner#{i}_ball"].visible = false
    end
    6.times do |i|
      level = $player.party[i].nil? ? "-" : "#{$player.party[i].level}"
      x = 0
      case $player.party.length
      when 1 then x = 480
      when 2 then x = 448 + 64*i
      when 3 then x = 416 + 64*i
      when 4 then x = 384 + 64*i
      when 5 then x = 352 + 64*i
      when 6 then x = 320 + 64*i
      end
      @sprites["party#{i}"] = PartySprite.new($player.party[i], self,
                                              "Lv.#{level}",
                                              "Graphics/Pictures/Active HUD/party_bg",
                                              "Graphics/Pictures/Active HUD/party_bg_highlight",
                                              proc{self.pbSummary(i)},
                                              x, 512, @viewport)
      @sprites["party#{i}"].setTextColor(BASE_COLOR, SHADOW_COLOR)
      @sprites["party#{i}"].setTextOffset(32, 6)
      @sprites["party#{i}"].text_align = 1
      @sprites["party#{i}"].visible = i < $player.party.length
    end
    pbUpdate
  end

  def redraw
    return if @disposed
    @balls = []
    recount_balls
    unless @balls_hidden
      if @ball_count > 0
        @sprites["ball_bg"].setBitmap("Graphics/Pictures/Active HUD/sel_ball")
        3.times do |i|
          thisball = ($game_temp.selected_ball + 1 - i) % @ball_count
          @sprites["ball_#{i}"].setBitmap("Graphics/Items/#{@balls[thisball][0]}")
          @sprites["ball_#{i}"].ox = @sprites["ball_#{i}"].width/2
          @sprites["ball_#{i}"].oy = @sprites["ball_#{i}"].height/2
          @sprites["ball_#{i}"].zoom_x = (i == 1 ? 1 : 0.8)
          @sprites["ball_#{i}"].zoom_y = (i == 1 ? 1 : 0.8)
          @sprites["ball_#{i}"].opacity = (i == 1 ? 255 : 128)
        end
      end
      @sprites["aim_marker"].setBitmap("Graphics/Pictures/Active HUD/aim_marker")
      @sprites["aim_marker"].ox = @sprites["aim_marker"].width/2
      @sprites["aim_marker"].oy = @sprites["aim_marker"].height
    end
    redrawParty
  end

  def redrawParty
    return if @party_hidden
    return unless @should_redraw_party
    6.times do |i|
      x = 0
      case $player.party.length
      when 1 then x = 480
      when 2 then x = 448 + 64*i
      when 3 then x = 416 + 64*i
      when 4 then x = 384 + 64*i
      when 5 then x = 352 + 64*i
      when 6 then x = 320 + 64*i
      end
      level = $player.party[i].nil? ? "-" : "#{$player.party[i].level}"
      @sprites["party#{i}"].pokemon = $player.party[i]
      @sprites["party#{i}"].x = x
      @sprites["party#{i}"].visible = i < $player.party.length
      @sprites["party#{i}"].text = "Lv.#{level}"
    end
    FollowingPkmn.refresh(false)
    pbDismountPkmn($PokemonGlobal.mounted_pkmn,false)
    @should_redraw_party = false
  end

  def swapBall(up=true)
    return unless @ball_count > 0
    if up
      #add animation ??
      $game_temp.selected_ball = ($game_temp.selected_ball + 1) % @ball_count
    else
      $game_temp.selected_ball = ($game_temp.selected_ball - 1) % @ball_count
    end
    redraw
  end

  def pbUpdate
    return if @disposed
    @overlay.bitmap.clear
    textpos = []
    thisball = (@ball_count > 0 ? $game_temp.selected_ball % @ball_count : 0)
    if @ball_count > 0 && !@balls_hidden
      textpos.push(["#{$bag.quantity(@balls[thisball][0])}x", Graphics.width-32+BALL_OFFSETS[0], Graphics.height-20+BALL_OFFSETS[1], 1, MessageConfig::DARK_TEXT_MAIN_COLOR, MessageConfig::DARK_TEXT_SHADOW_COLOR])
    end
    if $game_temp.autosave_progress != 0
      alpha = (Math.sin((@autosave_frame.to_f/8.00).to_f)+1)/2*192 + 64
      base = Color.new(248,248,248,alpha)
      shadow = Color.new(64,64,64,alpha)
      textpos.push([($game_temp.autosave_progress == 1 ? "Autosaving..." : "Autosave failed..."), Graphics.width-8, 24, 1, base, shadow])
      @autosave_frame += 1
      if @autosave_frame > 300
        $game_temp.autosave_progress = 0
        @autosave_frame = 0
      end
    end
    if !@party_hidden && $player.party.length > 0
      bounds = [@sprites["party0"].x-32,@sprites["party#{$player.party.length-1}"].x+32]
      holding = -1
      $player.party.each_with_index do |pkmn, i|
        next if holding != i && holding != -1
        if Mouse.press?(nil,:left) && @sprites["party#{i}"].highlighted
          holding = i
          @sprites["party#{i}"].x = [[Mouse.x-32, bounds[0]].max,bounds[1]].min
          newidx = 0
          newidx = [[0,((@sprites["party#{i}"].x.to_f-bounds[0].to_f)/64.0).floor].max,$player.party.length-1].min
          $player.party.insert(newidx, $player.party.delete_at(i))
          @should_redraw_party = true
        end
      end
      redrawParty if holding == -1
    end
    @command_list.each_with_index do |name, i|
      @sprites[name].visible = @commands[i]["condition"].call if @commands[i]["condition"] && !@pause_hidden
    end
    @sprites["aim_marker"].visible = @aiming
    if @aiming
      $game_player.set_movement_type(:throwing)
      $game_player.lock_pattern = true
      $game_player.pattern = 0 if !@sprites["thrown_pokeball"].visible
      Input.update
      if pbMapInterpreterRunning? || $game_player.moving? || $PokemonGlobal.sliding ||
        $PokemonGlobal.fishing || $game_player.on_middle_of_stair? || Input.dir4!=0
        stopAiming
      else
        mousepos = Mouse.getMousePos(true)
        ball = (@ball_count > 0 ? @balls[thisball][0] : :NONE)
        @sprites["aim_marker"].x = (((mousepos[0]+16) / 32).floor * 32 - @aim_offset[0]/4).clamp(Graphics.width/2-THROWN_BALL_STATS[ball][0]*32,THROWN_BALL_STATS[ball][0]*32+Graphics.width/2)
        @sprites["aim_marker"].y = (((mousepos[1]+8) / 32).floor * 32 - @aim_offset[1]/4 + 24).clamp(Graphics.height/2+32-THROWN_BALL_STATS[ball][0]*32,THROWN_BALL_STATS[ball][0]*32+Graphics.height/2+32)
        mousepos[0] -= Graphics.width/2
        mousepos[1] -= Graphics.height/2
        mousepos[0] /= 10
        mousepos[1] /= 10
        hidePause
        hideParty
        $game_player.direction = (mousepos[0].abs > mousepos[1].abs ? mousepos[0]>0 ? 6 : 4 : mousepos[1]>0 ? 2 : 8)
        target = [(mousepos[0]).clamp(-64, 64), (mousepos[1]).clamp(-64, 64)]
        @aim_offset = target
        $game_map.display_x = Math.lerp($game_map.display_x, target[0] + ($game_player.x * Game_Map::REAL_RES_X) - Game_Player::SCREEN_CENTER_X, 0.2)
        $game_map.display_y = Math.lerp($game_map.display_y, target[1] + ($game_player.y * Game_Map::REAL_RES_Y) - Game_Player::SCREEN_CENTER_Y, 0.2)
        throw_ball if Mouse.click?(nil,:left)
      end
    end
    $Partners.each_with_index do |partner, i|
      @sprites["partner#{i}_ball"].visible = false if partner.nil? && !@spoofing
      next if partner.nil?
      next unless partner.client_id.is_a?(Integer)
      next if partner.thrown_ball.nil?
      partner_event = partner.client_id ? pbMapInterpreter.get_character_by_name("partner#{i+1}") : nil
      next if partner_event.nil?
      @sprites["partner#{partner.client_id}_ball"].visible = partner.thrown_ball[3]
      next unless partner.thrown_ball[3] && THROWN_BALL_GRAPHIC[partner.thrown_ball[0]]
      @sprites["partner#{partner.client_id}_ball"].src_rect = THROWN_BALL_GRAPHIC[partner.thrown_ball[0]]
      @sprites["partner#{partner.client_id}_ball"].x = partner.thrown_ball[1] + partner_event.screen_x
      @sprites["partner#{partner.client_id}_ball"].y = partner.thrown_ball[2] + partner_event.screen_y
    end
    if @sprites["thrown_pokeball"]
      thrown_ball_x = @sprites["thrown_pokeball"].x-$game_player.screen_x
      thrown_ball_y = @sprites["thrown_pokeball"].y-$game_player.screen_y
      ball = (@ball_count > 0 ? @balls[thisball][0] : :NONE)
      $game_temp.thrown_ball = [ball,thrown_ball_x,thrown_ball_y,@sprites["thrown_pokeball"].visible]
    end
    pbDrawTextPositions(@overlay.bitmap, textpos) unless @overlay.bitmap.disposed?
    pbUpdateSpriteHash(@sprites)
  end

  def spoof_ball(ball_type, sp, ep)
    @spoofing = true
    start_pos = [Graphics.width/2 + (sp[0]-$game_player.x) * 32, Graphics.height/2 + (sp[1]-$game_player.y) * 32]
    end_pos = [Graphics.width/2 + (ep[0]-$game_player.x) * 32, Graphics.height/2 + (ep[1]-$game_player.y) * 32]
    @sprites["partner4_ball"].visible = true
    @sprites["partner4_ball"].src_rect = THROWN_BALL_GRAPHIC[ball_type]
    @sprites["partner4_ball"].x = start_pos[0]
    @sprites["partner4_ball"].y = start_pos[1]
    step = [(@sprites["partner4_ball"].x.to_f - end_pos[0].to_f).abs / THROWN_BALL_STATS[ball_type][1].to_f / 50.0, (@sprites["partner4_ball"].y.to_f - end_pos[1].to_f).abs / THROWN_BALL_STATS[ball_type][1].to_f / 50.0]
    THROWN_BALL_STATS[ball_type][1].times do
      Graphics.update
      @sprites["partner4_ball"].x = Math.lerp(@sprites["partner4_ball"].x, end_pos[0], step[0])
      @sprites["partner4_ball"].y = Math.lerp(@sprites["partner4_ball"].y, end_pos[1], step[1])
    end
    @sprites["partner4_ball"].visible = false
    @spoofing = false
  end
  
  def pbRefresh
    pbUpdate
  end

  def hidePause(frames = 8)
    return if @pause_hidden
    @pause_hidden = true
    frames.times do |i|
      pbUpdate
      MenuHandlers.each_no_check(:pause_menu) do |option, hash, name|
        next if name == nil
        next unless @sprites[name].respond_to?(:x)
        @sprites[name].x = Math.lerp(@sprites[name].x, Graphics.width, (i+1)/frames.to_f)
      end
      Input.update
      Graphics.update
    end
    MenuHandlers.each_no_check(:pause_menu) do |option, hash, name|
      next if name == nil
      next unless @sprites[name].respond_to?(:visible)
      @sprites[name].x = Graphics.width
      @sprites[name].visible = false
    end
  end

  def hideBalls(frames = 8)
    return if @balls_hidden
    @balls_hidden = true
    frames.times do |f|
      pbUpdate
      @sprites["ball_bg"].y = Math.lerp(@sprites["ball_bg"].y, Graphics.height+16, (f+1)/frames.to_f)
      3.times do |i|
        @sprites["ball_#{i}"].y = Math.lerp(@sprites["ball_#{i}"].y, Graphics.height+16, (f+1)/frames.to_f)
      end
      Input.update
      Graphics.update
    end
    @sprites["ball_bg"].y = Graphics.height+16
    @sprites["ball_bg"].visible = false
    3.times do |i|
      next unless @sprites["ball_#{i}"].respond_to?(:visible)
      @sprites["ball_#{i}"].y = Graphics.height+16
      @sprites["ball_#{i}"].visible = false
    end
  end
  
  def hideParty(frames = 8)
    return if @party_hidden
    @party_hidden = true
    frames.times do |f|
      pbUpdate
      6.times do |i|
        @sprites["party#{i}"].y += 32
      end
      Input.update
      Graphics.update
    end
    6.times do |i|
      @sprites["party#{i}"].visible = false
    end
  end

  def hide(frames = 8)
    hideParty(frames)
    hidePause(frames)
    hideBalls(frames)
  end

  def showPause(frames = 8)
    return unless $game_switches[60]
    return unless @pause_hidden
    @pause_hidden = false
    i = 0
    MenuHandlers.each_no_check(:pause_menu) do |option, hash, name|
      next if name == nil
      i += 1
      next unless @sprites[name].respond_to?(:visible)
      @sprites[name].visible = (@commands[i-1]["condition"] ? @commands[i-1]["condition"].call : true)
      @sprites[name].x = Graphics.width
    end
    frames.times do |i|
      pbUpdate
      MenuHandlers.each_no_check(:pause_menu) do |option, hash, name|
        next if name == nil
        next unless @sprites[name].respond_to?(:x)
        @sprites[name].x = Math.lerp(@sprites[name].x, Graphics.width-128, (i+1)/frames.to_f)
      end
      Input.update
      Graphics.update
    end
  end

  def showBalls(frames = 8)
    return unless @balls_hidden
    @balls_hidden = false
    redraw
    @sprites["ball_bg"].y = Graphics.height+16
    3.times do |i|
      @sprites["ball_#{i}"].y = Graphics.height+16
    end
    @sprites["ball_bg"].visible = true
    3.times do |i|
      next unless @sprites["ball_#{i}"].respond_to?(:visible)
      @sprites["ball_#{i}"].visible = true
    end
    frames.times do |f|
      pbUpdate
      @sprites["ball_bg"].y = Math.lerp(@sprites["ball_bg"].y, Graphics.height-64, (f+1)/frames.to_f)
      3.times do |i|
        @sprites["ball_#{i}"].y = Math.lerp(@sprites["ball_#{i}"].y, Graphics.height-36, (f+1)/frames.to_f)
      end
      Input.update
      Graphics.update
    end 
  end

  def showParty(frames = 8)
    return if !@party_hidden
    @party_hidden = false
    frames.times do |f|
      pbUpdate
      6.times do |i|
        @sprites["party#{i}"].y -= 32
      end
      Input.update
      Graphics.update
    end
    6.times do |i|
      @sprites["party#{i}"].y = 512
      @sprites["party#{i}"].visible = i < $player.party.length
    end
  end

  def show(frames = 8)
    showParty(frames)
    showPause(frames)
    showBalls(frames)
  end

  def throw_ball
    return if @ball_count == 0
    return if @sprites["thrown_pokeball"].visible
    $game_player.lock_pattern = false
    curr_ball = @balls[$game_temp.selected_ball][0]
    remove_ball
    pbSEPlay("Battle throw")
    redraw
    destination = [@sprites["aim_marker"].x, @sprites["aim_marker"].y]
    @sprites["thrown_pokeball"].src_rect = THROWN_BALL_GRAPHIC[curr_ball]
    @sprites["thrown_pokeball"].x = Graphics.width/2
    @sprites["thrown_pokeball"].y = Graphics.height/2
    @sprites["thrown_pokeball"].visible = true
    pos = [0,0]
    6.times do |i|
      $scene.update
      Graphics.update
      next if i%2 == 0
      $game_player.pattern = ($game_player.pattern + 1) % 4
    end
    $game_player.pattern = 0
    distance = (Math.sqrt((@sprites["thrown_pokeball"].y.to_f-destination[1].to_f)**2.0 + (@sprites["thrown_pokeball"].x.to_f-destination[0].to_f)**2.0) / 32.0).round
    step = [(@sprites["thrown_pokeball"].x.to_f - destination[0].to_f).abs / THROWN_BALL_STATS[curr_ball][1].to_f / 50.0, (@sprites["thrown_pokeball"].y.to_f - destination[1].to_f).abs / THROWN_BALL_STATS[curr_ball][1].to_f / 50.0]
    THROWN_BALL_STATS[curr_ball][1].times do
      $scene.update
      Graphics.update
      @sprites["thrown_pokeball"].x = Math.lerp(@sprites["thrown_pokeball"].x, destination[0], step[0])
      @sprites["thrown_pokeball"].y = Math.lerp(@sprites["thrown_pokeball"].y, destination[1], step[1])
      pos = $game_map.screenPosToTile(@sprites["thrown_pokeball"].x,@sprites["thrown_pokeball"].y)
      event_check = $game_map.check_event(pos[0], pos[1])
      event_check = pbMapInterpreter.get_character(event_check) if event_check
      break if event_check && event_check.name[/OverworldPkmn/i] && !event_check.variable.nil? && event_check.character_name != "[FW] Balls"
      break if !$game_map.passable?(pos[0], pos[1], 0) && !$game_map.terrain_tag(pos[0], pos[1], false).can_surf_freely
    end
    
    evt = $game_map.check_event(pos[0], pos[1])
    evts = []
    [0,-1,1].each do |x|
      [0,-1,1].each do |y|
        evt = $game_map.check_event(pos[0]+x, pos[1]+y)
        next if evt.nil?
        evts.push(evt)
      end
    end
    hitEvt = []
    evts.each do |evt|
      event = pbMapInterpreter.get_character(evt)
      if event.name[/OverworldPkmn/i] && !event.variable.nil? && event.character_name != "[FW] Balls"
        @sprites["thrown_pokeball"].visible = false
        case curr_ball
        when :MUD then event.variable.mudHit
        when :BAIT then event.variable.baitHit
        else; pbStartOverworldCapture(curr_ball, event, distance)
        end
        return
      elsif event.character_name != "" && !event.erased
        hitEvt.push(evt)
      end
    end
    pbSEPlay(hitEvt.empty? ? "Battle ball drop" : "Smack")
    10.times do
      $scene.update
      Graphics.update
      Input.update
    end
    @sprites["thrown_pokeball"].visible = false
  end

  def remove_ball
    $bag.remove(@balls[$game_temp.selected_ball][0],1)
    recount_balls
  end

  def recount_balls
    $bag.pockets[3].each do |ball|
      next if ball[0] == :ORIGINBALL
      @balls.push(ball)
    end
    @balls.push([:MUD, $bag.quantity(:MUD)]) if $bag.has?(:MUD)
    @balls.push([:BAIT, $bag.quantity(:BAIT)]) if $bag.has?(:BAIT)
    @ball_count = @balls.length
    hideBalls if @ball_count == 0
    $game_temp.selected_ball = @ball_count == 0 ? 0 : $game_temp.selected_ball % @ball_count
  end

  def pbSummary(index)
    hide
    VSummary.new(index) if !$game_temp.in_menu
    show
  end

  def pbHideMenu; end
  def pbShowMenu; end
  def aiming; @aiming; end
  def aiming=(value); @aiming = value; end
  def aim_offset=(value); @aim_offset = value; end

  def overlay; @overlay; end
  def background; @background; end

  def pbEndScene
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @background.dispose
    @viewport.dispose
  end
end

# Autosave
class PokemonGlobalMetadata
  attr_accessor :autosaveTime
  def autosaveTime; @autosaveTime = 0 if !@autosaveTime; return @autosaveTime; end
  def autosaveTime=(value); @autosaveTime = value; end
end
class Game_Temp
  attr_accessor :autosave_progress
  def autosave_progress; @autosave_progress = 0 if !@autosave_progress; return @autosave_progress; end
  def autosave_progress=(value); @autosave_progress = value; end
end
EventHandlers.add(:on_frame_update, :autosave,
  proc {
    next if $PokemonSystem.autosave==0
    next if SaveData.exists? && $game_temp.begun_new_game
    $PokemonGlobal.autosaveTime -= 1
    if $PokemonGlobal.autosaveTime < 0
      $PokemonGlobal.autosaveTime = Graphics.frame_rate * 60 * 5
      if Game.save
        $game_temp.autosave_progress = 1
      else
        $game_temp.autosave_progress = 2
      end
    end
  }
)

#===============================================================================
# Pause menu commands.
#===============================================================================
MenuHandlers.add(:pause_menu, :pokedex, {
  "name"      => _INTL("Journal"),
  "order"     => 10,
  "condition" => proc { next $player.has_pokedex },
  "effect"    => proc { |menu|
    $game_player.set_movement_type(:book)
    pbPlayDecisionSE
    menu.hide
    menu.background.bitmap = Graphics.snap_to_bitmap
    menu.background.bitmap.blur_rf(4)
    scene = Journal.new
    scene.pbStartScene
    menu.background.bitmap = nil
    menu.show
    menu.pbRefresh
    menu.show
=begin
    if Settings::USE_CURRENT_REGION_DEX
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    elsif $player.pokedex.accessible_dexes.length == 1
      $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[0]
      pbFadeOutIn {
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    else
      pbFadeOutIn {
        scene = PokemonPokedexMenu_Scene.new
        screen = PokemonPokedexMenuScreen.new(scene)
        screen.pbStartScreen
        menu.pbRefresh
      }
    end
=end
    $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
    next false
  }
})

MenuHandlers.add(:pause_menu, :party, {
  "name"      => _INTL("Pokémon"),
  "order"     => 20,
  "condition" => proc { next $player.party_count > 0 },
  "effect"    => proc { |menu|
    $game_player.set_movement_type(:book)
    pbPlayDecisionSE
    hidden_move = nil
    pbFadeOutIn {
      sscene = PokemonParty_Scene.new
      sscreen = PokemonPartyScreen.new(sscene, $player.party)
      hidden_move = sscreen.pbPokemonScreen
    }
    $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
    next false if !hidden_move
    $game_temp.in_menu = false
    pbUseHiddenMove(hidden_move[0], hidden_move[1])
    next true
  }
})

MenuHandlers.add(:pause_menu, :bag, {
  "name"      => _INTL("Bag"),
  "order"     => 30,
  "condition" => proc { next !pbInBugContest? },
  "effect"    => proc { |menu|
    $game_player.set_movement_type(:book)
    pbPlayDecisionSE
    menu.hide
    menu.background.bitmap = Graphics.snap_to_bitmap
    menu.background.bitmap.blur_rf(4)
    item = nil
    scene = BagUI.new
    scene.pbStartScene
    menu.background.bitmap = nil
    menu.show
    $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
    $game_temp.in_menu = false
    next false
  }
})

MenuHandlers.add(:pause_menu, :save, {
  "name"      => _INTL("Save"),
  "order"     => 60,
  "condition" => proc { next $game_system && !$game_system.save_disabled &&
                             !pbInSafari? && !pbInBugContest? },
  "effect"    => proc { |menu|
    $game_player.set_movement_type(:book)
    menu.hide
    scene = PokemonSave_Scene.new
    screen = PokemonSaveScreen.new(scene)
    if screen.pbSaveScreen
      menu.pbRefresh
      menu.show
      $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
      next true
    end
    menu.pbRefresh
    menu.show
    $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
    next false
  }
})

MenuHandlers.add(:pause_menu, :rooms, {
  "name"      => _INTL("Connect"),
  "order"     => 65,
  "condition" => proc { next $Connections.empty? },
  "effect"    => proc { |menu|
    $game_player.set_movement_type(:book)
    menu.hide
    menu.background.bitmap = Graphics.snap_to_bitmap
    menu.background.bitmap.blur_rf(4)
    (RoomUI.new).pbStartScene
    menu.background.bitmap = nil
    menu.pbRefresh
    menu.show
    $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
    next false
  }
})

MenuHandlers.add(:pause_menu, :options, {
  "name"      => _INTL("Options"),
  "order"     => 70,
  "effect"    => proc { |menu|
    $game_player.set_movement_type(:book)
    pbPlayDecisionSE
    pbFadeOutIn {
      scene = PokemonOption_Scene.new
      screen = PokemonOptionScreen.new(scene)
      screen.pbStartScreen
      pbUpdateSceneMap
      menu.pbRefresh
    }
    $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
    next false
  }
})

MenuHandlers.add(:pause_menu, :quit_game, {
  "name"      => _INTL("Quit Game"),
  "order"     => 80,
  "effect"    => proc { |menu|
    menu.hide
    if pbConfirmMessage(_INTL("Are you sure you want to quit the game?"))
      scene = PokemonSave_Scene.new
      screen = PokemonSaveScreen.new(scene)
      screen.pbSaveScreen
      menu.pbEndScene
      $scene = nil
      next true
    end
    menu.pbRefresh
    menu.show
    next false
  }
})

MenuHandlers.add(:pause_menu, :debug, {
  "name"      => _INTL("Debug"),
  "order"     => 90,
  "condition" => proc { next $DEBUG },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbFadeOutIn {
      pbDebugMenu
      menu.pbRefresh
    }
    next false
  }
})

class Game_Temp
  attr_accessor :selected_ball
  attr_accessor :thrown_ball
  def selected_ball; @selected_ball = 0 if !@selected_ball; return @selected_ball; end
  def selected_ball=(value); @selected_ball = value; end
  def thrown_ball; @thrown_ball = [:POKEBALL, 0, 0, false] if !@thrown_ball; return @thrown_ball; end
  def thrown_ball=(value); @thrown_ball = value; end
end

class Game_Map
  def screenPosToTile(x,y)
    return [((x.to_f-Graphics.width/2.0)/32.0).floor + $game_player.x, ((y.to_f-Graphics.height/2.0)/32.0).floor + $game_player.y]
  end
end