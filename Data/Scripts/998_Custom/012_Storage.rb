def pbStorage
  pbFadeOutIn {
    scan = Storage.new
    scan.pbStartScene
    scan.pbMain
  }
end

class Storage
  PATH = "Graphics/Pictures/Storage/"
  COLORS = [[Color.new("F8F8F8"), Color.new("31AD1B")],[Color.new("F8F8F8"), Color.new("0C7889")],[Color.new("F7B680"), Color.new("CC631E")]]
  TEXT_OFFSET_FRACTION = 6
  Y_OFFSETS = [96, 64] # Offset from top, offset between buttons
  MAX_BUTTONS = 8

  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @items = []
    $player.storage.each do |item, quantity|
      next if GameData::Item.get(item).pocket == 3
      @items.push([item, quantity]) if quantity > 0
    end
    @index = 0
    @cursor_index = 0
    @index_cap = @items.length
    @disposed = false
    @scroll_bitmap = Bitmap.new(PATH + "scroll")
    @item_button_bitmap = Bitmap.new(PATH + "button_item")
    @text_offset = @item_button_bitmap.height / TEXT_OFFSET_FRACTION - 10
    @index_last = 0
    @sorting_modes = ["Sort: A-Z", "Sort: Z-A", "Sort: 9-0", "Sort: 0-9", "Sort: Key", "Sort: Secondary"]
    @sorting_mode = 0
  end

  def pbStartScene
    # Background
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(PATH + "background")
    @sprites["background"].z = 0
    @sprites["background_overlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["background_overlay"].setBitmap(PATH + "background_overlay")
    @sprites["background_overlay"].z = 1
    pbCreateItemScreen
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

  def pbCreateItemScreen
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
    pbButtons
    pbScroll
  end

  def pbInputs
    return if @disposed
    @index_last = @index
    Input.update
    if Input.trigger?(Input::BACK)
      pbPlayCancelSE
      pbEndScene
      return
    elsif Input.trigger?(Input::DOWN) && @index_cap > 0
      previous_index = @index
      @index = (@index + 1) % @index_cap
      @cursor_index = (@index == 0 ? 0 : (@cursor_index + 1).clamp(0, MAX_BUTTONS - 1))
      if previous_index != @index
        pbPlayCursorSE
      end
    elsif Input.trigger?(Input::UP) && @index_cap > 0
      previous_index = @index
      @index = (@index - 1) % @index_cap
      @cursor_index = (@index == @index_cap - 1 ? @index.clamp(0, MAX_BUTTONS - 1) : (@cursor_index - 1).clamp(0, MAX_BUTTONS - 1))
      if previous_index != @index
        pbPlayCursorSE
      end
    elsif Input.trigger?(Input::ACTION)
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
    elsif Input.trigger?(Input::USE) && @items.length > 0
      pbPlayDecisionSE
      if @items.length > 0
        commands = []
        commands += ["Carry", "Toss"] if GameData::Item.get(@items[@index][0]).pocket == 1
        commands << "Cancel"
        decision = pbMessage(_INTL("What would you like to do with the {1}?", (storage_quantity(@items[@index][0]) > 1 ? GameData::Item.get(@items[@index][0]).name_plural : GameData::Item.get(@items[@index][0]).name)), commands, -1, "choice 2")
        case commands[decision]
        when "Carry"
          params = ChooseNumberParams.new
          params.setRange(0, storage_quantity(@items[@index][0]))
          params.setMessageSkin("choice 2")
          quantity = pbMessageChooseNumber(_INTL("How many would you like to carry?"), params)
          if quantity > 0
            pbMessage(_INTL("You grabbed {1} {2}.", quantity, (storage_quantity(@items[@index][0]) > 1 ? GameData::Item.get(@items[@index][0]).name_plural : GameData::Item.get(@items[@index][0]).name)), nil, -1, "choice 2")
            add_item(@items[@index][0], quantity)
            remove_from_storage(@items[@index][0], quantity)
            reload_items
          end
        when "Toss"
          params = ChooseNumberParams.new
          params.setRange(0, storage_quantity(@items[@index][0]))
          params.setMessageSkin("choice 2")
          quantity = pbMessageChooseNumber(_INTL("How many would you like to toss?"), params)
          if quantity > 0
            pbMessage(_INTL("You tossed {1} {2}.", quantity, (storage_quantity(@items[@index][0]) > 1 ? GameData::Item.get(@items[@index][0]).name_plural : GameData::Item.get(@items[@index][0]).name)), nil, -1, "choice 2")
            remove_from_storage(@items[@index][0], quantity)
            reload_items
          end
        when "Cancel"
          pbPlayCancelSE
        end
      end
    end
  end

  def pbScroll
    @sprites["scroll_item"].y = lerp(@sprites["scroll_item"].y, 32 + 536 * ((@index-@cursor_index).to_f/@items.length.to_f), 0.25) if @items.length > 0	
    @sprites["scroll_item"].x = 750
  end

  def pbButtons
    # Check index
    @items.length.clamp(0, MAX_BUTTONS).times do |i|
      @sprites["button_item_#{i}"].src_rect.set(0, (@cursor_index == i ? @item_button_bitmap.height / 2 : 0), @item_button_bitmap.width, @item_button_bitmap.height / 2)
    end
    # Draw text
    textpos = []
    imagepos = []
    if @items.length == 0
      textpos.push([_INTL("No items."), 162, 104, 0, COLORS[0][0], COLORS[0][1]])
    end
    list = @index-@cursor_index
    (list...list+MAX_BUTTONS).each_with_index do |pi, i|
      next if pi < 0 || pi >= @items.length
      service = GameData::Item.try_get(@items[pi][0])
      next if !service
      textpos.push([service.name, @sprites["button_item_#{i}"].x - 124, @sprites["button_item_#{i}"].y + @text_offset, 0, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
      textpos.push(["#{$player.storage[@items[pi][0]]}x", @sprites["button_item_#{i}"].x - 110, @sprites["button_item_#{i}"].y + @text_offset + 26, 2, COLORS[(@cursor_index == i ? 1 : 0)][0], COLORS[(@cursor_index == i ? 1 : 0)][1]])
      textpos.push([@sorting_modes[@sorting_mode], 234, 512, 2, COLORS[0][0], COLORS[0][1]])
      imagepos.push([GameData::Item.icon_filename(@items[pi][0]), @sprites["button_item_#{i}"].x - 180, @sprites["button_item_#{i}"].y + 4])
    end
    if @index_last != @index
      selected_item = GameData::Item.try_get(@items[@index][0])
      @sprites["item_overlay"].bitmap.clear
      drawTextEx(@sprites["item_overlay"].bitmap, 136, 46, 208, 16, selected_item.description, COLORS[0][0], COLORS[0][1])
    end
    textpos.push(["Capacity:", 142, 392, 0, COLORS[0][0], COLORS[0][1]])
    total = storage_total
    textpos.push(["#{total.to_digits(4)} / #{$player.storage_capacity.to_digits(4)}", 238, 432, 2, COLORS[(total >= $player.storage_capacity ? 2 : 0)][0], COLORS[(total >= $player.storage_capacity ? 2 : 0)][1]])
    pbDrawTextPositions(@sprites["overlay"].bitmap, textpos)
    pbDrawImagePositions(@sprites["overlay"].bitmap, imagepos)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @scroll_bitmap.dispose
    @item_button_bitmap.dispose
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
      $player.storage.each do |item, quantity|
        next if GameData::Item.get(item).pocket == 3
        @items.push([item, quantity]) if quantity > 0
      end
    end
    @index_cap = @items.length
    pbCreateItemScreen
    if @screen == 6
      @index = @index.clamp(0, @index_cap)
      @cursor_index = @index.clamp(0, MAX_BUTTONS)
      selected_item = GameData::Item.try_get(@items[@index][0])
      @sprites["item_overlay"].bitmap.clear
      drawTextEx(@sprites["item_overlay"].bitmap, 136, 46, 208, 16, selected_item.description, COLORS[0][0], COLORS[0][1])
    end
  end
end