class Journal
  BASE_COLOR = Color.new(91,51,44)
  SHADOW_COLOR = Color.new(204,174,106)
  BASE_COLOR_ALT = Color.new(45,33,32)
  SHADOW_COLOR_ALT = SHADOW_COLOR
  PATH = "Graphics/Pictures/Journal/"

  def initialize
    $game_temp.in_menu = true
    @sprites = {}
    @viewport = nil
    @overlay = nil
    @disposed = false
    @screen = 0
    @entry_index = $PokemonGlobal.lastmon
    @current_selected_mon = @entry_index
    @sliderbmp = AnimatedBitmap.new(PATH+"scroll_block")
    @typeBitmap = AnimatedBitmap.new(_INTL("Graphics/Pictures/types"))
    @stamp_marks = []
    @stamps = []
    @personal_dex = []
    @quest_index = $PokemonGlobal.lastquest
    @region_dex = pbAllRegionalSpecies(0)
    pbStartScene
  end

  def pbStartScene
    # Initialize scene objects
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @overlay.z = 99999
    pbSetSystemFont(@overlay.bitmap)
    # Setup Background
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(PATH+"background")
    @sprites["background"].x = (Graphics.width - @sprites["background"].width)/2
    @sprites["background"].y = (Graphics.height - @sprites["background"].height)/2
    # Used for the trainer sprite
    @sprites["trainerbg"] = IconSprite.new(162, 64, @viewport)
    @sprites["trainerbg"].setBitmap(PATH+"trainer_bg")
    @sprites["trainer"] = IconSprite.new(130, 64, @viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    # Stamps
    3.times do |y|
      4.times do |x|
        @sprites["stamp_mark#{y*4+x}"] = IconSprite.new(162+80*x, 304+72*y, @viewport)
        @sprites["stamp_mark#{y*4+x}"].setBitmap(PATH+"stamp_mark")
        @stamp_marks.push(@sprites["stamp_mark#{y*4+x}"])
        @sprites["stamp#{y*4+x}"] = IconSprite.new(162+80*x, 304+72*y, @viewport)
        @sprites["stamp#{y*4+x}"].setBitmap(PATH+"stamps")
        @sprites["stamp#{y*4+x}"].src_rect = Rect.new(64*((y*4+x)%6),(y*4+x>=6 ? 64 : 0),64,64)
        @stamps.push(@sprites["stamp#{y*4+x}"])
      end
    end
    # Buttons
    @sprites["trainer_card_button"] = ButtonSprite.new(self,"About #{$player.name}",PATH+"button",PATH+"button_highlight",proc{pbSEPlay("page turn");self.screen=1},544,64,@viewport)
    @sprites["trainer_card_button"].setTextOffset(0,16)
    @sprites["trainer_card_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
    @sprites["dex_button"] = ButtonSprite.new(self,"Pokémon",PATH+"button",PATH+"button_highlight",proc{pbSEPlay("page turn");self.screen=2},544,128,@viewport)
    @sprites["dex_button"].setTextOffset(0,16)
    @sprites["dex_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
    @sprites["map_button"] = ButtonSprite.new(self,"Region Map",PATH+"button",PATH+"button_highlight",proc{pbSEPlay("page turn");self.screen=4},544,192,@viewport)
    @sprites["map_button"].setTextOffset(0,16)
    @sprites["map_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
    @sprites["quest_button"] = ButtonSprite.new(self,"Quests",PATH+"button",PATH+"button_highlight",proc{pbSEPlay("page turn");self.screen=5},544,256,@viewport)
    @sprites["quest_button"].setTextOffset(0,16)
    @sprites["quest_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
    @sprites["back_button"] = ButtonSprite.new(self,"Back",PATH+"button",PATH+"button_highlight",proc{goBack},544,464,@viewport)
    @sprites["back_button"].setTextOffset(0,16)
    @sprites["back_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
    @sprites["close_button"] = ButtonSprite.new(self,"Close",PATH+"button",PATH+"button_highlight",proc{goBack},544,464,@viewport)
    @sprites["close_button"].setTextOffset(0,16)
    @sprites["close_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
    # Personal Dex
    @region_dex.each do |species|
      skip = !$player.seen?(species)
      if skip
        species_data = GameData::Species.get(species)
        GameData::Species.get(species_data.get_baby_species).get_family_evolutions.each do |sp|
          next unless $player.seen?(sp[0]) || $player.seen?(sp[1]) || $player.seen?("#{sp[0].to_s}_1".to_sym) || $player.seen?("#{sp[1].to_s}_1".to_sym) || $player.seen?("#{sp[0].to_s}_2".to_sym) || $player.seen?("#{sp[1].to_s}_2".to_sym)
          skip = false
          break
        end
      end
      next if skip
      @personal_dex.push(species)
    end
    # Dex Buttons
    5.times do |i|
      @sprites["dex_button_#{i}"] = ButtonSprite.new(self,"Species",PATH+"pokemon_entry",PATH+"pokemon_entry_highlight",proc{next unless $player.seen?(self.personal_dex[self.entry_index+i]);pbSEPlay("page turn");self.entry_index+=i;self.screen=3},544,64+80*i,@viewport)
      @sprites["dex_button_#{i}"].text_align = 0
      @sprites["dex_button_#{i}"].setTextOffset(-64,22)
      @sprites["dex_button_#{i}"].setTextColor(BASE_COLOR,SHADOW_COLOR)
      @sprites["dex_button_#{i}"].visible = false
      @sprites["dex_image_#{i}"] = PokemonSpeciesIconSprite.new(nil, @viewport)
      @sprites["dex_image_#{i}"].x = 558
      @sprites["dex_image_#{i}"].y = 64+80*i
      @sprites["dex_image_#{i}"].visible = false
      @sprites["quest_button_#{i}"] = ButtonSprite.new(self,"Quest",PATH+"quest_entry",PATH+"quest_entry_highlight",proc{next},544,64+80*i,@viewport)
      @sprites["quest_button_#{i}"].setTextOffset(0,22)
      @sprites["quest_button_#{i}"].setTextColor(BASE_COLOR,SHADOW_COLOR)
      @sprites["quest_button_#{i}"].visible = false
    end
    # Dex sprites
    @sprites["dex_selected_mon"] = IconSprite.new(308, 192, @viewport)
    @sprites["dex_selected_mon"].visible = false
    # Scroll bar
    @sprites["scroll_bar"] = IconSprite.new(864, 48, @viewport)
    @sprites["scroll_bar"].setBitmap(PATH+"scroll_bar")
    @sprites["scroll_bar"].visible = false
    # Progress bar
    @sprites["progress_bar"] = IconSprite.new(138, 416, @viewport)
    @sprites["progress_bar"].setBitmap(PATH+"progress_bar_bg")
    @sprites["progress_bar"].visible = false
    pbTransparentAndShow(@sprites) { pbUpdate }
    pbMain
  end

  def pbUpdate
    $PokemonGlobal.lastmon = @entry_index
    $PokemonGlobal.lastquest = @quest_index
    Graphics.update
    Input.update
    $scene.update
    @overlay&.bitmap.clear
    pbUpdateSpriteHash(@sprites) if @sprites
  end

  def pbMain
    loop do
      break if @disposed
      if Input.trigger?(Input::BACK)
        pbSEPlay("page turn")
        @screen == 0 ? break : @screen == 3 ? @screen = 2 : @screen = 0
      end
      case @screen
      when 0 # Main Menu
        drawMainMenu
      when 1 # Trainer Card
        drawTrainerCard
      when 2 # Pokedex
        drawDex
      when 3 # Pokemon Specific Info
        drawDetails
      when 4 # Map
        drawMap
      when 5 # Quests
        drawQuests
      end

      @sprites["trainer"].visible = @screen == 0 || @screen == 1
      @sprites["trainerbg"].visible = @screen == 0 || @screen == 1
      @stamp_marks.each { |mark| mark.visible = @screen == 0 || @screen == 1 }
      @stamps.each_with_index { |stamp, i| stamp.visible = (@screen == 0 || @screen == 1) && $player.badges[i] }
      @sprites["dex_selected_mon"].visible = @screen == 2 || @screen == 3
      @sprites["scroll_bar"].visible = @screen == 2 || @screen == 5
      @sprites["progress_bar"].visible = false unless @screen == 5

      # Buttons
      @sprites["trainer_card_button"].visible = @screen == 0
      @sprites["dex_button"].visible = @screen == 0
      @sprites["map_button"].visible = @screen == 0
      @sprites["quest_button"].visible = @screen == 0
      @sprites["back_button"].visible = @screen != 0
      @sprites["close_button"].visible = @screen == 0

      # Dex Buttons
      5.times do |i|
        show = @screen == 2 && !@sprites["dex_button_#{i}"].hidden
        @sprites["dex_button_#{i}"].visible = show
        @sprites["dex_image_#{i}"].visible = show
        @sprites["quest_button_#{i}"].visible = @screen == 5 && !@sprites["quest_button_#{i}"].hidden
      end

      pbUpdate
    end
    pbEndScene
  end

  def drawMainMenu
    textpos = []
    # Player Name
    textpos.push([$player.name, 276, 64, 0, BASE_COLOR, SHADOW_COLOR])
    # Play Time
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    textpos.push(["Time Played", 276, 96, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push([time, 276, 128, 0, BASE_COLOR, SHADOW_COLOR])
    # Start Time
    starttime = _INTL("{1} {2}, {3}",pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),$PokemonGlobal.startTime.day,$PokemonGlobal.startTime.year)
    textpos.push(["Adventure Started", 276, 160, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push([starttime, 276, 192, 0, BASE_COLOR, SHADOW_COLOR])
    # Money
    textpos.push(["Coins:", 178, 240, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    #textpos.push([_INTL("${1}", $player.money.to_s_formatted), 276, 240, 0, BASE_COLOR, SHADOW_COLOR])
    drawFormattedTextEx(@overlay.bitmap, 246, 240, 300, _INTL("{1}", pbGoldString($player.money, true)), BASE_COLOR, SHADOW_COLOR)
    # Pokémon
    textpos.push(["Pokémon:", 178, 272, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push([sprintf("%d/%d", $player.pokedex.owned_count, $player.pokedex.seen_count), 276, 272, 0, BASE_COLOR, SHADOW_COLOR])
    
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def goBack
    pbSEPlay("page turn")
    self.screen == 0 ? pbEndScene : self.screen=(self.screen==3 ? 2 : 0)
  end

  def drawTrainerCard
    drawMainMenu
    textpos = []
    # Stamp Count
    textpos.push(["Stamps:", 560, 64, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$player.badge_count}", 816, 64, 0, BASE_COLOR, SHADOW_COLOR])
    # Distance Walked
    textpos.push(["Distance Walked:", 560, 96, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.distance_walked}", 816, 96, 0, BASE_COLOR, SHADOW_COLOR])
    # Eggs Hatched
    textpos.push(["Eggs Hatched:", 560, 128, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.eggs_hatched}", 816, 128, 0, BASE_COLOR, SHADOW_COLOR])
    # Evolution Count
    textpos.push(["Pokémon Evolved:", 560, 160, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.evolution_count}", 816, 160, 0, BASE_COLOR, SHADOW_COLOR])
    # Win Loss Ratio Wild
    textpos.push(["Wild Battle W/L:", 560, 192, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.wild_battles_won}/#{$stats.wild_battles_lost}", 816, 192, 0, BASE_COLOR, SHADOW_COLOR])
    # Win Loss Ratio Trainer
    textpos.push(["Trainer Battle W/L:", 560, 224, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.trainer_battles_won}/#{$stats.trainer_battles_lost}", 816, 224, 0, BASE_COLOR, SHADOW_COLOR])
    # Black Out Count
    textpos.push(["Times Blacked Out:", 560, 256, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.blacked_out_count}", 816, 256, 0, BASE_COLOR, SHADOW_COLOR])
    # Items Bought
    textpos.push(["Total Items Bought:", 560, 288, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.mart_items_bought}", 816, 288, 0, BASE_COLOR, SHADOW_COLOR])
    # Money Spent
    textpos.push(["Total Coins Spent:", 560, 320, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    #textpos.push(["$#{$stats.money_spent_at_marts.to_s_formatted}", 816, 320, 0, BASE_COLOR, SHADOW_COLOR])
    drawFormattedTextEx(@overlay.bitmap, 726, 320, 200, _INTL("<ac>{1}</ac>", pbGoldString($stats.money_spent_at_marts, true)), BASE_COLOR, SHADOW_COLOR)
    # Play Sessions
    textpos.push(["Sessions Played:", 560, 352, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.play_sessions}", 816, 352, 0, BASE_COLOR, SHADOW_COLOR])
    # Time since save
    textpos.push(["Time Since Last Save:", 560, 384, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    totalsec = $stats.time_last_saved.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    textpos.push(["#{time}", 816, 384, 0, BASE_COLOR, SHADOW_COLOR])
    # Total Caught
    textpos.push(["Total Pokémon Caught:", 560, 416, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{$stats.caught_pokemon_count}", 816, 416, 0, BASE_COLOR, SHADOW_COLOR])
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def drawDex
    textpos = []
    if Mouse.scroll_direction > 0
      @entry_index == 0 ? @entry_index = @personal_dex.length-1 : @entry_index-=1
    elsif Mouse.scroll_direction < 0
      @entry_index == @personal_dex.length-1 ? @entry_index = 0 : @entry_index+=1
    end
    pokeinfo = []
    @personal_dex.each_with_index do |species, i|
      species_data = GameData::Species.get(species)
      base = $player.seen?(species) ? BASE_COLOR_ALT : BASE_COLOR
      shadow = $player.seen?(species) ? SHADOW_COLOR_ALT : SHADOW_COLOR
      pokeinfo.push(["#{species_data.name}", base, shadow, species_data.id, species_data.form])
    end
    # Dex Buttons
    5.times do |i|
      current_entry = pokeinfo[i+@entry_index]
      if i > @entry_index+pokeinfo.length || current_entry.nil?
        @sprites["dex_button_#{i}"].hidden = true
        @sprites["dex_button_#{i}"].visible = false
        @sprites["dex_image_#{i}"].visible = false
        next
      end
      @sprites["dex_button_#{i}"].hidden = false
      @sprites["dex_button_#{i}"].text = ($player.seen?(current_entry[3]) ? current_entry[0] : "???")
      @sprites["dex_button_#{i}"].setTextColor(current_entry[1],current_entry[2])
      $player.seen?(current_entry[3]) ? @sprites["dex_image_#{i}"].color.set(0, 0, 0, 0) : @sprites["dex_image_#{i}"].color.set(0, 0, 0, 255)
      @sprites["dex_image_#{i}"].pbSetParams(current_entry[3], 0, current_entry[4])
      @sprites["dex_image_#{i}"].active = @sprites["dex_button_#{i}"].highlighted
      @current_selected_mon = i+@entry_index if @sprites["dex_button_#{i}"].highlighted
    end
    # Little Details for current Selected Mon
    species = GameData::Species.get(@personal_dex[@current_selected_mon])
    should_show_data = $player.seen?(species.id)
    name = (should_show_data ? species.name : "???")
    textpos.push([name, 308, 64, 2, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["The #{species.category} Pokémon", 308, 96, 2, BASE_COLOR, SHADOW_COLOR]) if should_show_data
    @sprites["dex_selected_mon"].bitmap = (should_show_data ? GameData::Species.sprite_bitmap(species.species, species.form).bitmap : Bitmap.new("Graphics/Pokemon/Front/000"))
    @sprites["dex_selected_mon"].ox = @sprites["dex_selected_mon"].width/2
    @sprites["dex_selected_mon"].oy = @sprites["dex_selected_mon"].height/2
    if should_show_data
      @overlay.bitmap.blt(192, 288, @typeBitmap.bitmap, Rect.new(0,28*GameData::Type.get(species.types[0]).icon_position,64,28))
      @overlay.bitmap.blt(260, 288, @typeBitmap.bitmap, Rect.new(0,28*GameData::Type.get(species.types[1]).icon_position,64,28)) if species.types.length > 1
      drawTextEx(@overlay.bitmap, 176, 336, 320, 6, species.pokedex_entry, BASE_COLOR, SHADOW_COLOR)
    else
      textpos.push(["Not enough data gathered...", 308, 288, 2, BASE_COLOR, SHADOW_COLOR])
    end
    # Slider
    if pokeinfo.length > 12
      sliderheight = 444
      boxheight = (sliderheight * 5 / (pokeinfo.length-4)).floor
      boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
      boxheight = [boxheight.floor, 16].max
      y = 48
      y += ((sliderheight - boxheight) * @entry_index / (pokeinfo.length-2)).floor
      @overlay.bitmap.blt(856, y, @sliderbmp.bitmap, Rect.new(0, 0, 20, 12))
      i = 0
      while i * 4 < boxheight - 18
        @overlay.bitmap.blt(856, y + 4 + (i * 4), @sliderbmp.bitmap, Rect.new(0, 12, 20, 8))
        i += 1
      end
      @overlay.bitmap.blt(856, y + boxheight - 18, @sliderbmp.bitmap, Rect.new(0, 20, 20, 12))
    else
      @overlay.bitmap.blt(856, 48, @sliderbmp.bitmap, Rect.new(0, 0, 20, 12))
      53.times do |i|
        @overlay.bitmap.blt(856, 60 + 8*i, @sliderbmp.bitmap, Rect.new(0, 12, 20, 8))
      end
      @overlay.bitmap.blt(856, 480, @sliderbmp.bitmap, Rect.new(0, 20, 20, 12))
    end
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def drawDetails
    textpos = []
    species = GameData::Species.get(@personal_dex[@current_selected_mon])
    textpos.push([species.name, 308, 64, 2, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["The #{species.category} Pokémon", 308, 96, 2, BASE_COLOR, SHADOW_COLOR])
    @overlay.bitmap.blt(192, 288, @typeBitmap.bitmap, Rect.new(0,28*GameData::Type.get(species.types[0]).icon_position,64,28))
    @overlay.bitmap.blt(260, 288, @typeBitmap.bitmap, Rect.new(0,28*GameData::Type.get(species.types[1]).icon_position,64,28)) if species.types.length > 1
    drawTextEx(@overlay.bitmap, 176, 336, 320, 6, species.pokedex_entry, BASE_COLOR, SHADOW_COLOR)
    textpos.push(["Weight / Height:", 560, 64, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.weight}lbs / #{species.height}\"", 748, 64, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Base HP:", 560, 96, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.base_stats[:HP]}", 748, 96, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Base Attack:", 560, 128, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.base_stats[:ATTACK]}", 748, 128, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Base Defense:", 560, 160, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.base_stats[:DEFENSE]}", 748, 160, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Base Sp. Attack:", 560, 192, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.base_stats[:SPECIAL_ATTACK]}", 748, 192, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Base Sp. Defense:", 560, 224, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.base_stats[:SPECIAL_DEFENSE]}", 748, 224, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Base Speed:", 560, 256, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{species.base_stats[:SPEED]}", 748, 256, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Gender Ratio:", 560, 288, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{GameData::GenderRatio.get(species.gender_ratio).message}", 748, 288, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Capture Odds:", 560, 320, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    textpos.push(["#{getCatchMessage(species.catch_rate)}", 748, 320, 0, BASE_COLOR, SHADOW_COLOR])
    textpos.push(["Areas:", 560, 352, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
    locations = []
    GameData::Encounter.each_of_version(0) do |enc_data|
      next if locations.any? { |a| a.include?(enc_data.map.map_id) }
      next if !pbFindEncounter(enc_data.types, species)
      map_metadata = GameData::MapMetadata.try_get(enc_data.map)
      next if !map_metadata || map_metadata.has_flag?("HideEncountersInPokedex")
      locations.push([enc_data.map.name, enc_data.map.map_id])
    end
    textpos.push(["Area Unknown", 748, 352, 0, BASE_COLOR, SHADOW_COLOR]) if locations.length == 0
    textpos.push(["#{locations[0][0]}", 748, 352, 0, BASE_COLOR, SHADOW_COLOR]) if locations.length > 0
    textpos.push(["#{locations[1][0]}", 560, 384, 0, BASE_COLOR, SHADOW_COLOR]) if locations.length > 1
    textpos.push(["#{locations[2][0]}", 748, 384, 0, BASE_COLOR, SHADOW_COLOR]) if locations.length > 2
    textpos.push(["#{locations[3][0]}", 560, 416, 0, BASE_COLOR, SHADOW_COLOR]) if locations.length > 3
    textpos.push(["#{locations[4][0]}", 748, 416, 0, BASE_COLOR, SHADOW_COLOR]) if locations.length > 4
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def drawMap
    scene = PokemonRegionMap_Scene.new(-1, false)
    screen = PokemonRegionMapScreen.new(scene)
    screen.pbStartScreen
    @screen = 0
  end

  def drawQuests
    textpos = []
    quests = []
    $player.quests.each_with_index do |q, i|
      next unless q.active && !q.completed
      quests.push([i, q, q.name, q.description, q.rewards])
    end
    if Mouse.scroll_direction > 0
      @quest_index == 0 ? @quest_index = quests.length-1 : @quest_index-=1
    elsif Mouse.scroll_direction < 0
      @quest_index == quests.length-1 ? @quest_index = 0 : @quest_index+=1
    end
    # Quest Buttons
    5.times do |i|
      current_entry = quests[i+@quest_index]
      if i > @quest_index+quests.length || current_entry.nil?
        @sprites["quest_button_#{i}"].hidden = true
        @sprites["quest_button_#{i}"].visible = false
        next
      end
      @sprites["quest_button_#{i}"].hidden = false
      @sprites["quest_button_#{i}"].text = current_entry[2]
      @sprites["quest_button_#{i}"].setTextColor(BASE_COLOR,SHADOW_COLOR)
      @current_selected_mon = i+@quest_index if @sprites["quest_button_#{i}"].highlighted
    end
    # Quest details
    if quests.length > 0
      quest_to_draw = @current_selected_mon > quests.length-1 ? quests[0] : quests[@current_selected_mon]
      textpos.push([quest_to_draw[2], 176, 64, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
      drawTextEx(@overlay.bitmap, 176, 96, 320, 3, quest_to_draw[3], BASE_COLOR, SHADOW_COLOR)
      if quest_to_draw[4].length > 0
        textpos.push(["Rewards:", 176, 192, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
        quest_to_draw[4].each_with_index do |reward, i|
          item = GameData::Item.get(reward[0])
          qty = reward[1]
          name = qty == 1 ? item.name : item.name_plural
          itembmp = Bitmap.new(GameData::Item.icon_filename(reward[0]))
          textpos.push(["#{qty} #{name}", 224, 224+48*i+itembmp.height/3, 0, BASE_COLOR, SHADOW_COLOR])
          @overlay.bitmap.blt(176, 224+48*i, itembmp, Rect.new(0, 0, itembmp.width, itembmp.height))
        end
      end
      if quest_to_draw[1].progress > 0
        textpos.push(["Progress:", 176, 384, 0, BASE_COLOR_ALT, SHADOW_COLOR_ALT])
        @overlay.bitmap.blt(138, 416, Bitmap.new(PATH+"progress_bar"), Rect.new(0, 0, (180*quest_to_draw[1].progress).floor*2, 64))
        @sprites["progress_bar"].visible = true
      end
    else
      textpos.push(["You have no quests...", 308, 288, 2, BASE_COLOR, SHADOW_COLOR])
      textpos.push(["No quests found...", 716, 288, 2, BASE_COLOR, SHADOW_COLOR])
      @sprites["progress_bar"].visible = false
    end
    # Slider
    if quests.length > 12
      sliderheight = 444
      boxheight = (sliderheight * 5 / (quests.length-4)).floor
      boxheight += [(sliderheight - boxheight) / 2, sliderheight / 6].min
      boxheight = [boxheight.floor, 16].max
      y = 48
      y += ((sliderheight - boxheight) * @quest_index / (quests.length-2)).floor
      @overlay.bitmap.blt(856, y, @sliderbmp.bitmap, Rect.new(0, 0, 20, 12))
      i = 0
      while i * 4 < boxheight - 18
        @overlay.bitmap.blt(856, y + 4 + (i * 4), @sliderbmp.bitmap, Rect.new(0, 12, 20, 8))
        i += 1
      end
      @overlay.bitmap.blt(856, y + boxheight - 18, @sliderbmp.bitmap, Rect.new(0, 20, 20, 12))
    else
      @overlay.bitmap.blt(856, 48, @sliderbmp.bitmap, Rect.new(0, 0, 20, 12))
      53.times do |i|
        @overlay.bitmap.blt(856, 60 + 8*i, @sliderbmp.bitmap, Rect.new(0, 12, 20, 8))
      end
      @overlay.bitmap.blt(856, 480, @sliderbmp.bitmap, Rect.new(0, 20, 20, 12))
    end
    pbDrawTextPositions(@overlay.bitmap, textpos)
  end

  def pbFindEncounter(enc_types, species)
    return false if !enc_types
    enc_types.each_value do |slots|
      next if !slots
      slots.each { |slot| return true if GameData::Species.get(slot[1]).species == species }
    end
    return false
  end

  def getCatchMessage(rate)
    ret = "Extremely Challenging"
    ret = "Pretty Difficult" if rate > 10
    ret = "Very Difficult" if rate > 40
    ret = "Slightly Difficult" if rate > 70
    ret = "Alright Chance" if rate > 100
    ret = "Decent Chance" if rate > 140
    ret = "Great Chance" if rate > 180
    ret = "High Chance" if rate > 220
    return ret
  end

  def screen; @screen; end
  def screen=(value); @screen=value; end
  def entry_index; @entry_index; end
  def entry_index=(value); @entry_index = value; end
  def personal_dex; @personal_dex; end

  def pbEndScene
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @sliderbmp.dispose
    @overlay.dispose
    @viewport.dispose
    @typeBitmap.dispose
    $game_temp.in_menu = false
  end
end