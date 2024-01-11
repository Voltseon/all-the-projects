
BOUGHT_SWITCH = 77
NEW_BADGE_SWITCH = 98

class Trainer
    attr_writer :characters_met
    attr_writer :bought_items

    # Professor, Rival, David, Fitch, Laura-Gene, Ariel, Nathan, Morgan, Arsenio, Elsie & Sigfried
    def characters_met
        @characters_met = [false,false,false,false,false,false,false,false,false,false] if !@characters_met
        return @characters_met
    end

    def bought_items
        @bought_items = [] if !@bought_items
        return @bought_items
    end
end

#-------------------------------------------------------------------------------
# Entry for Pager Screen
#-------------------------------------------------------------------------------
class MenuEntryPager < MenuEntry
	def initialize
		@icon = "menuPager"
		@name = "Pager"
	end

    def selected(menu)
        menu.pbHideMenu
        pbUsePager
        menu.pbShowMenu
	end

	def selectable?; return $PokemonBag.pbHasItem?(:PAGER); end
end

MENU_ENTRIES.push("MenuEntryPager")

class PokemonMartScreen
    def pbBuyScreen(from_pager=false)
        @scene.pbStartBuyScene(@stock,@adapter)
        item=nil
        bought=false
        loop do
          item=@scene.pbChooseBuyItem
          break if !item
          quantity=0
          itemname=@adapter.getDisplayName(item)
          price=@adapter.getPrice(item)
          if @adapter.getMoney<price
            pbDisplayPaused(_INTL("You don't have enough money."))
            next
          end
          if GameData::Item.get(item).is_important?
            if from_pager
                if !pbConfirm(_INTL("A {1} will be ${2}. OK?",
                itemname,price.to_s_formatted))
                next
                end
            else
                if !pbConfirm(_INTL("Certainly. You want {1}. That will be ${2}. OK?",
                    itemname,price.to_s_formatted))
                next
                end
            end
            quantity=1
          else
            maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : @adapter.getMoney / price
            maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
            if from_pager
                quantity=@scene.pbChooseNumber(_INTL("How many of {1}?",itemname),item,maxafford)
            else
            quantity=@scene.pbChooseNumber(
                _INTL("{1}? Certainly. How many would you like?",itemname),item,maxafford)
            end
            next if quantity==0
            price*=quantity
            if from_pager
                if !pbConfirm(_INTL("{2} of {1} will be ${3}. OK?",
                itemname,quantity,price.to_s_formatted))
                next
                end
            else
                if !pbConfirm(_INTL("{1}, and you want {2}. That will be ${3}. OK?",
                    itemname,quantity,price.to_s_formatted))
                next
                end
            end
          end
          if @adapter.getMoney<price
            pbDisplayPaused(_INTL("You don't have enough money."))
            next
          end
          added=0
          quantity.times do
            if from_pager
                $Trainer.bought_items.push(item)
                $game_switches[BOUGHT_SWITCH] = true
            else
                break if !@adapter.addItem(item)
            end
            bought=true
            added+=1
          end
          if added!=quantity
            added.times do
              if !@adapter.removeItem(item)
                raise _INTL("Failed to delete stored items")
              end
            end
            pbDisplayPaused(_INTL("You have no more room in the Bag."))
          else
            @adapter.setMoney(@adapter.getMoney-price)
            for i in 0...@stock.length
              if GameData::Item.get(@stock[i]).is_important? && $PokemonBag.pbHasItem?(@stock[i])
                @stock[i]=nil
              end
            end
            @stock.compact!
            pbDisplayPaused(_INTL("Items have been processed!")) { pbSEPlay("Mart buy item") }
            if $PokemonBag
              if quantity>=10 && GameData::Item.get(item).is_poke_ball? && GameData::Item.exists?(:PREMIERBALL)
                if from_pager
                    if $Trainer.bought_items.push(GameData::Item.get(:PREMIERBALL))
                        pbDisplayPaused(_INTL("A Premier Ball has also been added as a bonus."))
                    end
                else
                    if @adapter.addItem(GameData::Item.get(:PREMIERBALL))
                        pbDisplayPaused(_INTL("I'll throw in a Premier Ball, too."))
                    end
                end
              end
            end
            pbDisplayPaused(_INTL("Your items will be available in any PTA Center!")) if from_pager && bought==true
          end
        end
        @scene.pbEndBuyScene
      end
end

