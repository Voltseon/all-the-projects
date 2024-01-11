#===============================================================================
# Abstraction layer for Pokemon Essentials
#===============================================================================
class PokemonMartAdapter_BattlePoints
  CUSTOM_PRICES = {
    :FIRESTONE => 5,
    :LEAFSTONE => 5,
    :WATERSTONE => 5,
    :THUNDERSTONE => 5,
    :CHOICEBAND => 10,
    :CHOICESPECS => 10,
    :CHOICESCARF => 10,
    :UTILITYUMBRELLA => 10,
    :HEAVYDUTYBOOTS => 10,
    :EJECTPACK => 10,
    :HITECHEARBUDS => 10,
    :TERRAINEXTENDER => 10,
    :THROATSPRAY => 10,
    :WEAKNESSPOLICY => 10,
    :BLUNDERPOLICY => 10,
    :FOCUSSASH => 15,
    :EVIOLITE => 15,
    :DEVIOLITE => 15,
    :RARECANDY => 30,
    :ABILITYCAPSULE => 30,
    :ABILITYPATCH => 40,
    :TIMEFLUTE => 50
  }

  DEFAULT_BATTLE_POINT_MART = [
    [
      :EVIOLITE, :DEVIOLITE, :RARECANDY,
      :ABILITYCAPSULE, :ABILITYPATCH, :TIMEFLUTE
    ],
    [
      :FIRESTONE, :LEAFSTONE, :WATERSTONE, :THUNDERSTONE,
      :CHOICEBAND, :CHOICESPECS, :CHOICESCARF
    ],
    [
      :UTILITYUMBRELLA, :HEAVYDUTYBOOTS, :EJECTPACK, :HITECHEARBUDS, :TERRAINEXTENDER, :THROATSPRAY,
      :WEAKNESSPOLICY, :BLUNDERPOLICY,
      :FOCUSSASH
    ]
  ]
  
  def getBattlePoints
    return $player.battle_points
  end

  def getBattlePointsString
    return ($player.battle_points).to_s
  end

  def setBattlePoints(value)
    $player.battle_points = value
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

  def getPrice(item, selling = false)
    if CUSTOM_PRICES[item]
      if selling
        return CUSTOM_PRICES[item] / 2
      else
        return CUSTOM_PRICES[item]
      end
    end
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if selling
        return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1] >= 0
      elsif $game_temp.mart_prices[item][0] > 0
        return $game_temp.mart_prices[item][0]
      end
    end
    endprice = (selling ? GameData::Item.get(item).sell_price / 100 : GameData::Item.get(item).price / 100)
    return 1 if endprice < 1
    return endprice
  end

  def getDisplayPrice(item, selling = false)
    price = getPrice(item, selling).to_s_formatted
    return _INTL("{1} BP", price)
  end

  def canSell?(item)
    return getPrice(item, true) > 0 && !GameData::Item.get(item).is_important?
  end

  def addItem(item)
    return $bag.add(item)
  end

  def removeItem(item)
    return $bag.remove(item)
  end
end

#===============================================================================
# Buy and Sell adapters
#===============================================================================
class BuyAdapter_BattlePoints
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
    @adapter.getDisplayPrice(item, false)
  end

  def isSelling?
    return false
  end
end

#===============================================================================
#
#===============================================================================
class SellAdapter_BattlePoints
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
    if @adapter.showQuantity?(item)
      return sprintf("x%d", @adapter.getQuantity(item))
    else
      return ""
    end
  end

  def isSelling?
    return true
  end
end

