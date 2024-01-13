class MainMenu
  BASE_COLOR = Color.new(254,255,255)
  SHADOW_COLOR = Color.new(64,64,64)#202,87,14)
  EXP_EMPTY = Color.new(25,13,76)
  EXP_FULL = Color.new(0,128,255)
  PATH = "Graphics/Pictures/Menu/"
  SCREEN_TITLES = ["Main Menu", "Play", "Multiplayer", "Collection", "Profile", "Pivot Pass"]
  ANIMATED_BGS = {
    "oasis" => {
      "frames" => 2,
      "frame_time" => 25
    },
    "factory" => {
      "frames" => 8,
      "frame_time" => 4
    },
    "fairyland" => {
      "frames" => 4,
      "frame_time" => 15
    }
  }
  BG_GRAPHIC = "fairyland"
  
  def initialize
    $game_temp.main_menu_calling = false
    $game_temp.training = false
    $game_temp.in_a_match = false
    $game_temp.in_a_lobby = false
    $game_temp.end_match_called = false
    $game_temp.match_ended = false
    pbGlobalFadeOut(1, false)
    checkVersion
    @viewport = nil
    @collection_character_viewport = nil
    @collectible_overlay_viewport = nil
    @collectible_hotkey_viewport = nil
    @friends_list_viewport = nil
    @pivotpass_viewport = nil
    @pivotpass_levels = 100
    @scrolling_anim = true
    @sprites = {}
    @overlay = nil
    @overlay_small = nil
    @overlay_timer = nil
    @overlay_pp = nil
    @disposed = false
    self.screen = $game_temp.main_menu_screen
    $game_temp.main_menu_screen = 0
    @lobby_page = 0
    @lobbies = []
    @lobbydata = []
    @should_show_loading = false
    @refresh_lobby = true
    @mouse_last_x = Mouse.x
    @mouse_last_y = Mouse.y
    @collection_generic = []
    @collectible_overlay = false
    @collectible_hotkey_select = false
		@collection_hash = {}
    @characters_sorted = []
		@selected_collectible_type = nil
		@selected_collectible = nil
    $game_switches[59] = false
    (78..80).each { |i| $game_switches[i] = true}
    $player.checkUnlocked
    get_account_from_database
    check_pp_rewards
    check_day_change
    $game_temp.friends_online = $player.friends.any? { |friend| friend.online? }
    pbStartScene
  end
  
  def pbStartScene
    Discord.update_activity({
      :large_image => "icon_big",
      :large_image_text => "Pivot",
      :details => "In the Main Menu",
    })
    pbSetWindowText("Pivot")
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    @overlay_small = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay_small.z = 99999
    @overlay_timer = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay_timer.z = 99999
    pbSetSystemFont(@overlay.bitmap)
    pbSetSmallFont(@overlay_small.bitmap)
    pbSetSmallFont(@overlay_timer.bitmap)
    @sprites["bg"] = ChangelingSprite.new(0,0,@viewport)
    ANIMATED_BGS[BG_GRAPHIC]["frames"].times do |i|
      @sprites["bg"].addBitmap(i, "Graphics/Pictures/Animated Backgrounds/#{BG_GRAPHIC}_#{i}")
    end
    @sprites["bg"].changeBitmap(0)
    @sprites["top_bar"] = IconSprite.new(0,0,@viewport)
    @sprites["top_bar"].setBitmap(PATH+"topbar")
    @sprites["profile"] = ButtonSprite.new(self,"",PATH+"profile",PATH+"profile_highlight",proc{pbPlayDecisionSE; pbGlobalFadeOut; self.screen=4;},0,Graphics.width-76, 2,@viewport, nil, proc{pbAnnounce(:fools_profile) if $april_fools})
    @sprites["profile"].setTooltip("Profile")
    @sprites["friend_requests"] = ButtonSprite.new(self, "Friend Requests", PATH+"button", PATH+"button_highlight", proc{pbPlayDecisionSE; pbAcceptFriendRequest}, 0, 404, 88, @viewport, nil, proc{pbAnnounce(:fools_friend_requests) if $april_fools})
    @sprites["friend_requests"].setTextOffset(0,24)
    @sprites["profile_notification"] = IconSprite.new(Graphics.width-76, 2,@viewport)
    @sprites["profile_notification"].setBitmap(PATH+"profile_notification_blue")
    @sprites["profile_notification"].setBitmap(PATH+"profile_notification_green") if $game_temp.friends_online
    @sprites["profile_notification"].setBitmap(PATH+"profile_notification_blue") if $player.friend_requests.length > 0
    @sprites["profile_notification"].visible = $player.friend_requests.length > 0 || $game_temp.friends_online
    @sprites["settings"] = ButtonSprite.new(self,"",PATH+"settings",PATH+"settings_highlight",proc{openOptions},0,916,492,@viewport,nil,proc{pbAnnounce(:fools_options) if $april_fools})
		@sprites["settings"].setTooltip("Options")
    @sprites["discord"] = ButtonSprite.new(self,"",PATH+"discord",PATH+"discord_highlight",proc{pbPlayDecisionSE; System.launch("https://discord.com/invite/gpVJdSfJan")},0,828,492,@viewport,nil,proc{pbAnnounce(:fools_discord) if $april_fools})
    @sprites["discord"].setTooltip("Join the official Pivot Discord server!", "Discord")
    @sprites["logout"] = ButtonSprite.new(self,"Logout",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE; pbLogout},0,712,496,@viewport,nil,proc{ })
    @sprites["logout"].setTextOffset(0,24)
		@sprites["back"] = ButtonSprite.new(self,"",PATH+"back",PATH+"back_highlight",proc{self.goBackOne},0,24,80,@viewport,nil,proc{pbAnnounce(:fools_back) if $april_fools})
    @sprites["back"].setTooltip("Go Back")
    @sprites["stats"] = IconSprite.new(688,88,@viewport)
    @sprites["stats"].setBitmap(PATH+"stats")
    @sprites["profile_stats"] = IconSprite.new(684,88,@viewport)
    @sprites["profile_stats"].setBitmap(PATH+"profile_stats")
    @sprites["name"] = ButtonSprite.new(self,"",PATH+"empty",PATH+"empty",proc{pbPlayDecisionSE; pbChangePlayerName},0,684, 84,@viewport, nil, proc{pbAnnounce(:fools_rename) if $april_fools}, "#{$player.name} Lv. #{$player.level}")
    @sprites["name"].setTextOffset(0,6)
    @sprites["name"].text_align = 2
    # Main Menu
    @sprites["challenges"] = IconSprite.new(688,88,@viewport)
    @sprites["challenges"].setBitmap(PATH+"challenge_list")
    3.times do |i|
      @sprites["challenge_#{i}"] = IconSprite.new(696,208+i*90,@viewport)
      @sprites["challenge_#{i}"].setBitmap(PATH+"challenge_progress")
    end
    @sprites["clock"] = IconSprite.new(806,428,@viewport)
    @sprites["clock"].setBitmap(PATH+"clock")
    @sprites["pivot_pass"] = ButtonSprite.new(self,"Pivot Pass",PATH+"gold_button",PATH+"gold_button_highlight",proc{pbPlayDecisionSE; pbGlobalFadeOut; self.screen=5;},0,32,308,@viewport,nil,proc{},"Season 1")
    @sprites["pivot_pass"].setTextOffset(0,24)
    @sprites["pivot_pass_notification"] = IconSprite.new(32,308,@viewport)
    @sprites["pivot_pass_notification"].setBitmap(PATH+"notification_circle")
    @sprites["collection"] = ButtonSprite.new(self,"Collection",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE; pbGlobalFadeOut; self.screen=3;},0,32,392,@viewport,nil,proc{})
    @sprites["collection"].setTextOffset(0,24)
    @sprites["play"] = ButtonSprite.new(self,"Play",PATH+"play_button",PATH+"play_button_highlight",proc{pbPlayDecisionSE; pbGlobalFadeOut; self.screen=1;},0,32,476,@viewport,nil,proc{pbAnnounce(:fools_play) if $april_fools})
    @sprites["play"].setTextOffset(0,24)
    # Play Menu
    @sprites["solo"] = ButtonSprite.new(self,"Singleplayer (vs. CPU)",PATH+"singleplayer_button",PATH+"singleplayer_button_highlight",proc{pbPlayDecisionSE; $game_temp.training = false; $game_temp.arena_select_calling = true; @disposed = true; $game_temp.solo_mode = true},0,12,166,@viewport, nil)
    @sprites["solo"].setTextOffset(0,24)
    @sprites["multiplayer"] = ButtonSprite.new(self,"Multiplayer",PATH+"multiplayer_button",PATH+"multiplayer_button_highlight",proc{pbPlayDecisionSE; pbGlobalFadeOut; self.screen=2;},0,352,166,@viewport, nil)
    @sprites["multiplayer"].setTextOffset(0,24)
    @sprites["training"] = ButtonSprite.new(self,"Training",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE; $game_temp.training = true; setArena(:TRAININGROOM); $game_temp.character_select_calling = true; @disposed = true},0,720,192,@viewport,nil,proc{pbAnnounce(:fools_training) if $april_fools})
    @sprites["training"].setTextOffset(0,24)
    @sprites["tutorial"] = ButtonSprite.new(self, "Replay Tutorial",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; pbReplayTutorial},0,720,276,@viewport, nil, proc{pbAnnounce(:fools_replay_tutorial) if $april_fools})
    @sprites["tutorial"].setTextOffset(0,24)
    @sprites["coming_soon"] = ButtonSprite.new(self,"Coming Soon",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE},0,720,360,@viewport,PATH+"button_disabled",proc{})
    @sprites["coming_soon"].setTextOffset(0,24)
    @sprites["coming_soon"].enabled = false
    # Multiplayer Menu
    @sprites["join"] = ButtonSprite.new(self,"Enter Code",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE; enterCode},0,32,392,@viewport, nil, proc{pbAnnounce(:fools_enter_code) if $april_fools})
    @sprites["join"].setTextOffset(0,24)
    @sprites["create"] = ButtonSprite.new(self,"Create Lobby",PATH+"button",PATH+"button_highlight",proc{pbPlayDecisionSE; $game_temp.training = false; $game_temp.arena_select_calling = true; @disposed = true;},0,32,476,@viewport,nil,proc{pbAnnounce(:fools_create_lobby) if $april_fools})
    @sprites["create"].setTextOffset(0,24)
    4.times do |i|
      suffix = (i==3 ? "_last" : "")
      @sprites["lobby#{i}"] = ButtonSprite.new(self,"",PATH+"lobby_button#{suffix}",PATH+"lobby_button_highlight#{suffix}",proc{pbPlayDecisionSE; pbBGMStop(1.0); pbGlobalFadeOut; @disposed = true; pbJoinLobby(@lobbies[i+@lobby_page*4].to_i);},0,690,158+i*78,@viewport)
    end
    @sprites["arrow_up"] = ButtonSprite.new(self,"",PATH+"arrow_up",PATH+"arrow_up_highlight",proc{self.lobby_page-=1},0,624,88,@viewport)
    @sprites["arrow_down"] = ButtonSprite.new(self,"",PATH+"arrow_down",PATH+"arrow_down_highlight",proc{self.lobby_page+=1},0,624,420,@viewport)
    @sprites["refresh"] = ButtonSprite.new(self,"",PATH+"refresh",PATH+"refresh_highlight",proc{self.refresh_lobby=true},0,962,96,@viewport,nil,proc{pbAnnounce(:fools_refresh) if $april_fools})
    # Friends List
    @sprites["friends_list_bg"] = IconSprite.new(280,154,@viewport)
    @sprites["friends_list_bg"].setBitmap(PATH+"friends_list")
    @friends_list_viewport = Viewport.new(282,224,316,312)
    @friends_list_viewport.z = 99999
    @friend_list_scroll_position = 0
    @friend_list_scroll_capacity = ($player.friends.length <= 0) ? 1 : ($player.friends.length-4)*78
    @friend_list_scroll_torque = 0
    $player.friends.each_with_index do |friend, i|
      banner = "default"
      banner = Collectible.get(friend.equipped_collectibles[:banner]).banner unless friend.equipped_collectibles == nil
      @sprites["friend_#{i}"] = ButtonSprite.new(self,"#{friend.name}",PATH+"/Banners/#{banner}/banner",PATH+"/Banners/#{banner}/banner_highlight",proc{pbPlayDecisionSE;},0,0,i*78+@friend_list_scroll_position,@friends_list_viewport, nil, nil, "Lv. #{friend.level}")
      colors = getBannerColors(banner)
      @sprites["friend_#{i}"].setTextOffset(0,28)
      @sprites["friend_#{i}"].setTextColor(colors["name_color"], colors["name_shadow"])
      @sprites["friend_#{i}"].setSubtitleColor(colors["level_color"], colors["level_shadow"])
      #@sprites["friend_#{i}"].setTooltip("Online", "#{friend.name} Lvl. #{friend.level}")
    end
    @sprites["friends_list_overlay"] = IconSprite.new(-2,-70,@friends_list_viewport)
    @sprites["friends_list_overlay"].setBitmap(PATH+"friends_list_overlay")
    # Collection
    @collection_character_viewport = Viewport.new(242-90,140,720,94)
    @collection_character_viewport.z = 99999
    @collection_character_scroll_position = 0
    @collection_generic_viewport = Viewport.new(242-90,288,720,106)
    @collection_generic_viewport.z = 99999
    @collection_generic_scroll_position = 0
    @sprites["collection_bg"] = IconSprite.new(240-90,92,@viewport)
    @sprites["collection_bg"].setBitmap(PATH+"collectibles")
    i = 0
    characters_unsorted = []
    Character.each do |character|
      next unless character.playable && !character.is_evolution
      characters_unsorted.push(character)
    end
    @characters_sorted = characters_unsorted.sort { |a,b| $player.unlocked_characters.include?(a.internal) ? -1*characters_unsorted.find_index(a) : characters_unsorted.length - characters_unsorted.find_index(a) }
    @characters_sorted.each do |character|
      default_graphic = "Graphics/Pictures/Character Selection/#{character.internal}/default"
      selected_graphic = "Graphics/Pictures/Character Selection/#{character.internal}/selected"
      disabled_graphic = "Graphics/Pictures/Character Selection/#{character.internal}/disabled"
      @sprites["character_#{i}"] = ButtonSprite.new(self,"",default_graphic,selected_graphic,proc{ previewCollectible("skin_#{character.internal}".to_sym) },0,i*100+@collection_character_scroll_position,0,@collection_character_viewport,disabled_graphic,proc{})
      @sprites["character_#{i}"].enabled = $player.unlocked_characters.include?(character.internal)
			@sprites["character_#{i}"].setTooltip("Equipped: #{$player.equipped_skin(character)}", character.name)
      i += 1
    end
    [:audiopack, :beam, :banner, :loadingscreen, :emote].each_with_index do |collectible, i|
      case collectible
			when :audiopack then type_name = "Audio Pack"
			when :beam then type_name = "Spawn Beam"
			when :banner then type_name = "Player Banner"
			when :loadingscreen then type_name = "Loading Screen"
      when :emote then type_name = "Emote"
			end
      @sprites["#{collectible}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ previewCollectible(collectible) },0,286+i*80,448,@viewport, nil, proc{})
      @sprites["#{collectible}_button_overlay"] = IconSprite.new(@sprites["#{collectible}_button"].x+4,@sprites["#{collectible}_button"].y+4,@viewport)
      if collectible == :emote
        type_desc = "Equipped: " + $player.equipped_emotes
        collectible_graphic = (type_desc != "None") ? Collectible.get($player.equipped_collectibles[:emote].values.find { |e| !e.nil? && e != :emote_NONE }).internal : :emote_NONE
        collectible_graphic = :emote_NONE if collectible_graphic.nil? || collectible_graphic == :skin_ZUBAT_default
      else
        collectible_graphic = Collectible.get($player.equipped_collectibles[collectible]).internal
        type_desc = "Equipped: #{Collectible.get($player.equipped_collectibles[collectible]).name.gsub!("#{type_name} - ","")}"
      end
      @sprites["#{collectible}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible_graphic}")
			@sprites["#{collectible}_button"].setTooltip(type_desc, type_name)
    end
    @collection_character_scroll_capacity = (i-7)*100
    @collection_character_scroll_torque = 0
    i = 0
    $player.collectibles.each do |c|
      collectible = Collectible.get(c)
      next unless collectible.type == :generic
      @collection_generic.push(collectible.internal)
      @sprites["#{collectible.internal}_#{i}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ collectible.use_proc.call },0,4+i*80+@collection_generic_scroll_position,0,@collection_generic_viewport, nil, proc{})
      @sprites["#{collectible.internal}_#{i}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_#{i}_button"].x+4,@sprites["#{collectible.internal}_#{i}_button"].y+4,@collection_generic_viewport)
      @sprites["#{collectible.internal}_#{i}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
			@sprites["#{collectible.internal}_#{i}_button"].setTooltip(collectible.description, collectible.name)
      i += 1
    end
    @collection_generic_scroll_capacity = [(i-9)*80, 20].max
    @collection_generic_scroll_torque = 0
    @sprites["loading"] = IconSprite.new(Graphics.width-64,Graphics.height-64,@viewport)
    @sprites["loading"].bitmap = Bitmap.new("Graphics/Pictures/rotom_load.gif")
    @collectible_overlay_viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @collectible_overlay_viewport.z = 99999
    @sprites["collectible_overlay"] = IconSprite.new(0,0,@collectible_overlay_viewport)
    collectible_overlay_bitmap = Bitmap.new(Graphics.width,Graphics.height)
    collectible_overlay_bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,128))
    @sprites["collectible_overlay"].bitmap = collectible_overlay_bitmap
    @sprites["collectible_preview_background"] = IconSprite.new(692,132,@collectible_overlay_viewport)
    @sprites["collectible_preview_background"].setBitmap(PATH+"collectible_preview_background")
    @sprites["collectible_preview"] = IconSprite.new(624,48,@collectible_overlay_viewport)
    @sprites["collectible_preview"].setBitmap(PATH+"collectible_preview")
		@sprites["collectible_grid_bg"] = IconSprite.new(46,52,@collectible_overlay_viewport)
		@sprites["collectible_grid_bg"].setBitmap(PATH+"collection_grid_bg")
    @sprites["collectible_apply"] = ButtonSprite.new(self,"Equip",PATH+"play_button",PATH+"play_button_highlight",proc{equip_selected},0,32,476,@collectible_overlay_viewport,PATH+"button_disabled", proc{})
    @sprites["collectible_apply"].setTextOffset(0,24)
    @sprites["collectible_cancel"] = ButtonSprite.new(self,"Cancel",PATH+"button",PATH+"button_highlight",proc{pbPlayCloseMenuSE; cancel_collection_preview; @collectible_overlay = false},0,304,476,@collectible_overlay_viewport,nil,proc{})
    @sprites["collectible_cancel"].setTextOffset(0,24)
		@collection_hash = {}
    $player.collectibles.each do |c|
      collectible = Collectible.get(c)
			next if collectible.type == :generic || collectible.internal == :emote_NONE
			key = collectible.type == :skin ? "skin_#{collectible.character}".to_sym : collectible.type
      if collectible.type == :skin
        character = Character.get(collectible.character)
        next unless character.playable && !character.is_evolution
      end
			@collection_hash[key] = [] if @collection_hash[key].nil?
			@collection_hash[key].push(collectible)
    end
		grid_width = 6
		grid_position = [64,124]
		button_width = 80
		button_height = 110
		# Audio Packs
		i = 0
		x_position = grid_position[0]
		y_position = grid_position[1]
		@collection_hash[:audiopack].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ pbPlayDecisionSE; @selected_collectible = collectible; previewCollectible(collectible.type, collectible)  },0,x_position,y_position,@collectible_overlay_viewport, PATH+"button_collectible_selected", proc{})
			@sprites["#{collectible.internal}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_button"].x+4,@sprites["#{collectible.internal}_button"].y+4,@collectible_overlay_viewport)
			@sprites["#{collectible.internal}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
			@sprites["#{collectible.internal}_button"].setTooltip(collectible.description, collectible.name)
			i += 1
			x_position += button_width
			x_position = grid_position[0] if i%grid_width==0
			y_position += button_height if i%grid_width==0
		end
		# Beams
		i = 0
		x_position = grid_position[0]
		y_position = grid_position[1]
		@collection_hash[:beam].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ pbPlayDecisionSE; @selected_collectible = collectible; previewCollectible(collectible.type, collectible)  },0,x_position,y_position,@collectible_overlay_viewport, PATH+"button_collectible_selected", proc{})
			@sprites["#{collectible.internal}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_button"].x+4,@sprites["#{collectible.internal}_button"].y+4,@collectible_overlay_viewport)
			@sprites["#{collectible.internal}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
			@sprites["#{collectible.internal}_button"].setTooltip(collectible.description, collectible.name)
			i += 1
			x_position += button_width
			x_position = grid_position[0] if i%grid_width==0
			y_position += button_height if i%grid_width==0
		end
		# Banners
		i = 0
		x_position = grid_position[0]
		y_position = grid_position[1]
		@collection_hash[:banner].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ pbPlayDecisionSE; @selected_collectible = collectible; previewCollectible(collectible.type, collectible)  },0,x_position,y_position,@collectible_overlay_viewport, PATH+"button_collectible_selected", proc{})
			@sprites["#{collectible.internal}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_button"].x+4,@sprites["#{collectible.internal}_button"].y+4,@collectible_overlay_viewport)
			@sprites["#{collectible.internal}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
			@sprites["#{collectible.internal}_button"].setTooltip(collectible.description, collectible.name)
			i += 1
			x_position += button_width
			x_position = grid_position[0] if i%grid_width==0
			y_position += button_height if i%grid_width==0
		end
		# Loading Screens
		i = 0
		x_position = grid_position[0]
		y_position = grid_position[1]
		@collection_hash[:loadingscreen].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ pbPlayDecisionSE; @selected_collectible = collectible; previewCollectible(collectible.type, collectible)  },0,x_position,y_position,@collectible_overlay_viewport, PATH+"button_collectible_selected", proc{})
			@sprites["#{collectible.internal}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_button"].x+4,@sprites["#{collectible.internal}_button"].y+4,@collectible_overlay_viewport)
			@sprites["#{collectible.internal}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
			@sprites["#{collectible.internal}_button"].setTooltip(collectible.description, collectible.name)
			i += 1
			x_position += button_width
			x_position = grid_position[0] if i%grid_width==0
			y_position += button_height if i%grid_width==0
		end
    # Emotes
    i = 0
    x_position = grid_position[0]
    y_position = grid_position[1]
    @collection_hash[:emote].each_with_index do |collectible, i|
      @sprites["#{collectible.internal}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ pbPlayDecisionSE; @selected_collectible = collectible; previewCollectible(collectible.type, collectible)  },0,x_position,y_position,@collectible_overlay_viewport, PATH+"button_collectible_selected", proc{})
      @sprites["#{collectible.internal}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_button"].x+4,@sprites["#{collectible.internal}_button"].y+4,@collectible_overlay_viewport)
      @sprites["#{collectible.internal}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
      @sprites["#{collectible.internal}_button"].setTooltip(collectible.description, collectible.name)
      i += 1
      x_position += button_width
      x_position = grid_position[0] if i%grid_width==0
      y_position += button_height if i%grid_width==0
    end
		# Skins
		@collection_hash.keys.each do |key|
			next if key == :audiopack || key == :beam || key == :banner || key == :loadingscreen || key == :emote
			i = 0
			x_position = grid_position[0]
			y_position = grid_position[1]
			@collection_hash[key].each_with_index do |collectible, i|
				@sprites["#{collectible.internal}_button"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",proc{ pbPlayDecisionSE; @selected_collectible = collectible; previewCollectible("skin_#{collectible.character.to_s}".to_sym, collectible)  },0,x_position,y_position,@collectible_overlay_viewport, PATH+"button_collectible_selected", proc{})
				@sprites["#{collectible.internal}_button_overlay"] = IconSprite.new(@sprites["#{collectible.internal}_button"].x+4,@sprites["#{collectible.internal}_button"].y+4,@collectible_overlay_viewport)
				@sprites["#{collectible.internal}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible.internal}")
				@sprites["#{collectible.internal}_button"].setTooltip(collectible.description, collectible.name)
				i += 1
				x_position += button_width
				x_position = grid_position[0] if i%grid_width==0
				y_position += button_height if i%grid_width==0
			end
		end
    @collectible_hotkey_viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @collectible_hotkey_viewport.z = 99999
    @sprites["collectible_hotkey_overlay"] = IconSprite.new(0,0,@collectible_hotkey_viewport)
    collectible_hotkey_bitmap = Bitmap.new(Graphics.width,Graphics.height)
    collectible_hotkey_bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(0,0,0,128))
    @sprites["collectible_hotkey_overlay"].bitmap = collectible_hotkey_bitmap
    @sprites["collectible_hotkey_cancel"] = ButtonSprite.new(self,"Cancel",PATH+"button",PATH+"button_highlight",proc{pbPlayCloseMenuSE; @collectible_hotkey_select = false},0,378,305,@collectible_hotkey_viewport,nil,proc{})
    @sprites["collectible_hotkey_cancel"].setTextOffset(0,24)
    # Choose which hotkey to equip the emote to
    #392
    #378
    # 195
    # 305
    $player.equipped_collectibles[:emote].values.each_with_index do |collectible, i|
      use_proc = proc{ pbPlayDecisionSE; $player.equipped_collectibles[:emote][i+1] = @selected_collectible; reset_collection_buttons; @collectible_hotkey_select = false;}
      @sprites["emote_#{i}"] = ButtonSprite.new(self,"",PATH+"button_collectible",PATH+"button_collectible_highlight",use_proc,0,392+i*80,195,@collectible_hotkey_viewport, nil, proc{}, "#{i+1}")
      @sprites["emote_#{i}_overlay"] = IconSprite.new(@sprites["emote_#{i}"].x+4,@sprites["emote_#{i}"].y+4,@collectible_hotkey_viewport)
      @sprites["emote_#{i}"].setTextOffset(-2,60)
      next if collectible == :emote_NONE
      @sprites["emote_#{i}_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{Collectible.get($player.equipped_collectibles[:emote][i+1]).internal}")
      @sprites["emote_#{i}"].setTooltip("Equipped: #{Collectible.get($player.equipped_collectibles[:emote][i+1]).name.gsub("Emote - ","")}", "Emote")
    end
    # PIVOT PASS
    mid_width = 140
    start_x = 28
    @pivotpass_viewport = Viewport.new(0,176,16 + (mid_width*$player.pivot_pass_rewards.length) + 18,242)
    @pivotpass_viewport.z = 99999
    @overlay_pp = BitmapSprite.new(Graphics.width,Graphics.height, @pivotpass_viewport)
    @overlay_pp.z = 99999
    pbSetSmallFont(@overlay_pp.bitmap)
    @pivotpass_scroll_position = 0
    @pivotpass_scroll_capacity = ($player.pivot_pass_rewards.length-7) * mid_width + 54
    @pivotpass_scroll_torque = 0
    @sprites["pivotpass_bg_start"] = IconSprite.new(start_x,0,@pivotpass_viewport)
    @sprites["pivotpass_bg_start"].setBitmap(PATH+"pivot_pass_bg_start")
    $player.pivot_pass_rewards.length.times do |i|
      x = start_x+16+i*mid_width
      @sprites["pivotpass_bg_mid_#{i}"] = IconSprite.new(x,0,@pivotpass_viewport)
      @sprites["pivotpass_bg_mid_#{i}"].setBitmap(PATH+"pivot_pass_bg_mid")
      @sprites["pivotpass_button_#{i}"] = ButtonSprite.new(self,"",PATH+"pivot_pass_button",PATH+"pivot_pass_button_highlight",proc{},0,x+48,58,@pivotpass_viewport, PATH+"pivot_pass_button_selected", proc{}, "#{(i+1)*(@pivotpass_levels/$player.pivot_pass_rewards.length)}")
      @sprites["pivotpass_button_#{i}"].setTextOffset(-2,60)
      @sprites["pivotpass_button_#{i}_overlay"] = IconSprite.new(@sprites["pivotpass_button_#{i}"].x+4,@sprites["pivotpass_button_#{i}"].y+4,@pivotpass_viewport) 
      @sprites["pivotpass_button_#{i}_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{$player.pivot_pass_rewards[i].collectible}")
    end
    @sprites["pivotpass_bg_end"] = IconSprite.new(16+mid_width*@pivotpass_levels,0,@pivotpass_viewport)
    @sprites["pivotpass_bg_end"].setBitmap(PATH+"pivot_pass_bg_end")
    @sprites["pivotpass_progress_start"] = IconSprite.new(start_x+2,168,@pivotpass_viewport)
    @sprites["pivotpass_progress_start"].setBitmap(PATH+"pivot_pass_progress_start")
    @pivotpass_levels.times do |i|
      x = start_x+14+i*28
      @sprites["pivotpass_progress_mid_#{i}"] = IconSprite.new(x,168,@pivotpass_viewport)
      @sprites["pivotpass_progress_mid_#{i}"].setBitmap(PATH+"pivot_pass_progress_mid")
    end
    @sprites["pivotpass_progress_end"] = IconSprite.new(start_x+14+14*@pivotpass_levels,168,@pivotpass_viewport)
    @sprites["pivotpass_progress_end"].setBitmap(PATH+"pivot_pass_progress_end")
    @sprites["pivotpass_progress_indicator"] = IconSprite.new(start_x,174,@pivotpass_viewport)
    @sprites["pivotpass_progress_indicator"].setBitmap(PATH+"pivot_pass_progress_indicator")
    #System.cls
    if $april_fools && rand(100) < 35
      pbBGMPlay("BR 31 Reception Desk 2", 80)
    else
      pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).main_menu, AudioPack.get($PokemonGlobal.audio_pack)), 80)
    end
    pbMain
  end
    
  def pbMain
    @frame = 0
    update_challenges
    loop do
      break if @disposed
      @sprites["bg"].changeBitmap(@frame % (ANIMATED_BGS[BG_GRAPHIC]["frames"]*ANIMATED_BGS[BG_GRAPHIC]["frame_time"])/ANIMATED_BGS[BG_GRAPHIC]["frame_time"]) if @sprites["bg"].currentKey != @frame % (ANIMATED_BGS[BG_GRAPHIC]["frames"]*ANIMATED_BGS[BG_GRAPHIC]["frame_time"])/ANIMATED_BGS[BG_GRAPHIC]["frame_time"]
      pbUpdate
      @delta_mouse_x = Mouse.x - @mouse_last_x
      @delta_mouse_y = Mouse.y - @mouse_last_y
      goBackOne if Input.trigger?(Input::BACK) && !$game_temp.message_window_showing
      textpos = []
      smalltextpos = []
      pptextpos = []
      @overlay.bitmap.clear
      @overlay_timer.bitmap.clear
      @overlay_pp.bitmap.clear
      # Visibility based on screen
      update_visibilty
      title = SCREEN_TITLES[@screen] || "Invalid"
      textpos.push([title,Graphics.width/2+48, 24, 1, BASE_COLOR, SHADOW_COLOR])
      if @screen == 0
        # Challenges
        textpos.push(["Daily Challenges",848, 108, 2, BASE_COLOR, SHADOW_COLOR])
        # Display time until midnight in hours and minutes
        time = Time.now
        time = Time.new(time.year, time.month, time.day, 0, 0, 0, time.utc_offset)
        time = time + 86400
        time = time - Time.now
        hours = time.to_i/3600
        minutes = (time.to_i/60)%60
        smalltextpos.push(["#{hours}h #{minutes}m",828, 428, 0, BASE_COLOR, SHADOW_COLOR])
