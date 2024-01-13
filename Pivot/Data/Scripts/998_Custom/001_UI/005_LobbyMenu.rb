class LobbyMenu
  attr_accessor :sprites

  BASE_COLOR = Color.new(254,255,255)
  SHADOW_COLOR = Color.new(64,64,64)
  PATH = "Graphics/Pictures/Menu/"

  def initialize(lobby_id, table_name)
    $game_temp.lobby_calling = false
    $game_temp.in_a_lobby = true
    pbGlobalFadeOut(1)
    @viewport = nil
    @sprites = {}
    @overlay = nil
    @disposed = false
    $table_name = table_name
    @lobby_id = lobby_id
    @discord_stupid_fucking_id_bullshit = Base64.encode64($table_name.to_s)
    @arena_id = table_name[table_name.length-2..table_name.length-1].to_i
    @visibility = table_name[table_name.length-4].to_i
    @lobby_members = []
    @ret_method = 0
    $game_temp.ready = false
  end

  def pbStartScene
    pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).lobby_menu, AudioPack.get($PokemonGlobal.audio_pack)), 90, 100)
    Discord.update_activity({
      :large_image => "icon_big",
      :large_image_text => "Pivot",
      :details => "In a #{@visibility == 0 ? "Public Lobby | #{Arena.get(@arena_id).name}" : "Lobby"}",
      :state => "#{@visibility == 0 ? "Lobby ID: #{$table_name}" : "Private Lobby"}",
      :party_id => $table_name.to_s,
      :party_size => 1,
      :party_max => 4,
      :join_secret => @discord_stupid_fucking_id_bullshit
    })
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    @undertitle = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @undertitle.z = 99998
    pbSetSystemFont(@overlay.bitmap)
    pbSetSmallFont(@undertitle.bitmap)
    @sprites["bg"] = ChangelingSprite.new(0,0,@viewport)
    MainMenu::ANIMATED_BGS[MainMenu::BG_GRAPHIC]["frames"].times do |i|
      @sprites["bg"].addBitmap(i, "Graphics/Pictures/Animated Backgrounds/#{MainMenu::BG_GRAPHIC}_#{i}")
    end
    @sprites["bg"].changeBitmap(0)
    @sprites["top_bar"] = IconSprite.new(0,0,@viewport)
    @sprites["top_bar"].setBitmap(PATH+"topbar")
    @sprites["name"] = ButtonSprite.new(self,"",MainMenu::PATH+"empty",MainMenu::PATH+"empty",proc{ },0,Graphics.width-174, 0,@viewport, nil, proc{pbAnnounce(:fools_rename) if $april_fools}, "#{$player.name} Lv. #{$player.level}")
    @sprites["name"].setTextOffset(0,4)
    @sprites["name"].text_align = 1
    @sprites["stats"] = IconSprite.new(688,88,@viewport)
    @sprites["stats"].setBitmap(PATH+"stats")
    buttonPath = PATH + "/Banners/default/banner"
    4.times do |i|
      suffix = (i==3 ? "_last" : "")
      @sprites["lobby#{i}"] = ButtonSprite.new(self,"",buttonPath+suffix,buttonPath+"_highlight#{suffix}",proc{ clickPlayer(i) },0,690,158+i*78,@viewport,nil,proc{pbAnnounce(:fools_kick) if $april_fools && $Client_id == 0})
    end
    @sprites["arena_#{@arena_id}"] = ButtonSprite.new(self,Arena.get(@arena_id).name,ArenaSelection::PATH+"arena_#{@arena_id}_sel",ArenaSelection::PATH+"arena_#{@arena_id}_sel",proc{  },0,342,88,@viewport,ArenaSelection::PATH+"arena_#{@arena_id}_sel",proc{pbAnnounce(("fools_"+Arena.get(@arena_id).name.downcase.gsub(" ","_")).to_sym) if $april_fools})
    @sprites["arena_#{@arena_id}"].setTextOffset(0,16)
    @sprites["arena_#{@arena_id}"].hoverable = false
    @sprites["leave"] = ButtonSprite.new(self,"Leave",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE; leaveRoom},0,32,476,@viewport,nil,proc{pbAnnounce(:fools_leave) if $april_fools})
    @sprites["leave"].setTextOffset(0,24)
    @sprites["start"] = ButtonSprite.new(self,"Start",PATH+"play_button",PATH+"play_button_highlight",proc{next unless $Client_id == 0; pbPlayDecisionSE; startGame},0,32,476,@viewport,nil,proc{pbAnnounce(:fools_start) if $april_fools})
    @sprites["start"].visible = false
    @sprites["start"].setTextOffset(0,24)
    @sprites["stocks"] = ButtonSprite.new(self,"Stocks: #{$game_temp.max_stocks}",PATH+"button",PATH+"button_highlight",proc{next unless $Client_id == 0; pbPlayDecisionSE; changeStocks(true)},0,32,88,@viewport,nil,proc{pbAnnounce(("fools_stocks_"+$game_temp.max_stocks.to_s).to_sym) if $april_fools})
    @sprites["stocks"].visible = false
    @sprites["stocks"].setTextOffset(0,24)
    @sprites["time"] = ButtonSprite.new(self,"Time: #{$game_temp.match_time_formatted}",PATH+"button",PATH+"button_highlight",proc{next unless $Client_id == 0; pbPlayDecisionSE; changeMatchTime(true)},0,32,172,@viewport,nil,proc{pbAnnounce(("fools_time_"+$game_temp.match_time.round.to_s).to_sym) if $april_fools})
    @sprites["time"].visible = false
    @sprites["time"].setTextOffset(0,24)
    @sprites["host_crown"] = IconSprite.new(0,0,@viewport)
    @sprites["host_crown"].setBitmap(PATH+"crown")
    @sprites["host_crown"].visible = false
    @sprites["host_crown"].z = 99999
  end

  def pbUpdate
    return if @disposed
    leaveRoom if Input.press?(Input::BACK) && !$game_temp.message_window_showing
    textpos = []
    smalltextpos = []
    @overlay.bitmap.clear
    @undertitle.bitmap.clear
    @sprites["leave"].y = ($Client_id == 0 ? 392 : 476) unless @lobby_members.count == 1
    @sprites["stocks"].text = "Stocks: #{$game_temp.max_stocks}"
    @sprites["time"].text = "Time: #{$game_temp.match_time_formatted}"
    # Draw top bar info
    @sprites["name"].subtitle = "#{$player.name} Lv. #{$player.level}"
    #textpos.push(["#{$player.name} Lv. #{$player.level}",Graphics.width-16, 16, 1, BASE_COLOR, SHADOW_COLOR])
    @overlay.bitmap.fill_rect(Graphics.width-112,46,96,8,MainMenu::EXP_EMPTY)
    part = ($player.exp.to_f-$player.exp_to_current_level.to_f)/($player.total_exp_to_next_level.to_f-$player.exp_to_current_level.to_f)
    @overlay.bitmap.fill_rect(Graphics.width-112,46,part*96,8,MainMenu::EXP_FULL)
    # Draw lobby info
    textpos.push(["Lobby (ID: #{$table_name})",Graphics.width/2, 24, 2, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
    textpos.push(["#{@lobby_members[0][2]}'s Lobby (#{[@lobby_members.count, 4].min}/4)",848, 102, 2, BASE_COLOR, SHADOW_COLOR]) unless !@lobby_members[0]
    smalltextpos.push(["(#{[(4-@lobby_members.count).abs, 0].max} spectating)",848, 132, 2, Color.new(197,198,198), SHADOW_COLOR]) if @lobby_members[0] != nil && @lobby_members.count > 4
    4.times do |i|
      name = (i>@lobby_members.length-1) ? "" : "#{@lobby_members[i][2]}"
      lvl = (i>@lobby_members.length-1) ? "" : "Lv. #{@lobby_members[i][3]}"
      banner = (i>@lobby_members.length-1) ? "default" : @lobby_members[i][4]
      banner = "default" if banner == nil
      colors = getBannerColors(banner)
      suffix = (i==3 ? "_last" : "")
      if name == "" && (@sprites["lobby#{i}"].bitmaps[0] != PATH+"/Banners/default/banner#{suffix}")
        @sprites["lobby#{i}"].bitmaps = [PATH+"/Banners/default/banner#{suffix}",PATH+"/Banners/default/banner_highlight#{suffix}"]
        @sprites["lobby#{i}"].hoverable = false
      elsif name != "" && (@sprites["lobby#{i}"].bitmaps[0] == PATH+"/Banners/default/banner#{suffix}")
        @sprites["lobby#{i}"].bitmaps = [PATH+"/Banners/#{banner}/banner#{suffix}",PATH+"/Banners/#{banner}/banner_highlight#{suffix}"]
        @sprites["lobby#{i}"].hoverable = true
      end
      name_x = 848
      if @lobby_members[i] && @lobby_members[i][0] == 1
        if @sprites["host_crown"].visible == false
          @sprites["host_crown"].x = 848 - (((@overlay.bitmap.text_size(name).width/2).round * 2)/2).round - 15
          @sprites["host_crown"].y = 180+i*78
          @sprites["host_crown"].visible = true
          @sprites["host_crown"].z = 99999
        end
        name_x = 848 + 13
      end
      textpos.push([name, name_x,176+i*78, 2, colors["name_color"], colors["name_shadow"]])
      smalltextpos.push([lvl, 848,204+i*78, 2, colors["level_color"], colors["level_shadow"]])
    end
    pbDrawTextPositions(@overlay.bitmap, textpos)
    pbDrawTextPositions(@undertitle.bitmap, smalltextpos)
    Graphics.update
    Input.update
    pbUpdateSpriteHash(@sprites)
    @sprites["start"].visible = $Client_id == 0 unless @lobby_members.count == 1
    @sprites["stocks"].visible = $Client_id == 0 unless @lobby_members.count == 1
    @sprites["time"].visible = $Client_id == 0 unless @lobby_members.count == 1
    pbGlobalFadeIn if $overlay.faded_out? && !@disposed
  end

  def set_lobby_members(lobby_members)
    # Sort room members by ID and set client ID to the index of the player in the array
    lobby_members.sort!{ |a,b| a[0] <=> b[0] }
    lobby_members.each_with_index { |member,i| next if member[1] != $player.id; $Client_id = i }
    if @lobby_members != lobby_members
      @lobby_members = lobby_members
      #echoln "Lobby members: #{@lobby_members}"
      return unless @lobby_members.include?($player.id)
      # Update Discord Rich Presence
      Discord.update_activity({
        :large_image => "icon_big",
        :large_image_text => "Pivot",
        :details => "In a #{@visibility == 0 ? "Public Lobby | #{Arena.get(@arena_id).name}" : "Lobby"}",
        :state => "#{@visibility == 0 ? "Lobby ID: #{$table_name}" : "Private Lobby"}",
        :party_id => $table_name.to_s,
        :party_size => @lobby_members.count,
        :party_max => 4,
        :join_secret => @discord_stupid_fucking_id_bullshit
      })
    end
  end

  def ret_method; @ret_method; end

  def startGame
    if @lobby_members.count == 1
      pbAnnounce(:fools_at_least_2) if $april_fools
      pbMessage(_INTL("You need at least 2 players to start a match."))
    else
      @ret_method = 2
      pbWebRequest({:ROOM_ID => $table_name, :ROOM_METHOD => "Delete"})
    end
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
    pbAnnounce(("fools_time_"+$game_temp.match_time.round.to_s).to_sym) if $april_fools
  end

  def clickPlayer(index)
    return if index > @lobby_members.length-1
    if index == $Client_id
      return
    else
      commands = []
      commands.push(_INTL("Send Friend Request")) unless $player.friends.include?(Friend.new(@lobby_members[index][1]))
      commands.push(_INTL("Kick")) if $Client_id == 0
      return if commands.length == 0
      commands.push(_INTL("Cancel"))
      pbPlayDecisionSE
      command = pbShowCommandsWithHelp(nil,commands,("What would you like to do?"),-1)
      case command
      when 0
        pbSendFriendRequest(@lobby_members[index][1])
      when 1
        pbAnnounce(:fools_are_you_sure_kick) if $april_fools
        if pbConfirmMessage(_INTL("Are you sure you want to kick this player?"))
          id = @lobby_members[index][1]
          pbWebRequest({:ROOM_ID => $table_name, :ROOM_METHOD => "Leave", :PLAYER_ID => id})
        end
      end
    end
  end

  def leaveRoom
    pbAnnounce(:fools_are_you_sure_leave) if $april_fools
    if pbConfirmMessage(_INTL("Are you sure you want to leave the room?"))
      @ret_method = 1
      pbPlayCloseMenuSE
      pbWebRequest({:ROOM_ID => $table_name, :ROOM_METHOD => "Leave"})
      pbWebRequest({:ROOM_ID => $table_name, :ROOM_METHOD => "Delete"}) if $Client_id == 0
      $game_temp.main_menu_calling = true
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
    pbAnnounce(("fools_stocks_"+$game_temp.max_stocks.to_s).to_sym) if $april_fools
  end

  def pbEndScene
    pbGlobalFadeOut(24, ($game_temp.main_menu_calling ? false : true))
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
    $game_temp.in_a_lobby = false
  end
end

at_exit {
  if $game_temp.in_a_lobby
    pbWebRequest({:ROOM_ID => $table_name, :ROOM_METHOD => "Leave"})
    pbWebRequest({:ROOM_ID => $table_name, :ROOM_METHOD => "Delete"}) if $Client_id == 0
    $game_temp.in_a_lobby = false
  end
}