#===============================================================================
# Pokémon Mart
#===============================================================================
class Window_PokemonMart_BattlePoints < Window_DrawableCommand
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
class PokemonMart_Scene_BattlePoints
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
    @sprites["coinswindow"].text = _INTL("BP:\r\n<r>{1}", @adapter.getBattlePointsString)
  end

  def pbStartBuyOrSellScene(buying, stock, adapter)
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
    winAdapter = buying ? BuyAdapter_BattlePoints.new(adapter) : SellAdapter_BattlePoints.new(adapter)
    @sprites["itemwindow"] = Window_PokemonMart_BattlePoints.new(
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
    @sprites["coinswindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["coinswindow"])
    @sprites["coinswindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["coinswindow"].visible = true
    @sprites["coinswindow"].viewport = @viewport
    @sprites["coinswindow"].x = 0
    @sprites["coinswindow"].y = 0
    @sprites["coinswindow"].width = 190
    @sprites["coinswindow"].height = 96
    @sprites["coinswindow"].baseColor = Color.new(88, 88, 80)
    @sprites["coinswindow"].shadowColor = Color.new(168, 184, 184)
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
    @buying = buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock, adapter)
    pbStartBuyOrSellScene(true, stock, adapter)
  end

  def pbStartSellScene(bag, adapter)
    if $bag
      pbStartSellScene2(bag, adapter)
    else
      pbStartBuyOrSellScene(false, bag, adapter)
    end
  end

  def pbStartSellScene2(bag, adapter)
    @subscene = PokemonBag_Scene.new
    @adapter = adapter
    @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 99999
    numFrames = Graphics.frame_rate * 4 / 10
    alphaDiff = (255.0 / numFrames).ceil
    (0..numFrames).each do |j|
      col = Color.new(0, 0, 0, j * alphaDiff)
      @viewport2.color = col
      Graphics.update
      Input.update
    end
    @subscene.pbStartScene(bag,$player.party)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["coinswindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["coinswindow"])
    @sprites["coinswindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["coinswindow"].visible = false
    @sprites["coinswindow"].viewport = @viewport
    @sprites["coinswindow"].x = 0
    @sprites["coinswindow"].y = 0
    @sprites["coinswindow"].width = 186
    @sprites["coinswindow"].height = 96
    @sprites["coinswindow"].baseColor = Color.new(88, 88, 80)
    @sprites["coinswindow"].shadowColor = Color.new(168, 184, 184)
    pbDeactivateWindows(@sprites)
    @buying = false
    pbRefresh
  end

  def pbEndBuyScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    # Scroll left after showing screen
    pbScrollMap(4, 5, 5)
  end

  def pbEndSellScene
    @subscene&.pbEndScene
    pbDisposeSpriteHash(@sprites)
    if @viewport2
      numFrames = Graphics.frame_rate * 4 / 10
      alphaDiff = (255.0 / numFrames).ceil
      (0..numFrames).each do |j|
        col = Color.new(0, 0, 0, (numFrames - j) * alphaDiff)
        @viewport2.color = col
        Graphics.update
        Input.update
      end
      @viewport2.dispose
    end
    @viewport.dispose
    pbScrollMap(4, 5, 5) if !@subscene
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end

  def pbShowBattlePoints
    pbRefresh
    @sprites["coinswindow"].visible = true
  end

  def pbHideBattlePoints
    pbRefresh
    @sprites["coinswindow"].visible = false
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
    itemprice = @adapter.getPrice(item, !@buying)
    itemprice /= 2 if !@buying
    pbDisplay(helptext, true)
    using(numwindow = Window_AdvancedTextPokemon.new("")) do   # Showing number of items
      pbPrepareWindow(numwindow)
      numwindow.viewport = @viewport
      numwindow.width = 224
      numwindow.height = 64
      numwindow.baseColor = Color.new(88, 88, 80)
      numwindow.shadowColor = Color.new(168, 184, 184)
      numwindow.text = _INTL("x{1}<r> {2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
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
            numwindow.text = _INTL("x{1}<r> {2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::RIGHT)
          curnumber += 10
          curnumber = maximum if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r> {2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::UP)
          curnumber += 1
          curnumber = 1 if curnumber > maximum
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r> {2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
            pbPlayCursorSE
          end
        elsif Input.repeat?(Input::DOWN)
          curnumber -= 1
          curnumber = maximum if curnumber < 1
          if curnumber != oldnumber
            numwindow.text = _INTL("x{1}<r> {2} BP", curnumber, (curnumber * itemprice).to_s_formatted)
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

  def pbChooseSellItem
    if @subscene
      return @subscene.pbChooseItem
    else
      return pbChooseBuyItem
    end
  end
end

#===============================================================================
#
#===============================================================================
class PokemonMartScreen_BattlePoints
  def initialize(scene, stock)
    @scene = scene
    @stock = stock
    @adapter = PokemonMartAdapter_BattlePoints.new
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
      if @adapter.getBattlePoints < price
        pbDisplayPaused(_INTL("You don't have enough BP."))
        next
      end
      if GameData::Item.get(item).is_important?
        next if !pbConfirm(_INTL("So you want {1}?\nIt'll be {2} BP. All right?",
                            itemname, price.to_s_formatted))
        quantity = 1
      else
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getBattlePoints / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        quantity = @scene.pbChooseNumber(
          _INTL("So how many {1}?", itemnameplural), item, maxafford
        )
        next if quantity == 0
        price *= quantity
        if quantity > 1
          next if !pbConfirm(_INTL("So you want {1} {2}?\nThey'll be {3} BP. All right?",
                                   quantity, itemnameplural, price.to_s_formatted))
        elsif quantity > 0
          next if !pbConfirm(_INTL("So you want {1} {2}?\nIt'll be {3} BP. All right?",
                                   quantity, itemname, price.to_s_formatted))
        end
      end
      if @adapter.getBattlePoints < price
        pbDisplayPaused(_INTL("You don't have enough BP."))
        next
      end
      added = 0
      quantity.times do
        break if !@adapter.addItem(item)
        added += 1
      end
      if added == quantity
        $stats.mart_items_bought += quantity
        @adapter.setBattlePoints(@adapter.getBattlePoints - price)
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
def pbPokemonMart_BattlePoints(stock, speech = nil, cantsell = false)
  stock.delete_if { |item| GameData::Item.get(item).is_important? && checkItemAll(item) }
  pbCallBub
  pbMessage(speech || _INTL("\\bWelcome! How may I help you?"))
  scene = PokemonMart_Scene_BattlePoints.new
  screen = PokemonMartScreen_BattlePoints.new(scene, stock)
  screen.pbBuyScreen
  $game_temp.clear_mart_prices
end
