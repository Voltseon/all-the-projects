
class VoltseonsMarketPlace

  # Change bounce amount by using VoltseonsMarketPlace::BounceAmount = X

  STARINGBGM = "DPPT 137 Super Contest Cool Category.ogg"
  STOMPSE = "se_gui_battle_swoosh"
  BounceAmount = 6

  PostCreditBGM = "DPPT 155 Beginning Dimension Arceus.ogg"
  PostCreditPingSound = "Ping"

end

def getAllGiftMons(mapid = -1)
  calls = []
  mapData = Compiler::MapData.new
  if mapid == -1
    for id in mapData.mapinfos.keys.sort
      map = mapData.getMap(id)
      for event in map.events.values
        for page in event.pages
          list = page.list
          for i in 0...list.length
            next if list[i].code!=355
            command = list[i].parameters[0].clone
            for j in (i+1)...list.length
              break if list[j].code!=655
              command += "\r\n"+list[j].parameters[0]
            end
            if command[/^(pbAddPokemon)/i] || command[/^(vAP)/i]
              calls.push("#{command}, #{pbGetMapNameFromId(id)}")
            end
          end
        end
      end
    end
  else
    map = mapData.getMap(mapid)
    for event in map.events.values
      for page in event.pages
        list = page.list
        for i in 0...list.length
          next if list[i].code!=355
          command = list[i].parameters[0].clone
          for j in (i+1)...list.length
            break if list[j].code!=655
            command += "\r\n"+list[j].parameters[0]
          end
          if command[/^(pbAddPokemon)/i] || command[/^(vAP)/i]
            calls.push("#{command}, #{pbGetMapNameFromId(mapid)}")
          end
        end
      end
    end
  end
  echoln calls
end

def getAllItems(mapid = -1)
  calls = []
  mapData = Compiler::MapData.new
  if mapid == -1
    for id in mapData.mapinfos.keys.sort
      map = mapData.getMap(id)
      for event in map.events.values
        for page in event.pages
          list = page.list
          for i in 0...list.length
            next if list[i].code!=355
            command = list[i].parameters[0].clone
            for j in (i+1)...list.length
              break if list[j].code!=655
              command += "\r\n"+list[j].parameters[0]
            end
            if command[/^(vFI)/i]
              calls.push("#{command}, #{pbGetMapNameFromId(id)}")
            end
          end
        end
      end
    end
  else
    map = mapData.getMap(mapid)
    for event in map.events.values
      for page in event.pages
        list = page.list
        for i in 0...list.length
          next if list[i].code!=355
          command = list[i].parameters[0].clone
          for j in (i+1)...list.length
            break if list[j].code!=655
            command += "\r\n"+list[j].parameters[0]
          end
          if command[/^(vFI)/i]
            calls.push("#{command}, #{pbGetMapNameFromId(mapid)}")
          end
        end
      end
    end
  end
  echoln calls
end

def setplayerback(amt=2)
  dirx = 1
  diry = 1
  dirx = 0 if $game_player.direction == 2 || $game_player.direction == 8
  diry = 0 if $game_player.direction == 4 || $game_player.direction == 6
  amt *= -1 if $game_player.direction == 2 || $game_player.direction == 6
  $game_player.playermoveto($game_player.x + amt * dirx, $game_player.y + amt * diry)
end

def pbMovesGameDataToPokemon(pkmn,*moves)
  pkmn.moves.clear
  for move in moves
    pkmn.moves.push(Pokemon::Move.new(move))
  end
  return pkmn
end

def checkParty(*args)
  ret = true
  for spec in args
    ret = false if !$Trainer.has_species?(spec)
  end
  return ret
end

# Enigma Farm
Events.onStepTaken += proc { |_sender,_e|
  for i in $Trainer.pokemon_party
    next if !i.hasAbility?(:ENIGMAFARM)
    $game_temp.enigma_farm_steps += 1
    if $game_temp.enigma_farm_steps == 100
      $PokemonBag.pbStoreItem(:ENIGMABERRY,1)
      $game_temp.enigma_farm_steps = 0
    end
    break
  end
}

