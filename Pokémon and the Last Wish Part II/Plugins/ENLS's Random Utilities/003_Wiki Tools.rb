def pbGetMachineFromMove(moveid)
  GameData::Item.each do |item|
    return item if item.is_machine? && item.move == moveid
  end
end

def pbGetFormattedRegionalNumber(dexid,species)
  number = pbGetRegionalNumber(dexid,species)
  ret = ""
  if number < 100
    ret << "0"
  end
  if number < 10
    ret << "0"
  end
  ret << "#{number}"
  return ret
end

ALL_TMS = [
  :HOLDBACK,
  :WISH,
  :NIGHTDAZE,
  :VITALTHROW,
  :LUNGE,
  :MAGNITUDE,
  :TOXIC,
  :DRILLPECK,
  :SLACKOFF,
  :MEGAKICK,
  :MEGAPUNCH,
  :DRAININGKISS,
  :PARABOLICCHARGE,
  :SLUDGE,
  :HIDDENPOWER,
  :FIRELASH,
  :GLACIATE,
  :LEAFBLADE,
  :FIRSTIMPRESSION,
  :MAGNETBOMB,
  :NIGHTSHADE,
  :SYNCHRONOISE,
  :STOMP,
  :AQUAJET,
  :PSYCHOMATTER,
  :BOUNCE,
  :SURF,
  :STONEEDGE,
  :CURSE,
  :EXTREMESPEED
]

ALL_MOVES = [
  :LIFEDRAIN,
  :FLAREDASH,
  :CURSEDWATER,
  :PSYCHOMATTER,
  :CRYSTALLINEFLARE,
  :MAGNETWAVE,
  :STATICFIST,
  :NASTYPUNCH
]

ALL_ABILITIES = [
  :ROUGHSHELL,
  :TAINTEDBODY,
  :WEATHERING,
  :ENIGMAFARM,
  :STATICVEINS,
  :QUICKFIST
]

DEBUG_PATH = "WikiDebug/"

def pbFindEncounter(enc_types, species)
  return false if !enc_types
  enc_types.each_value do |slots|
    next if !slots
    slots.each { |slot| return slot if GameData::Species.get(slot[1]).species == species }
  end
  return false
end

def pbCheckKey(key, species)
  return false if !key
  key.each do |k|
    next if !k
    return true if GameData::Species.get(k[1]).species == species
  end
  return false
end

def checkEvoMethod(myEvos, evolutionParam)
  case myEvos
  when :Level then return "starting at level #{evolutionParam}"
  when :Happiness then return "when leveled up with high friendship"
  when :HappinessDay then return "when leveled up with high friendship during the daytime"
  when :HappinessNight then return "when leveled up with high friendship during the nighttime"
  when :Location then return "when leveled up in [[#{evolutionParam}]]"
  when :Item then return "when exposed to a #{evolutionParam}"
  when :HasMove then return "when leveled up while knowing #{evolutionParam}"
  end
  return ""
end