def pbReceiveStoredItems
    return false if $Trainer.bought_items.length < 1
    return false if !$game_switches[BOUGHT_SWITCH]
    if $Trainer.bought_items.length == 1
        item = GameData::Item.get($Trainer.bought_items[0])
        pbMessage(_INTL("Here's your item."))
        pbMessage(_INTL("\\me[Item get]You obtained a \\c[1]{1}\\c[0] from the \\c[2]Pager Market\\c[0]!\\wtnp[30]",item.name))
        pbMessage(_INTL("You put the {1} away\\nin the <icon=bagPocket{2}>\\c[1]{3} Pocket\\c[0].",item.name,item.pocket,PokemonBag.pocketNames()[item.pocket]))
    else
        pbMessage(_INTL("Here are your items."))
        pbMessage(_INTL("\\me[Item get]You obtained items from the \\c[2]Pager Market\\c[0]!\\wtnp[30]"))
    end

    $game_switches[BOUGHT_SWITCH] = false


    for i in 0..$Trainer.bought_items.length-1
        $PokemonBag.pbStoreItem(GameData::Item.get($Trainer.bought_items[i]))
    end
    $Trainer.bought_items = []
    return true
end

def pbUsePager
    $game_temp.in_menu = false
    pbSEPlay("PC open")
    stock = generate_stock
    for i in 0...stock.length
        stock[i] = GameData::Item.get(stock[i]).id
        stock[i] = nil if GameData::Item.get(stock[i]).is_important? && $PokemonBag.pbHasItem?(stock[i])
    end
    stock.compact!
    commands = []
    cmdMessage = -1
    cmdBuy  = -1
    cmdSell = -1
    cmdClose = -1
    cmdMap = -1
    cmdPokeSearch = -1
    commands[cmdMessage = commands.length]  = _INTL("Call")
    commands[cmdBuy = commands.length]  = _INTL("Buy Items")
    commands[cmdSell = commands.length] = _INTL("Sell Items")
    commands[cmdMap = commands.length] = _INTL("Map")
    commands[cmdPokeSearch = commands.length] = _INTL("PokéSearch")
    commands[cmdClose = commands.length] = _INTL("Close")
    cmd = pbMessage(
        _INTL("What would you like to do?"),
        commands,cmdClose+1)
    loop do
        if cmdMessage>=0 && cmd==cmdMessage
            pbSEPlay("PC access")
            send_message
        elsif cmdBuy>=0 && cmd==cmdBuy
            pbSEPlay("PC access")
            if $game_switches[NEW_BADGE_SWITCH]
                pbMessage(_INTL("New items have been added!"))
                $game_switches[NEW_BADGE_SWITCH] = false
            end
            scene = PokemonMart_Scene.new
            screen = PokemonMartScreen.new(scene,stock)
            screen.pbBuyScreen(true)
        elsif cmdSell>=0 && cmd==cmdSell
            pbSEPlay("PC access")
            scene = PokemonMart_Scene.new
            screen = PokemonMartScreen.new(scene,stock)
            screen.pbSellScreen
        elsif cmdMap>=0 && cmd==cmdMap
            pbShowMap(-1,false)
        elsif cmdPokeSearch>=0 && cmd == cmdPokeSearch
          scene = PokeSearch_Scene.new
          screen = PokeSearch_Screen.new(scene)
          screen.pbStartScreen
          break
        else
            pbSEPlay("PC close")
            break
        end
        cmd = pbMessage(_INTL("What would you like to do?"),
            commands,cmdClose+1)
    end
    $game_temp.clear_mart_prices
end

ItemHandlers::UseFromBag.add(:PAGER, proc { |item|
    next 2
})

ItemHandlers::UseInField.add(:PAGER,proc { |item|
    pbUsePager
    next true
})

