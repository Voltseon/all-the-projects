#===============================================================================
# Abstraction layer for Secret Bases
#===============================================================================
class SecretBaseMartAdapter
  def getMoney
    return $player.money
  end

  def getMoneyString
    return pbGetGoldString
  end

  def setMoney(value)
    $player.money = value
  end

  def getInventory
    return $secret_bag
  end

  def getName(item)
    return GameData::SecretBaseDecoration.get(item).name
  end

  def getDisplayName(item)
    item_name = getName(item)
    return item_name
  end

  def getDescription(item)
    return GameData::SecretBaseDecoration.get(item).description
  end

  def getItemIcon(item)
    return (item) ? GameData::SecretBaseDecoration.icon_filename(item) : nil
  end

  def getPrice(item, selling = false)
    if $game_temp.mart_prices && $game_temp.mart_prices[item]
      if selling
        return $game_temp.mart_prices[item][1] if $game_temp.mart_prices[item][1] >= 0
      elsif $game_temp.mart_prices[item][0] > 0
        return $game_temp.mart_prices[item][0]
      end
    end
    return GameData::SecretBaseDecoration.get(item).sell_price if selling
    return GameData::SecretBaseDecoration.get(item).price
  end

  def getDisplayPrice(item, selling = false)
    price = getPrice(item, selling).to_s_formatted
    return _INTL("$ {1}", price)
  end

  def canSell?(item)
    return getPrice(item, true) > 0
  end
  
  def isPlaced?(pocket,index)
    return $secret_bag.is_placed?(pocket,index)
  end

  def addItem(item)
    return $secret_bag.add(item)
  end

  def removeItem(item)
    return $secret_bag.remove(item)
  end
  def removeItemAt(pocket,index)
    $secret_bag.remove_at_index(pocket,index)
  end
end

#===============================================================================
# Buy and Sell adapters
#===============================================================================
class BuyAdapter
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
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
class SellAdapter
  def initialize(adapter)
    @adapter = adapter
  end

  def getDisplayName(item)
    @adapter.getDisplayName(item)
  end

  def getDisplayPrice(item)
    return ""
  end

  def isSelling?
    return true
  end
end