=begin
        if @sprites["pivot_pass_notification"].visible
          smalltextpos.push(["1", 32, 308, 0, BASE_COLOR, SHADOW_COLOR])
        end
=end
      elsif @screen == 2 # Lobbies
        @should_show_loading = false if @sprites["loading"].bitmap.current_frame == 0
        textpos.push(["Lobbies",878, 102, 1, BASE_COLOR, SHADOW_COLOR])
        if @refresh_lobby
          showLoading
          @lobbies = pbWebRequest({:ROOM_METHOD => "List"}){ @sprites["loading"].update }.split("&^*#@")
          pbWebRequest({:ROOM_METHOD => "Clean"})
          @lobbies = [] if @lobbies[0] == "No rooms found"
          if $game_temp.latest_version != Settings::GAME_VERSION
            @lobbies = [] unless $DEBUG
          end
          @lobbydata = []
          newlobbies = []
          @lobbies.each do |lobby|
            lobby = lobby.chop[1..-1]
            visibility = lobby[lobby.length-4].to_i
            region = lobby[lobby.length-3].to_i
            map_id = lobby[lobby.length-2..lobby.length-1].to_i
            lobby_check = pbWebRequest({:ROOM_ID => lobby, :ROOM_METHOD => "Check"})
            next if (region == CableClub::HOSTS.length-1 && !$DEBUG)
            next if visibility == 1
            next if lobby_check == "Empty room"
            if lobby_check.include?('&^#')
              lobby_players = lobby_check.split('&^*#@')
              next if lobby_players.length >= 4
              newlobbies.push(lobby)
              @lobbydata.push([lobby_players[0].split('&^#')[2], lobby_players.length, region, map_id])
            end
          end
          @lobbies = newlobbies
          @refresh_lobby = false
        end
        4.times do |i|
          j = i+@lobby_page*4
          if j > @lobbies.length-1
            @sprites["lobby#{i}"].visible = false
          elsif @lobbydata[j]
            textpos.push(["#{@lobbydata[j][0]}'s Lobby",698,170+i*78, 0, BASE_COLOR, SHADOW_COLOR])
            textpos.push(["#{@lobbydata[j][1]}/4",998,170+i*78, 1, BASE_COLOR, SHADOW_COLOR])
            textpos.push([Arena.get(@lobbydata[j][3]).name,698,202+i*78, 0, Color.new(197,198,198), SHADOW_COLOR])
            textpos.push(["#{CableClub::HOSTS[@lobbydata[j][2]][:short_name]}",998,202+i*78, 1, Color.new(197,198,198), SHADOW_COLOR])
          end
        end
        if @lobbies.length < 1
          textpos.push(["No available lobbies...",698,166, 0, BASE_COLOR, SHADOW_COLOR])
        end
      elsif @screen == 3 # Collection
        textpos.push(["Characters", 604-90, 104, 2, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["General", 604-90, 248, 2, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Global", 604-90, 408, 2, BASE_COLOR, SHADOW_COLOR])
        if @collectible_overlay
        else
          textpos.push(["Empty...", 604-90, 332, 2, BASE_COLOR, SHADOW_COLOR]) if @collection_generic.length == 0
          if Mouse.hold_short?
            if Mouse.over?(@collection_character_viewport)
              @collection_character_scroll_position = (@collection_character_scroll_position + @delta_mouse_x).clamp(-@collection_character_scroll_capacity, 20)
              @collection_character_scroll_torque = @delta_mouse_x / 2
            elsif Mouse.over?(@collection_generic_viewport) && @collection_generic.length > 9
              @collection_generic_scroll_position = (@collection_generic_scroll_position + @delta_mouse_x).clamp(-@collection_generic_scroll_capacity-20, 20)
              @collection_generic_scroll_torque = @delta_mouse_x / 2
            end
          else
            # character scroll
            @collection_character_scroll_position = (@collection_character_scroll_position + @collection_character_scroll_torque).clamp(-@collection_character_scroll_capacity, 20)
            @collection_character_scroll_torque *= 0.8
            if @collection_character_scroll_position < -@collection_character_scroll_capacity+20
              @collection_character_scroll_position += 1
              @collection_character_scroll_torque = 0
            elsif @collection_character_scroll_position > 0
              @collection_character_scroll_position -= 1
              @collection_character_scroll_torque = 0
            end
            # generic scroll
            @collection_generic_scroll_position = (@collection_generic_scroll_position + @collection_generic_scroll_torque).clamp(-@collection_generic_scroll_capacity-20, 20)
            @collection_generic_scroll_torque *= 0.8
            if @collection_generic_scroll_position < -@collection_generic_scroll_capacity
              @collection_generic_scroll_position += 1
              @collection_generic_scroll_torque = 0
            elsif @collection_generic_scroll_position > 0
              @collection_generic_scroll_position -= 1
              @collection_generic_scroll_torque = 0
            end
          end
          @collection_character_scroll_position = (@collection_character_scroll_position.round/2).round*2
          @collection_generic_scroll_position = (@collection_generic_scroll_position.round/2).round*2
          @collection_generic_scroll_torque = 0 if @collection_generic_scroll_torque.abs < 0.1
          @collection_character_scroll_torque = 0 if @collection_character_scroll_torque.abs < 0.1
        end
      elsif @screen == 4 # Profile
        @sprites["name"].subtitle = "#{$player.name} Lv. #{$player.level}"
        #textpos.push(["#{$player.name} Lv. #{$player.level}",Graphics.width-16, 16, 1, BASE_COLOR, SHADOW_COLOR])
        @overlay.bitmap.fill_rect(796,130,96,8,EXP_EMPTY)
        part = ($player.exp.to_f-$player.exp_to_current_level.to_f)/($player.total_exp_to_next_level.to_f-$player.exp_to_current_level.to_f)
        @overlay.bitmap.fill_rect(796,130,part*96,8,EXP_FULL)
        # Stats
        #textpos.push(["Stats",878, 102, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Games won:",700, 174, 0, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Games lost:",700, 206, 0, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Total take downs:",700, 238, 0, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Total faints:",700, 270, 0, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Most played Pokémon:",700, 302, 0, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["Most take downs:",700, 366, 0, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["TD/F Ratio:",700, 398, 0, BASE_COLOR, SHADOW_COLOR])
        # Stats (variables)
        textpos.push(["#{$stats.games_won}",992, 174, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["#{$stats.games_lost}",992, 206, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["#{$stats.total_take_downs}",992, 238, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["#{$stats.total_faints}",992, 270, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["#{$stats.most_played_character[0]} (#{$stats.most_played_character[1]}x)",992, 334, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["#{$stats.takedown_record}",992, 366, 1, BASE_COLOR, SHADOW_COLOR])
        textpos.push(["#{$stats.tdf_ratio.round(3)}",992, 398, 1, BASE_COLOR, SHADOW_COLOR])
        if Mouse.hold_short?
          if Mouse.over?(@friends_list_viewport)
            @friend_list_scroll_position = (@friend_list_scroll_position + @delta_mouse_y).clamp(-@friend_list_scroll_capacity, 20)
            @friend_list_scroll_torque = @delta_mouse_y / 2
          end
        else
          # Friend list scroll
          @friend_list_scroll_position = (@friend_list_scroll_position + @friend_list_scroll_torque).clamp(-@friend_list_scroll_capacity, 20)
          @friend_list_scroll_torque *= 0.8
          if @friend_list_scroll_position < -@friend_list_scroll_capacity+20
            @friend_list_scroll_position += 1
            @friend_list_scroll_torque = 0
          elsif @friend_list_scroll_position > 0
            @friend_list_scroll_position -= 1
            @friend_list_scroll_torque = 0
          end
        end
        @friend_list_scroll_position = (@friend_list_scroll_position.round/2).round*2
        @friend_list_scroll_torque = 0 if @friend_list_scroll_torque.abs < 0.1

      elsif @screen == 5 # Pivot Pass
        dest_x = -((@pivotpass_scroll_capacity / @pivotpass_levels) * $player.pp_level).round
        if !(dest_x-20..dest_x+20).include?(@pivotpass_scroll_position)
          @pivotpass_scroll_position = ease_in_out(@pivotpass_scroll_position, dest_x, 0.12) if @scrolling_anim
        else
          @scrolling_anim = false
        end
        #textpos.push(["Characters", 604-90, 104, 2, BASE_COLOR, SHADOW_COLOR])
        pptextpos.push(["#{$player.pp_level}", @sprites["pivotpass_progress_indicator"].x+18, @sprites["pivotpass_progress_indicator"].y+40, 2, BASE_COLOR, SHADOW_COLOR])
        if Mouse.hold_short?
          if Mouse.over?(@pivotpass_viewport)
            @pivotpass_scroll_position = (@pivotpass_scroll_position + @delta_mouse_x).clamp(-@pivotpass_scroll_capacity, 20)
            @pivotpass_scroll_torque = @delta_mouse_x / 2
          end
        else
          # character scroll
          @pivotpass_scroll_position = (@pivotpass_scroll_position + @pivotpass_scroll_torque).clamp(-@pivotpass_scroll_capacity, 20)
          @pivotpass_scroll_torque *= 0.8
          if @pivotpass_scroll_position < -@pivotpass_scroll_capacity+20
            @pivotpass_scroll_position += 1
            @pivotpass_scroll_torque = 0
          elsif @pivotpass_scroll_position > 0
            @pivotpass_scroll_position -= 1
            @pivotpass_scroll_torque = 0
          end
        end
        @pivotpass_scroll_position = (@pivotpass_scroll_position.round/2).round*2
        @pivotpass_scroll_torque = 0 if @pivotpass_scroll_torque.abs < 0.1

      else
        
      end
      pbDrawTextPositions(@overlay.bitmap, textpos)
      pbDrawTextPositions(@overlay_timer.bitmap, smalltextpos)
      pbDrawTextPositions(@overlay_pp.bitmap, pptextpos)
      pbGlobalFadeIn(24, self) if $overlay.faded_out? && !@disposed
      $player.checkExp if @frame%5==0
      if frame%1800==0 # Every 30 seconds
        pbUpdateLastOnline($player.id)
      end
      @mouse_last_x = Mouse.x
      @mouse_last_y = Mouse.y
      @frame += 1
    end
    pbBGMStop(1.0)
    pbEndScene
  end
    
  def pbUpdate
    return if @disposed
    Graphics.update
    Input.update
    pbUpdateSpriteHash(@sprites)
  end

  def previewCollectible(collectible_type, collectible = nil)
    @collectible_overlay = true
    pbPlayDecisionSE
		@selected_collectible_type = collectible_type
    @selected_collectible = collectible.internal if collectible
    if @selected_collectible_type == :emote
      @selected_collectible = $player.equipped_collectibles[:emote].values.find { |e| !e.nil? && e != :emote_NONE } if !@selected_collectible
    else
		  @selected_collectible = $player.equipped_collectibles[@selected_collectible_type] if !@selected_collectible
		end
    #@sprites["collectible_preview_background"].setBitmap("Graphics/Pictures/Collectibles/Previews/#{Collectible.get(@selected_collectible).internal}")
    frame = @sprites["collectible_preview_background"].bitmap.current_frame
    @sprites["collectible_preview_background"].setBitmap("Graphics/Pictures/Collectibles/Previews/#{Collectible.get(@selected_collectible).internal}.gif")
    @sprites["collectible_preview_background"].bitmap.goto_and_play(frame) if @sprites["collectible_preview_background"].bitmap.animated?
		collectible = Collectible.get(@selected_collectible)
		if collectible.type == :audiopack
			pbBGMPlay(AudioPack.parse(AudioPack.get(collectible.audio_pack).main_menu, AudioPack.get(collectible.audio_pack)), 80)
		end
  end

	def equip_selected
    if @selected_collectible_type == :emote
      pbPlayDecisionSE
      #$player.equipped_collectibles[:emote][1] = @selected_collectible
      @collectible_hotkey_select = true
    else
      if Collectible.get(@selected_collectible).type == :skin
        c = Collectible.get(@selected_collectible)
        $player.equipped_collectibles["skin_#{c.character}".to_sym] = @selected_collectible
        character = Character.get(c.character)
        if character.evolution
          $player.equipped_collectibles["skin_#{character.evolution}".to_sym] = "skin_#{character.evolution}_#{c.skin}".to_sym
        end
        if Character.get(character.evolution).evolution
          $player.equipped_collectibles["skin_#{Character.get(character.evolution).evolution}".to_sym] = "skin_#{Character.get(character.evolution).evolution}_#{c.skin}".to_sym
        end
      else
        $player.equipped_collectibles[@selected_collectible_type] = @selected_collectible
      end
      pbPlayDecisionSE
		  reset_collection_buttons
		  collectible = Collectible.get(@selected_collectible)
		  if collectible.type == :audiopack
		  	pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).main_menu, AudioPack.get($PokemonGlobal.audio_pack)), 80)
		  end
      @selected_collectible = nil
      @collectible_overlay = false
      Game.save
    end
		#$player.equipped_collectibles[@selected_collectible_type] = @selected_collectible
	end

	def reset_collection_buttons
    # Reset the tooltip text for the collection buttons to the equipped collectibles
    [:audiopack, :beam, :banner, :loadingscreen, :emote].each_with_index do |collectible, i|
      case collectible
      when :audiopack then type_name = "Audio Pack"
      when :beam then type_name = "Spawn Beam"
      when :banner then type_name = "Player Banner"
      when :loadingscreen then type_name = "Loading Screen"
      when :emote then type_name = "Emote"
      end
      if collectible == :emote
        type_desc = "Equipped: " + $player.equipped_emotes
        collectible_graphic = (type_desc != "None") ? Collectible.get($player.equipped_collectibles[:emote].values.find { |e| !e.nil? && e != :emote_NONE }).internal : :emote_NONE
        collectible_graphic = :emote_NONE if collectible_graphic.nil? || collectible_graphic == :skin_ZUBAT_default
      else
        collectible_graphic = Collectible.get($player.equipped_collectibles[collectible]).internal
        type_desc = "Equipped: #{Collectible.get($player.equipped_collectibles[collectible]).name.gsub("#{type_name} - ","")}"
      end
      @sprites["#{collectible}_button_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{collectible_graphic}")
			@sprites["#{collectible}_button"].setTooltip(type_desc, type_name)
    end
    @characters_sorted.each_with_index do |character, i|
      @sprites["character_#{i}"].setTooltip("Equipped: #{$player.equipped_skin(character)}", character.name)
    end
    $player.equipped_collectibles[:emote].values.each_with_index do |collectible, i|
      @sprites["emote_#{i}"].setTooltip(Collectible.get(collectible).name) if collectible != :emote_NONE
      @sprites["emote_#{i}_overlay"].setBitmap("Graphics/Pictures/Collectibles/#{Collectible.get(collectible).internal}")
    end
    
	end

	def cancel_collection_preview
    reset_collection_buttons
		if @selected_collectible_type == :audiopack
			pbBGMPlay(AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).main_menu, AudioPack.get($PokemonGlobal.audio_pack)), 80)
		end
		@selected_collectible = nil
	end

  
  def goBackOne
    return if $game_temp.message_window_showing
    if @screen > 0 && @screen < 3
      pbPlayCloseMenuSE
      pbGlobalFadeOut
      @refresh_lobby = true
      self.screen -= 1
    elsif @screen == 3 || @screen == 4 || @screen == 5
      if @collectible_overlay
        pbPlayCloseMenuSE
        cancel_collection_preview
        @collectible_overlay = false
        @screen = 3
      elsif @collectible_hotkey_select
        pbPlayCloseMenuSE
        @collectible_hotkey_select = false
      else
        pbPlayCloseMenuSE
        pbGlobalFadeOut
        self.screen = 0
        Game.save
      end
    end
  end

  def update_visibilty
    @sprites["settings"].visible = @screen==0 || @screen==1 || @screen==2
    @sprites["training"].visible = @screen==1
    @sprites["tutorial"].visible = @screen==1
    @sprites["coming_soon"].visible = @screen==1
    @sprites["discord"].visible = @screen==0 || @screen==1 || @screen==2
    @sprites["collection"].visible = @screen==0
    @sprites["pivot_pass"].visible = @screen==0
    @sprites["pivot_pass_notification"].visible = false
    @sprites["play"].visible = @screen==0
    @sprites["solo"].visible = @screen==1
    @sprites["multiplayer"].visible = @screen==1
    @sprites["profile"].visible = @screen!=4
    @sprites["stats"].visible = @screen==2
    @sprites["profile_stats"].visible = @screen==4
    @sprites["friend_requests"].visible = @screen==4
    @sprites["name"].visible = @screen==4
    @sprites["profile_notification"]&.visible = $player.friend_requests.length > 0 || ($game_temp.friends_online && @screen!=4)
    @sprites["challenges"].visible = @screen==0
    3.times do |i|
      @sprites["challenge_#{i}"].visible = @screen==0
    end
    @sprites["clock"].visible = @screen==0
    @sprites["join"].visible = @screen==2
    @sprites["create"].visible = @screen==2
    @sprites["logout"].visible = @screen==4
    @sprites["back"].visible = @screen > 0
    @sprites["refresh"].visible = @screen==2
    @sprites["loading"].visible = @should_show_loading && @screen==2
    @sprites["arrow_up"].visible = @screen==2 && @lobby_page > 0
    @sprites["arrow_down"].visible = @screen==2 && @lobbies.length > 4 && @lobby_page < (@lobbies.length/4.0).ceil-1
    @sprites["collection_bg"].visible = @screen==3
    @sprites["back"].hoverable = !@collectible_overlay
    @sprites["profile"].hoverable = !@collectible_overlay
    @sprites["friends_list_bg"].visible = @screen==4
    $player.friends.each_with_index do |friend, i|
      next if !@sprites["friend_#{i}"] || !friend
      @sprites["friend_#{i}"].visible = @screen==4
      @sprites["friend_#{i}"].y = i*78+@friend_list_scroll_position
      @sprites["friend_#{i}"].hoverable = Mouse.over?(@friends_list_viewport)
    end
    @sprites["friends_list_overlay"].visible = @screen==4
    @sprites["collectible_preview_background"].visible = @screen==3 && @collectible_overlay
    @sprites["collectible_preview"].visible = @screen==3 && @collectible_overlay
		@sprites["collectible_grid_bg"].visible = @screen==3 && @collectible_overlay
    @sprites["collectible_apply"].visible = @screen==3 && @collectible_overlay
    if @collectible_overlay
      selected_is_equipped = false
      if @selected_collectible_type == :emote
        selected_is_equipped = $player.equipped_collectibles[:emote].values.include?(@selected_collectible)
      else
        selected_is_equipped = @selected_collectible == $player.equipped_collectibles[@selected_collectible_type]
      end
      if selected_is_equipped && !["Unequip", "Equipped"].include?(@sprites["collectible_apply"].text)
        @sprites["collectible_apply"].text = (@selected_collectible_type == :emote) ? "Unequip" : "Equipped"
        @sprites["collectible_apply"].click_proc = (@sprites["collectible_apply"].text == "Unequip") ? proc{ pbPlayDecisionSE; $player.equipped_collectibles[:emote][$player.equipped_collectibles[:emote].key(@selected_collectible)] = :emote_NONE; @collectible_overlay = false; reset_collection_buttons; @selected_collectible = nil} : proc{equip_selected}
        @sprites["collectible_apply"].enabled = @selected_collectible_type == :emote
      elsif !selected_is_equipped && @sprites["collectible_apply"].text != "Equip"
        @sprites["collectible_apply"].click_proc = proc{equip_selected}
        @sprites["collectible_apply"].text = "Equip"
        @sprites["collectible_apply"].enabled = true
      end
      @sprites["collectible_apply"].hoverable = !@collectible_hotkey_select
    end
    @sprites["collectible_cancel"].visible = @screen==3 && @collectible_overlay
    @sprites["collectible_cancel"].hoverable = !@collectible_hotkey_select
    [:audiopack, :beam, :banner, :loadingscreen, :emote].each_with_index do |collectible, i|
      @sprites["#{collectible}_button"].visible = @screen==3
      @sprites["#{collectible}_button_overlay"].visible = @screen==3
      @sprites["#{collectible}_button"].hoverable = !@collectible_overlay
    end
    i = 0
    Character.each do |character|
      next unless character.playable && !character.is_evolution
      @sprites["character_#{i}"].visible = @screen==3
      if @screen==3
        @sprites["character_#{i}"].x = i*100+@collection_character_scroll_position
        @sprites["character_#{i}"].hoverable = !@collectible_overlay && Mouse.over?(@collection_character_viewport)
      end
      i += 1
    end
    @collection_generic.each_with_index do |collectible, i|
      @sprites["#{collectible}_#{i}_button"].visible = @screen==3
      @sprites["#{collectible}_#{i}_button"].x = 4+i*80+@collection_generic_scroll_position
      @sprites["#{collectible}_#{i}_button"].hoverable = !@collectible_overlay && Mouse.over?(@collection_generic_viewport)
      @sprites["#{collectible}_#{i}_button_overlay"].visible = @screen==3
      @sprites["#{collectible}_#{i}_button_overlay"].x = 4+@sprites["#{collectible}_#{i}_button"].x
    end

    mid_width = @sprites["pivotpass_bg_mid_0"].bitmap.width || 140
    start_x = 28
    @sprites["pivotpass_bg_start"].visible = @screen==5
    @sprites["pivotpass_bg_start"].x = start_x+@pivotpass_scroll_position
    @sprites["pivotpass_bg_end"].visible = @screen==5
    @sprites["pivotpass_bg_end"].x = start_x+16+mid_width*$player.pivot_pass_rewards.length+@pivotpass_scroll_position
    $player.pivot_pass_rewards.length.times do |i|
      x = start_x+16+mid_width*(i)
      @sprites["pivotpass_bg_mid_#{i}"].visible = @screen==5
      @sprites["pivotpass_bg_mid_#{i}"].x = x+@pivotpass_scroll_position
      @sprites["pivotpass_button_#{i}"].visible = @screen==5
      @sprites["pivotpass_button_#{i}"].x = x+48+@pivotpass_scroll_position
      @sprites["pivotpass_button_#{i}"].enabled = (i+1)*(@pivotpass_levels/$player.pivot_pass_rewards.length) > $player.pp_level
      @sprites["pivotpass_button_#{i}_overlay"].visible = @screen==5
      @sprites["pivotpass_button_#{i}_overlay"].x = @sprites["pivotpass_button_#{i}"].x+4
    end
    @sprites["pivotpass_progress_start"].visible = @screen==5
    @sprites["pivotpass_progress_start"].x = start_x+2+@pivotpass_scroll_position
    @pivotpass_levels.times do |i|
      x = start_x+14+i*28
      @sprites["pivotpass_progress_mid_#{i}"].visible = @screen==5 && ((i+3) <= $player.pp_level || i+3 >= @pivotpass_levels && $player.pp_level >= @pivotpass_levels)
      @sprites["pivotpass_progress_mid_#{i}"].x = x+@pivotpass_scroll_position
    end
    @sprites["pivotpass_progress_end"].visible = @screen==5 && $player.pp_level >= @pivotpass_levels
    @sprites["pivotpass_progress_end"].x = start_x+14+28*@pivotpass_levels+@pivotpass_scroll_position
    @sprites["pivotpass_progress_indicator"].visible = @screen==5
    @sprites["pivotpass_progress_indicator"].x = [28*($player.pp_level-1), 28].max + @pivotpass_scroll_position

    @sprites["collectible_overlay"].visible = @collectible_overlay && @screen==3
    @sprites["collectible_hotkey_overlay"].visible = @collectible_hotkey_select && @collectible_overlay && @screen==3
    @sprites["collectible_hotkey_cancel"].visible = @collectible_hotkey_select && @collectible_overlay && @screen==3
    4.times do |i|
      @sprites["lobby#{i}"].visible = @screen==2
    end
		# Audio Packs
		@collection_hash[:audiopack].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :audiopack
			@sprites["#{collectible.internal}_button"].enabled = (@selected_collectible == collectible.internal) ? false : true
      @sprites["#{collectible.internal}_button"].hoverable = !@collectible_hotkey_select
			@sprites["#{collectible.internal}_button_overlay"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :audiopack
		end
		# Beams
		@collection_hash[:beam].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :beam
			@sprites["#{collectible.internal}_button"].enabled = @selected_collectible != collectible.internal
      @sprites["#{collectible.internal}_button"].hoverable = !@collectible_hotkey_select
			@sprites["#{collectible.internal}_button_overlay"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :beam
		end
		# Banners
		@collection_hash[:banner].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :banner
			@sprites["#{collectible.internal}_button"].enabled = @selected_collectible != collectible.internal
      @sprites["#{collectible.internal}_button"].hoverable = !@collectible_hotkey_select
			@sprites["#{collectible.internal}_button_overlay"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :banner
		end
		# Loading Screens
		@collection_hash[:loadingscreen].each_with_index do |collectible, i|
			@sprites["#{collectible.internal}_button"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :loadingscreen
			@sprites["#{collectible.internal}_button"].enabled = @selected_collectible != collectible.internal
      @sprites["#{collectible.internal}_button"].hoverable = !@collectible_hotkey_select
			@sprites["#{collectible.internal}_button_overlay"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :loadingscreen
		end
    # Emotes
    @collection_hash[:emote].each_with_index do |collectible, i|
      @sprites["#{collectible.internal}_button"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :emote
      @sprites["#{collectible.internal}_button"].hoverable = !@collectible_hotkey_select
      @sprites["#{collectible.internal}_button_overlay"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == :emote
    end
		# Skins
		@collection_hash.keys.each do |key|
			next if key == :audiopack || key == :beam || key == :banner || key == :loadingscreen
			@collection_hash[key].each_with_index do |collectible, i|
				@sprites["#{collectible.internal}_button"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == key
				@sprites["#{collectible.internal}_button"].enabled = @selected_collectible != collectible.internal
        @sprites["#{collectible.internal}_button"].hoverable = !@collectible_hotkey_select
				@sprites["#{collectible.internal}_button_overlay"].visible = @screen==3 && @collectible_overlay && @selected_collectible_type == key
			end
		end
    # Emote equip buttons
    $player.equipped_collectibles[:emote].values.each_with_index do |collectible, i|
      @sprites["emote_#{i}"].visible = @screen==3 && @collectible_overlay && @collectible_hotkey_select && @selected_collectible_type == :emote
      @sprites["emote_#{i}_overlay"].visible = @screen==3 && @collectible_overlay && @collectible_hotkey_select && @selected_collectible_type == :emote
    end
  end
  
  def openOptions
    return if $game_temp.message_window_showing
    pbPlayDecisionSE
    PokemonOptionScreen.new(PokemonOption_Scene.new).pbStartScreen
    @disposed = true if $game_temp.tutorial_calling
  end
  
  def enterCode
    pbAnnounce(:fools_enter_id) if $april_fools
    table_name = pbMessageFreeText("Enter the ID for the lobby", "", false, 7)
    check_valid = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Check"})
    if table_name == ""
      
    elsif check_valid.include?("Empty room")
      pbAnnounce(:fools_lobby_not_available) if $april_fools
      pbMessage("Lobby ID #{table_name} is not available!")
    else
      @disposed = true
      pbJoinLobby(table_name)
    end
  end

  def pbLogout
    if pbConfirmMessage(_INTL("Are you sure you want to log out of your account?"))
      $game_temp.logout_calling = true
      @disposed = true
    end
  end
  
  def pbReplayTutorial
    pbAnnounce(:fools_are_you_sure_tutorial) if $april_fools
    if pbConfirmMessage(_INTL("Are you sure you want to replay the tutorial?"))
      pbMapInterpreter.pbSetSelfSwitch(1, "D", false, 83)
      pbMapInterpreter.pbSetSelfSwitch(1, "C", false, 83)
      pbMapInterpreter.pbSetSelfSwitch(1, "B", false, 83)
      pbMapInterpreter.pbSetSelfSwitch(1, "A", false, 83)
      pbMapInterpreter.pbSetSelfSwitch(3, "A", false, 1)
      $game_temp.tutorial_calling = true
      @disposed = true
    end
  end

  def reload_main_menu
    $game_temp.main_menu_calling = true
    @disposed = true
  end
  
  def update_challenges
    return unless @screen == 0
    return if $player.challenges.nil? || $player.challenges.empty?
    @overlay_small&.dispose
    @overlay_small = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSmallFont(@overlay_small.bitmap)
    challenges = pbGetChallengeTexts
    y = 160
    y_2 = 216
    challenges.each_with_index do |challenge, i|
      y += 12 if challenge[0].gsub("<c2=039F2108>", "").gsub("</c2>", "").length < 32
      drawFormattedTextEx(@overlay_small.bitmap, 706, y, 287, challenge[0], MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR, 24)
      @sprites["challenge_#{i}"].src_rect.width = challenge[1] > 0 ? (152*(challenge[1].to_f/challenge[2].to_f)).round * 2 : 0 unless @sprites["challenge_#{i}"].nil?
      drawFormattedTextEx(@overlay_small.bitmap, 696, y_2, 304, "<ac>#{challenge[1]}/#{challenge[2]}</ac>", MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR, 24)
      y -= 12 if challenge[0].gsub("<c2=039F2108>", "").gsub("</c2>", "").length < 32
      y += 90
      y_2 += 90
    end
  end

  # Check if we should generate new daily challenges.
  def check_day_change
    return if $player.last_challenge_day == Time.now.yday
    $player.last_challenge_day = Time.now.yday
    reset_daily_challenges
  end

  def reset_daily_challenges
    $player.reset_challenges
    update_challenges
    Game.save
    reload_main_menu
  end

  def check_pp_rewards
    $player.pivot_pass_rewards.each do |reward|
      if reward.unlock_level <= $player.pp_level && !reward.claimed
        $player.add_collectible(reward.collectible)
        reward.claimed = true
        notification("Pivot Pass Reward!", Collectible.get(reward.collectible).name, "Graphics/Pictures/Collectibles/#{Collectible.get(reward.collectible).internal}")
      end
    end
  end

  def get_account_from_database
    account = pbGetAccount($player.id)
    if account[0] == "success"
      $player.name = account[1]
      $player.exp = account[3].to_i
      local_friends = $player.friends.map { |friend| friend.id }.join(",")
      database_friends = account[4]
      if local_friends != database_friends
        $player.friends = database_friends.split(",").map { |friend| Friend.new(friend) }
      end
      $player.pp_level = account[7].to_i
      if account[8]
        $player.collectibles = account[8].split(",").map { |collectible| collectible.to_sym }
      else
        $player.collectibles = Player::DEFAULT_COLLECTIBLES
      end
      if account[9]
        received_hash = HTTPLite::JSON.parse(account[9]).map { |k,v| [k.to_sym,(k == "emote") ? HTTPLite::JSON.parse(v) : v.to_sym] }.to_h
        received_hash[:emote] = received_hash[:emote].map { |k,v| [k.to_i,(v == "") ? nil : v.to_sym] }.to_h
        $player.equipped_collectibles = received_hash
      else
        $player.equipped_collectibles = Player::DEFAULT_EQUIPPED_COLLECTIBLES
      end
    end
    friend_requests = $player.friend_requests(true)
    if friend_requests.length > 0
      friend_requests.each do |friend_request|
        notification("New Friend Request!", "#{friend_request.name} Lv. #{friend_request.level}", "Graphics/Pictures/rotom_load.gif")
      end
    end
  end
  
  def showLoading
    @should_show_loading = true
    @sprites["loading"].visible = true
    @sprites["loading"].bitmap.goto_and_play(1)
  end
  
  def screen; @screen; end
  def screen=(value)
    @screen = value
    @overlay_small&.dispose
    @overlay_small = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    update_challenges if @screen == 0
    @sprites["profile_notification"]&.setBitmap(PATH+"profile_notification_green") if $game_temp.friends_online
    @sprites["profile_notification"]&.setBitmap(PATH+"profile_notification_blue") if $player.friend_requests.length > 0
    @sprites["profile_notification"]&.visible = $game_temp.friends_online || $player.friend_requests.length > 0
    if @screen == 4 && $player.friend_requests.length > 0
      @sprites["profile_notification"]&.x = 404
      @sprites["profile_notification"]&.y = 88
    elsif @screen == 5 # Pivot Pass
      @scrolling_anim = true
    else
      @sprites["profile_notification"]&.x = Graphics.width-76
      @sprites["profile_notification"]&.y = 2
    end
    if $april_fools
      case @screen
      when 0
        pbAnnounce(:fools_main_menu)
      when 2
        pbAnnounce(:fools_multiplayer)
      end
    end
  end
  def refresh_lobby=(value); @refresh_lobby = value; end
  def lobby_page=(value); @lobby_page = value; end
  def lobby_page; @lobby_page; end
  def sprites; @sprites; end
  def sprites=(value); @sprites = value; end
  def frame; @frame; end
  def frame=(value); @frame = value; end
  
  def pbEndScene
    pbGlobalFadeOut
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @overlay_small.dispose
    @viewport.dispose
    @collection_character_viewport.dispose
    @collectible_overlay_viewport.dispose
    @collectible_hotkey_viewport.dispose
		@collection_generic_viewport.dispose
    @pivotpass_viewport.dispose
    @friends_list_viewport.dispose
  end
end
  
class Game_Temp
  attr_accessor :training, :main_menu_screen, :friends_online
  def training=(value); @training = value; end
  def training; @training = false if !@training; return @training; end
  def main_menu_screen=(value); @main_menu_screen = value; end
  def main_menu_screen; @main_menu_screen = 0 if !@main_menu_screen; return @main_menu_screen; end
  def friends_online; @friends_online = false if !@friends_online; return @friends_online; end
  def friends_online=(value); @friends_online = value; end
end