def send_message
    commands = []

    cmdMom = -1
    cmdDad = -1
    cmdLoblolly = -1
    cmdRival = -1
    cmdDavid = -1
    cmdFitch = -1
    cmdLauraGene = -1
    cmdAriel = -1
    cmdNat = -1
    cmdMorgan = -1
    cmdArsenio = -1
    cmdElsieSigfried = -1
    cmdBack = -1

    commands[cmdMom= commands.length]  = _INTL("Mom")
    commands[cmdDad = commands.length]  = _INTL("Dad")
    commands[cmdLoblolly = commands.length]  = _INTL("Prof. Loblolly") if $Trainer.characters_met[0]
    commands[cmdRival = commands.length]  = _INTL("Howlight Harlequin") if $Trainer.characters_met[1]
    commands[cmdDavid  = commands.length]  = _INTL("David") if $Trainer.characters_met[2]
    commands[cmdFitch  = commands.length]  = _INTL("Fitch") if $Trainer.characters_met[3]
    commands[cmdLauraGene  = commands.length]  = _INTL("Laura-Gene") if $Trainer.characters_met[4]
    commands[cmdAriel  = commands.length]  = _INTL("Ariel") if $Trainer.characters_met[5]
    commands[cmdNat  = commands.length]  = _INTL("Nathan") if $Trainer.characters_met[6]
    commands[cmdMorgan  = commands.length]  = _INTL("Morgan") if $Trainer.characters_met[7]
    commands[cmdArsenio  = commands.length]  = _INTL("Arsenio") if $Trainer.characters_met[8]
    commands[cmdElsieSigfried  = commands.length]  = _INTL("Elsie & Sigfried") if $Trainer.characters_met[9]
    commands[cmdBack = commands.length] = _INTL("Back")

    #momMessages = [_INTL("\\rI hope you're doing well sweety! Come by soon!"), _INTL("\\rAHHHH!!!")] momMessages[rand(0..momMessages.length-1)

    cmd = pbMessage(_INTL("Who would you like to call?"),commands,cmdBack+1)
    loop do
        if cmdMom>=0 && cmd==cmdMom
            pbWaitForCall(true)
            if $game_switches[55] # Post Seashore Town Attack (This is not the actual switch)
                pbMessage(_INTL("Mom: \\rHello? \\PN? Oh, it's you!"))
                pbMessage(_INTL("\\rHave you seen your father yet? If you do, let him know I have pancakes waiting!"))
                pbMessage(_INTL("\\rCall back soon, darling."))
            elsif $game_map.map_id == 33
                event = get_event_from_id(24)
                event.turn_toward_player
                pbMessage(_INTL("Mom: \\rHello? \\PN? Why are you calling me?"))
                pbMessage(_INTL("\\rYou are in the house, just come and talk to me in person like a normal person!"))
            else
                pbMessage(_INTL("Mom: \\rHello? \\PN? Oh, it's you!"))
                pbMessage(_INTL("\\rI trust you to bring your father home safe. But please make sure to take care of yourself too!"))
                pbMessage(_INTL("\\rDrink lots of water, and don't forget to take care of your Pokémon too."))
                pbMessage(_INTL("\\rI love you, darling!"))
            end
            pbSEPlay("PC close")
        elsif cmdDad>=0 && cmd==cmdDad
            pbWaitForCall(false)
        elsif cmdLoblolly>=0 && cmd==cmdLoblolly
            pbWaitForCall(true)
            if $game_switches[78] # Has paged Loblolly before
                pbMessage(_INTL("Loblolly: \\bOh, it's you \\PN! The experiment has settled itself."))
                pbMessage(_INTL("\\bSo how are you enjoying your journey? Catch any cool Pokémon?"))
                pbMessage(_INTL("\\bIf you ever feel like coming back to visit, make sure to see your mother first."))
                pbMessage(_INTL("\\bNothing is more important than famalial ties!"))
            elsif $game_map.map_id == 116
                event = get_event_from_id(5)
                event.turn_toward_player
                pbMessage(_INTL("Loblolly: \\b\\PN! I can see you calling me from over there!"))
                pbMessage(_INTL("\\bCome over here and talk to me."))
            else
                pbMessage(_INTL("Loblolly: \\bOh, it's you \\PN! How have you been?"))
                pbMessage(_INTL("\\bI certainly hope you've been enjoying your classic-\\se[Battle damage weak]"))
                pbMessage(_INTL("\\b...Oh, oh! I'm sorry, I need to run. One of my experiments has gone terribly wrong!"))
                pbMessage(_INTL("\\bToodaloo!\\wtnp[20]"))
                $game_switches[78] = true # Has paged Loblolly before
            end
            pbSEPlay("PC close")
        elsif cmdRival>=0 && cmd==cmdRival
            pbWaitForCall(false)
        elsif cmdDavid>=0 && cmd==cmdDavid
            pbWaitForCall(true)
            pbMessage(_INTL("David: \\bHello \\PN! I certainly didn't expect a call at this time of day."))
            pbMessage(_INTL("\\bHow's your journey going? Are you catching enough Pokémon?"))
            pbMessage(_INTL("\\bYou know the more Pokémon you catch the more well-rounded your team will become!"))
            pbSEPlay("PC close")
        elsif cmdFitch>=0 && cmd==cmdFitch
            pbWaitForCall(true)
            pbMessage(_INTL("Fitch: \\bWhat a surprise to receive a call from my favorite trainer!"))
            pbMessage(_INTL("\\b\\PN, how is your adventure going? Are you getting lots of excercise?"))
            pbMessage(_INTL("\\bI bet traveling so far makes you pretty tired! Be sure to drink lots of water."))
            pbSEPlay("PC close")
        elsif cmdLauraGene>=0 && cmd==cmdLauraGene
            pbWaitForCall(true)
            pbMessage(_INTL("Laura-Gene: \\rDelightful to hear from you, \\PN."))
            pbMessage(_INTL("\\rAre you... Looking for advice? I guess I have some words of wisdom."))
            pbMessage(_INTL("\\rDon't be afraid to slow down and take your time. Smell the roses, as you will."))
            pbMessage(_INTL("\\rThey smell pretty good where you are, I hear."))
            pbSEPlay("PC close")
        else
            pbSEPlay("PC close")
            break
        end
        cmd = pbMessage(_INTL("Who would you like to call?"),commands,cmdBack+1)
    end
