#===============================================================================
# Abstraction layer for Pokemon Essentials
#===============================================================================
class ShardMartAdapter
  def getMoney(shard)
    return $bag.quantity(shard)
  end

  def getMoneyString(shard=nil)
    return "" if shard.nil?
    amt = $bag.quantity(shard)
    return _INTL("{1} {2}",amt,shard.to_s.gsub("SHARD","").capitalize)
  end

  def getInventory
    return $bag
  end

  def getName(item)
    return GameData::Item.get(item).name
  end

  def getNamePlural(item)
    return GameData::Item.get(item).name_plural
  end

  def getDisplayName(item)
    item_name = getName(item)
    if GameData::Item.get(item).is_machine?
      machine = GameData::Item.get(item).move
      item_name = _INTL("{1} {2}", item_name, GameData::Move.get(machine).name)
    end
    return item_name
  end

  def getDisplayNamePlural(item)
    item_name_plural = getNamePlural(item)
    if GameData::Item.get(item).is_machine?
      machine = GameData::Item.get(item).move
      item_name_plural = _INTL("{1} {2}", item_name_plural, GameData::Move.get(machine).name)
    end
    return item_name_plural
  end

  def getDescription(item)
    return "" if item.nil?
    return GameData::Item.get(item).description
  end

  def getItemIcon(item)
    return (item) ? GameData::Item.icon_filename(item) : nil
  end

  # Unused
  def getItemIconRect(_item)
    return Rect.new(0, 0, 48, 48)
  end

  def getQuantity(item)
    return $bag.quantity(item)
  end

  def showQuantity?(item)
    return !GameData::Item.get(item).is_important?
  end

  def getPrice(item)
    return [:REDSHARD, 0] if item.nil?
    case item
    when :FIRESTONE then return [:REDSHARD, 10]
    when :WATERSTONE then return [:BLUESHARD, 10]
    when :THUNDERSTONE then return [:YELLOWSHARD, 10]
    when :LEAFSTONE then return [:GREENSHARD, 10]
    when :TM11 then return [:REDSHARD, 5] # Sunny Day
    when :TM18 then return [:BLUESHARD, 5] # Rain Dance
    when :TM07 then return [:GREENSHARD, 5] # Hail
    when :TM37 then return [:YELLOWSHARD, 5] # Sandstorm
    when :DUSKSTONE then return [:REDSHARD, 15]
    when :DAWNSTONE then return [:GREENSHARD, 15]
    when :SHINYSTONE then return [:YELLOWSHARD, 15]
    when :ICESTONE then return [:BLUESHARD, 15]
    when :MOONSTONE then return [:GREENSHARD, 15]
    when :SUNSTONE then return [:YELLOWSHARD, 15]
    end
    itm = GameData::Item.get(item).price
    price = [[itm/200,1].max, 25].min
    shard_type = (price%4==0) ? :REDSHARD : (price%4==1) ? :BLUESHARD : (price%4==2) ? :GREENSHARD : :YELLOWSHARD
    return [shard_type, price]
  end

  def getDisplayPrice(item)
    price = getPrice(item)
    return _INTL("{1} {2}", price[1], price[0].to_s.gsub("SHARD","").capitalize)
  end

  def addItem(item)
    return $bag.add(item)
  end

  def removeItem(item)
    return $bag.remove(item)
  end
end

#===============================================================================
# Adapters
#===============================================================================
class BuyAdapter
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayNamePlural(item)
    @adapter.getDisplayNamePlural(item)
  end

  def getDisplayPrice(item)
    @adapter.getDisplayPrice(item)
  end
end

