def pbShrine(type=0) # Bronze=0, Silver=1, Gold=2
  case type
  when 0 then pbMessage("It's an ancient bronze shrine.")
  when 1 then pbMessage("It's an ancient silver shrine.")
  when 2 then pbMessage("It's an ancient golden shrine.")
  end
  mons = $player.special_pokemon[:SHRINE][type]
  commands = ["Pray", "Purify", "Cancel"]
  choice = pbMessage("What would you like to do?",commands,3)
  case commands[choice]
  when "Pray"
    pbCommonEvent(10)
    $game_temp.shrine_battled = false
    party_gens = []
    $player.party.each { |pkmn| party_gens.push(pkmn.species_data.generation) }
    case type
    when 0
      new_roamers = false
      if party_gens.count(1) == $player.party.count && !($game_switches[101] || $game_switches[102] || $game_switches[103])
        $game_map.start_scroll(8,1,4)
        pbWait(8)
        $player.special_pokemon[:SHRINE][0][0..2].each_with_index do |pkmn, index|
          Pokemon.play_cry(pkmn)
          pbWait(40)
          $game_switches[101+index] = true
        end
        new_roamers = true
      end
      if party_gens.count(2) == $player.party.count && !($game_switches[104] || $game_switches[105] || $game_switches[106])
        $game_map.start_scroll(8,1,4)
        pbWait(8)
        $player.special_pokemon[:SHRINE][0][3..5].each_with_index do |pkmn, index|
          Pokemon.play_cry(pkmn)
          pbWait(40)
          $game_switches[104+index] = true
        end
        new_roamers = true
      end
      if party_gens.count(4) == $player.party.count
        $game_map.start_scroll(8,1,4)
        pbWait(8)
        $player.special_pokemon[:SHRINE][0][6..8].each_with_index do |pkmn, index|
          next if $game_switches[107+index]
          Pokemon.play_cry(pkmn)
          pbWait(40)
          $game_switches[107+index] = true
          new_roamers = true
        end
        if PBDayNight.isDay?
          unless $game_switches[110]
            Pokemon.play_cry($player.special_pokemon[:SHRINE][9])
            pbWait(40)
            $game_switches[110] = true
            new_roamers = true
          end
        else
          unless $game_switches[111]
            Pokemon.play_cry($player.special_pokemon[:SHRINE][10])
            pbWait(40)
            $game_switches[111] = true
            new_roamers = true
          end
        end
      end
      if party_gens.count(5) == $player.party.count && !($game_switches[112] || $game_switches[113] || $game_switches[114] || $game_switches[115] || $game_switches[116] || $game_switches[117])
        $game_map.start_scroll(8,1,4)
        pbWait(8)
        $player.special_pokemon[:SHRINE][0][11..16].each_with_index do |pkmn, index|
          Pokemon.play_cry(pkmn)
          pbWait(40)
          $game_switches[112+index] = true
        end
        new_roamers = true
      end
      if $player.has_species?(:GLIMMORA) && !($game_switches[118] || $game_switches[119] || $game_switches[120] || $game_switches[121])
        $game_map.start_scroll(8,1,4)
        pbWait(8)
        [:KROOKODILE, :WEAVILE, :CACTURNE, :HOUNDOOM].each_with_index do |mon, index|
          next if $game_switches[118+index]
          Pokemon.play_cry($player.special_pokemon[:SHRINE][0][26+index])
          pbWait(40)
          $game_switches[118+index] = true
          new_roamers = true
        end
      end
      if new_roamers
        $game_map.start_scroll(2,1,4)
        pbMessage("You heard the cries of special Pokémon. They started to roam the region.")
        pbRoamPokemon
      end
      if party_gens.count(3) == $player.party.count
        case $player.party[0].types[0]
        when :ROCK
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][17],45)
        when :ICE
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][18],45)
        when :STEEL
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][19],45)
        when :ELECTRIC
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][20],45)
        when :DRAGON
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][21],45)
        end
      end
      if party_gens.count(7) == $player.party.count-1
        if $player.has_species?(:JOLTEON)
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][22],45)
        elsif $player.has_species?(:SYLVEON)
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][23],45)
        elsif $player.has_species?(:LEAFEON)
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][24],45)
        elsif $player.has_species?(:VAPOREON)
          battle_shrine_mon($player.special_pokemon[:SHRINE][0][25],45)
        end
      end
    when 1
      unless $player&.shrine_mons[$player.special_pokemon[:SHRINE][1][0]]
        battle_shrine_mon($player.special_pokemon[:SHRINE][1][0],70)
      else
        fire_count = 0
        $player.party.each { |pkmn| fire_count += 1 if pkmn.types.include?(:FIRE) }
        battle_shrine_mon($player.special_pokemon[:SHRINE][1][1],70) if $player.party.count == fire_count
        if $player.has_species?(:ARTICUNO) && $player.has_species?(:ZAPDOS) && $player.has_species?(:MOLTRES)
          has_shadows = false
          $player.party.each { |pkmn| has_shadows = true if pkmn.shadowPokemon? }
          has_shadows ? battle_shrine_mon($player.special_pokemon[:SHRINE][1][2],70) : battle_shrine_mon($player.special_pokemon[:SHRINE][1][3],70)
        end
        if $player.has_species?(:LATIAS) && $player.has_species?(:LATIOS)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][4],70) if $player.has_species?(:KYOGRE) && $player.has_species?(:GROUDON)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][5],70) if [:HeavyRain, :Rain].include?($game_screen.weather_type)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][6],70) if [:HarshSun, :Sun].include?($game_screen.weather_type)
        end
        if $player.has_species?(:UXIE) && $player.has_species?(:MESPRIT) && $player.has_species?(:AZELF)
          case $player.party[0].item.id
          when :ADAMANTORB then battle_shrine_mon($player.special_pokemon[:SHRINE][1][7],70)
          when :LUSTROUSORB then battle_shrine_mon($player.special_pokemon[:SHRINE][1][8],70)
          when :GRISEOUSORB then battle_shrine_mon($player.special_pokemon[:SHRINE][1][9],70)
          end
        end
        battle_shrine_mon($player.special_pokemon[:SHRINE][1][10],70) if $player.has_species?(:REGIROCK) && $player.has_species?(:REGICE) &&
          $player.has_species?(:REGISTEEL) && $player.has_species?(:REGIELEKI) && $player.has_species?(:REGIDRAGO)
        if $player.has_species?(:LANDORUS) && $player.has_species?(:THUNDURUS) && $player.has_species?(:TORNADUS)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][11],70) if $player.has_species?(:RESHIRAM) && $player.has_species?(:ZEKROM)
          PBDayNight.isDay? ? battle_shrine_mon($player.special_pokemon[:SHRINE][1][12],70) : battle_shrine_mon($player.special_pokemon[:SHRINE][1][13],70)
        end
        if $player.has_species?(:NOIVERN)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][14],70) if $player.has_species?(:XERNEAS) && $player.has_species?(:YVELTAL)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][15],70) if $player.has_species?(:MAWILE)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][16],70) if $player.has_species?(:SABLEYE)
        end
        if $player.has_species?(:STONJOURNER)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][17],70) if $player.has_species?(:AEGISLASH)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][18],70) if $player.has_species?(:BASTIODON)
          ultrabeast = false
          $player.party.each { |pkmn| ultrabeast = true if pkmn.species_data.has_flag?("UltraBeast") }
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][19],70) if ultrabeast
        end
        if $player.has_species?(:CYCLIZAR)
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][31],70) if $player.party[0].attack >= $player.party[0].spatk
          battle_shrine_mon($player.special_pokemon[:SHRINE][1][32],70) if $player.party[0].attack < $player.party[0].spatk
        end
        caught_every_legend = true
        [:MEWTWO,:LUGIA,:HOOH,:KYOGRE,:GROUDON,:RAYQUAZA,:DIALGA,:PALKIA,:GIRATINA,:HEATRAN,
            :REGIGIGAS,:RESHIRAM,:ZEKROM,:KYUREM,:XERNEAS,:YVELTAL,:ZYGARDE,:ZACIAN,:ZAMAZENTA,:ETERNATUS,:KORAIDON,:MIRAIDON].each do |mon|
          caught_every_legend = false unless $player.pokedex.owned?(mon)
        end
        if $player.has_species?(:SOLGALEO) || $player.has_species?(:LUNALA)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][20],80) if $player.has_species?(:JELLICENT)
          heracross_check = 0
          $player.party.each do |pkmn|
            next unless pkmn.isSpecies?(:HERACROSS)
            heracross_check = 1 if pkmn.male?
            heracross_check = 2 if pkmn.female?
            break
          end
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][21],80) if heracross_check == 1
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][22],80) if heracross_check == 2
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][23],80) if $player.has_species?(:ELECTIVIRE)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][24],80) if $player.has_species?(:METAGROSS)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][25],80) if $player.has_species?(:AEGISLASH)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][26],80) if $player.has_species?(:ABSOL)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][27],80) if $player.has_species?(:SKRELP)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][28],80) if $player.has_species?(:RHYPERIOR)
          battle_shrine_ub($player.special_pokemon[:SHRINE][1][29],80) if $player.has_species?(:MAGMORTAR)
        end
        battle_shrine_mon($player.special_pokemon[:SHRINE][1][30],100) if caught_every_legend
      end
    when 2
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][0],90) if $player.has_species?(:MEWTWO)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][1],90) if $player.has_species?(:HOOH) && $player.has_species?(:LUGIA)
      if $player.has_species?(:RAYQUAZA)
        case $player.party[0].item.id
        when :STARPIECE  then battle_shrine_mon($player.special_pokemon[:SHRINE][2][2],90)
        when :COMETSHARD then battle_shrine_mon($player.special_pokemon[:SHRINE][2][3],90)
        end
      end
      if $player.has_species?(:HEATRAN)
        battle_shrine_mon($player.special_pokemon[:SHRINE][2][4],90)
        has_sea_pokemon = $player.has_species?(:QWILFISH) && ($player.has_species?(:BUIZEL) || $player.has_species?(:FLOATZEL)) && ($player.has_species?(:MANTYKE) || $player.has_species?(:MANTINE))
        battle_shrine_mon($player.special_pokemon[:SHRINE][2][5],90) if has_sea_pokemon
      end
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][6],90) if $player.party_count == 1
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][7],90) if $player.has_species?(:TERRAKION) && $player.has_species?(:COBALION) && $player.has_species?(:VIRIZION)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][8],90) if vHI(:ANCIENTSCROLL)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][9],90) if vHI(:ROCKETDRIVE)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][10],90) if vHI(:OLDPOKEBALL)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][11],5) if vHI(:SILVERMERCURY)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][12],90) if vHI(:SHADEROOTCARROT)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][13],90) if vHI(:ICEROOTCARROT)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][14],90) if vHI(:JUNGLESCARF)
      mimikyu_count = 0
      $player.party.each { |pkmn| mimikyu_count += 1 if pkmn.isSpecies?(:MIMIKYU) }
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][15],90) if mimikyu_count >= 4
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][16],90) if $player.has_species?(:MAGEARNA)
      if $player.has_species?(:TAPUFINI) && $player.has_species?(:TAPULELE) && $player.has_species?(:TAPUBULU) && $player.has_species?(:TAPUKOKO)
        PBDayNight.isDay? ? battle_shrine_mon($player.special_pokemon[:SHRINE][2][17],90) : battle_shrine_mon($player.special_pokemon[:SHRINE][2][18],90)
      end
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][19],90) if $player.has_species?(:SPECTRIER) && $player.has_species?(:GLASTRIER)
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][20],90) if $player.has_species?(:XURKITREE)
      caught_every_myth = true
        [:MEW,:CELEBI,:SHAYMIN,:MANAPHY,:KELDEO,:MELOETTA,:JIRACHI,:DEOXYS,:VICTINI,:GENESECT,:MAGEARNA,:MELTAN,
          :SPECTRIER,:GLASTRIER,:ZARUDE,:MARSHADOW,:VOLCANION,:COSMOG,:CALYREX,:ZERAORA].each do |mon|
          caught_every_myth = false unless $player.pokedex.owned?(mon)
      end
      battle_shrine_mon($player.special_pokemon[:SHRINE][2][21],100) if caught_every_myth
    end
    if pbResetAllRoamers
      pbMessage("Fainted roaming Pokémon have restored their health and started to roam again.")
    end
  when "Purify"
    pbRelicStone
  when "Cancel"
    pbMessage("You left the shrine alone.")
  end
