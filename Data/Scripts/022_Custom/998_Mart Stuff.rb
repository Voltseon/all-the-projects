def vPokeballsInFront(arr)
  return [] unless arr.is_a?(Array)
  ret = []
  bin = []
  arr.each do |i|
    item = GameData::Item.get(i)
    next unless item.is_poke_ball?
    ret.push(i)
    bin.push(i)
  end
  bin.each { |trash| arr.delete(trash) }
  ret.reverse!
  ret += arr
  return ret
end

def vNormalMart
  pbCallBub
  message = _INTL("\\bHello and welcome to the {1}! How may I help you?",$game_map.name)
  stock = $player.mart_stock[0]
  stock += $player.mart_stock[1] if $game_switches[60]
  stock += $player.mart_stock[2] if $player.badge_count > 0
  stock += $player.mart_stock[3] if $player.badge_count > 1
  stock += $player.mart_stock[4] if $player.badge_count > 2
  stock += $player.mart_stock[5] if $player.badge_count > 3
  stock += $player.mart_stock[6] if $player.badge_count > 4
  stock += $player.mart_stock[7] if $player.badge_count > 6
  stock += $player.mart_stock[8] if $player.badge_count > 7
  stock.sort! { |a, b| GameData::Item.keys.index(a) <=> GameData::Item.keys.index(b) }
  stock = vPokeballsInFront(stock)
  stock.insert(0,:HMEMULATOR) if $player.badge_count > 0
  pbPokemonMart(stock, message)
end

def vSpecialMart(mart_type, tmlist = [], additions = [])
  return false unless [:MEGA,:MINTS,:VITAMINS,:MEDICINE,:BALLS,:TYPEITEM,:EVO,:TM,:PLATES,:OTHER1,:OTHER2,:OTHER3,:SIG].include?(mart_type)
  pbCallBub
  message = _INTL("\\rHello and welcome to the {1}! How may I help you?",$game_map.name)
  stock = []
  case mart_type
  when :VITAMINS # Done
    stock = $player.mart_stock[9]
  when :MEDICINE # Done
    stock = $player.mart_stock[10]
  when :BALLS # Done
    stock = $player.mart_stock[11]
  when :TYPEITEM # Done
    stock = $player.mart_stock[12]
    stock += $player.mart_stock[23] if $player.has_pdaplus
  when :MINTS # Done
    stock = $player.mart_stock[13]
  when :MEGA # Done
    stock = $player.mart_stock[14]
    stock.each { |i| setPrice(i,5000); setSellPrice(i,0) }
  when :EVO # Done
    stock = $player.mart_stock[15]
  when :TM # Done
    tmlist.each do |tm|
      inst = "TM"
      inst += "0" if tm < 10
      inst += "#{tm}"
      stock.push(inst.to_sym)
    end
  when :SIG # Done
    stock = $player.mart_stock[16]
  when :PLATES # Done
    stock = $player.mart_stock[17]
  when :OTHER1 # Done
    stock = $player.mart_stock[18]
  when :OTHER2 # Done
    stock = $player.mart_stock[19]
  when :OTHER3 # Done
    stock = $player.mart_stock[20]
  end
  stock.sort! { |a, b| GameData::Item.keys.index(a) <=> GameData::Item.keys.index(b) }# unless mart_type == :VITAMINS
  additions.sort! { |a, b| GameData::Item.keys.index(a) <=> GameData::Item.keys.index(b) }
  stock = additions + stock
  pbPokemonMart(stock, message)
end

def vBerryShop(msg=true)
  if msg
    pbCallBub
    message = _INTL("\\rWelcome visitor to the Dim Village Berry House! How may I be of assistance?")
  else
    pbCallBub
    message = _INTL("\\rHello and welcome to the {1}! How may I help you?",$game_map.name)
  end
  stock = $player.mart_stock[22]
  stock.sort! { |a, b| GameData::Item.keys.index(a) <=> GameData::Item.keys.index(b) }
  pbPokemonMart(stock, message, true)
end