def thankForDLC
  moveOutfits
  $game_switches[98] = true
  pbMessage("\\xn[Dev Team]\\bThank you for supporting the game, and downloading the Arapawa Island DLC.")
  pbMessage("\\xn[Dev Team]\\bPlease check out the PANTS building in Wakaiwa City to gain access to all DLC features.")
end

Events.onStepTaken += proc {|_sender,*args|
  thankForDLC if !$game_switches[98] && $game_switches[99]
}

def playerStandingEvent
  for e in $game_map.events.values
    return e if e.onEvent?
  end
  return nil
end

def unlockCrisPc
  if pbSaveTest("Pokemon and the Last Wish","Exist",nil)
    save = pbSaveFile("Pokemon and the Last Wish")
    crisStorage = save[:storage_system]
    for partyPkmn in save[:player].party
      crisStorage.pbStoreCaught(partyPkmn)
    end
    pbSet(50,crisStorage)
  else
    crisOwner = Pokemon::Owner.new_foreign('Cris', ($Trainer.character_ID-1).abs)
    crisStorage = PokemonStorage.new
    allPkmn = []
    rtPkmn = []
      # Starter
      case pbGet(28)
      when 0
      pkmnStarter = Pokemon.new(:SCEPTILE,50)
      pkmnStarter.moves.clear
      pkmnStarter.moves.push(Pokemon::Move.new(:HYDROPUMP))
      pkmnStarter.moves.push(Pokemon::Move.new(:ICEBEAM))
      when 1
      pkmnStarter = Pokemon.new(:TYPHLOSION,50)
      pkmnStarter.moves.clear
      pkmnStarter.moves.push(Pokemon::Move.new(:ERUPTION))
      pkmnStarter.moves.push(Pokemon::Move.new(:FIRELASH))
      when 2
      pkmnStarter = Pokemon.new(:BLASTOISE,50)
      pkmnStarter.moves.clear
      pkmnStarter.moves.push(Pokemon::Move.new(:DUALCHOP))
      pkmnStarter.moves.push(Pokemon::Move.new(:LEAFBLADE))
      end
      pkmnStarter.moves.push(Pokemon::Move.new(:WISH))
      pkmnStarter.moves.push(Pokemon::Move.new(:SLACKOFF))
      pkmnStarter.item = :EXPERTBELT
      pkmnStarter.obtain_level = 10
      pkmnStarter.obtain_map = 43
      allPkmn.push(pkmnStarter)
      # Nora
      pkmnNora = Pokemon.new(:AGGRON,50)
      pkmnNora.name = "Nora"
      pkmnNora.gender = 1
      pkmnNora.moves.clear
      pkmnNora.moves.push(Pokemon::Move.new(:MAGNITUDE))
      pkmnNora.moves.push(Pokemon::Move.new(:ROCKWRECKER))
      pkmnNora.moves.push(Pokemon::Move.new(:HEAVYSLAM))
      pkmnNora.moves.push(Pokemon::Move.new(:STOMP))
      pkmnNora.owner = Pokemon::Owner.new_foreign('Tim', 0)
      pkmnNora.obtain_level = 7
      pkmnNora.obtain_map = 48
      pkmnNoraEv = 512
      GameData::Stat.each_main { |s| pkmnNora.iv[s.id] = 31; pkmnNora.ev[s.id] = rand(0..[0,[pkmnNoraEv,252].min].max); pkmnNoraEv -= pkmnNora.ev[s.id]}
      pkmnNora.level = rand(60..80)
      pkmnNora.calc_stats
      crisStorage.pbStoreCaught(pkmnNora)
      # Umbreon
      pkmnUmbreon = Pokemon.new(:UMBREON,50)
      pkmnUmbreon.moves.clear
      for move in [:DARKPULSE,:WISH,:SHADOWBALL,:MOONLIGHT]
        pkmnUmbreon.moves.push(Pokemon::Move.new(move))
      end
      pkmnUmbreon.obtain_level = 12
      pkmnUmbreon.obtain_map = 78
      allPkmn.push(pkmnUmbreon)
      # Sableye
      pkmnSableye = Pokemon.new(:SABLEYE,50)
      pkmnSableye.form = 1
      pkmnSableye.pokerus = 5
      pkmnSableye.gender = 0
      pkmnSableye.moves.clear
      for move in [:NIGHTSHADE,:FLAREDASH,:POWERGEM,:FOULPLAY]
        pkmnSableye.moves.push(Pokemon::Move.new(move))
      end
      pkmnSableye.obtain_level = 20
      pkmnSableye.obtain_map = 89
      allPkmn.push(pkmnSableye)
      # Mawile
      pkmnMawile = Pokemon.new(:MAWILE,50)
      pkmnMawile.form = 1
      pkmnMawile.pokerus = 5
      pkmnMawile.gender = 1
      pkmnMawile.moves.clear
      for move in [:DRAININGKISS,:LIFEDRAIN,:SYNTHESIS,:TAUNT]
        pkmnMawile.moves.push(Pokemon::Move.new(move))
      end
      pkmnMawile.obtain_level = 20
      pkmnMawile.obtain_map = 89
      allPkmn.push(pkmnMawile)
      # Raichu
      pkmnRaichu = Pokemon.new(:RAICHU,50)
      pkmnRaichu.moves.clear
      for move in [:THUNDER,:QUICKATTACK,:ENERGYBALL,:PARABOLICCHARGE]
        pkmnRaichu.moves.push(Pokemon::Move.new(move))
      end
      pkmnRaichu.obtain_level = 12
      pkmnRaichu.obtain_map = 78
      allPkmn.push(pkmnRaichu)
      # Larvi
      pkmnLarvi = Pokemon.new(:TYRANITAR,50)
      pkmnLarvi.name = "Larvi"
      pkmnLarvi.moves.clear
      pkmnLarvi.moves.push(Pokemon::Move.new(:EARTHQUAKE))
      pkmnLarvi.moves.push(Pokemon::Move.new(:STONEEDGE))
      pkmnLarvi.moves.push(Pokemon::Move.new(:CRUNCH))
      pkmnLarvi.moves.push(Pokemon::Move.new(:THRASH))
      pkmnLarvi.owner = Pokemon::Owner.new_foreign('Bart', 0)
      pkmnLarvi.obtain_level = 21
      pkmnLarvi.obtain_map = 96
      pkmnLarvi.item = :CHOICEBAND
      pkmnLarviEv = 512
      GameData::Stat.each_main { |s| pkmnLarvi.iv[s.id] = 31; pkmnLarvi.ev[s.id] = rand(0..[0,[pkmnLarviEv,252].min].max); pkmnLarviEv -= pkmnLarvi.ev[s.id]}
      pkmnLarvi.level = rand(60..80)
      pkmnLarvi.calc_stats
      crisStorage.pbStoreCaught(pkmnLarvi)
      # Dragonair
      pkmnDragonair = Pokemon.new(:DRAGONAIR,50)
      pkmnDragonair.moves.clear
      for move in [:THUNDERBOLT,:DRAGONRAGE,:SAFEGUARD,:SURF]
        pkmnDragonair.moves.push(Pokemon::Move.new(move))
      end
      pkmnDragonair.obtain_level = 30
      pkmnDragonair.obtain_map = 104
      pkmnDragonair.poke_ball = :ULTRABALL
      allPkmn.push(pkmnDragonair)
      # Weavile
      pkmnWeavile = Pokemon.new(:WEAVILE,43)
      pkmnWeavile.obtain_level = 32
      pkmnWeavile.obtain_map = 84
      pkmnWeavile.poke_ball = :TIMERBALL
      pkmnWeavile.owner = crisOwner
      pkmnWeavileEv = 512
      GameData::Stat.each_main { |s| pkmnWeavile.iv[s.id] = 31; pkmnWeavile.ev[s.id] = rand(0..[0,[pkmnWeavileEv,252].min].max); pkmnWeavileEv -= pkmnWeavile.ev[s.id] }
      pkmnWeavile.calc_stats
      crisStorage.pbStoreCaught(pkmnWeavile)
      # Route 1 mons
      for i in 0..rand(2..4)
        newPkmn = Pokemon.new([:ZIGZAGOON,:TAILLOW,:POOCHYENA,:SPINARAK,:NATU,:METAPOD][rand(0...6)],6)
        newPkmn.obtain_level = rand(6..7)
        newPkmn.obtain_map = 48
        newPkmn.level = rand(7..9)
        rtPkmn.push(newPkmn)
      end
      # Route 2 mons
      for j in 0..rand(2..4)
        newPkmn = Pokemon.new([:SPEAROW,:SENTRET,:RATTATA,:PIKACHU,:GROWLITHE,:KAKUNA,:EEVEE,:LEDYBA][rand(0...8)],7)
        newPkmn.obtain_level = rand(7..8)
        newPkmn.obtain_map = 78
        newPkmn.level = rand(8..13)
        rtPkmn.push(newPkmn)
      end
      # Prim Cave mons
      for k in 0..rand(2..4)
        newPkmn = Pokemon.new([:DUNSPARCE,:DUNSPARCE,:DIGLETT,:GEODUDE,:SLUGMA,:ONIX,:ZUBAT][rand(0...7)],9)
        newPkmn.obtain_level = rand(9..10)
        newPkmn.obtain_map = 79
        newPkmn.level = rand(10..12)
        rtPkmn.push(newPkmn)
      end
      # Route 3 mons
      for l in 0..rand(1..3)
        newPkmn = Pokemon.new([:HOOTHOOT,:SWINUB,:SHROOMISH,:ELECTRIKE,:SPHEAL,:SNORUNT][rand(0...6)],11)
        newPkmn.obtain_level = rand(11..12)
        newPkmn.obtain_map = 84
        newPkmn.level = rand(12..13)
        rtPkmn.push(newPkmn)
      end
      # Staring mons
      for m in 0..rand(2..3)
        newPkmn = Pokemon.new([:MAGIKARP,:TENTACOOL,:POLIWAG,:LAPRAS][rand(0...4)],12)
        newPkmn.obtain_level = rand(12..13)
        newPkmn.obtain_map = 76
        newPkmn.level = rand(13..15)
        rtPkmn.push(newPkmn)
      end
      # Used mons
      for m in 0..rand(1..2)
        newPkmn = Pokemon.new([:STEELIX,:CROBAT,:MAGCARGO][rand(0...3)],9)
        newPkmn.obtain_level = rand(9..10)
        newPkmn.obtain_map = 79
        newPkmn.level = rand(27..32)
        rtPkmn.push(newPkmn)
      end
    for pkmn in allPkmn
      pkmn.owner = crisOwner
      pkmnEv = 512
      GameData::Stat.each_main { |s| pkmn.iv[s.id] = 31; pkmn.ev[s.id] = rand(0..[0,[pkmnEv,252].min].max); pkmnEv -= pkmn.ev[s.id] }
      pkmn.level = rand(60..80)
      pkmn.calc_stats
      crisStorage.pbStoreCaught(pkmn)
    end
    prevSpecies = :GARDEVOIR
    for pkmn in rtPkmn
      next if prevSpecies == pkmn.species
      pkmn.owner = crisOwner
      pkmn.calc_stats
      crisStorage.pbStoreCaught(pkmn)
      prevSpecies = pkmn.species
    end
    pbSet(50,crisStorage)
  end