end

def battle_shrine_mon(mon,level)
  return false if $game_temp.shrine_battled
  return false if $player&.shrine_mons[mon]
  isForm = mon.to_s.include?("_")
  form = mon.to_s.split("_")[1].to_i if isForm
  pkmn = Pokemon.new(mon.to_s.gsub("_#{form}", "").to_sym,level)
  pkmn.form = form if isForm
  pkmn.play_cry
  pbWait(40)
  WildBattle.start(pkmn)
  $player&.shrine_mons[mon] = pbGet(1) == 4
  $game_temp.shrine_battled = true
  return true
end

def battle_shrine_ub(mon,level)
  return false if $game_temp.shrine_battled
  return false if $player&.shrine_mons[mon]
  vSST(9,"B")
  pbSEPlay("june")
  pbWait(10)
  Pokemon.play_cry(mon)
  pbWait(40)
  WildBattle.start(mon,level)
  vSSF(9,"B")
  $player&.shrine_mons[mon] = pbGet(1) == 4
  $game_temp.shrine_battled = true
  return true
end

class Player < Trainer
  attr_accessor :shrine_mons

  def shrine_mons
    @shrine_mons = {} if !@shrine_mons
    return @shrine_mons
  end
end

class Game_Temp
  attr_accessor :shrine_battled

  def shrine_battled
    @shrine_battled = false if !@shrine_battled
    return @shrine_battled
  end
end

GameData::EncounterType.register({
  :id => :Shrine,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})

GameData::EncounterType.register({
  :id => :Egg,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})

GameData::EncounterType.register({
  :id => :Gift,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})

GameData::EncounterType.register({
  :id => :Event,
  :type => :land,
  :trigger_chance => 1,
  :old_slots => [50, 20, 10, 5, 5, 5, 5],
})