#===============================================================================
# Pokémon Mart
#===============================================================================
class Window_ShardMart < Window_DrawableCommand
  def initialize(stock, adapter, x, y, width, height, viewport = nil)
    @stock       = stock
    @adapter     = adapter
    super(x, y, width, height, viewport)
    @selarrow    = AnimatedBitmap.new("Graphics/Pictures/martSel")
    @baseColor   = Color.new(88, 88, 80)
    @shadowColor = Color.new(168, 184, 184)
    self.windowskin = nil
  end

  def itemCount
    return @stock.length + 1
  end

  def item
    return (self.index >= @stock.length) ? nil : @stock[self.index]
  end

  def drawItem(index, count, rect)
    textpos = []
    rect = drawCursor(index, rect)
    ypos = rect.y
    if index == count - 1
      textpos.push([_INTL("CANCEL"), rect.x, ypos + 2, false, self.baseColor, self.shadowColor])
    else
      item = @stock[index]
      itemname = @adapter.getDisplayName(item)
      qty = @adapter.getDisplayPrice(item)
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2 - 16
      textpos.push([itemname, rect.x, ypos + 2, false, self.baseColor, self.shadowColor])
      textpos.push([qty, xQty, ypos + 2, false, self.baseColor, self.shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

#===============================================================================
#
#===============================================================================
class ShardMart_Scene
  DEFAULT_SHARD_MART = [
    :FIRESTONE, :WATERSTONE, :THUNDERSTONE, :LEAFSTONE,
    :TM07, :TM11, :TM18, :TM37,
    :DUSKSTONE, :DAWNSTONE, :SHINYSTONE, :ICESTONE,
    :MOONSTONE, :SUNSTONE
    ]

  def update
    pbUpdateSpriteHash(@sprites)
    @subscene&.pbUpdate
  end

  def pbRefresh
    if @subscene
      @subscene.pbRefresh
    else
      itemwindow = @sprites["itemwindow"]
      @sprites["icon"].item = itemwindow.item
      @sprites["itemtextwindow"].text =
        (itemwindow.item) ? @adapter.getDescription(itemwindow.item) : _INTL("Quit shopping.")
      @sprites["qtywindow"].visible = !itemwindow.item.nil?
      @sprites["qtywindow"].text    = _INTL("In Bag:<r>{1}", @adapter.getQuantity(itemwindow.item))
      @sprites["qtywindow"].y       = Graphics.height - 102 - @sprites["qtywindow"].height
      itemwindow.refresh
    end
    @sprites["moneywindow"].text = _INTL("{1}", @adapter.getMoneyString(@adapter.getPrice(itemwindow.item)[0]))
  end

  def pbStartBuyScene2(stock, adapter)
    # Scroll right before showing screen
    pbScrollMap(6, 5, 5)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @stock = stock
    @adapter = adapter
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/Pictures/martScreen")
    @sprites["icon"] = ItemIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    winAdapter = BuyAdapter.new(adapter)
    @sprites["itemwindow"] = Window_ShardMart.new(
      stock, winAdapter, Graphics.width - 316 - 16, 10, 330 + 16, Graphics.height - 124
    )
    @sprites["itemwindow"].viewport = @viewport
    @sprites["itemwindow"].index = 0
    @sprites["itemwindow"].refresh
    @sprites["itemtextwindow"] = Window_UnformattedTextPokemon.newWithSize(
      "", 64, Graphics.height - 96 - 16, Graphics.width - 64, 128, @viewport
    )
    pbPrepareWindow(@sprites["itemtextwindow"])
    @sprites["itemtextwindow"].baseColor = Color.new(248, 248, 248)
    @sprites["itemtextwindow"].shadowColor = Color.new(0, 0, 0)
    @sprites["itemtextwindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = true
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 190
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["qtywindow"])
    @sprites["qtywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["qtywindow"].viewport = @viewport
    @sprites["qtywindow"].width = 190
    @sprites["qtywindow"].height = 64
    @sprites["qtywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["qtywindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtywindow"].text = _INTL("In Bag:<r>{1}", @adapter.getQuantity(@sprites["itemwindow"].item))
    @sprites["qtywindow"].y    = Graphics.height - 102 - @sprites["qtywindow"].height
    pbDeactivateWindows(@sprites)
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock, adapter)
    pbStartBuyScene2(stock, adapter)
  end

  def pbEndBuyScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    pbScrollMap(4, 5, 5)
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end

  def pbShowMoney
    pbRefresh
    @sprites["moneywindow"].visible = true
  end

  def pbHideMoney
    pbRefresh
    @sprites["moneywindow"].visible = false
  end

  def pbShowQuantity
    pbRefresh
    @sprites["qtywindow"].visible = true
  end

  def pbHideQuantity
    pbRefresh
    @sprites["qtywindow"].visible = false
  end

  def pbDisplay(msg, brief = false)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    i = 0
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      self.update
      if !cw.busy?
        return if brief
        pbRefresh if i == 0
      end
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        cw.resume if cw.busy?
      end
      return if i >= Graphics.frame_rate * 3 / 2
      i += 1 if !cw.busy?
    end
  end

  def pbDisplayPaused(msg)
    cw = @sprites["helpwindow"]
    cw.letterbyletter = true
    cw.text = msg
    pbBottomLeftLines(cw, 2)
    cw.visible = true
    yielded = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      wasbusy = cw.busy?
      self.update
      if !cw.busy? && !yielded
        yield if block_given?   # For playing SE as soon as the message is all shown
        yielded = true
      end
      pbRefresh if !cw.busy? && wasbusy
      if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
        if cw.resume && !cw.busy?
          @sprites["helpwindow"].visible = false
          break
        end
      end
    end
  end

  def pbConfirm(msg)
    dw = @sprites["helpwindow"]
    dw.letterbyletter = true
    dw.text = msg
    dw.visible = true
    pbBottomLeftLines(dw, 2)
    commands = [_INTL("Yes"), _INTL("No")]
    cw = Window_CommandPokemon.new(commands)
    cw.viewport = @viewport
    pbBottomRight(cw)
    cw.y -= dw.height
    cw.index = 0
    pbPlayDecisionSE
    loop do
      cw.visible = !dw.busy?
      Graphics.update
      Input.update
      cw.update
      self.update
      if Input.trigger?(Input::BACK) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible = false
        return false
      end
      if Input.trigger?(Input::USE) && dw.resume && !dw.busy?
        cw.dispose
        @sprites["helpwindow"].visible = false
        return (cw.index == 0)
      end
    end
  end

  def pbChooseNumber(helptext, item, maximum)
    curnumber = 1
    ret = 0
    helpwindow = @sprites["helpwindow"]
    itemprice = @adapter.getPrice(item)
    pbDisplay(helptext, true)
    using(numwindow = Window_AdvancedTextPokemon.new("")) do   # Showing number of items
      pbPrepareWindow(numwindow)
      numwindow.viewport = @viewport
      numwindow.width = 224
      numwindow.height = 64
      numwindow.baseColor = Color.new(88, 88, 80)
      numwindow.shadowColor = Color.new(168, 184, 184)
      numwindow.text = _INTL("x{1}<r>{2} {3}", curnumber, (curnumber * itemprice[1]).to_s_formatted, itemprice[0].to_s.gsub("SHARD","").capitalize)
      pbBottomRight(numwindow)
      numwindow.y -= helpwindow.height
      loop do
        Graphics.update
        Input.update
        numwindow.update
        update
        oldnumber = curnumber
        if Input.repeat?(Input::LEFT)
          curnumber -= 10
          curnumber = 1 if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} {3}", curnumber, (curnumber * itemprice[1]).to_s_formatted, itemprice[0].to_s.gsub("SHARD","").capitalize)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} {3}", curnumber, (curnumber * itemprice[1]).to_s_formatted, itemprice[0].to_s.gsub("SHARD","").capitalize)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = 1 if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} {3}", curnumber, (curnumber * itemprice[1]).to_s_formatted, itemprice[0].to_s.gsub("SHARD","").capitalize)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r>{2} {3}", curnumber, (curnumber * itemprice[1]).to_s_formatted, itemprice[0].to_s.gsub("SHARD","").capitalize)
            pbPlayCursorSE
          end
        elsif Input.trigger?(Input::USE)
          ret = curnumber
          break
        elsif Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = 0
          break
        end
      end
    end
    helpwindow.visible = false
    return ret
  end

  def pbChooseBuyItem
    itemwindow = @sprites["itemwindow"]
    @sprites["helpwindow"].visible = false
    pbActivateWindow(@sprites, "itemwindow") {
      pbRefresh
      loop do
        Graphics.update
        Input.update
        olditem = itemwindow.item
        self.update
        pbRefresh if itemwindow.item != olditem
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          return nil
        elsif Input.trigger?(Input::USE)
          if itemwindow.index < @stock.length
            pbRefresh
            return @stock[itemwindow.index]
          else
            return nil
          end
        end
      end
    }
  end