def extractFormsForWiki
      GameData::Species.each do |species|
        speciest = Pokemon.new(species,1)
        speciest.form = 0
        speciest = GameData::Species.get(speciest.species)
        next if species.name == "Pikachu" || species.name == "Eevee" || species.name == "Rotom" || species.name == "Unown"
        next if species.name == "Deoxys" && species.form < 4
        next if species.form != 1 && species.name != "Deoxys"
        next if !pbLoadRegionalDexes[2].include?(species.id) && !pbLoadRegionalDexes[2].include?(speciest.id)
        pbSetWindowText(_INTL("Writing article for {1}...", species.id))
        Graphics.update if species.id_number % 50 == 0
        base_species = GameData::Species.get(species.species)
        filename = "#{DEBUG_PATH}Forms/#{species.name}.txt"
        textresult = "{{DISPLAYTITLE:#{species.real_form_name}}}\n"
        textresult << "{{PokemonInfobox|type=[[File:"
        textresult << "#{GameData::Type.get(species.type1).name}Type.png]]"
        textresult << "<br>[[File:#{GameData::Type.get(species.type2).name}Type.png]]" if species.type2 != species.type1
        textresult << "|abilities="
        species.abilities.each do |a|
          ability = GameData::Ability.try_get(a).name
          ability = "[[#{ability}]]" if ALL_ABILITIES.include?(a)
          textresult << "#{ability}<br>"
        end
        species.hidden_abilities.each do |a|
          ability = GameData::Ability.try_get(a).name
          ability = "[[#{ability}]]" if ALL_ABILITIES.include?(a)
          textresult << "#{ability} (Hidden)"
        end
        textresult << "|region=[[Peskan]]|pokedex=[[Peskan Pokédex|<nowiki>##{pbGetFormattedRegionalNumber(2,species)}</nowiki>]]|evolves_from="
        previousSpecies = GameData::Species.get_species_form(species.get_previous_species, species.form)
        if previousSpecies.name == species.name
          textresult << "None|evolves_into="
        else
          textresult << "[[#{previousSpecies.name}]]|evolves_into="
        end
        myEvolutions = GameData::Species.get(species).get_evolutions
        if myEvolutions[0]
          evolutionMethod = ""
          evolutionParam = myEvolutions[0][2]
          evolutionParam = GameData::Item.get(myEvolutions[0][2]).name if myEvolutions[0][1] == :Item
          evolutionParam = GameData::Move.get(myEvolutions[0][2]).name if myEvolutions[0][1] == :HasMove
          case myEvolutions[0][1]
          when :Level then evolutionMethod = "(lvl. #{evolutionParam})"
          when :Ninjask then evolutionMethod = "(lvl. #{evolutionParam})"
          when :Happiness then evolutionMethod = "(Happiness)"
          when :HappinessDay then evolutionMethod = "(Happiness Daytime)"
          when :HappinessNight then evolutionMethod = "(Happiness Nighttime)"
          when :Location then evolutionMethod = "(Location: [[#{evolutionParam}]])"
          when :Item then evolutionMethod = "(Item: #{evolutionParam})"
          when :HasMove then evolutionMethod = "(Knowing #{evolutionParam})"
          end
        end
        if !myEvolutions[0]
          textresult << "None|weight="
        else
          textresult << "[[#{GameData::Species.get(myEvolutions[0][0]).name}]] #{evolutionMethod}|weight="
        end
        textresult << "#{species.weight/10.0} kg|height=#{species.height/10.0} m|gender={{#{species.gender_ratio}}}|image=#{species.id}.png|title=[[File:#{species.id}_icon.png]]\n<big>'''#{species.name}'''</big>}}'''#{species.name}''' is a "
        textresult << "#{GameData::Type.get(species.type1).name}"
        textresult << "/#{GameData::Type.get(species.type2).name}" if species.type2 != species.type1
        textresult << "-type Pokémon introduced in [[Pokémon and the Last Wish: Part II]].\n\nIt "
        if previousSpecies.name != species.name
          myEvolutions = previousSpecies.get_evolutions
          if myEvolutions[0]
          evolutionMethod = ""
          evolutionParam = myEvolutions[0][2]
          evolutionParam = GameData::Item.get(myEvolutions[0][2]).name if myEvolutions[0][1] == :Item
          evolutionParam = GameData::Move.get(myEvolutions[0][2]).name if myEvolutions[0][1] == :HasMove
          evolutionMethod = checkEvoMethod(myEvolutions[0][1], evolutionParam)
          textresult << "evolves from [[#{previousSpecies.name}]] #{evolutionMethod}"
          end
        end
        myEvolutions = GameData::Species.get(species).get_evolutions
        if myEvolutions[0]
          evolutionMethod = ""
          evolutionParam = myEvolutions[0][2]
          evolutionParam = GameData::Item.get(myEvolutions[0][2]).name if myEvolutions[0][1] == :Item
          evolutionParam = GameData::Move.get(myEvolutions[0][2]).name if myEvolutions[0][1] == :HasMove
          evolutionMethod = checkEvoMethod(myEvolutions[0][1], evolutionParam)
          textresult << " and " if previousSpecies.name != species.name
          textresult << "evolves into [[#{GameData::Species.get(myEvolutions[0][0]).name}]] #{evolutionMethod}"
        else
          textresult << "is not known to evolve into or from any other Pokémon" if previousSpecies.name == species.name
        end
        textresult << ".\n\n==Game data==\n\n===Pokédex entry===\n<blockquote>#{species.pokedex_entry}</blockquote>\n\n===Game locations===\n=====[[Pokémon and the Last Wish]]=====\n{| class=\"fandom-table\"\n|Unobtainable\n|}\n\n\n=====[[Pokémon and the Last Wish: Part II]]=====\n{| class=\"fandom-table\"\n|Chance\n|Area\n|Min Lvl.\n|Max Lvl.\n|Encounter Type"
        mapInfos = pbLoadMapInfos
        GameData::Encounter.each_of_version(0) do |enc_data|
          findEncounter = pbFindEncounter(enc_data.types, species.species)
          next if findEncounter == false
          encounterType = ""
          enc_data.types.keys.each do |key|
            next if !pbCheckKey(enc_data.types[key],species.species)
            case key
            when :Land then encounterType += "[[File:GrassEncounter.png]]"
            when :Cave then encounterType += "[[File:CaveEncounter.png]]"
            when :SuperRod then encounterType += "[[File:StaringEncounter.png]]"
            end
          end
          mapname = mapInfos[enc_data.map].name
          case enc_data.map
          when 133 then mapname += "]] (East)"
          when 135 then mapname += "]] (West)"
          when 145 then mapname += "]] (South)"
          when 171 then mapname += "]] (North)"
          else mapname += "]]"
          end
          textresult << "\n|-\n|#{findEncounter[0]}%\n|[[#{mapname}\n|#{findEncounter[2]}\n|#{findEncounter[3]}\n|#{encounterType}"
        end
        textresult << "\n|}\n"
        textresult << "\n\n===Base stats ===\n"
        textresult << "{{BaseStats|HP=#{species.base_stats[:HP]}|Attack=#{species.base_stats[:ATTACK]}|Defense=#{species.base_stats[:DEFENSE]}|SpAtk=#{species.base_stats[:SPECIAL_ATTACK]}|SpDef=#{species.base_stats[:SPECIAL_DEFENSE]}|Speed=#{species.base_stats[:SPEED]}}}\n\n"
        textresult << "\n===Type effectiveness ===\n"
        immuneEffective = ""
        qresistEffective = ""
        resistEffective = ""
        normalEffective = ""
        weakEffective = ""
        qweakEffective = ""
        otype1 = species.type1
        otype2 = species.type2
        GameData::Type.each do |type|
          next if type.id == :QMARKS
          typemod = Effectiveness::NORMAL_EFFECTIVE_ONE ** 2
          mod1 = Effectiveness.calculate_one(type.id, otype1)
          mod2 = (otype1 == otype2) ? Effectiveness::NORMAL_EFFECTIVE_ONE : Effectiveness.calculate_one(type.id, otype2)
          typemod = mod1 * mod2
          case typemod
          when 0 then immuneEffective += ("[[File:#{GameData::Type.get(type).name}Type.png]]")
          when 1 then qresistEffective += ("[[File:#{GameData::Type.get(type).name}Type.png]]")
          when 2 then resistEffective += ("[[File:#{GameData::Type.get(type).name}Type.png]]")
          when 4 then normalEffective += ("[[File:#{GameData::Type.get(type).name}Type.png]]")
          when 8 then weakEffective += ("[[File:#{GameData::Type.get(type).name}Type.png]]")
          when 16 then qweakEffective += ("[[File:#{GameData::Type.get(type).name}Type.png]]")
          end
        end
        effectiveness = ""
        effectiveness += "\n|Damaged normally by:\n|#{normalEffective}" if normalEffective != ""
        effectiveness += "\n|-\n|Weak to:\n|#{weakEffective}" if weakEffective != ""
        effectiveness += "\n|-\n|4x weak to:\n|#{qweakEffective}" if qweakEffective != ""
        effectiveness += "\n|-\n|Immune to:\n|#{immuneEffective}" if immuneEffective != ""
        effectiveness += "\n|-\n|Resistant to:\n|#{resistEffective}" if resistEffective != ""
        effectiveness += "\n|-\n|4x resistant to:\n|#{qresistEffective}" if qresistEffective != ""
        textresult << "{| class=\"fandom-table\"#{effectiveness}\n|-\n\n|}\n"
        textresult << "=== Learnset===\n\n====By levelling up====\n{| class=\"sortable article-table\"\n|+\n!Lvl\n!Move\n!Type\n!Category\n!Pwr.\n!Acc.\n!PP\n"
        species.moves.each do |m|
          movename = GameData::Move.get(m[1]).name
          movename = "[[#{movename}]]" if ALL_MOVES.include?(m[1])
          textresult << "|-\n"
          textresult << "|#{m[0]}\n"
          textresult << "|#{movename}\n"
          textresult << "|[[File:#{GameData::Type.get(GameData::Move.get(m[1]).type).name}Type.png]]\n"
          case GameData::Move.get(m[1]).category
          when 0 then textresult << "|[[File:PhysicalCategory.png]]\n"
          when 1 then textresult << "|[[File:SpecialCategory.png]]\n"
          when 2 then textresult << "|[[File:StatusCategory.png]]\n"
          end
          if GameData::Move.get(m[1]).base_damage == 0
            textresult << "| -\n"
          else
            textresult << "|#{GameData::Move.get(m[1]).base_damage}\n"
          end
          if GameData::Move.get(m[1]).accuracy == 0
            textresult << "| -%\n"
          else
            textresult << "|#{GameData::Move.get(m[1]).accuracy}%\n"
          end
          textresult << "|#{GameData::Move.get(m[1]).total_pp}\n"
        end
        textresult << "|}\n====By TM/HM====\n{| class=\"sortable article-table\"\n|+\n! colspan=\"2\" |TM\n!Move\n!Type\n!Category\n!Pwr.\n!Acc.\n!PP\n"
        machines = []
        hm       = []
        species.tutor_moves.each do |m|
          next if !ALL_TMS.include?(m)
          if GameData::Move.get(m).hidden_move?
            hm.push(pbGetMachineFromMove(m).id)
            next
          end
          machines.push(pbGetMachineFromMove(m).id)
        end
        machines = machines.uniq.sort
        hm = hm.uniq.sort
        machines.each do |m|
          move = GameData::Move.get(GameData::Item.get(m).move)
          movename = move.name
          movename = "[[#{movename}]]" if ALL_MOVES.include?(move.id)
          moveitem = pbGetMachineFromMove(move.id)
          textresult << "|-\n"
          textresult << "|[[File:Machine #{move.type}.png|frameless|24x24px]]\n"
          textresult << "|[[Item Locations#TMs|#{moveitem.name}]]\n"
          textresult << "|#{movename}\n"
          textresult << "|[[File:#{GameData::Type.get(move.type).name}Type.png]]\n"
          case move.category
          when 0 then textresult << "|[[File:PhysicalCategory.png]]\n"
          when 1 then textresult << "|[[File:SpecialCategory.png]]\n"
          when 2 then textresult << "|[[File:StatusCategory.png]]\n"
          end
          if move.base_damage == 0
            textresult << "| -\n"
          else
            textresult << "|#{move.base_damage}\n"
          end
          if move.accuracy == 0
            textresult << "| -%\n"
          else
            textresult << "|#{move.accuracy}%\n"
          end
          textresult << "|#{move.total_pp}\n"
        end
        hm.each do |m|
          move = GameData::Move.get(GameData::Item.get(m).move)
          movename = move.name
          movename = "[[#{movename}]]" if ALL_MOVES.include?(move.id)
          moveitem = pbGetMachineFromMove(move.id)
          textresult << "|-\n"
          textresult << "|[[File:Machine #{move.type}.png|frameless|24x24px]]\n"
          textresult << "|#{moveitem.name}\n"
          textresult << "|#{movename}\n"
          textresult << "|[[File:#{GameData::Type.get(move.type).name}Type.png]]\n"
          case move.category
          when 0 then textresult << "|[[File:PhysicalCategory.png]]\n"
          when 1 then textresult << "|[[File:SpecialCategory.png]]\n"
          when 2 then textresult << "|[[File:StatusCategory.png]]\n"
          end
          if move.base_damage == 0
            textresult << "| -\n"
          else
            textresult << "|#{move.base_damage}\n"
          end
          if move.accuracy == 0
            textresult << "| -%\n"
          else
            textresult << "|#{move.accuracy}%\n"
          end
          textresult << "|#{move.total_pp}\n"
        end
        textresult << "|}\n===Sprites===\n"
        textresult << "\n{| class=\"article-table\"\n|+\n!Front\n!Back\n!Shiny Front\n!Shiny Back\n!Icon\n"
        textresult << "|-"
        textresult << "\n|[[File:#{species.id}.png]]"
        textresult << "\n|[[File:#{species.id}_back.png]]"
        textresult << "\n|[[File:#{species.id}_shiny.png]]"
        textresult << "\n|[[File:#{species.id}_shiny_back.png]]"
        textresult << "\n|[[File:#{species.id}_icon.png]]"
        outfitable = [:CACNEA_1,:CACTURNE_1,:BUIZEL_1,:FLOATZEL_1,:WOOPER_1,:QUAGSIRE_1,:MAWILE_1,:SABLEYE_1,:SPIRITOMB_1,:BULBASAUR,:IVYSAUR,:VENUSAUR,:TOTODILE,:CROCONAW,:FERALIGATR,:TORCHIC,:COMBUSKEN,:BLAZIKEN,:CELEBI,:MANKEY_1,:PRIMEAPE_1,:PORYGON2,:PORYGONZ]
        if outfitable.include?(species.id)
          textresult << "\n|-\n|[[File:#{speciest.id}_outfit.png]]"
          textresult << "\n|[[File:#{speciest.id}_outfit_back.png]]"
          textresult << "\n|[[File:#{speciest.id}_outfit_shiny.png]]"
          textresult << "\n|[[File:#{speciest.id}_outfit_shiny_back.png]]"
          textresult << "\n|[[File:#{speciest.id}_outfit_icon.png]]"
        end
    File.write(filename, textresult)
    File.write("#{DEBUG_PATH}/PostToWiki/vagrant/post_data/#{species.name}.txt", textresult)
    echoln "- Extracted wiki article for #{species.id} to #{DEBUG_PATH}Forms/#{species.name}.txt"
    #echoln getAllGiftMons
  end
  pbSetWindowText(nil)
  echoln "** Successfully extracted articles for all forms to #{DEBUG_PATH}Forms/ **"