def vBikeMart
  pbCallBub
  message = _INTL("\\bHello there trainer, how may I help you?")
  pbPokemonMart([:ACROBIKE,:MACHBIKE], message, true)
end

def vCenterInteract(balls_id)
  return if $game_switches[1]
  thisevent = get_self
  pbSetPokemonCenter
  pbCallBub
  pbMessage("\\rHello, and welcome to the #{$game_map.name}.")
  pbCallBub
  pbMessage("\\rWe restore your tired Pokémon to full health.")
  pbCallBub
  if pbConfirmMessage("\\rWould you like to rest your Pokémon?")
    pbCallBub
    pbMessage("\\rOK, I'll take your Pokémon for a few seconds.")
    $stats.poke_center_count += 1
    MakeHealingBallGraphics.new
    FollowingPkmn.toggle_off(true)
    if Settings.pbGetGeneration >= 8   # No need to heal stored Pokémon
      $player.heal_party
    else
      pbEachPokemon { |pkmn, box| pkmn.heal }   # Includes party Pokémon
    end
    pbMoveRoute(thisevent,[PBMoveRoute::TurnLeft,PBMoveRoute::Wait,2],true)
    pbSet(6,0)
    count = $player.pokemon_count
    for i in 1..count
      pbSet(6, i)
      pbSEPlay("Battle ball shake")
      pbWait(16)
    end
    pbMoveRoute(get_character(balls_id),[PBMoveRoute::StepAnimeOn])
    pbMEPlay("Pkmn healing")
    pbWait(58)
    pbSet(6,0)
    get_character(balls_id).pattern = 0
    pbMoveRoute(get_character(balls_id),[PBMoveRoute::WalkAnimeOff])
    pbMoveRoute(thisevent,[PBMoveRoute::Wait,15,PBMoveRoute::TurnDown],true)
    FollowingPkmn.toggle_on(true)
    pbWait(15)
    if pbPokerus?
      pbCallBub
      pbMessage("\\rYour Pokémon may be infected by PokéRus.")
      pbCallBub
      pbMessage("\\rLittle is known about the PokeRus except that they are microscopic life-forms that attach to Pokémon.")
      pbCallBub
      pbMessage("\\rWhile infected, Pokémon are said to grow exceptionally well.")
      $game_switches[2] = true
    else
      pbCallBub
      pbMessage("\\rThank you for waiting.")
      pbCallBub
      pbMessage("\\rWe've restored your Pokémon to full health.")
      pbMoveRoute(thisevent,[PBMoveRoute::Graphic,"NPC 13",0,8,3,PBMoveRoute::Wait,15,PBMoveRoute::Graphic,"NPC 13",0,2,0],true)
      pbCallBub
      pbMessage("\\rWe hope to see you again!")
    end
  else
    pbCallBub
    pbMessage("\\rWe hope to see you again!")
  end
end

def vCenterBlackout(balls_id)
  $game_switches[1] = false
  thisevent = get_self
  pbCallBub
  pbMessage("\\rFirst, you should restore your Pokémon to full health.")
  $stats.poke_center_count += 1
  MakeHealingBallGraphics.new
  if Settings.pbGetGeneration >= 8   # No need to heal stored Pokémon
    $player.heal_party
  else
    pbEachPokemon { |pkmn, box| pkmn.heal }   # Includes party Pokémon
  end
  pbMoveRoute(thisevent,[PBMoveRoute::TurnLeft,PBMoveRoute::Wait,2],true)
  pbSet(6,0)
  count = $player.pokemon_count
  for i in 1..count
    pbSet(6, i)
    pbSEPlay("Battle ball shake")
    pbWait(16)
  end
  pbMoveRoute(get_character(balls_id),[PBMoveRoute::StepAnimeOn])
  pbMEPlay("Pkmn healing")
  pbWait(58)
  pbSet(6,0)
  get_character(balls_id).pattern = 0
  pbMoveRoute(get_character(balls_id),[PBMoveRoute::WalkAnimeOff])
  pbMoveRoute(thisevent,[PBMoveRoute::Wait,15,PBMoveRoute::TurnDown],true)
  pbWait(15)
  pbCallBub
  pbMessage("\\rYour Pokémon have been healed to perfect health.")
  pbMoveRoute(thisevent,[PBMoveRoute::Graphic,"NPC 13",0,8,3,PBMoveRoute::Wait,15,PBMoveRoute::Graphic,"NPC 13",0,2,0],true)
  pbCallBub
  pbMessage("\\rWe hope you excel!")