end

def pbWaitForCall(go_through=true)
    waitingMessage = "\\se[Voltorb Flip gain coins]...\\. \\se[Voltorb Flip gain coins]...\\. \\se[Voltorb Flip gain coins]...\\| "
    finalMessage = ""
    for i in 0..rand(1,2); finalMessage += waitingMessage; end
    pbMessage(_INTL("{1}\\wtnp[2]", finalMessage))
    if go_through
        pbSEPlay("GUI save choice")
        return true
    end
    pbSEPlay("GUI sel buzzer")
    pbMessage(_INTL("No one picked up..."))
    return false
end

def generate_stock
    case $Trainer.badge_count
    when 0
        return [
            :POKEBALL,
            :POTION,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :ESCAPEROPE,
            :REPEL
          ]
    when 1
        return [
            :POKEBALL, :GREATBALL,
            :POTION, :SUPERPOTION,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL
            ]
    when 2
        return [
            :POKEBALL, :GREATBALL,
            :POTION, :SUPERPOTION,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL,
            :LUCKYEGG
            ]
    when 3
        return [
            :POKEBALL, :GREATBALL,
            :POTION, :SUPERPOTION,
            :HYPERPOTION,
            :REVIVE,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL,
            :LUCKYEGG
            ]
    when 4
        return [
            :POKEBALL, :GREATBALL,
            :POTION, :SUPERPOTION,
            :HYPERPOTION,
            :REVIVE,
            :ETHER,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :FULLHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL, :MAXREPEL,
            :LUCKYEGG
            ]
    when 5
        return [
            :POKEBALL, :GREATBALL, :ULTRABALL,
            :POTION, :SUPERPOTION,
            :HYPERPOTION,
            :REVIVE,
            :ETHER, :ELIXIR,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :FULLHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL, :MAXREPEL,
            :LUCKYEGG, :EVIOLITE
            ]
    when 6
        return [
            :POKEBALL, :GREATBALL, :ULTRABALL,
            :QUICKBALL, :TIMERBALL,
            :POTION, :SUPERPOTION,
            :HYPERPOTION, :MAXPOTION,
            :REVIVE,
            :ETHER, :ELIXIR,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :FULLHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL, :MAXREPEL,
            :LUCKYEGG, :EVIOLITE,
            :BLACKSLUDGE, :PURITYORB
            ]
    when 7
        return [
            :POKEBALL, :GREATBALL, :ULTRABALL,
            :QUICKBALL, :TIMERBALL, :DUSKBALL,
            :POTION, :SUPERPOTION,
            :HYPERPOTION, :MAXPOTION,
            :REVIVE,
            :ETHER, :MAXETHER, :ELIXIR,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :FULLHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL, :MAXREPEL,
            :LUCKYEGG, :EVIOLITE,
            :BLACKSLUDGE, :PURITYORB, :SHELLBELL,
            :ABILITYCANDY
            ]
    else
        return [
            :POKEBALL, :GREATBALL, :ULTRABALL,
            :QUICKBALL, :TIMERBALL, :DUSKBALL,
            :POTION, :SUPERPOTION,
            :HYPERPOTION, :MAXPOTION,
            :FULLRESTORE,:REVIVE,
            :ETHER, :MAXETHER, :ELIXIR, :MAXELIXIR,
            :ANTIDOTE, :PARALYZEHEAL,
            :AWAKENING, :BURNHEAL, :ICEHEAL,
            :PETRIFYHEAL, :FULLHEAL, :ESCAPEROPE,
            :REPEL, :SUPERREPEL, :MAXREPEL,
            :LUCKYEGG, :EVIOLITE,
            :BLACKSLUDGE, :PURITYORB, :SHELLBELL,
            :ABILITYCANDY, :HIDDENABILITYCANDY,
            :DUSKSTONE, :DAWNSTONE
            ]
    end
end