end

DebugMenuCommands.register("extractformsforwiki", {
  "parent"      => "othermenu",
  "name"        => _INTL("Extract Forms"),
  "description" => _INTL("Extract Forms"),
  "always_show" => true,
  "effect"      => proc {
    extractFormsForWiki
  }
})

def extractPokedexForWiki
  textresult = "{| class=\"article-table\"\n|+\n|'''No.'''\n|''' '''\n| colspan=\"2\" |'''Pokémon'''\n|'''Type'''\n"
  pbLoadRegionalDexes[2].each do |s|
    pbSetWindowText(_INTL("Writing pokedex..."))
    #Graphics.update if s.id_number % 50 == 0
    species = GameData::Species.get(s)
    textresult << "|-\n"
    textresult << "|##{pbGetFormattedRegionalNumber(2,species)}\n"
    textresult << "|[[File:#{species.id}_icon.png|frameless|31x31px]]\n"
    if species.form == 1
      textresult << "|[[#{species.name}]]\n"
    else
      textresult << "|#{species.name}\n"
    end
    textresult << "|[[File:#{GameData::Type.get(species.type1).name}Type.png]]"
    textresult << " [[File:#{GameData::Type.get(species.type2).name}Type.png]]" if species.type1 != species.type2
    textresult << "\n"
  end
  textresult << "|}"
  File.write("#{DEBUG_PATH}pokedex.txt", textresult)
  echoln "** Successfully extracted Pokédex article to #{DEBUG_PATH}pokedex.txt"
  pbSetWindowText(nil)
end

DebugMenuCommands.register("extractpokedexforwiki", {
  "parent"      => "othermenu",
  "name"        => _INTL("Extract Pokedex"),
  "description" => _INTL("Extract Pokedex"),
  "always_show" => true,
  "effect"      => proc {
    extractPokedexForWiki
  }
})