end

class StorageSystemPCCris
  def shouldShow?
    return true
  end

  def name
    return _INTL("{1}'s PC",pbGet(27))
  end

  def access
    pbMessage(_INTL("\\se[PC access]The Pokémon Storage System was opened."))
    command = 0
    loop do
      command = pbShowCommandsWithHelp(nil,
         [_INTL("Organize Boxes"),
         _INTL("Withdraw Pokémon"),
         _INTL("Deposit Pokémon"),
         _INTL("See ya!")],
         [_INTL("Organize the Pokémon in Boxes and in your party."),
         _INTL("Move Pokémon stored in Boxes to your party."),
         _INTL("Store Pokémon in your party in Boxes."),
         _INTL("Return to the previous menu.")],-1,command
      )
      if command>=0 && command<3
        if command==1   # Withdraw
          if pbGet(50).party_full?
            pbMessage(_INTL("Your party is full!"))
            next
          end
        elsif command==2   # Deposit
          count=0
          for p in pbGet(50).party
            count += 1 if p && !p.egg? && p.hp>0
          end
          if count<=1
            pbMessage(_INTL("Can't deposit the last Pokémon!"))
            next
          end
        end
        pbFadeOutIn {
          scene = PokemonStorageScene.new
          screen = PokemonStorageScreen.new(scene,pbGet(50))
          screen.pbStartScreen(command)
        }
      else
        break
      end
    end
  end