#===============================================================================
#
#===============================================================================
class SecretBaseMart_Scene
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
      itemwindow.refresh
    end
    @sprites["moneywindow"].text = _INTL("Money:\r\n<r>{1}", @adapter.getMoneyString)
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
    @sprites["background"].setBitmap("Graphics/Pictures/SecretBases/secretMartScreen")
    @sprites["icon"] = SecretBaseDecorIconSprite.new(36, Graphics.height - 50, nil, @viewport)
    winAdapter = buying ? BuyAdapter.new(adapter) : SellAdapter.new(adapter)
    @sprites["itemwindow"] = Window_PokemonMart.new(
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
    pbDeactivateWindows(@sprites)
    @buying = buying
    pbRefresh
    Graphics.frame_reset
  end

  def pbStartBuyScene(stock, adapter)
    pbStartBuyOrSellScene(true, stock, adapter)
  end

  def pbStartSellScene(bag, adapter)
    @subscene = SecretBag_Scene.new
    @adapter = adapter
    @subscene.pbStartScene(bag)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewport
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["moneywindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["moneywindow"])
    @sprites["moneywindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["moneywindow"].visible = false
    @sprites["moneywindow"].viewport = @viewport
    @sprites["moneywindow"].x = 0
    @sprites["moneywindow"].y = 0
    @sprites["moneywindow"].width = 186
    @sprites["moneywindow"].height = 96
    @sprites["moneywindow"].baseColor = Color.new(88, 88, 80)
    @sprites["moneywindow"].shadowColor = Color.new(168, 184, 184)
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
    @viewport.dispose
    pbScrollMap(4, 5, 5) if !@subscene
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end

  def pbShowMoney
    pbRefresh
    @sprites["moneywindow"].visible = true
    if @buying
      @sprites["moneywindow"].x = 0
      @sprites["moneywindow"].y = 0
    else
      @sprites["moneywindow"].x = Graphics.width - @sprites["moneywindow"].width
      @sprites["moneywindow"].y = 64
    end
  end

  def pbHideMoney
    pbRefresh
    @sprites["moneywindow"].visible = false
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

  def pbChooseSellItem(continue_selection=false)
    return @subscene.pbChooseItem(continue_selection)
  end
end

#===============================================================================
#
#===============================================================================
class SecretBaseMartScreen
  def initialize(scene, stock)
    @scene = scene
    @stock = stock
    @adapter = SecretBaseMartAdapter.new
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
      itemname       = @adapter.getDisplayName(item)
      price = @adapter.getPrice(item)
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      next if !pbConfirm(_INTL("So you want {1}?\nIt'll be ${2}. All right?",
                            itemname, price.to_s_formatted))
      quantity = 1
      if @adapter.getMoney < price
        pbDisplayPaused(_INTL("You don't have enough money."))
        next
      end
      added = 0
      quantity.times do
        break if !@adapter.addItem(item)
        added += 1
      end
      if added == quantity
        $stats.money_spent_at_marts += price
        $stats.mart_items_bought += quantity
        @adapter.setMoney(@adapter.getMoney - price)
        pbDisplayPaused(_INTL("Thanks!\nI'll send it to your PC at home.")) { pbSEPlay("Mart buy item") }
      else
        added.times do
          if !@adapter.removeItem(item)
            raise _INTL("Failed to delete stored items")
          end
        end
        pbDisplayPaused(_INTL("The space for {1} is full.", itemname))
      end
    end
    @scene.pbEndBuyScene
  end

  def pbSellScreen
    @scene.pbStartSellScene(@adapter.getInventory, @adapter)
    item = [-1,-1]
    firstloop = true
    loop do
      item = @scene.pbChooseSellItem(!firstloop)
      break if item[0]<0
      decor = @adapter.getInventory.pockets[item[0]][item[1]]
      itemname       = @adapter.getDisplayName(decor[0])
      if @adapter.isPlaced?(item[0],item[1])
        pbDisplayPaused(_INTL("Sorry, that {1} is in use.\nI can't buy it.", itemname))
          next
      elsif !@adapter.canSell?(decor[0])
        pbDisplayPaused(_INTL("Oh, no. I can't buy the {1}.", itemname))
        next
      end
      price = @adapter.getPrice(decor[0], true)
      @scene.pbShowMoney
      if pbConfirm(_INTL("I can pay ${1}.\nWould that be OK?", price.to_s_formatted))
        old_money = @adapter.getMoney
        @adapter.setMoney(@adapter.getMoney + price)
        $stats.money_earned_at_marts += @adapter.getMoney - old_money
        @adapter.removeItemAt(item[0],item[1])
        sold_item_name = itemname
        pbDisplayPaused(_INTL("You turned over the {1} and got ${2}.",
                              sold_item_name, price.to_s_formatted)) { pbSEPlay("Mart buy item") }
        @scene.pbRefresh
      end
      @scene.pbHideMoney
      firstloop = false
    end
    @scene.pbEndSellScene
  end
end

#===============================================================================
#
#===============================================================================
def pbSecretBaseMart(stock, speech = nil, cansell = false)
  commands = []
  cmdBuy  = -1
  cmdSell = -1
  cmdQuit = -1
  commands[cmdBuy = commands.length]  = _INTL("I'm here to buy")
  commands[cmdSell = commands.length] = _INTL("I'm here to sell") if cansell
  commands[cmdQuit = commands.length] = _INTL("No, thanks")
  cmd = pbMessage(speech || _INTL("Welcome! How may I help you?"), commands, cmdQuit + 1)
  loop do
    if cmdBuy >= 0 && cmd == cmdBuy
      scene = SecretBaseMart_Scene.new
      screen = SecretBaseMartScreen.new(scene, stock)
      screen.pbBuyScreen
    elsif cmdSell >= 0 && cmd == cmdSell
      scene = SecretBaseMart_Scene.new
      screen = SecretBaseMartScreen.new(scene, stock)
      screen.pbSellScreen
    else
      pbMessage(_INTL("Do come again!"))
      break
    end
    cmd = pbMessage(_INTL("Is there anything else I can do for you?"), commands, cmdQuit + 1)
  end
  $game_temp.clear_mart_prices
end