end

def vVendingMachine
  unless $game_player.direction==8
    pbMessage("It's a vending machine.")
    return
  end
  choices = $player.mart_stock[21]
  commands = []
  choices.each_with_index do |c, index|
    item = GameData::Item.get(c)
    commands.push("#{item.name} - $#{item.price}")
  end
  commands.push("Cancel")
  command = pbMessage("It's a vending machine.\nWhich drink would you like?\\G", commands, 5)
  return false if command == 4
  item = choices[command]
  item_data = GameData::Item.get(item)
  price = item_data.price
  item_name = item_data.name
  if $player.money.decrypt >= price
    if $bag.can_add?(item)
      $player.money = $player.money.decrypt - price
      pbMessage(_INTL("\\G\\se[mart_buy]You paid ${1}.",price))
      pbSEPlay("actual_vending")
      $stats.drinks_bought += 1
      $bag.add(item)
      pbMessage("\\GA #{item_name} dropped down!\\me[RSE 220 Obtained an Item!]\\wtnp[30]")
      if rand(10) == 1 && $bag.can_add?(item) && !$player.murphyslaw
        pbExclaim($game_player)
        pbSEPlay("actual_vending")
        if rand(10) == 1 && !$bag.has?(:SILVERMERCURY)
          pbItemBall(:SILVERMERCURY)
        else
          $stats.drinks_won += 1
          $bag.add(item)
          pbMessage("Bonus! Another #{item_name} dropped down.\\me[RSE 220 Obtained an Item!]\\wtnp[30]")
        end
      end
    else
      pbMessage("\\GYou have no room left in the Bag.")
    end
  else
    pbMessage("\\GYou don't have enough money.")
  end
end

def vMegaStone
  ret = :AUDINITE
  if pbGet(26) == 1 || pbGet(26) == 3
    case pbGet(7)
    when 1 then (pbGet(26) == 1) ? ret = :VENUSAURITE : ret = :SCEPTILITE
    when 2 then (pbGet(26) == 1) ? ret = :CHARIZARDITEX : ret = :BLAZIKENITE
    when 3 then (pbGet(26) == 1) ? ret = :BLASTOISINITE : ret = :SWAMPERTITE
    end
  end
  pbReceiveItem(ret)
  pbReceiveItem(:CHARIZARDITEY) if ret == :CHARIZARDITEX
end

def vOtherMegaStone
  [:AUDINITE,:VENUSAURITE,:SCEPTILITE,:CHARIZARDITEX,:CHARIZARDITEY,:BLAZIKENITE,:BLASTOISINITE,:SWAMPERTITE].each do |i|
    $bag.add(i) unless $item_log.found_items.include?(i)
  end
  pocket = 1
  pbMessage("\\me[Mega stone get]You obtained some mega stones!\\wtnp[30]")
  pbMessage(_INTL("You put them in\\nyour Bag's <icon=bagPocket{1}>\\c[1]{2}\\c[0] pocket.", pocket, PokemonBag.pocket_names[pocket - 1]))
end