end

GameData::TerrainTag.register({
  :id                     => :DeepSand,
  :id_number              => 25,
  :land_wild_encounters   => true,
  :battle_environment     => :Sand,
  :must_walk              => true,
  :deep_bush              => true,
})

def ecruteakDance(eventID)
  event = get_event_from_id(eventID)
  path = [
    [PBMoveRoute::Right,6],
    [PBMoveRoute::Up,8],
    [PBMoveRoute::Left,4],
    [PBMoveRoute::Down,2],
    [PBMoveRoute::Left,4],
    [PBMoveRoute::Up,8],
    [PBMoveRoute::Right,6],
    [PBMoveRoute::Down,2],
    [PBMoveRoute::Right,6],
    [PBMoveRoute::Up,8],
    [PBMoveRoute::Left,4],
    [PBMoveRoute::Down,2],
    [PBMoveRoute::Left,4],
    [PBMoveRoute::Right,6]
  ]
  path.each do |route|
    $game_map.start_scroll(route[1], 1, 3)
    pbMoveRoute(event, [route[0]], true)
    pbWait(30)
    pbMoveRoute(event, [PBMoveRoute::TurnLeft,PBMoveRoute::Wait,8,PBMoveRoute::TurnUp,PBMoveRoute::Wait,8,PBMoveRoute::TurnRight,PBMoveRoute::Wait,8,PBMoveRoute::TurnDown,PBMoveRoute::Wait,8],true)
    event.animation_id = 28
    pbWait(40)
    event.animation_id = 28
    pbWait(60)
  end
  pbWait(5)
  pbFlash(Color.new(255, 255, 255, 255), 10)
  for i in 0...10
    pbWait(7)
    event.animation_id = 28
  end
  pbWait(5)
  pbMoveRoute(event, [PBMoveRoute::TurnLeft,PBMoveRoute::Wait,8,PBMoveRoute::TurnUp,PBMoveRoute::Wait,8,PBMoveRoute::TurnRight,PBMoveRoute::Wait,8,PBMoveRoute::TurnDown,PBMoveRoute::Wait,8],true)
  pbWait(40)
  pbFlash(Color.new(255, 255, 255, 255), 10)
  for i in 0...20
    pbWait(7)
    event.animation_id = 28
  end
  pbFlash(Color.new(255, 255, 255, 255), 10)
end


def vTranslate(message = "Hello World", lang = "DE")
  auth_key = "7780c5f1-b0d3-1dbc-704f-8b0c9f472023:fx"
  url = "https://api-free.deepl.com/v2/translate"
  data = "auth_key=#{auth_key}&text=#{message}&source_lang=EN&target_lang=#{lang}"
  output = pbPostToStringWiki(url, data) rescue ""
  return HTTPLite::JSON.parse(output)["translations"][0]["text"] rescue ""
end