end

#===============================================================================
#
#===============================================================================
class ShardMartScreen
  def initialize(scene, stock)
    @scene = scene
    @stock = stock
    @adapter = ShardMartAdapter.new
  end

  def pbConfirm(msg)
    return @scene.pbConfirm(msg)
  end

  def pbDisplay(msg)
    return @scene.pbDisplay(msg)
  end

  def pbDisplayPaused(msg, &block)
    return @scene.pbDisplayPaused(msg, &block)
  end

  def pbBuyScreen
    @scene.pbStartBuyScene(@stock, @adapter)
    item = nil
    loop do
      item = @scene.pbChooseBuyItem
      break if !item
      quantity       = 0
      itemname       = @adapter.getDisplayName(item)
      itemnameplural = @adapter.getDisplayNamePlural(item)
      price = @adapter.getPrice(item)
      if @adapter.getMoney(price[0]) < price[1]
        pbDisplayPaused(_INTL("You don't have enough shards."))
        next
      end
      if GameData::Item.get(item).is_important?
        next if !pbConfirm(_INTL("So you want {1}?\nIt'll be {2} {3}. All right?",
                            itemname, price[1].to_s_formatted, (price[1] == 1 ? @adapter.getDisplayName(price[0]) : @adapter.getDisplayNamePlural(price[0]))))
        quantity = 1
      else
        maxafford = (price[1] <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney(price[0]) / price[1]
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        quantity = @scene.pbChooseNumber(
          _INTL("So how many {1}?", itemnameplural), item, maxafford
        )
        next if quantity == 0
        price[1] *= quantity
        if quantity > 1
          next if !pbConfirm(_INTL("So you want {1} {2}?\nThey'll be {3} <icon={4}>. All right?",
                                   quantity, itemnameplural, price[1].to_s_formatted, price[0]))
        elsif quantity > 0
          next if !pbConfirm(_INTL("So you want {1} {2}?\nIt'll be {3} <icon={4}>. All right?",
                                   quantity, itemname, price[1].to_s_formatted, price[0]))
        end
      end
      if @adapter.getMoney(price[0]) < price[1]
        pbDisplayPaused(_INTL("You don't have enough shards."))
        next
      end
      added = 0
      quantity.times do
        break if !@adapter.addItem(item)
        added += 1
      end
      if added == quantity
        $stats.mart_items_bought += quantity
        $bag.remove(price[0], price[1])
        @stock.delete_if { |item| GameData::Item.get(item).is_important? && checkItemAll(item) }
        pbDisplayPaused(_INTL("Here you are! Thank you!")) { pbSEPlay("mart_buy") }
        if quantity >= 10 && GameData::Item.exists?(:PREMIERBALL)
          if Settings::MORE_BONUS_PREMIER_BALLS && GameData::Item.get(item).is_poke_ball?
            premier_balls_added = 0
            (quantity / 10).times do
              break if !@adapter.addItem(:PREMIERBALL)
              premier_balls_added += 1
            end
            ball_name = GameData::Item.get(:PREMIERBALL).name
            ball_name = GameData::Item.get(:PREMIERBALL).name_plural if premier_balls_added > 1
            $stats.premier_balls_earned += premier_balls_added
            pbDisplayPaused(_INTL("And have {1} {2} on the house!", premier_balls_added, ball_name))
          elsif !Settings::MORE_BONUS_PREMIER_BALLS && GameData::Item.get(item) == :POKEBALL
            if @adapter.addItem(:PREMIERBALL)
              ball_name = GameData::Item.get(:PREMIERBALL).name
              $stats.premier_balls_earned += 1
              pbDisplayPaused(_INTL("And have 1 {1} on the house!", ball_name))
            end
          end
        end
      else
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("You have no room in your Bag."))
      end
    end
    @scene.pbEndBuyScene
  end
end

#===============================================================================
#
#===============================================================================
def pbShardMart(stock, speech = nil)
  stock.delete_if { |item| GameData::Item.get(item).is_important? && checkItemAll(item) }
  commands = []
  cmdBuy  = -1
  cmdQuit = -1
  commands[cmdBuy = commands.length]  = _INTL("Yes!")
  commands[cmdQuit = commands.length] = _INTL("No, thanks.")
  pbCallBub
  cmd = pbMessage(speech || _INTL("Welcome! How may I help you?"), commands, cmdQuit + 1)
  loop do
    if cmdBuy >= 0 && cmd == cmdBuy
      scene = ShardMart_Scene.new
      screen = ShardMartScreen.new(scene, stock)
      screen.pbBuyScreen
    else
      pbCallBub
      pbMessage(_INTL("Do come again!"))
      break
    end
    pbCallBub
    cmd = pbMessage(_INTL("Is there anything else I can do for you?"), commands, cmdQuit + 1)
  end
  $game_temp.clear_mart_prices
end
