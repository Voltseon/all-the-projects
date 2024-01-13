class ArenaSelection
  PATH = "Graphics/Pictures/Arenas/"
  BUTTON_WIDTH = 322
  BUTTON_HEIGHT = 388
  PADDING = 18

  def initialize
    $game_temp.arena_select_calling = false
    pbGlobalFadeOut(1)
    @viewport = nil
    @sprites = {}
    @overlay = nil
    @disposed = false
    @index = -1
    @visibility = 0
    pbStartScene
  end

  def pbStartScene
    pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).lobby_menu, AudioPack.get($PokemonGlobal.audio_pack)), 90, 100)
    Discord.update_activity({
      :large_image => "icon_big",
      :large_image_text => "Pivot",
      :details => "Selecting an Arena",
    })
    $Client_id = 0
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    x_position = 12
    y_position = 158
    @sprites["bg"] = IconSprite.new(0,0,@viewport)
    @sprites["bg"].setBitmap(MainMenu::PATH+"bg")
    Arena.each_with_index do |a, i|
      next if a.internal == :TRAININGROOM
      @sprites["arena_#{i}"] = ButtonSprite.new(self,a.name,PATH+"arena_#{i}",PATH+"arena_#{i}_sel",proc{next if self.index == i; pbPlayDecisionSE; self.index = i; $game_temp.lobby_calling = true; setArena(a.internal); @disposed = true;},0,x_position,y_position,@viewport,PATH+"arena_#{i}_disabled",proc{pbAnnounce(("fools_"+a.name.downcase.gsub(" ","_")).to_sym) if $april_fools})
      @sprites["arena_#{i}"].setTextOffset(0,16)
      @sprites["arena_#{i}"].enabled = $player.unlocked_arenas.include?(a.internal)
      @sprites["arena_#{i}"].text = "Locked" if !@sprites["arena_#{i}"].enabled
      @sprites["arena_#{i}"].hover_proc = proc{pbAnnounce(("fools_unlocked_"+a.unlocked_level.to_s).to_sym)} if $april_fools && !@sprites["arena_#{i}"].enabled
      x_position += BUTTON_WIDTH + PADDING
      x_position = 12 if (i+1)%3==0
      y_position += BUTTON_HEIGHT + PADDING if (i+1)%3==0
    end
    @sprites["visibility"] = ButtonSprite.new(self,"",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; self.visibility = (self.visibility-1).abs},2,Graphics.width-278,80,@viewport, nil, proc{pbAnnounce("fools_visibility_#{self.visibility}".to_sym) if $april_fools})
    @sprites["visibility"].setTextOffset(0,24)
    @sprites["visibility"].visible = !$game_temp.solo_mode
    @sprites["region"] = ButtonSprite.new(self,"",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; switchRegion},2,472,80,@viewport,nil,proc{pbAnnounce("fools_region_#{CableClub::HOSTS[$player.region][:short_name]}".to_sym) if $april_fools})
    @sprites["region"].setTextOffset(0,24)
    @sprites["region"].visible = !$game_temp.solo_mode
    @sprites["match_time"] = ButtonSprite.new(self,"Time: #{$game_temp.match_time_formatted}",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; changeMatchTime(true)},2,Graphics.width-278,80,@viewport, nil, proc{pbAnnounce("fools_visibility_#{self.visibility}".to_sym) if $april_fools})
    @sprites["match_time"].setTextOffset(0,24)
    @sprites["match_time"].visible = $game_temp.solo_mode
    @sprites["stocks"] = ButtonSprite.new(self,"Stocks: #{$game_temp.max_stocks}",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; changeStocks(true)},2,472,80,@viewport,nil,proc{pbAnnounce("fools_region_#{CableClub::HOSTS[$player.region][:short_name]}".to_sym) if $april_fools})
    @sprites["stocks"].setTextOffset(0,24)
    @sprites["stocks"].visible = $game_temp.solo_mode
    @sprites["cpus"] = ButtonSprite.new(self,"CPUs: #{$game_temp.cpus}",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; changeCpus(true)},2,198,80,@viewport,nil,proc{pbAnnounce("fools_region_#{CableClub::HOSTS[$player.region][:short_name]}".to_sym) if $april_fools})
    @sprites["cpus"].setTextOffset(0,24)
    @sprites["cpus"].visible = $game_temp.solo_mode
    @sprites["back"] = ButtonSprite.new(self,"",MainMenu::PATH+"back",MainMenu::PATH+"back_highlight",proc{goBack},0,24,80,@viewport,nil,proc{pbAnnounce(:fools_back) if $april_fools})
    @sprites["top_bar"] = IconSprite.new(0,0,@viewport)
    @sprites["top_bar"].setBitmap(MainMenu::PATH+"topbar")
    @sprites["name"] = ButtonSprite.new(self,"",MainMenu::PATH+"empty",MainMenu::PATH+"empty",proc{ },0,Graphics.width-174, 0,@viewport, nil, proc{pbAnnounce(:fools_rename) if $april_fools}, "#{$player.name} Lv. #{$player.level}")
    @sprites["name"].setTextOffset(0,4)
    @sprites["name"].text_align = 1
    pbSetSystemFont(@overlay.bitmap)
    pbMain
  end

  def pbMain
    pbAnnounce(:fools_select_arena) if $april_fools
    frame = 0
    loop do
      break if @disposed
      pbUpdate
      goBack if Input.press?(Input::BACK) && !$game_temp.message_window_showing
      unless Input::scroll_v == 0
        if @sprites["arena_#{Arena.count-2}"].y + (Input::scroll_v*20) < 174
          y = 174 - @sprites["arena_#{Arena.count-2}"].y
        elsif @sprites["visibility"].y + (Input::scroll_v*20) > 80
          y = 80 - @sprites["visibility"].y
        else
          y = Input::scroll_v*32
        end
        @sprites["back"].y = @sprites["back"].y + y
        @sprites["visibility"].y = @sprites["visibility"].y + y
        @sprites["region"].y = @sprites["region"].y + y
        @sprites["match_time"].y = @sprites["match_time"].y + y
        @sprites["stocks"].y = @sprites["stocks"].y + y
        @sprites["cpus"].y = @sprites["cpus"].y + y
        Arena.each_with_index do |a, i|
          next if a.internal == :TRAININGROOM
          @sprites["arena_#{i}"].y = @sprites["arena_#{i}"].y + y
        end 
      end
      textpos = []
      @overlay.bitmap.clear
      @sprites["visibility"].text = "#{self.visibility == 0 ? "Public Lobby" : "Private Lobby"}"
      @sprites["region"].text = "Region: #{CableClub::HOSTS[$player.region][:name]}"
      @sprites["stocks"].text = "Stocks: #{$game_temp.max_stocks}"
      @sprites["cpus"].text = "CPUs: #{$game_temp.cpus}"
      @sprites["match_time"].text = "Time: #{$game_temp.match_time_formatted}"
      # Draw top bar info
      @sprites["name"].subtitle = "#{$player.name} Lv. #{$player.level}"
      #textpos.push(["#{$player.name} Lv. #{$player.level}",Graphics.width-16, 16, 1, BASE_COLOR, SHADOW_COLOR])
      @overlay.bitmap.fill_rect(Graphics.width-112,46,96,8,MainMenu::EXP_EMPTY)
      part = ($player.exp.to_f-$player.exp_to_current_level.to_f)/($player.total_exp_to_next_level.to_f-$player.exp_to_current_level.to_f)
      @overlay.bitmap.fill_rect(Graphics.width-112,46,part*96,8,MainMenu::EXP_FULL)
      textpos.push(["Select Arena",Graphics.width/2, 24, 2, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
      pbDrawTextPositions(@overlay.bitmap,textpos)
      pbGlobalFadeIn if $overlay.faded_out? && !@disposed
      pbUpdateLastOnline($player.id) if frame % 3600==0
      frame += 1
    end
    pbEndScene
  end

  def pbUpdate
    return if @disposed
    Graphics.update
    Input.update
    pbUpdateSpriteHash(@sprites)
  end

  def goBack
    pbPlayCloseMenuSE
    pbGlobalFadeOut
    $Client_id = 1
    $game_temp.main_menu_screen = 1
    $game_temp.main_menu_calling = true
    @disposed = true
  end

  def index; @index; end
  def index=(value)
    @index = value
  end

  def visibility; @visibility; end
  def visibility=(value)
    @visibility = value
    pbAnnounce("fools_visibility_#{@visibility}".to_sym) if $april_fools
  end

  def switchRegion
    if $DEBUG
      $player.region = ($player.region+1) % CableClub::HOSTS.length
    else
      $player.region = ($player.region+1) % (CableClub::HOSTS.length-1)
    end
    pbAnnounce("fools_region_#{CableClub::HOSTS[$player.region][:short_name]}".to_sym) if $april_fools
  end

  def changeMatchTime(increase = true)
    if increase
      case $game_temp.match_time
      when 480.0
        $game_temp.match_time = 900.0
      when 900.0
        $game_temp.match_time = 180.0
      when 180.0
        $game_temp.match_time = 300.0
      when 300.0
        $game_temp.match_time = 480.0
      end
    else
      case $game_temp.match_time
      when 480.0
        $game_temp.match_time = 300.0
      when 900.0
        $game_temp.match_time = 480.0
      when 180.0
        $game_temp.match_time = 900.0
      when 300.0
        $game_temp.match_time = 180.0
      end
    end
  end

  def changeStocks(increase = true)
    if increase
      if $game_temp.max_stocks == 10
        $game_temp.max_stocks = 1
      elsif $game_temp.max_stocks == 7
        $game_temp.max_stocks += 3
      else
        $game_temp.max_stocks += 2
      end
    else
      if $game_temp.max_stocks == 1
        $game_temp.max_stocks = 10
      elsif $game_temp.max_stocks == 10
        $game_temp.max_stocks -= 3
      else
        $game_temp.max_stocks -= 2
      end
    end
  end

  def changeCpus(increase = true)
    if increase
      $game_temp.cpus = ($game_temp.cpus)%3 + 1
    else
      $game_temp.cpus = ($game_temp.cpus-2)%3 + 1
    end
  end

  def pbEndScene
    pbGlobalFadeOut
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
    if $game_temp.solo_mode
      if $game_temp.lobby_calling
        $game_temp.lobby_calling = false
        $game_temp.character_select_calling = true
      end
    else
      pbCreateLobby(rand(100..999), $player.region, self.index, self.visibility) if $Partners.empty? && $game_temp.lobby_calling
    end
  end
end