def vSwapCan
  can = vHI(:SQUIRTBOTTLE) ? :SQUIRTBOTTLE : vHI(:SPRAYDUCK) ? :SPRAYDUCK : vHI(:SPRINKLOTAD) ? :SPRINKLOTAD : vHI(:WAILMERPAIL) ? :WAILMERPAIL : :SQUIRTBOTTLE
  choices = []
  choices.push("Squirt Bottle") unless vHI(:SQUIRTBOTTLE)
  choices.push("Sprayduck") unless vHI(:SPRAYDUCK)
  choices.push("Sprinklotad") unless vHI(:SPRINKLOTAD)
  choices.push("Wailmer Pail") unless vHI(:WAILMERPAIL)
  choices.push("Nevermind")
  pbCallBub
  c = pbMessage("\\rWhich Watering Can would you like instead?",choices,3)
  case choices[c]
  when "Squirt Bottle" then $bag.replace_item(can,:SQUIRTBOTTLE)
  when "Sprayduck" then $bag.replace_item(can,:SPRAYDUCK)
  when "Sprinklotad" then $bag.replace_item(can,:SPRINKLOTAD)
  when "Wailmer Pail" then $bag.replace_item(can,:WAILMERPAIL)
  when "Nevermind" then return
  end
  pbCallBub
  pbMessage("\\rThere you go! I hope you prefer this one.")
end

def vMasseur
  $game_temp.evolution_screen = true
  pbMessage("\\G\\rHi there, I am the Pokémon Masseur. For only $500 I can massage your Pokémon.")
  if pbConfirmMessage("\\G\\rWould you like me to massage your Pokémon?")
    if $player.money.decrypt < 500
      pbMessage("\\G\\rOh! You don't have enough money... Please come back when you have at least $500!")
      $game_temp.evolution_screen = false
      return false
    end
    pbChoosePokemon(1, 3, proc { |pkmn|
      next pkmn.fused.nil? && !pkmn.egg? && pkmn.hp > 0
    })
    idx = pbGet(1)
    if idx < 0
      pbMessage("\\G\\rThat's alright, please come again!")
      $game_temp.evolution_screen = false
      return false
    end
    pbMessage("\\G\\r#{pbGet(3)} it is then? That will be $500.")
    pbSEPlay("Mart buy item")
    $player.money = $player.money.decrypt - 500
    pbMessage("\\G\\rAlright, I am going to massage your #{pbGet(3)} now.")
    pkmn = $player.party[idx]
    if pkmn.shadowPokemon?
      pbMessage("\\rHmmmm... Interesting, this Pokémon seems really tense but I will manage!")
    end
    pbFadeOutIn {
      pbSEPlay("se_vending_drop")
      pbWait(12)
      pbMessage("\\rAh there you go! All set!")
    }
    if pkmn.shadowPokemon?
      pkmn.hyper_mode = false if pkmn.hyper_mode
      pbRaiseHappinessAndReduceHeartNoScene(pkmn, 1, false)
    else
      pkmn.happiness = (pkmn.happiness + 30).clamp(0, 255)
      pkmn.happiness = 70 if $player.murphyslaw
      pkmn.happiness = 0 if $player.hatemode
      pkmn.happiness = 255 if $player.lovemode
    end
    pbMessage("\\rAlright, your #{pbGet(3)} feels much better now.")
    pbMessage("\\rPlease come again!")
  else
    pbMessage("\\G\\rThat's alright, please come again!")
    $game_temp.evolution_screen = false
    return false
  end
  $game_temp.evolution_screen = false
end

def vLI
  pbChoosePokemon(1, 2, proc { |pkmn|
    pkmn.able?
  })
  if $game_variables[1] >= 0
    case $player.party[$game_variables[1]].species
    when :SHAYMIN then return vLIP(:GRACIDEA)
    when :THUNDURUS,:LANDORUS,:TORNADUS then return vLIP(:REVEALGLASS)
    when :HOOPA then return vLIP(:PRISONBOTTLE)
    when :ZYGARDE then return vLIP(:ZYGARDECUBE)
    when :RESHIRAM,:ZEKROM,:KYUREM then return vLIP(:DNASPLICERS)
    when :CALYREX,:SPECTRIER,:GLASTRIER then return vLIP(:REINSOFUNITY)
    end
  end
  return false
end

def vLIP(itm)
  return false if vHI(itm)
  return pbReceiveItem(itm)
end

def vEval(item)
  return false if vHI(item)
  pbMessage("\\rBut this does call for a reward. I'll send it over to you!")
  pbReceiveItem(item)
end