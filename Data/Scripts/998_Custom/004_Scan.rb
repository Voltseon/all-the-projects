def pbScan
  pbFadeOutIn {
    scan = Scan.new
    scan.pbStartScene
    scan.pbMain
  }
end

def pbScanPokemon(species)
  return unless species
  return if $player.seen?(species)
  pkmn = GameData::Species.try_get(species)
  return unless pkmn
  pbNotify(_INTL("Databank entry added!"), _INTL("{1}", pkmn.name), 1)
  $player.pokedex.set_seen(species)
end

MenuHandlers.add(:pause_menu, :scan, {
  "name"      => _INTL("S.C.A.N."),
  "order"     => 40,
  "condition" => proc { next $player },
  "effect"    => proc { |menu|
    pbPlayDecisionSE
    pbScan
  }
})

class Scan
  PATH = "Graphics/Pictures/SCAN/"
  COLORS = [[Color.new("F8F8F8"), Color.new("3DA6F7")],[Color.new("F8F8F8"), Color.new("3D5FF7")],[Color.new("62E6F7"), Color.new("3DA6F7")],[Color.new("FF8CAA"), Color.new("A666AD")]]
  TEXT_OFFSET_FRACTION = 6
  Y_OFFSETS = [96, 64] # Offset from top, offset between buttons
  MAX_BUTTONS = 8

  ITEM_LOCATIONS = {
    :SYLVANOR => [:FERRICIODIDE, :SYLVENBRANCH, :TWINE, :SYLVENSTONES, :LUMINAR],
    :GLINTERRA => [:COARSESAND, :SANDSTONE, :SILICATESHARD, :SILICATECRYSTAL],
    :VULKAMOS => [:COPPERNUGGET, :PIECEOFIRON, :MOLTENMETAL, :GOLDHAIR, :PLATINUMINGOT],
    :LUSATIA => [:MUSHROOMCAP, :WATER, :METEORITE, :NEBULASPORES],
    :DIGIRELM => [:CHROME, :DATASTRAND, :MUON, :RAWDATA],
    :LUNIN => [:MOONSTONE]
  }

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @dex_entries = []
    pbAllRegionalSpecies(0).each do |species|
      next if !$player.seen?(species)
      @dex_entries.push(species)
    end
    @planets = $player.visited_planets
    @items = []
    $player.items.each do |item, quantity|
      next if GameData::Item.get(item).pocket == 3
      @items.push([item, quantity]) if quantity > 0
    end
    @recipes = $player.crafting_recipes
    @recipes.delete_if { |recipe| !MenuHandlers.call(:recipe, recipe, "condition") }
    @index = 0
    @cursor_index = 0
    @index_pokemon = nil
    @index_planet = nil
    @screen = 0
    @screen_last = 0
    @indexes = [(@recipes.length > 0 ? 6 : 5), 3, 3, @dex_entries.length, @dex_entries.length, @planets.length, @items.length, @recipes.length]
    @disposed = false
    @button_bitmap = Bitmap.new(PATH + "button")
    @scroll_bitmap = Bitmap.new(PATH + "scroll")
    @item_button_bitmap = Bitmap.new(PATH + "button_item")
    @recipe_button_bitmap = Bitmap.new(PATH + "button_recipe")
    @text_offset = @button_bitmap.height / TEXT_OFFSET_FRACTION - 2
    @foreground_overlay_timer = 100
    @pressed_scans = [[], [], [], [], [], [], []]
    @index_last = 0
    @sorting_modes = ["Sort: A-Z", "Sort: Z-A", "Sort: 9-0", "Sort: 0-9", "Sort: Key", "Sort: Secondary"]
    @sorting_mode = 0
    @drawn_entry = false
  end

  def pbStartScene
    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(PATH + "background")
    @sprites["background"].z = 0
    @sprites["background_overlay"] = ChangelingSprite.new(0, 0, @viewport)
    @sprites["background_overlay"].addBitmap(0, PATH + "background_0")
    @sprites["background_overlay"].addBitmap(1, PATH + "background_1")
    @sprites["background_overlay"].addBitmap(2, PATH + "background_2")
    @sprites["background_overlay"].addBitmap(3, PATH + "background_3")
    @sprites["background_overlay"].addBitmap(4, PATH + "background_4")
    @sprites["background_overlay"].addBitmap(5, PATH + "background_5")
    @sprites["background_overlay"].addBitmap(6, PATH + "background_6")
    @sprites["background_overlay"].addBitmap(7, PATH + "background_7")
    @sprites["background_overlay"].changeBitmap(@screen)
    @sprites["background_overlay"].z = 1
    @sprites["foreground"] = Sprite.new(@viewport)
    @sprites["foreground"].bitmap = Bitmap.new(PATH + "foreground")
    @sprites["foreground"].z = 2
    @sprites["foreground_overlay"] = ChangelingSprite.new(0, 0, @viewport)
    @sprites["foreground_overlay"].addBitmap(1, PATH + "foreground_overlay_1")
    @sprites["foreground_overlay"].addBitmap(2, PATH + "foreground_overlay_2")
    @sprites["foreground_overlay"].addBitmap(3, PATH + "foreground_overlay_3")
    @sprites["foreground_overlay"].changeBitmap(1)
    @sprites["foreground_overlay"].z = 3
    # Home
    pbCreateScreenZero
    # Pokemon
    pbCreateScreenOne
    # Planets
    pbCreateScreenTwo
    # Pokemon Databank
    pbCreateScreenThree
    # Pokemon Info
    pbCreateScreenFour
    # Planet Databank
    pbCreateScreenFive
    # Item Databank
    pbCreateScreenSix
    # Recipe Databank
    pbCreateScreenSeven
    # Update Scroll
    pbScroll
    # Overlay
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].z = 100
    pbSetSystemFont(@sprites["overlay"].bitmap)
    # Check buttons
    pbButtons
    # Show
    pbFadeInAndShow(@sprites)
  end

  def pbCreateScreenZero
    # Pokemon Button
    @sprites["button_pokemon"] = Sprite.new(@viewport)
    @sprites["button_pokemon"].bitmap = @button_bitmap
    @sprites["button_pokemon"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon"].ox = @button_bitmap.width / 2
    @sprites["button_pokemon"].x = Graphics.width / 2
    @sprites["button_pokemon"].y = Y_OFFSETS[0]
    @sprites["button_pokemon"].z = 5
    # Planet Button
    @sprites["button_planet"] = Sprite.new(@viewport)
    @sprites["button_planet"].bitmap = @button_bitmap
    @sprites["button_planet"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet"].ox = @button_bitmap.width / 2
    @sprites["button_planet"].x = Graphics.width / 2
    @sprites["button_planet"].y = Y_OFFSETS[0] + Y_OFFSETS[1]
    @sprites["button_planet"].z = 5
    # Inventory Button
    @sprites["button_inventory"] = Sprite.new(@viewport)
    @sprites["button_inventory"].bitmap = @button_bitmap
    @sprites["button_inventory"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_inventory"].ox = @button_bitmap.width / 2
    @sprites["button_inventory"].x = Graphics.width / 2
    @sprites["button_inventory"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * 2
    @sprites["button_inventory"].z = 5
    # Service Button
    @sprites["button_service"] = Sprite.new(@viewport)
    @sprites["button_service"].bitmap = @button_bitmap
    @sprites["button_service"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_service"].ox = @button_bitmap.width / 2
    @sprites["button_service"].x = Graphics.width / 2
    @sprites["button_service"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * 3
    @sprites["button_service"].z = 5
    # Recipe Button
    @sprites["button_recipe"] = Sprite.new(@viewport)
    @sprites["button_recipe"].bitmap = @button_bitmap
    @sprites["button_recipe"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_recipe"].ox = @button_bitmap.width / 2
    @sprites["button_recipe"].x = Graphics.width / 2
    @sprites["button_recipe"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * 4
    @sprites["button_recipe"].z = 5
    # Back Button
    @sprites["button_close"] = Sprite.new(@viewport)
    @sprites["button_close"].bitmap = @button_bitmap
    @sprites["button_close"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_close"].ox = @button_bitmap.width / 2
    @sprites["button_close"].x = Graphics.width / 2
    @sprites["button_close"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * (@recipes.length > 0 ? 5 : 4)
    @sprites["button_close"].z = 5
  end

  def pbCreateScreenOne
    # Local Button
    @sprites["button_pokemon_local"] = Sprite.new(@viewport)
    @sprites["button_pokemon_local"].bitmap = @button_bitmap
    @sprites["button_pokemon_local"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon_local"].ox = @button_bitmap.width / 2
    @sprites["button_pokemon_local"].x = Graphics.width / 2
    @sprites["button_pokemon_local"].y = Y_OFFSETS[0]
    @sprites["button_pokemon_local"].z = 5
    # Universal Button
    @sprites["button_pokemon_universal"] = Sprite.new(@viewport)
    @sprites["button_pokemon_universal"].bitmap = @button_bitmap
    @sprites["button_pokemon_universal"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon_universal"].ox = @button_bitmap.width / 2
    @sprites["button_pokemon_universal"].x = Graphics.width / 2
    @sprites["button_pokemon_universal"].y = Y_OFFSETS[0] + Y_OFFSETS[1]
    @sprites["button_pokemon_universal"].z = 5
    # Back Button
    @sprites["button_pokemon_back"] = Sprite.new(@viewport)
    @sprites["button_pokemon_back"].bitmap = @button_bitmap
    @sprites["button_pokemon_back"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon_back"].ox = @button_bitmap.width / 2
    @sprites["button_pokemon_back"].x = Graphics.width / 2
    @sprites["button_pokemon_back"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * 2
    @sprites["button_pokemon_back"].z = 5
  end

  def pbCreateScreenTwo
    # Local Button
    @sprites["button_planet_local"] = Sprite.new(@viewport)
    @sprites["button_planet_local"].bitmap = @button_bitmap
    @sprites["button_planet_local"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet_local"].ox = @button_bitmap.width / 2
    @sprites["button_planet_local"].x = Graphics.width / 2
    @sprites["button_planet_local"].y = Y_OFFSETS[0]
    @sprites["button_planet_local"].z = 5
    # Universal Button
    @sprites["button_planet_universal"] = Sprite.new(@viewport)
    @sprites["button_planet_universal"].bitmap = @button_bitmap
    @sprites["button_planet_universal"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet_universal"].ox = @button_bitmap.width / 2
    @sprites["button_planet_universal"].x = Graphics.width / 2
    @sprites["button_planet_universal"].y = Y_OFFSETS[0] + Y_OFFSETS[1]
    @sprites["button_planet_universal"].z = 5
    # Back Button
    @sprites["button_planet_back"] = Sprite.new(@viewport)
    @sprites["button_planet_back"].bitmap = @button_bitmap
    @sprites["button_planet_back"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet_back"].ox = @button_bitmap.width / 2
    @sprites["button_planet_back"].x = Graphics.width / 2
    @sprites["button_planet_back"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * 2
    @sprites["button_planet_back"].z = 5
  end

  def pbCreateScreenThree
    # Pokémon Buttons
    @dex_entries.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_pokemon_data_#{i}"] = Sprite.new(@viewport)
      @sprites["button_pokemon_data_#{i}"].bitmap = @button_bitmap
      @sprites["button_pokemon_data_#{i}"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
      @sprites["button_pokemon_data_#{i}"].ox = @button_bitmap.width / 2
      @sprites["button_pokemon_data_#{i}"].x = Graphics.width / 2 + 160
      @sprites["button_pokemon_data_#{i}"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * i - 48
      @sprites["button_pokemon_data_#{i}"].z = 5
    end
    # Preview Pokémon
    @sprites["pokemon_preview"] = PokemonSprite.new(@viewport)
    @sprites["pokemon_preview"].setOffset(PictureOrigin::CENTER)
    @sprites["pokemon_preview"].x = 306
    @sprites["pokemon_preview"].y = 188
    @sprites["pokemon_preview"].z = 5
    @sprites["pokemon_preview"].setSpeciesBitmap(nil)
    @sprites["pokemon_preview"].visible = false
    @sprites["scroll_pokemon"] = Sprite.new(@viewport)
    # Scroll
    @sprites["scroll_pokemon"].bitmap = Bitmap.new(18, 536)
    if @dex_entries.length > 0
      @sprites["scroll_pokemon"].bitmap.blt(0, 0, @scroll_bitmap, Rect.new(0,0,18,8))
      @sprites["scroll_pokemon"].bitmap.stretch_blt(Rect.new(0,8,18,520*(MAX_BUTTONS.to_f/@dex_entries.length.to_f).clamp(0.0,1.0)), @scroll_bitmap, Rect.new(0,8,18,2))
      @sprites["scroll_pokemon"].bitmap.blt(0, 520*(MAX_BUTTONS.to_f/@dex_entries.length.to_f).clamp(0.0,1.0)+8, @scroll_bitmap, Rect.new(0,10,18,8))
    end
    @sprites["scroll_pokemon"].z = 4
  end

  def pbCreateScreenFour
    # Pokémon Overlay
    @sprites["pokemon_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["pokemon_overlay"].z = 6
    pbSetSystemFont(@sprites["pokemon_overlay"].bitmap)
  end

  def pbCreateScreenFive
    @planets.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_planet_data_#{i}"] = Sprite.new(@viewport)
      @sprites["button_planet_data_#{i}"].bitmap = @button_bitmap
      @sprites["button_planet_data_#{i}"].src_rect.set(0, 0, @button_bitmap.width, @button_bitmap.height / 2)
      @sprites["button_planet_data_#{i}"].ox = @button_bitmap.width / 2
      @sprites["button_planet_data_#{i}"].x = Graphics.width / 2
      @sprites["button_planet_data_#{i}"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * i - 48
      @sprites["button_planet_data_#{i}"].z = 5
    end
    # Scroll
    @sprites["scroll_planet"] = Sprite.new(@viewport)
    @sprites["scroll_planet"].bitmap = Bitmap.new(18, 536)
    if @planets.length > 0
      @sprites["scroll_planet"].bitmap.blt(0, 0, @scroll_bitmap, Rect.new(0,0,18,8))
      @sprites["scroll_planet"].bitmap.stretch_blt(Rect.new(0,8,18,520*(MAX_BUTTONS.to_f/@planets.length.to_f).clamp(0.0,1.0)), @scroll_bitmap, Rect.new(0,8,18,2))
      @sprites["scroll_planet"].bitmap.blt(0, 520*(MAX_BUTTONS.to_f/@planets.length.to_f).clamp(0.0,1.0)+8, @scroll_bitmap, Rect.new(0,10,18,8))
    end
    @sprites["scroll_planet"].z = 4
  end

  def pbCreateScreenSix
    @items.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_item_#{i}"] = Sprite.new(@viewport)
      @sprites["button_item_#{i}"].bitmap = @item_button_bitmap
      @sprites["button_item_#{i}"].src_rect.set(0, 0, @item_button_bitmap.width, @item_button_bitmap.height / 2)
      @sprites["button_item_#{i}"].ox = @item_button_bitmap.width / 2
      @sprites["button_item_#{i}"].x = Graphics.width / 2 + 150
      @sprites["button_item_#{i}"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * i - 48
      @sprites["button_item_#{i}"].z = 5
    end
    # Scroll
    @sprites["scroll_item"] = Sprite.new(@viewport)
    @sprites["scroll_item"].bitmap = Bitmap.new(18, 536)
    if @items.length > 0
      @sprites["scroll_item"].bitmap.blt(0, 0, @scroll_bitmap, Rect.new(0,0,18,8))
      @sprites["scroll_item"].bitmap.stretch_blt(Rect.new(0,8,18,520*(MAX_BUTTONS.to_f/@items.length.to_f).clamp(0.0,1.0)), @scroll_bitmap, Rect.new(0,8,18,2))
      @sprites["scroll_item"].bitmap.blt(0, 520*(MAX_BUTTONS.to_f/@items.length.to_f).clamp(0.0,1.0)+8, @scroll_bitmap, Rect.new(0,10,18,8))
    end
    @sprites["scroll_item"].z = 4
    # Item Overlay
    @sprites["item_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["item_overlay"].z = 6
    pbSetSystemFont(@sprites["item_overlay"].bitmap)
  end

  def pbCreateScreenSeven
    @recipes.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_recipe_#{i}"] = Sprite.new(@viewport)
      @sprites["button_recipe_#{i}"].bitmap = @recipe_button_bitmap
      @sprites["button_recipe_#{i}"].src_rect.set(0, 0, @recipe_button_bitmap.width, @recipe_button_bitmap.height / 2)
      @sprites["button_recipe_#{i}"].ox = @recipe_button_bitmap.width / 2
      @sprites["button_recipe_#{i}"].x = Graphics.width / 2 + 150
      @sprites["button_recipe_#{i}"].y = Y_OFFSETS[0] + Y_OFFSETS[1] * i - 48
      @sprites["button_recipe_#{i}"].z = 5
    end
    # Scroll
    @sprites["scroll_recipe"] = Sprite.new(@viewport)
    @sprites["scroll_recipe"].bitmap = Bitmap.new(18, 536)
    if @recipes.length > 0
      @sprites["scroll_recipe"].bitmap.blt(0, 0, @scroll_bitmap, Rect.new(0,0,18,8))
      @sprites["scroll_recipe"].bitmap.stretch_blt(Rect.new(0,8,18,520*(MAX_BUTTONS.to_f/@recipes.length.to_f).clamp(0.0,1.0)), @scroll_bitmap, Rect.new(0,8,18,2))
      @sprites["scroll_recipe"].bitmap.blt(0, 520*(MAX_BUTTONS.to_f/@recipes.length.to_f).clamp(0.0,1.0)+8, @scroll_bitmap, Rect.new(0,10,18,8))
    end
    @sprites["scroll_recipe"].z = 4
  end

  def pbMain
    while !@disposed
      pbUpdate
      pbInputs
    end
  end

  def pbUpdate
    return if @disposed
    # Updates
    Graphics.update
    pbUpdateSpriteHash(@sprites)
    @sprites["overlay"].bitmap.clear
    @sprites["background_overlay"].changeBitmap(@screen) if @screen_last != @screen
    @sprites["foreground_overlay"].visible = @foreground_overlay_timer < 6
    @foreground_overlay_timer += 1 if @sprites["foreground_overlay"].visible
    @screen_last = @screen
    @sprites["pokemon_preview"].setSpeciesBitmap(@index_pokemon) if @screen == 3 || @screen == 4
    @sprites["pokemon_preview"].visible = @screen == 3 || @screen == 4
    @sprites["item_overlay"].visible = @screen == 6
    @sprites["pokemon_overlay"].visible = @screen == 4
    pbButtons
    pbScroll
  end

  def pbInputs
    return if @disposed
    @index_last = @index
    Input.update
    if Input.trigger?(Input::BACK)
      @sprites["foreground_overlay"].changeBitmap(2)
      @foreground_overlay_timer = 0
      pbPlayCancelSE
      case @screen
      when 0
        pbEndScene
        return
      when 1
        @screen = 0
        @index = 0
      when 2
        @screen = 0
        @index = 1
      when 3
        @screen = 1
        @index = 0
      when 4
        @screen = 3
      when 5
        @screen = 2
        @index = 0
      when 6
        @screen = 0
        @index = 2
      when 7
        @screen = 0
        @index = 4
      end
      @cursor_index = @index unless @screen == 3 || @screen == 5 || @screen == 6 || @screen == 7
    elsif Input.trigger?(Input::DOWN) && @indexes[@screen] > 0
      previous_index = @index
      @index = (@index + 1) % @indexes[@screen]
      @cursor_index = (@index == 0 ? 0 : (@cursor_index + 1).clamp(0, MAX_BUTTONS - 1))
      if previous_index != @index
        pbPlayCursorSE
        @sprites["foreground_overlay"].changeBitmap(3)
        @foreground_overlay_timer = 2
        @index_pokemon = @dex_entries[@index] if @screen == 3 || @screen == 4
        Pokemon.play_cry(@index_pokemon) if @screen == 4 && @index_pokemon != nil
        @drawn_entry = false if @screen == 4
      end
    elsif Input.trigger?(Input::UP) && @indexes[@screen] > 0
      previous_index = @index
      @index = (@index - 1) % @indexes[@screen]
      @cursor_index = (@index == @indexes[@screen] - 1 ? @index.clamp(0, MAX_BUTTONS - 1) : (@cursor_index - 1).clamp(0, MAX_BUTTONS - 1))
      if previous_index != @index
        pbPlayCursorSE
        @sprites["foreground_overlay"].changeBitmap(3)
        @foreground_overlay_timer = 2
        @index_pokemon = @dex_entries[@index] if @screen == 3 || @screen == 4
        Pokemon.play_cry(@index_pokemon) if @screen == 4 && @index_pokemon != nil
        @drawn_entry = false if @screen == 4
      end
    elsif Input.trigger?(Input::ACTION)
      if @screen == 6
        pbPlayDecisionSE
        @sorting_mode = (@sorting_mode + 1) % @sorting_modes.length
        case @sorting_mode
        when 0 # A-Z
          @items.sort! { |a, b| GameData::Item.get(a[0]).name <=> GameData::Item.get(b[0]).name }
        when 1 # Z-A
          @items.sort! { |a, b| GameData::Item.get(b[0]).name <=> GameData::Item.get(a[0]).name }
        when 2 # Quantity
          @items.sort! { |a, b| b[1] <=> a[1] }
        when 3 # Quantity
          @items.sort! { |a, b| a[1] <=> b[1] }
        when 4 # Type
          @items.sort! { |a, b| GameData::Item.keys.find_index(b[0]) <=> GameData::Item.keys.find_index(a[0]) }
        when 5 # Type
          @items.sort! { |a, b| GameData::Item.keys.find_index(a[0]) <=> GameData::Item.keys.find_index(b[0]) }
        end
        reload_items(false)
      end
    elsif Input.trigger?(Input::USE) && @indexes[@screen] > 0
      @sprites["foreground_overlay"].changeBitmap(1)
      @foreground_overlay_timer = 0
      case @screen
      when 0
        case @index
        when 0
          @screen = 1
          @index = 0
          pbPlayDecisionSE
        when 1
          @screen = 2
          @index = 0
          pbPlayDecisionSE
        when 2
          pbPlayDecisionSE
          if @items.length == 0
            pbMessage(_INTL("\\pop[digital]You have no items."))
          else
            @screen = 6
            @index = 0
            @cursor_index = 0
          end
        when 3
          pbPlayDecisionSE
          if @pressed_scans[@screen][@index]
            pbMessage(_INTL("\\pop[digital]A connection could not be established."))
          else
            pbMessage(_INTL("\\pop[digital]Trying to establish a connection to the S.C.A.N. Services\\wtnp[8].\\wtnp[8].\\wtnp[8].\\wtnp[8]"))
            pbMessage(_INTL("\\pop[digital]A connection could not be established.\\wtnp[10]"))
            @pressed_scans[@screen][@index] = true
          end
        when 4
          if @recipes.length == 0
            @sprites["foreground_overlay"].changeBitmap(2)
            pbPlayCancelSE
            pbEndScene
            return
          else
            @screen = 7
            @index = 0
            @cursor_index = 0
            pbPlayDecisionSE
          end
        when 5
          @sprites["foreground_overlay"].changeBitmap(2)
          pbPlayCancelSE
          pbEndScene
          return
        end
      when 1
        case @index
        when 0
          pbPlayDecisionSE
          if @dex_entries.length == 0
            pbMessage(_INTL("\\pop[digital]No Pokémon have been registered in the local databank."))
          else
            @screen = 3
            @index = 0
            @index_pokemon = @dex_entries[@index] if @screen == 3
          end
        when 1
          pbPlayDecisionSE
          if @pressed_scans[@screen][@index]
            pbMessage(_INTL("\\pop[digital]A connection could not be established."))
          else
            pbMessage(_INTL("\\pop[digital]Trying to establish a connection to the S.C.A.N. Services\\wtnp[8].\\wtnp[8].\\wtnp[8].\\wtnp[8]"))
            pbMessage(_INTL("\\pop[digital]A connection could not be established.\\wtnp[10]"))
            @pressed_scans[@screen][@index] = true
          end
        when 2
          @screen = 0
          @index = 0
          pbPlayCancelSE
          @sprites["foreground_overlay"].changeBitmap(2)
        end
      when 2
        case @index
        when 0
          pbPlayDecisionSE
          @screen = 5
          @index = 0
        when 1
          pbPlayDecisionSE
          if @pressed_scans[@screen][@index]
            pbMessage(_INTL("\\pop[digital]A connection could not be established."))
          else
            pbMessage(_INTL("\\pop[digital]Trying to establish a connection to the S.C.A.N. Services\\wtnp[8].\\wtnp[8].\\wtnp[8].\\wtnp[8]"))
            pbMessage(_INTL("\\pop[digital]A connection could not be established.\\wtnp[10]"))
            @pressed_scans[@screen][@index] = true
          end
        when 2
          @screen = 0
          @index = 1
          pbPlayCancelSE
          @sprites["foreground_overlay"].changeBitmap(2)
        end
      when 3
        pbPlayDecisionSE
        @screen = 4
        @drawn_entry = false
        Pokemon.play_cry(@index_pokemon)
      when 4
        Pokemon.play_cry(@index_pokemon)
      when 5
        pbPlayDecisionSE
        @index_planet = @planets[@index]
      when 6
        pbPlayDecisionSE
        commands = []
        commands += ["Store", "Toss"] if GameData::Item.get(@items[@index][0]).pocket == 1
        commands << "Cancel"
        decision = pbMessage(_INTL("What would you like to do with the {1}?", (item_quantity(@items[@index][0]) > 1 ? GameData::Item.get(@items[@index][0]).name_plural : GameData::Item.get(@items[@index][0]).name)), commands)
        case commands[decision]
        when "Store"
          params = ChooseNumberParams.new
          params.setRange(0, item_quantity(@items[@index][0]))
          quantity = pbMessageChooseNumber(_INTL("How many would you like to store?"), params)
          if quantity > 0
            pbMessage(_INTL("You stored {1} {2}.", quantity, (item_quantity(@items[@index][0]) > 1 ? GameData::Item.get(@items[@index][0]).name_plural : GameData::Item.get(@items[@index][0]).name)))
            remove_item(@items[@index][0], quantity)
            add_to_storage(@items[@index][0], quantity)
            reload_items
          end
        when "Toss"
          params = ChooseNumberParams.new
          params.setRange(0, item_quantity(@items[@index][0]))
          quantity = pbMessageChooseNumber(_INTL("How many would you like to toss?"), params)
          if quantity > 0
            pbMessage(_INTL("You tossed {1} {2}.", quantity, (item_quantity(@items[@index][0]) > 1 ? GameData::Item.get(@items[@index][0]).name_plural : GameData::Item.get(@items[@index][0]).name)))
            remove_item(@items[@index][0], quantity)
            reload_items
          end
        when "Cancel"
          pbPlayCancelSE
        end
      when 7
        current_recipe = @recipes[@index]
        crafted = false
        if current_recipe
          if MenuHandlers.call(:recipe, current_recipe, "condition")
            recipe = MenuHandlers.get(:recipe, current_recipe)
            if recipe
              if has_item(recipe["items"])
                crafted = true
                recipe["items"].each do |item, quantity|
                  remove_item(item, quantity)
                end
                recipe["yield"].each do |item, quantity|
                  $player.increase_carry_capacity if item.to_s.include?("CAPACITY")
                  $player.increase_storage_capacity if item.to_s.include?("STORAGE")
                  add_item(item, quantity)
                end
              end
            end
          end
        end
        crafted ? pbSEPlay("Craft") : pbPlayBuzzerSE
      end
      @cursor_index = @index unless @screen == 3 || @screen == 5 || @screen == 6 || @screen == 7
    end
  end

  def pbScroll
    @sprites["scroll_pokemon"].visible = @screen == 3
    @sprites["scroll_planet"].visible = @screen == 5
    @sprites["scroll_item"].visible = @screen == 6
    @sprites["scroll_recipe"].visible = @screen == 7
    case @screen
    when 3
      @sprites["scroll_pokemon"].x = 720
      @sprites["scroll_pokemon"].y = lerp(@sprites["scroll_pokemon"].y, 32 + 536 * ((@index-@cursor_index).to_f/@dex_entries.length.to_f), 0.25) if @dex_entries.length > 0
    when 5
      @sprites["scroll_planet"].y = lerp(@sprites["scroll_planet"].y, 32 + 536 * ((@index-@cursor_index).to_f/@planets.length.to_f), 0.25) if @planets.length > 0
      @sprites["scroll_planet"].x = 720
    when 6
      @sprites["scroll_item"].y = lerp(@sprites["scroll_item"].y, 32 + 536 * ((@index-@cursor_index).to_f/@items.length.to_f), 0.25) if @items.length > 0	
      @sprites["scroll_item"].x = 750
    when 7
      @sprites["scroll_recipe"].y = lerp(@sprites["scroll_recipe"].y, 32 + 536 * ((@index-@cursor_index).to_f/@recipes.length.to_f), 0.25) if @recipes.length > 0
      @sprites["scroll_recipe"].x = 720
    end
  end

  def pbButtons
    # Check visibility
    @sprites["button_pokemon"].visible = @screen == 0
    @sprites["button_planet"].visible = @screen == 0
    @sprites["button_inventory"].visible = @screen == 0
    @sprites["button_service"].visible = @screen == 0
    @sprites["button_recipe"].visible = @screen == 0 && @recipes.length > 0
    @sprites["button_close"].visible = @screen == 0
    @sprites["button_pokemon_local"].visible = @screen == 1
    @sprites["button_pokemon_universal"].visible = @screen == 1
    @sprites["button_pokemon_back"].visible = @screen == 1
    @sprites["button_planet_local"].visible = @screen == 2
    @sprites["button_planet_universal"].visible = @screen == 2
    @sprites["button_planet_back"].visible = @screen == 2
    @dex_entries.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_pokemon_data_#{i}"].visible = @screen == 3
    end
    @planets.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_planet_data_#{i}"].visible = @screen == 5
    end
    @items.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_item_#{i}"].visible = @screen == 6
    end
    @recipes.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_recipe_#{i}"].visible = @screen == 7
    end
    # Check index
    @sprites["button_pokemon"].src_rect.set(0, (@cursor_index == 0 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet"].src_rect.set(0, (@cursor_index == 1 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_inventory"].src_rect.set(0, (@cursor_index == 2 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_service"].src_rect.set(0, (@cursor_index == 3 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_close"].src_rect.set(0, ((@cursor_index == 4 && @recipes.length == 0) || (@cursor_index == 5 && @recipes.length > 0) ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_recipe"].src_rect.set(0, (@cursor_index == 4 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon_local"].src_rect.set(0, (@cursor_index == 0 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon_universal"].src_rect.set(0, (@cursor_index == 1 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_pokemon_back"].src_rect.set(0, (@cursor_index == 2 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet_local"].src_rect.set(0, (@cursor_index == 0 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet_universal"].src_rect.set(0, (@cursor_index == 1 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @sprites["button_planet_back"].src_rect.set(0, (@cursor_index == 2 ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    @dex_entries.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_pokemon_data_#{i}"].src_rect.set(0, (@cursor_index == i ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    end
    @planets.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_planet_data_#{i}"].src_rect.set(0, (@cursor_index == i ? @button_bitmap.height / 2 : 0), @button_bitmap.width, @button_bitmap.height / 2)
    end
    @items.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_item_#{i}"].src_rect.set(0, (@cursor_index == i ? @item_button_bitmap.height / 2 : 0), @item_button_bitmap.width, @item_button_bitmap.height / 2)
    end
    @recipes.length.clamp(0, MAX_BUTTONS).times do |i|
      list = @index-@cursor_index
      mult = MenuHandlers.call(:recipe, @recipes[list +i], "condition") && has_item(MenuHandlers.get(:recipe, @recipes[list +i])["items"]) ? 0 : 2
      @sprites["button_recipe_#{i}"].src_rect.set(0, (@cursor_index == i ? @recipe_button_bitmap.height / 4 : 0) + mult * @recipe_button_bitmap.height / 4, @recipe_button_bitmap.width, @recipe_button_bitmap.height / 4)
    end
    # Draw text
    textpos = []
    imagepos = []
    case @screen
    when 0
      textpos.push([_INTL("Pokémon"), @sprites["button_pokemon"].x, @sprites["button_pokemon"].y + @text_offset, 2, COLORS[(@cursor_index == 0 ? 1 : 0)][0], COLORS[(@cursor_index == 0 ? 1 : 0)][1]])
      textpos.push([_INTL("Planets"), @sprites["button_planet"].x, @sprites["button_planet"].y + @text_offset, 2, COLORS[(@cursor_index == 1 ? 1 : 0)][0], COLORS[(@cursor_index == 1 ? 1 : 0)][1]])
      textpos.push([_INTL("Inventory"), @sprites["button_inventory"].x, @sprites["button_inventory"].y + @text_offset, 2, COLORS[(@cursor_index == 2 ? 1 : 0)][0], COLORS[(@cursor_index == 2 ? 1 : 0)][1]])
      textpos.push([_INTL("Service"), @sprites["button_service"].x, @sprites["button_service"].y + @text_offset, 2, COLORS[(@cursor_index == 3 ? 1 : 0)][0], COLORS[(@cursor_index == 3 ? 1 : 0)][1]])
      textpos.push([_INTL("Close"), @sprites["button_close"].x, @sprites["button_close"].y + @text_offset, 2, COLORS[((@cursor_index == 4 && @recipes.length == 0) || (@cursor_index == 5 && @recipes.length > 0) ? 1 : 0)][0], COLORS[((@cursor_index == 4 && @recipes.length == 0) || (@cursor_index == 5 && @recipes.length > 0) ? 1 : 0)][1]])
      textpos.push([_INTL("Crafting"), @sprites["button_recipe"].x, @sprites["button_recipe"].y + @text_offset, 2, COLORS[(@cursor_index == 4 ? 1 : 0)][0], COLORS[(@cursor_index == 4 ? 1 : 0)][1]]) if @recipes.length > 0
    when 1
      textpos.push([_INTL("Local Databank"), @sprites["button_pokemon_local"].x, @sprites["button_pokemon_local"].y + @text_offset, 2, COLORS[(@cursor_index == 0 ? 1 : 0)][0], COLORS[(@cursor_index == 0 ? 1 : 0)][1]])
      textpos.push([_INTL("S.C.A.N. Databank"), @sprites["button_pokemon_universal"].x, @sprites["button_pokemon_universal"].y + @text_offset, 2, COLORS[(@cursor_index == 1 ? 1 : 0)][0], COLORS[(@cursor_index == 1 ? 1 : 0)][1]])
      textpos.push([_INTL("Back"), @sprites["button_pokemon_back"].x, @sprites["button_pokemon_back"].y + @text_offset, 2, COLORS[(@cursor_index == 2 ? 1 : 0)][0], COLORS[(@cursor_index == 2 ? 1 : 0)][1]])
    when 2
      textpos.push([_INTL("Local Databank"), @sprites["button_planet_local"].x, @sprites["button_planet_local"].y + @text_offset, 2, COLORS[(@cursor_index == 0 ? 1 : 0)][0], COLORS[(@cursor_index == 0 ? 1 : 0)][1]])
      textpos.push([_INTL("S.C.A.N. Databank"), @sprites["button_planet_universal"].x, @sprites["button_planet_universal"].y + @text_offset, 2, COLORS[(@cursor_index == 1 ? 1 : 0)][0], COLORS[(@cursor_index == 1 ? 1 : 0)][1]])
      textpos.push([_INTL("Back"), @sprites["button_planet_back"].x, @sprites["button_planet_back"].y + @text_offset, 2, COLORS[(@cursor_index == 2 ? 1 : 0)][0], COLORS[(@cursor_index == 2 ? 1 : 0)][1]])
    when 3
      list = @index-@cursor_index
      (list...list+MAX_BUTTONS).each_with_index do |pi, i|
        next if pi < 0 || pi >= @dex_entries.length
        textpos.push([GameData::Species.try_get(@dex_entries[pi]).name, @sprites["button_pokemon_data_#{i}"].x, @sprites["button_pokemon_data_#{i}"].y + @text_offset, 2, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
      end
      preview_mon = GameData::Species.try_get(@index_pokemon)
      weight = ""
      height = ""
      if System.user_language[3..4] == "US"   # If the user is in the United States
        inches = (preview_mon.height / 0.254).round
        pounds = (preview_mon.weight / 0.45359).round
        height = _ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12)
        weight = _ISPRINTF("{1:4.1f} lbs.", pounds / 10.0)
      else
        height = _ISPRINTF("{1:.1f} m", preview_mon.height / 10.0)
        weight = _ISPRINTF("{1:.1f} kg", preview_mon.weight / 10.0)
      end
      ["Weight", weight, "Height", height].each_with_index do |text, i|
        textpos.push([text.to_s, 218, 304 + 32 * i, 0, COLORS[i%2*2][0], COLORS[i%2*2][1]])
      end
      mon_planet = GameData::Planet.try_get(preview_mon.habitat.to_sym)
      mon_planet_name = mon_planet.name if mon_planet
      mon_planet_name = "Earth" if mon_planet == nil
      mon_planet_name = "???" if preview_mon.habitat == "UNKNOWN"
      textpos.push([mon_planet_name, 218, 460, 0, COLORS[0][0], COLORS[0][1]])
    when 4
      preview_mon = GameData::Species.try_get(@index_pokemon)
      weight = ""
      height = ""
      if System.user_language[3..4] == "US"   # If the user is in the United States
        inches = (preview_mon.height / 0.254).round
        pounds = (preview_mon.weight / 0.45359).round
        height = _ISPRINTF("{1:d}'{2:02d}\"", inches / 12, inches % 12)
        weight = _ISPRINTF("{1:4.1f} lbs.", pounds / 10.0)
      else
        height = _ISPRINTF("{1:.1f} m", preview_mon.height / 10.0)
        weight = _ISPRINTF("{1:.1f} kg", preview_mon.weight / 10.0)
      end
      ["Weight", weight, "Height", height].each_with_index do |text, i|
        textpos.push([text.to_s, 218, 304 + 32 * i, 0, COLORS[i%2*2][0], COLORS[i%2*2][1]])
      end
      [preview_mon.name, "#{preview_mon.category} Pokémon"].each_with_index do |text, i|
        textpos.push([text.to_s, 476, 102 + 32 * i, 0, COLORS[i%2*2][0], COLORS[i%2*2][1]])
      end
      preview_mon.types.each_with_index do |type, i|
        imagepos.push(["Graphics/Pictures/types", 476 + 70 * i, 162, 0, GameData::Type.get(type).icon_position*28, 64, 28])
      end
      if !@drawn_entry
        @sprites["pokemon_overlay"].bitmap.clear
        drawTextEx(@sprites["pokemon_overlay"].bitmap, 476, 204, 260, 16, preview_mon.pokedex_entry, COLORS[0][0], COLORS[0][1])
        @drawn_entry = true
      end
      mon_planet = GameData::Planet.try_get(preview_mon.habitat.to_sym)
      mon_planet_name = mon_planet.name if mon_planet
      mon_planet_name = "Earth" if mon_planet == nil
      mon_planet_name = "???" if preview_mon.habitat == "UNKNOWN"
      textpos.push([mon_planet_name, 218, 460, 0, COLORS[0][0], COLORS[0][1]])
    when 5
      list = @index-@cursor_index
      (list...list+MAX_BUTTONS).each_with_index do |pi, i|
        next if pi < 0 || pi >= @planets.length
        planet = GameData::Planet.try_get(@planets[pi])
        next if !planet
        textpos.push([planet.name, @sprites["button_planet_data_#{i}"].x, @sprites["button_planet_data_#{i}"].y + @text_offset, 2, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
      end
    when 6
      list = @index-@cursor_index
      (list...list+MAX_BUTTONS).each_with_index do |pi, i|
        next if pi < 0 || pi >= @items.length
        service = GameData::Item.try_get(@items[pi][0])
        next if !service
        textpos.push([service.name, @sprites["button_item_#{i}"].x - 124, @sprites["button_item_#{i}"].y + @text_offset, 0, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
        textpos.push(["#{$player.items[@items[pi][0]]}x", @sprites["button_item_#{i}"].x - 110, @sprites["button_item_#{i}"].y + @text_offset + 26, 2, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
        textpos.push([@sorting_modes[@sorting_mode], 234, 512, 2, COLORS[0][0], COLORS[0][1]])
        imagepos.push([GameData::Item.icon_filename(@items[pi][0]), @sprites["button_item_#{i}"].x - 180, @sprites["button_item_#{i}"].y + 4])
      end
      selected_item = GameData::Item.try_get(@items[@index][0])
      if @index_last != @index
        @sprites["item_overlay"].bitmap.clear
        drawTextEx(@sprites["item_overlay"].bitmap, 136, 46, 208, 16, selected_item.description, COLORS[0][0], COLORS[0][1])
      end
      item_origin = nil
      ITEM_LOCATIONS.each do |key, value|
        if value.include?(@items[@index][0])
          item_origin = key
          break
        end
      end
      origin = item_origin ? GameData::Planet.get(item_origin).name : selected_item.pocket == 1 ? "Earth" : "Artificial"
      textpos.push([origin, 240, 344, 2, COLORS[0][0], COLORS[0][1]])
      textpos.push(["Quantity:", 136, 406, 0, COLORS[0][0], COLORS[0][1]])
      textpos.push(["#{$player.items[selected_item.id]}x", 340, 406, 1, COLORS[0][0], COLORS[0][1]])
      textpos.push(["Capacity:", 136, 440, 0, COLORS[0][0], COLORS[0][1]])
      textpos.push(["#{$player.carry_capacity}x", 340, 440, 1, COLORS[0][0], COLORS[0][1]])
    when 7
      list = @index-@cursor_index
      (list...list+MAX_BUTTONS).each_with_index do |pi, i|
        next if pi < 0 || pi >= @recipes.length
        recipe = MenuHandlers.get(:recipe, @recipes[pi])
        next if !recipe
        textpos.push([recipe["name"], @sprites["button_recipe_#{i}"].x - 124, @sprites["button_recipe_#{i}"].y + @text_offset, 0, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
      end
      current_recipe = MenuHandlers.get(:recipe, @recipes[@index])
      if current_recipe
        can_craft = has_item(current_recipe["items"]) && MenuHandlers.call(:recipe, @recipes[@index], "condition")
        textpos.push([(MenuHandlers.call(:recipe, @recipes[@index], "condition") ? (can_craft ? "C: Craft" : "Not Enough!") : "Can't Craft"), 276, 518, 2, COLORS[(can_craft ? 0 : 3)][0], COLORS[(can_craft ? 0 : 3)][1]])
        i = 0
        current_recipe["items"].each do |item, quantity|
          has = item_quantity(item) >= quantity
          imagepos.push([PATH+"icon_crafting", 176, 246 + 64 * i, 0, (has ? 0 : 52), 52, 52])
          item_icon = ($player.items[item].nil? ? GameData::Item.icon_filename("000") : GameData::Item.icon_filename(item))
          imagepos.push([item_icon, 178, 248 + 64 * i])
          textpos.push(["#{item_quantity(item).to_digits}/#{quantity.to_digits}", 240, 260 + 64 * i, 0, COLORS[(has ? 0 : 3)][0], COLORS[(has ? 0 : 3)][1]])
          i += 1
        end
        i = 0
        current_recipe["yield"].each do |item, quantity|
          imagepos.push([PATH+"icon_crafting", 176, 60 + 64 * i, 0, 0, 52, 52])
          imagepos.push([GameData::Item.icon_filename(item), 178, 64 + 64 * i])
          textpos.push(["#{quantity}x", 240, 76 + 64 * i, 0, COLORS[0][0], COLORS[0][1]])
          i += 1
        end
      end
    end
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @button_bitmap.dispose
    @scroll_bitmap.dispose
    @item_button_bitmap.dispose
    @recipe_button_bitmap.dispose
  end

  def reload_items(new_items=true)
    @items.length.clamp(0, MAX_BUTTONS).times do |i|
      break unless @sprites["button_item_#{i}"]
      @sprites["button_item_#{i}"].dispose
    end
    @sprites["scroll_item"].bitmap.clear
    @sprites["item_overlay"].bitmap.clear
    if new_items
      @items = []
      $player.items.each do |item, quantity|
        next if GameData::Item.get(item).pocket == 3
        @items.push([item, quantity]) if quantity > 0
      end
    end
    @indexes[6] = @items.length
    pbCreateScreenSix
    if @screen == 6
      @index = @index.clamp(0, @indexes[6]-1)
      @cursor_index = @index.clamp(0, MAX_BUTTONS)
      selected_item = GameData::Item.try_get(@items[@index][0])
      @sprites["item_overlay"].bitmap.clear
      drawTextEx(@sprites["item_overlay"].bitmap, 136, 46, 208, 16, selected_item.description, COLORS[0][0], COLORS[0][1])
    end
  end
end