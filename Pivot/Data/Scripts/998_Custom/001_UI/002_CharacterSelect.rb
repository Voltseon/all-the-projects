class CharacterSelection
  PATH = "Graphics/Pictures/Character Selection/"
  BUTTON_WIDTH = 96
  PADDING = 32
  STATS_FULL = [Color.new(213,186,255), Color.new(234,57,44), Color.new(145,229,142)] # Speed, Attack, HP
  STATS_FULL_2  = [Color.new(163,107,255), Color.new(183,18,23), Color.new(121,198,69)] # Speed, Attack, HP
  STATS_FULL_3  = [Color.new(95,48,175), Color.new(137,11,32), Color.new(95,142,24)] # Speed, Attack, HP
  STATS_EMPTY = [Color.new(37,32,51), Color.new(81,9,34), Color.new(45,53,19)] # Speed, Attack, HP

  def initialize
    $game_temp.character_select_calling = false
    pbGlobalFadeOut(1)
    #$Client_id = 4 if $game_temp.spectating 
    @viewport = nil
    @sprites = {}
    @overlay = nil
    @disposed = false
    $game_temp.ready = false
    $game_temp.spectating = $Client_id > 3
    @index = $player.character_ID-1
    @index = 0 if @index < 0
    @ready_count = 0
    @player_count = 1
    @characters = {}
    Character.each_with_index do |c, i|
      next unless c.playable
      #next if c.internal == :HERACROSS && !$DEBUG
      if !System.file_exists?("#{PATH}/#{c.internal.to_s}/default.png")
        @index = 0 if @index == i
        next
      end
      @characters[i] = c
    end
    pbStartScene
  end

  def pbStartScene
    if $Partners.empty? && !$game_temp.training && !$game_temp.solo_mode
      $game_temp.main_menu_calling = true
      return
    end
    pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).character_selection, AudioPack.get($PokemonGlobal.audio_pack)), 80, 100)
    Discord.update_activity({
      :large_image => "icon_big",
      :large_image_text => "Pivot",
      :details => "Selecting a Character",
    })
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    @description = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @description.z = 99999
    margin = (Graphics.width - (@characters.length * BUTTON_WIDTH)) / (Graphics.width - 1)
    x_position = 32
    y_position = 112
    y_position += 32 if $game_temp.training || $game_temp.solo_mode
    @sprites["bg"] = IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap(MainMenu::PATH+"bg")
    @sprites["top_bar"] = IconSprite.new(0,0,@viewport)
    @sprites["top_bar"].setBitmap(MainMenu::PATH+"topbar")
    @sprites["top_bar"].z = 1
    @sprites["stats"] = IconSprite.new(588,88,@viewport)
    @sprites["stats"].setBitmap(PATH+"stats")
    @sprites["name"] = ButtonSprite.new(self,"",MainMenu::PATH+"empty",MainMenu::PATH+"empty",proc{ },0,Graphics.width-174, 0,@viewport, nil, proc{pbAnnounce(:fools_rename) if $april_fools}, "#{$player.name} Lv. #{$player.level}")
    @sprites["name"].setTextOffset(0,4)
    @sprites["name"].text_align = 1
    @sprites["name"].z = 1
    @sprites["settings"] = ButtonSprite.new(self,"",MainMenu::PATH+"settings",MainMenu::PATH+"settings_highlight",proc{pbPlayDecisionSE; PokemonOptionScreen.new(PokemonOption_Scene.new).pbStartScreen},0,916,492,@viewport)
    @characters.each do |i, c|
      @sprites["char_#{i}"] = ButtonSprite.new(self,"","#{PATH}/#{c.internal.to_s}/default","#{PATH}/#{c.internal.to_s}/selected",proc{next if self.index == i; pbAnnounce(:character, i); self.index = i},0,x_position,y_position,@viewport,"#{PATH}/#{c.internal.to_s}/disabled")
      @sprites["char_#{i}"].enabled = $player.unlocked_characters.include?(c.internal)
      @sprites["char_#{i}"].enabled = false if $game_temp.spectating
      #@sprites["char_#{i}"].z = 99990
      x_position += BUTTON_WIDTH + margin + PADDING
      x_position = 32 if (i+1)%4==0
      y_position += 80 + margin + PADDING if (i+1)%4==0
    end
    @sprites["confirm"] = ButtonSprite.new(self,"Confirm",PATH+"confirm",PATH+"confirm_sel",proc{pbPlayDecisionSE; pbChangePlayer(@index+1); $game_temp.start_match_calling = true; @disposed = true;},0,32,476,@viewport,nil,proc{pbAnnounce(:fools_confirm) if $april_fools})
    @sprites["confirm"].setTextOffset(0,24)
    @sprites["confirm"].visible = @index>=0 && ((@ready_count == @player_count && $Client_id == 0) || $game_temp.training || $game_temp.solo_mode)
    @sprites["ready"] = ButtonSprite.new(self,"Ready",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; $game_temp.ready = true;},0,32,476,@viewport, nil, proc{pbAnnounce(:fools_ready) if $april_fools})
    @sprites["ready"].setTextOffset(0,24)
    @sprites["ready"].visible = @index>=0 && !$game_temp.ready && !$game_temp.training && !$game_temp.spectating && !$game_temp.solo_mode
    @sprites["unready"] = ButtonSprite.new(self,"Unready",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayCancelSE; $game_temp.ready = false;},0,32,476,@viewport, nil, proc{pbAnnounce(:fools_unready) if $april_fools})
    @sprites["unready"].setTextOffset(0,24)
    @sprites["unready"].visible = @index>=0 && $game_temp.ready && !@sprites["confirm"].visible && !$game_temp.training && !$game_temp.spectating && !$game_temp.solo_mode
    #@sprites["leave"] = ButtonSprite.new(self,"Back",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayCancelSE; return false},0,32,392,@viewport)
    #@sprites["leave"].setTextOffset(0,24)
    @sprites["back"] = ButtonSprite.new(self,"",MainMenu::PATH+"back",MainMenu::PATH+"back_highlight",proc{goBack},0,24,72,@viewport,nil,proc{pbAnnounce(:fools_back) if $april_fools})
    @sprites["back"].visible = $game_temp.training
    @sprites["back2"] = ButtonSprite.new(self,"",MainMenu::PATH+"back",MainMenu::PATH+"back_highlight",proc{goBack2},0,24,72,@viewport,nil,proc{pbAnnounce(:fools_back) if $april_fools})
    @sprites["back2"].visible = $game_temp.solo_mode
    pbSetSystemFont(@overlay.bitmap)
    pbSetSystemFont(@description.bitmap)
    @player_count = [$Partners.length+1, 4].min
    pbMain
  end

  def pbMain
    highlightedChar = @index
    oldHighlightedChar = -1
    drawFormattedTextEx(@description.bitmap, 600, 272, 390, @characters[highlightedChar].description, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR, 28)
    if $april_fools
      pbAnnounce(:fools_select_character) if !$game_temp.spectating
      pbAnnounce(:fools_spectating) if $game_temp.spectating
    end
    loop do
      break if @disposed
      pbUpdate
      goBack if Input.press?(Input::BACK) && ($game_temp.training || $game_temp.solo_mode) && !$game_temp.message_window_showing
      if Input::scroll_v != 0 && @characters.count > 12
        y_position = 112
        y_position += 32 if $game_temp.training || $game_temp.solo_mode
        if @sprites["char_#{@characters.count-4}"].y + (Input::scroll_v*13) < 250
          y = 250 - @sprites["char_#{@characters.count-4}"].y
        elsif @sprites["char_0"].y + (Input::scroll_v*13) > y_position
          y = y_position - @sprites["char_0"].y
        else
          y = Input::scroll_v*13
        end
        @characters.each do |i, c|
          @sprites["char_#{i}"].y += y
        end
      end
      textpos = []
      @overlay.bitmap.clear
      # Check for version mismatch
      if $overlay&.faded_out?
        version_check_data = [0,0]
        $Partners.each do |partner|
          next unless partner.is_a?(Partner)
          version_check_data[0] += 1
          if partner.version == ""
            version_check_data[1] += 1
            next
          end
          version_check_data[1] += 1 if partner.version == Settings::GAME_VERSION
        end
        if version_check_data[0] != version_check_data[1]
          pbMessage("You or another player is on an outdated version of Pivot. Please update to the latest version in order to access online features.\\wtnp[40]")
          $Connections.each { |connection| connection.dispose }
          $Partners = []
          break
        end
      end
      #@sprites["leave"].visible = $game_temp.training
      @sprites["confirm"].visible = @index>=0 && ((@ready_count == @player_count && $Client_id == 0) || $game_temp.training || $game_temp.solo_mode)
      @ready_count = $game_temp.ready ? 1 : 0
      $Partners.each do |partner|
        next unless partner.is_a?(Partner)
        next unless partner.map_id
        next if partner.client_id > 3
        @ready_count += 1 if partner.ready
        if $game_temp.start_match_calling
          pbPlayDecisionSE unless $game_temp.spectating
          pbChangePlayer(@index+1) unless $game_temp.spectating
          $game_player.transparent = true if $game_temp.spectating
          $game_temp.start_match_calling = true
          @disposed = true
          break
        end
      end
      @sprites["ready"].visible = @index>=0 && !$game_temp.ready && !$game_temp.training && !$game_temp.spectating && !$game_temp.solo_mode
      @sprites["unready"].visible = @index>=0 && $game_temp.ready && !@sprites["confirm"].visible && !$game_temp.training && !$game_temp.spectating && !$game_temp.solo_mode
      @sprites["ready"].text = "Ready (#{@ready_count}/#{@player_count})"
      @sprites["unready"].text = "Unready (#{@ready_count}/#{@player_count})"
      # Draw top bar info
      @sprites["name"].subtitle = "#{$player.name} Lv. #{$player.level}"
      #textpos.push(["#{$player.name} Lv. #{$player.level}",Graphics.width-16, 16, 1, BASE_COLOR, SHADOW_COLOR])
      @overlay.bitmap.fill_rect(Graphics.width-112,46,96,8,MainMenu::EXP_EMPTY)
      part = ($player.exp.to_f-$player.exp_to_current_level.to_f)/($player.total_exp_to_next_level.to_f-$player.exp_to_current_level.to_f)
      @overlay.bitmap.fill_rect(Graphics.width-112,46,part*96,8,MainMenu::EXP_FULL)
      if $game_temp.spectating
        textpos.push(["Spectating",Graphics.width/2, 24, 2, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
      else
        textpos.push(["Select Your Character",Graphics.width/2, 24, 2, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
      end
      # Character Select stuff
      oldHighlightedChar = highlightedChar
      if !@sprites["char_#{@index}"].highlighted
        @sprites["char_#{@index}"].highlighted = true
        highlightedChar = @index
      end
      @characters.each do |i, value|
        s = @sprites["char_#{i}"]
        pad = PADDING/2
        if Mouse.over_area?(s.x, s.y, s.width, s.height) && s.visible && s.enabled
          if highlightedChar != i
            highlightedChar = i
            break
          end
        end
      end
      if highlightedChar != oldHighlightedChar
        @description.bitmap.clear
        drawFormattedTextEx(@description.bitmap, 600, 272, 390, @characters[highlightedChar].description, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR, 28)
        oldHighlightedChar = highlightedChar
      end
      unless highlightedChar < 0
        textpos.push(["#{@characters[highlightedChar].name}", 798, 102, 2, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
        textpos.push(["Speed:", 600, 160, 0, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
        textpos.push(["Attack:", 600, 192, 0, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
        textpos.push(["HP:", 600, 224, 0, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
        # Variables
        # move_speed
        @overlay.bitmap.fill_rect(742, 160, 250, 8, STATS_EMPTY[0])
        current_evolution = @characters[highlightedChar].evolution
        final_stage = (current_evolution ? Character.get(current_evolution).evolution : current_evolution)
        current_evolution = nil if current_evolution == :ZUBAT
        final_stage = nil if current_evolution == nil || current_evolution == final_stage
        if current_evolution
          if final_stage
            part = Character.get(final_stage).speed.to_f/10.0
            @overlay.bitmap.fill_rect(742, 160, part*250, 8, STATS_FULL_3[0])
            part = Character.get(current_evolution).speed.to_f/10.0
            @overlay.bitmap.fill_rect(742, 160, part*250, 8, STATS_FULL_2[0])
          else
            part = Character.get(final_stage).speed.to_f/10.0
            @overlay.bitmap.fill_rect(742, 160, part*250, 8, STATS_FULL_3[0])
          end
        end
        part = (@characters[highlightedChar].speed.to_f/10.0)
        @overlay.bitmap.fill_rect(742, 160, part*250, 8, STATS_FULL[0])
        # attack
        @overlay.bitmap.fill_rect(742, 192, 250, 8, STATS_EMPTY[1])
        if current_evolution
          if final_stage
            part = Character.get(final_stage).attack.to_f/10.0
            @overlay.bitmap.fill_rect(742, 192, part*250, 8, STATS_FULL_3[1])
            part = Character.get(current_evolution).attack.to_f/10.0
            @overlay.bitmap.fill_rect(742, 192, part*250, 8, STATS_FULL_2[1])
          else
            part = Character.get(final_stage).attack.to_f/10.0
            @overlay.bitmap.fill_rect(742, 192, part*250, 8, STATS_FULL_3[1])
          end
        end
        part = (@characters[highlightedChar].attack.to_f/10.0)
        @overlay.bitmap.fill_rect(742, 192, part*250, 8, STATS_FULL[1])
        # hp
        @overlay.bitmap.fill_rect(742, 224, 250, 8, STATS_EMPTY[2])
        if current_evolution
          if final_stage
            part = Character.get(final_stage).hp.to_f/100.0
            @overlay.bitmap.fill_rect(742, 224, part*250, 8, STATS_FULL_3[2])
            part = Character.get(current_evolution).hp.to_f/100.0
            @overlay.bitmap.fill_rect(742, 224, part*250, 8, STATS_FULL_2[2])
          else
            part = Character.get(final_stage).hp.to_f/100.0
            @overlay.bitmap.fill_rect(742, 224, part*250, 8, STATS_FULL_3[2])
          end
        end
        part = (@characters[highlightedChar].hp.to_f/100.0)
        @overlay.bitmap.fill_rect(742, 224, part*250, 8, STATS_FULL[2])
        pbDrawTextPositions(@overlay.bitmap,textpos)
      end
      pbGlobalFadeIn if $overlay.faded_out? && !@disposed
    end
    pbBGMStop(1.0)
    pbEndScene
  end

  def pbUpdate
    return if @disposed
    #CableClub.start_update
    Graphics.update
    Input.update
    pbUpdateSpriteHash(@sprites)
    #CableClub.resolve_update
  end

  def goBack
    return if $game_temp.message_window_showing
    pbPlayCloseMenuSE
    $game_temp.main_menu_screen = 1
    $game_temp.main_menu_calling = true
    @disposed = true;
  end

  def goBack2
    return if $game_temp.message_window_showing
    pbPlayCloseMenuSE
    $game_temp.arena_select_calling = true
    @disposed = true;
  end

  def index; @index; end
  def index=(value)
    @index = value
  end

  def pbEndScene
    pbGlobalFadeOut(24, ($game_temp.main_menu_calling ? false : true))
    @disposed = true
    $game_temp.training = false if $game_temp.main_menu_calling
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
  end
end