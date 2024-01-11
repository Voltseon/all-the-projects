################################################################################
#
# ENLS's Random Utilities
# Just some random methods that I thought were useful
#
################################################################################

################################################################################
#
# Party Manipulation & Information
#
################################################################################

# Party Index Number | Variables: pok = The Pokemon
def pbPartyIndex(pok,form=0)
  $Trainer.party.each_with_index do |s, i|
    return i if s.isSpecies?(pok.upcase) && !s.egg? && s.form == form
  end
  return nil
  # Example: pbPartyIndex("Cyndaquil") - Returns party index number of Cyndaquil, returns nil if no Cyndaquil is found.
end

# Move Species in Party | Variables: pok = The Pokemon, new = New Position in Party (0 to 5)
def pbSetPartyPosition(pok,newid,form=0)
  species = GameData::Species.get(pok.upcase).id
  oldid = pbPartyIndex(species,form)
  if oldid == nil
    return false
  end
  if oldid!=newid
    tmp = $Trainer.party[oldid]
    $Trainer.party[oldid] = $Trainer.party[newid]
    $Trainer.party[newid] = tmp
    return true
  end
  # Example: pbSetPartyPosition("Jirachi",0,1) - Finds first Jirachi of form 1 in party and swaps it with the Pokemon with id 0 (1st pos)
end

################################################################################
#
# Extract Credits from Debug menu to credits.txt file
#
################################################################################

# Extracts Credits to credits.txt | Variables: 
#   confirm = Ask for confirmation if file exists (Default: true)
#   links = Include links as hyperlinks in the plugin names. Good for Relic Castle. (Default: false)
# Example: pbExtractCredits - Extracts the credits to credits.txt.
#          pbExtractCredits(false) - Same as above but doesn't ask for confirmation even if file exists.
#          pbExtractCredits(false, true) - Same as above but also asks to include the hyperlinks in the plugin names.
def pbExtractCredits(confirm=true, links=false)
  msgwindow = pbCreateMessageWindow
  includeLinks = false
  if confirm
    if safeExists?("credits.txt") &&
      !pbConfirmMessage(_INTL("credits.txt already exists. Overwrite it?"))
    pbDisposeMessageWindow(msgwindow)
    return
    end
  end
  if links
    if pbConfirmMessage(_INTL("Include plugin hyperlinks in plugin names? (Good for Relic Castle's BB Code formatting)"))
      includeLinks = true
      pbDisposeMessageWindow(msgwindow)
    end
  end
 pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
  creditsText = Scene_Credits::CREDIT
  plugin_credits = ""
  PluginManager.plugins.each do |plugin|
    pcred = PluginManager.credits(plugin)
    if includeLinks
      plugin_credits << "[url=#{PluginManager.link(plugin)}]\"#{plugin}\"[/url] v.#{PluginManager.version(plugin)} by:\n"
    else
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
    end
    if pcred.size >= 5
      plugin_credits << pcred[0] + "\n"
      i = 1
      until i >= pcred.size
        plugin_credits << pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n"
        i += 2
      end
    else
      pcred.each { |name| plugin_credits << name + "\n" }
    end
    plugin_credits << "\n"
  end
  creditsText.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
  creditsText.gsub!("<s>", "\n")
  File.write("credits.txt", creditsText)
  pbMessageDisplay(msgwindow,_INTL("All text in the game was extracted and saved to credits.txt."))
  pbDisposeMessageWindow(msgwindow)
end


# Trainers

def getMapTrainers(id, map = nil, mapData = nil)
  mapData = Compiler::MapData.new if mapData.nil?
  map = mapData.getMap(id) if map.nil?
  trainers = []
  map.events.each_value do |event|
    pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
    next if !event || pages.length == 0
    trainer_list = getEventTrainer(event)
    next if trainer_list == []
    trainer_list.each do |trainer|
      next if trainer.nil?
      next if trainer == false || !trainer.is_a?(GameData::Trainer)
      trainers.push(trainer)
      #echoln "  ** Processed #{trainer.real_name} **"
    end
  end
  return trainers
end

def getEventTrainer(event)
  pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
  retval = []
  return [] if event.name[/skipforwiki/]
  pages.each do |page|
    list = page.list
    script = ""
    list.length.times do |i|
      next unless list[i].code == 111 || list[i].code == 355 || list[i].code == 655
      if list[i].code == 111
        next if list[i].parameters[0] != 12
        script = list[i].parameters[1]
      else
        next if list[i].parameters[0] == ""
        script = list[i].parameters[0]
      end
      next if script == ""
      # Trainer
      [/TrainerBattle.start/].each do |c|
        next unless script[c]
        script.gsub!(/_core/,"")
        script.gsub!(/#{c}\(:/,"")
        script.gsub!(/\:/,"")
        script.gsub!(/(?=[)!]).*/,"")
        next if nil_or_empty?(script)
        tr = script.split(",")
        (tr.length > 3 ? 2 : 1).times do |i|
          trtype = tr[0 + i*3].gsub("\"", "").strip.to_sym
          trname = tr[1 + i*3].gsub("\"", "").strip
          trversion = 0
          unless nil_or_empty?(tr[2 + i*3])
            trversion = tr[2 + i*3].gsub("\"", "").strip.to_i
          end
          ret = GameData::Trainer.get(trtype, trname, trversion)
          #echoln "** Retrieving #{ret.id} **"
          retval.push(ret)
        end
      end
    end
  end
  return retval
end

# Items

BANNED_ITEM_MAPS = []

def pbGetAllItems
  items = []
  mapData = Compiler::MapData.new
  mapData.mapinfos.keys.sort.each do |id|
    next if BANNED_ITEM_MAPS.include?(id) || pbGetMapNameFromId(id).include?("MAP")
    map = mapData.getMap(id)
    next if !map || !mapData.mapinfos[id]
    items += getMapItems(id,map,mapData)
  end
  return items
end

def getMapItems(id, map = nil, mapData = nil)
  mapData = Compiler::MapData.new if mapData.nil?
  map = mapData.getMap(id) if map.nil?
  items = []
  map.events.each_value do |event|
    pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
    next if !event || pages.length == 0
    #next unless event.name == "FieldItem" || event.name == "HiddenItem" # Some events have .noshadow name too
    item_list = getEventItem(event)
    next if item_list == []
    item_list.each do |it|
      item = it[0]
      type = it[1]
      next if item.nil?
      next if item == false || !item.is_a?(GameData::Item)
      case event.name
      when "HiddenItem" then location = "#{pbGetMapNameFromId(id)} (Hidden)"
      when ".noshadow" then location = "#{pbGetMapNameFromId(id)} (Hidden)"
      when "FieldItem" then location = "#{pbGetMapNameFromId(id)} (Field)"
      when "Condo sign" then location = "#{pbGetMapNameFromId(id)} (On a sign)"
      else 
        location = "#{pbGetMapNameFromId(id)}"
        case type
        when 1 then location << " (Gift)"
        when 2 then location << " (Berry plant)"
        end
      end
      if item.id == :HM01 || item.flags.include?("WeatherChip")
        location << " (After 5th gym)"
      elsif item.id == :BANETTITE || item.id == :SOULDEW || item.id == :POKEMONBOXLINK
        location << " (After beating the league)"
      end
      items.push({
        "item"     => item,
        "location" => location,
        "mapid"    => id
      })
      #echoln "** Processed #{item.name} **"
    end
  end
  return items
end


def getEventItem(event)
  pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
  retval = []
  return [] if event.name[/skipforwiki/]
  pages.each do |page|
    list = page.list
    script = ""
    list.length.times do |i|
      next unless list[i].code == 111 || list[i].code == 355 || list[i].code == 655
      if list[i].code == 111
        next if list[i].parameters[0] != 12
        script = list[i].parameters[1]
      else
        next if list[i].parameters[0] == ""
        script = list[i].parameters[0]
      end
      next if script == ""
      # Field
      [/pbItemBall/].each do |c|
        next unless script[c]
        next if script.nil?
        script = script.gsub(/#{c}\(:/,"")
        next if script.nil?
        script = script.gsub(/(?=[,)!]).*/,"").gsub(")", "")
        next if nil_or_empty?(script)
        ret = GameData::Item.try_get(script)
        next if ret.nil?
        #echoln "** Retrieving #{ret.id} **"
        retval.push([ret, 0])
      end
      # Berry
      [/pbPickBerry/].each do |c|
        next unless script[c]
        next if script.nil?
        script = script.gsub(/#{c}\(:/,"")
        next if script.nil?
        script = script.gsub(/(?=[,)!]).*/,"").gsub(")", "")
        next if nil_or_empty?(script)
        ret = GameData::Item.try_get(script)
        next if ret.nil?
        #echoln "** Retrieving #{ret.id} **"
        retval.push([ret, 2])
      end
      # Gift
      [/pbReceiveItem/, /vRI/, /vAI/, /vFI/, /$bag.add/].each do |c|
        next unless script[c]
        next if script.nil?
        script = script.gsub(/#{c}\(:/,"")
        next if script.nil?
        script = script.gsub(/(?=[,)!]).*/,"").gsub(")", "")
        next if nil_or_empty?(script)
        ret = GameData::Item.try_get(script)
        next if ret.nil?
        #echoln "** Retrieving #{ret.id} **"
        retval.push([ret, 1])
      end
    end
  end
  return retval
end



# Adds Extract Credits button to Debug menu
MenuHandlers.add(:debug_menu, :extractcredits, {
  "name"        => _INTL("Extract Credits"),
  "parent"      => :other_menu,
  "description" => _INTL("Extract the credits to a single file."),
  "effect"      => proc {
    pbExtractCredits(true, true)
  }
})


def starterQuiz
  ret = false
  if pbConfirmMessage(_INTL("Are you ready for the quiz?"))
    allQuestions = [_INTL("Do you think that you might be a genius?"),
                 _INTL("Do you like to do things according to plan?"),
                 _INTL("You have a really important test tomorrow! What do you do?"),
                 _INTL("You hear a rumor that might make you rich! What do you do?"),
                 _INTL("You're told to wait in a big, empty room. What do you do?"),
                 _INTL("Your friend takes a spectacular fall! What do you do?"),
                 _INTL("Do you think that anything goes when it comes to winning?"),
                 _INTL("You discover a secret passage in a basement. What do you do?"),
                 _INTL("You're daydreaming...when your friend sprays you with water! What do you do?"),
                 _INTL("Do you get injured a lot?"),
                 _INTL("Have you ever wanted to communicate with aliens from another planet?"),
                 _INTL("Do you change the channels often while watching TV?"),
                 _INTL("Are you a city person or a country person?")
                ]
      
    allAnswers = [[_INTL("Certainly!"),_INTL("Well, not really...")],
               [_INTL("Of course!"),_INTL("I'm not good at planning."),_INTL("Plans? Who needs plans?")],
               [_INTL("Study all night long."),_INTL("Wing it! I'm sure it will be fine!"),_INTL("Test?! I think I have a fever...")],
               [_INTL("Keep it all to myself."),_INTL("Share it with friends."),_INTL("Spread a different rumor!")],
               [_INTL("Wait quietly."),_INTL("Search for something to do."),_INTL("Wander outside."),_INTL("Cradle my knees and sit in the corner!")],
               [_INTL("Help my friend up!"),_INTL("Laugh! It's too funny!"),_INTL("Take a picture before helping them up.")],
               [_INTL("Of course!"),_INTL("No way!")],
               [_INTL("Go through it!"),_INTL("Stay away from it.")],
               [_INTL("Get mad!"),_INTL("Get sad."),_INTL("Woo-hoo! Water fight!")],
               [_INTL("Yes!"),_INTL("No!")],
               [_INTL("Yes!"),_INTL("No!")],
               [_INTL("Yes!"),_INTL("No!")],
               [_INTL("I like the city!"),_INTL("I like the country!"),_INTL("I like them both!")]
              ]

    allResults = [[[1],[3]],
                  [[2,8],[5,9],[1]],
                  [[7,4,9],[8],[6]],
                  [[1],[6,9],[5]],
                  [[3],[2],[7],[8]],
                  [[5,6,8],[3,4],[2,9]],
                  [[6,7,9],[1,2,3]],
                  [[3,4],[1,7]],
                  [[4,9],[6],[7]],
                  [[5],[8]],
                  [[3,4,5],[1,2,6,8]],
                  [[1,2,4,5],[3,6,7,8,9]],
                  [[5],[7],[2,4]]
                ]

    genResults = []
    allQuestions.each_with_index do |question, i|
      genResults += quizQuestion(allQuestions[i], allAnswers[i], allResults[i])
    end
    quizResult = {}
    quizResult = genResults.tally
    highest = 1
    quizResult.each do |key, value|
      next if value.nil? || key.nil?
      highest = key if value > quizResult[highest]
    end
    pbSet(26,highest)
    regions = ["None","Kanto","Johto","Hoenn","Sinnoh","Unova","Kalos","Alola","Galar","Paldea"]
    genCount = genResults.count(pbGet(26))
    genCount+=1 if genCount == 4
    percent = (genResults.count(pbGet(26)).to_f/8.0)
    percent *= 100.0
    pbMessage(_INTL("Quiz Completed. #{percent.round}% of people in #{regions[pbGet(26)]} had similar answers to yours."))
    ret = true
  end
  return ret
end

def quizQuestion(question, answers, results)
  genResults = []
  command = pbMessage(question, answers, answers.length)
  for i in results[command]
    genResults.push(i)
  end
  return genResults
end

def get_encounter_rates
  mons = []
  regionalSpecies = []
  GameData::Species.each_species { |s| regionalSpecies.push(s.id) }
  GameData::Species.each do |species|
    odds = 0
    GameData::Encounter.each do |enc|
      enc.types.each do |type, slots|
        next if slots.nil? || slots == [] || slots == {}
        next unless slots.any? { |slot| GameData::Species.get(slot[1]).id == species.id && GameData::Species.get(slot[1]).form == species.form }
        slots.each { |slot| odds += slot[0].to_i if GameData::Species.get(slot[1]).id == species.id && GameData::Species.get(slot[1]).form == species.form}
      end
    end
    mons.push([species.name, (species.form == 0 ? nil : species.real_form_name), odds, species, species.id, (regionalSpecies.include?(species.id) ? regionalSpecies.index(species.id) : 9999)])
  end
  new_mons = []
  mons.each do |mon|
    if mon[2] > 0
      new_mons.push(mon)
      next
    end
    evos = mon[3].get_family_species
    evolution_odds = 0
    if evos.length > 0
      evos.each do |evo|
        mons.each do |mon_two|
          next unless mon_two[4] == evo
          evolution_odds += mon_two[2]
        end
      end
    end
    new_mons.push(mon) if evolution_odds == 0
  end
  new_mons.sort! { |a, b| b[2] <=> a[2] || a[5] <=> b[5] }
  File.open("mons.txt", "w") do |f|
    textual = ""
    new_mons.each do |mon|
      textual << "#{mon[2]}% : #{mon[0]}#{mon[1].nil? ? "" : " (#{mon[1]})"}\n"
    end
    textural = textual[0..-2]
    f.write(textual)
  end
end

module VersionNumber
  URL = "https://pastebin.com/raw/nakQ52bC"
  ThreadURL = "https://reliccastle.com/threads/5415/"
end

class PokemonSystem
  attr_accessor :muted_update

  def muted_update
    @muted_update = "" if !@muted_update
    return @muted_update
  end
end

def pbCheckAvailableUpdate
  latest_version = pbDownloadToString(VersionNumber::URL)
  return if nil_or_empty?(latest_version)
  if Settings::GAME_VERSION != latest_version
    return if latest_version == $PokemonSystem.muted_update
    sprites = {}
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    addBackgroundPlane(sprites, "background", "loadbg", viewport)
    pbFadeInAndShow(sprites)
    sprites["msgwindow"] = pbCreateMessageWindow
    pbMessageDisplay(sprites["msgwindow"], _INTL("A new update (v#{latest_version}) is available. Current version: v#{Settings::GAME_VERSION}"))
    loop do
      pbMessageDisplay(sprites["msgwindow"], _INTL("Open Relic Castle thread to download latest version?\\wtnp[0]"))
      command = pbShowCommands(sprites["msgwindow"], [_INTL("Yes"), _INTL("No")], -1)
      if command == -1 || command == 1
        pbMessageDisplay(sprites["msgwindow"], _INTL("Stop getting update notifications for version #{latest_version}?\\wtnp[0]"))
        command_two = pbShowCommands(sprites["msgwindow"], [_INTL("Yes"), _INTL("No")], -1)
        if command_two == 0
          $PokemonSystem.muted_update = latest_version
        end
        break
      else
        System.launch(VersionNumber::ThreadURL)
        break
      end
    end
    pbFadeOutAndHide(sprites)
    pbDisposeMessageWindow(sprites["msgwindow"])
    pbDisposeSpriteHash(sprites)
    viewport.dispose
  end
end

def checkItemAll(item)
  return false if item.nil? || !item.is_a?(Symbol)
  return true if $PokemonGlobal.pcItemStorage && $PokemonGlobal.pcItemStorage.quantity(item) > 0
  return true if $bag.has?(item)
  ret = false
  $player.party.each { |pkmn| ret = true if pkmn.item == item }
  return ret if ret
  $PokemonStorage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; ret = true if pkmn.item == item } }
  return ret if ret
  $PokemonGlobal.day_care.slots.each { |slot| next unless slot.filled?; ret = true if slot.pokemon.item == item }
  return ret
end

def getAllPokemon(trainer = $player, storage = $PokemonStorage, global = $PokemonGlobal)
  ret = []
  trainer.party.each { |pkmn| next if pkmn.nil?; ret.push(pkmn) }
  storage.boxes.each { |box| box.pokemon.each { |pkmn| next if pkmn.nil?; ret.push(pkmn) } }
  global.day_care.slots.each { |slot| next unless slot.filled?; ret.push(slot.pokemon) }
  global.purifyChamber.sets.each { |set| set.list.each { |pkmn| next if pkmn.nil? ret.push(pkmn) }; ret.push(set.shadow) unless set.shadow.nil? }
  return ret
end

ITEM_GRAPHICS = {
  # Item ID           => [Item graphic file, direction, pattern]
  # Item001
  :MASTERBALL         => ["Item001", 2, 0],
  :ULTRABALL          => ["Item001", 2, 1],
  :GREATBALL          => ["Item001", 2, 2],
  :POKEBALL           => ["Item001", 2, 3],
  :NETBALL            => ["Item001", 4, 0],
  :DIVEBALL           => ["Item001", 4, 1],
  :NESTBALL           => ["Item001", 4, 2],
  :REPEATBALL         => ["Item001", 4, 3],
  :TIMERBALL          => ["Item001", 6, 0],
  :LUXURYBALL         => ["Item001", 6, 1],
  :PREMIERBALL        => ["Item001", 6, 2],
  :DUSKBALL           => ["Item001", 6, 3],
  :HEALBALL           => ["Item001", 8, 0],
  :QUICKBALL          => ["Item001", 8, 1],
  :CHERISHBALL        => ["Item001", 8, 2],
  :POTION             => ["Item001", 8, 3],
  # Item002   
  :ANTIDOTE           => ["Item002", 2, 0],
  :BURNHEAL           => ["Item002", 2, 1],
  :ICEHEAL            => ["Item002", 2, 2],
  :AWAKENING          => ["Item002", 2, 3],
  :PARLYZHEAL         => ["Item002", 4, 0],
  :PARALYZEHEAL       => ["Item002", 4, 0],
  :FULLRESTORE        => ["Item002", 4, 1],
  :MAXPOTION          => ["Item002", 4, 2],
  :HYPERPOTION        => ["Item002", 4, 3],
  :SUPERPOTION        => ["Item002", 6, 0],
  :FULLHEAL           => ["Item002", 6, 1],
  :REVIVE             => ["Item002", 6, 2],
  :MAXREVIVE          => ["Item002", 6, 3],
  :FRESHWATER         => ["Item002", 8, 0],
  :SODAPOP            => ["Item002", 8, 1],
  :LEMONADE           => ["Item002", 8, 2],
  :MOOMOOMILK         => ["Item002", 8, 3],
  # Item003   
  :ENERGYPOWDER       => ["Item003", 2, 0],
  :ENERGYROOT         => ["Item003", 2, 1],
  :HEALPOWDER         => ["Item003", 2, 2],
  :REVIVALHERB        => ["Item003", 2, 3],
  :ETHER              => ["Item003", 4, 0],
  :MAXETHER           => ["Item003", 4, 1],
  :ELIXIR             => ["Item003", 4, 2],
  :MAXELIXIR          => ["Item003", 4, 3],
  :SACREDASH          => ["Item003", 6, 0],
  :HPUP               => ["Item003", 6, 1],
  :PROTEIN            => ["Item003", 6, 2],
  :IRON               => ["Item003", 6, 3],
  :CARBOS             => ["Item003", 8, 0],
  :CALCIUM            => ["Item003", 8, 1],
  :RARECANDY          => ["Item003", 8, 2],
  :PPUP               => ["Item003", 8, 3],
  # Item004   
  :ZINC               => ["Item004", 2, 0],
  :PPMAX              => ["Item004", 2, 1],
  :GUARDSPEC          => ["Item004", 2, 2],
  :DIREHIT            => ["Item004", 2, 3],
  :XATTACK            => ["Item004", 4, 0],
  :XDEFENSE           => ["Item004", 4, 1],
  :XSPEED             => ["Item004", 4, 2],
  :XACCURACY          => ["Item004", 4, 3],
  :XSPATK             => ["Item004", 6, 0],
  :XSPDEF             => ["Item004", 6, 1],
  :POKEDOLL           => ["Item004", 6, 2],
  :FLUFFYTAIL         => ["Item004", 6, 3],
  :SHOALSALT          => ["Item004", 8, 0],
  :SHOALSHELL         => ["Item004", 8, 1],
  :REDSHARD           => ["Item004", 8, 2],
  :BLUESHARD          => ["Item004", 8, 3],
  # Item005   
  :YELLOWSHARD        => ["Item005", 2, 0],
  :GREENSHARD         => ["Item005", 2, 1],
  :SUPERREPEL         => ["Item005", 2, 2],
  :MAXREPEL           => ["Item005", 2, 3],
  :ESCAPEROPE         => ["Item005", 4, 0],
  :REPEL              => ["Item005", 4, 1],
  :SUNSTONE           => ["Item005", 4, 2],
  :MOONSTONE          => ["Item005", 4, 3],
  :FIRESTONE          => ["Item005", 6, 0],
  :THUNDERSTONE       => ["Item005", 6, 1],
  :WATERSTONE         => ["Item005", 6, 2],
  :LEAFSTONE          => ["Item005", 6, 3],
  :TINYMUSHROOM       => ["Item005", 8, 0],
  :BIGMUSHROOM        => ["Item005", 8, 1],
  :PEARL              => ["Item005", 8, 2],
  :BIGPEARL           => ["Item005", 8, 3],
  # Item006   
  :STARDUST           => ["Item006", 2, 0],
  :STARPIECE          => ["Item006", 2, 1],
  :NUGGET             => ["Item006", 2, 2],
  :HEARTSCALE         => ["Item006", 2, 3],
  :HONEY              => ["Item006", 4, 0],
  :ROOTFOSSIL         => ["Item006", 4, 1],
  :CLAWFOSSIL         => ["Item006", 4, 2],
  :HELIXFOSSIL        => ["Item006", 4, 3],
  :DOMEFOSSIL         => ["Item006", 6, 0],
  :OLDAMBER           => ["Item006", 6, 1],
  :RAREBONE           => ["Item006", 6, 2],
  :SHINYSTONE         => ["Item006", 6, 3],
  :DUSKSTONE          => ["Item006", 8, 0],
  :DAWNSTONE          => ["Item006", 8, 1],
  :GRISEOUSORB        => ["Item006", 8, 2],
  :ADAMANTORB         => ["Item006", 8, 3],
  # Item007   
  :LUSTROUSORB        => ["Item007", 2, 0],
  :BRIGHTPOWDER       => ["Item007", 2, 1],
  :EXPSHARE           => ["Item007", 2, 2],
  :KINGSROCK          => ["Item007", 2, 3],
  :DEEPSEATOOTH       => ["Item007", 4, 0],
  :DEEPSEASCALE       => ["Item007", 4, 1],
  :EVERSTONE          => ["Item007", 4, 2],
  :LUCKYEGG           => ["Item007", 4, 3],
  :METALCOAT          => ["Item007", 6, 0],
  :LEFTOVERS          => ["Item007", 6, 1],
  :DRAGONSCALE        => ["Item007", 6, 2],
  :SOFTSAND           => ["Item007", 6, 3],
  :HARDSTONE          => ["Item007", 8, 0],
  :MAGNET             => ["Item007", 8, 1],
  :SILKSCARF          => ["Item007", 8, 2],
  :UPGRADE            => ["Item007", 8, 3],
  # Item008   
  :SHELLBELL          => ["Item008", 2, 0],
  :SEAINCENSE         => ["Item008", 2, 1],
  :LAXINCENSE         => ["Item008", 2, 2],
  :METALPOWDER        => ["Item008", 2, 3],
  :THICKCLUB          => ["Item008", 4, 0],
  :LEEK               => ["Item008", 4, 1],
  :STICK              => ["Item008", 4, 1],
  :QUICKPOWDER        => ["Item008", 4, 2],
  :METRONOME          => ["Item008", 4, 3],
  :ICYROCK            => ["Item008", 6, 0],
  :SMOOTHROCK         => ["Item008", 6, 1],
  :HEATROCK           => ["Item008", 6, 2],
  :DAMPROCK           => ["Item008", 6, 3],
  :CHOICESCARF        => ["Item008", 8, 0],
  :STICKYBARB         => ["Item008", 8, 1],
  :FLAMEPLATE         => ["Item008", 8, 2],
  :SPLASHPLATE        => ["Item008", 8, 3],
  # Item009   
  :ZAPPLATE           => ["Item009", 2, 0],
  :MEADOWPLATE        => ["Item009", 2, 1],
  :ICICLEPLATE        => ["Item009", 2, 2],
  :FISTPLATE          => ["Item009", 2, 3],
  :TOXICPLATE         => ["Item009", 4, 0],
  :EARTHPLATE         => ["Item009", 4, 1],
  :SKYPLATE           => ["Item009", 4, 2],
  :MINDPLATE          => ["Item009", 4, 3],
  :INSECTPLATE        => ["Item009", 6, 0],
  :STONEPLATE         => ["Item009", 6, 1],
  :SPOOKYPLATE        => ["Item009", 6, 2],
  :DRACOPLATE         => ["Item009", 6, 3],
  :DREADPLATE         => ["Item009", 8, 0],
  :IRONPLATE          => ["Item009", 8, 1],
  :ODDINCENSE         => ["Item009", 8, 2],
  :ROCKINCENSE        => ["Item009", 8, 3],
  # Item010   
  :FULLINCENSE        => ["Item010", 2, 0],
  :WAVEINCENSE        => ["Item010", 2, 1],
  :ROSEINCENSE        => ["Item010", 2, 2],
  :LUCKINCENSE        => ["Item010", 2, 3],
  :PUREINCENSE        => ["Item010", 4, 0],
  :PROTECTOR          => ["Item010", 4, 1],
  :ELECTIRIZER        => ["Item010", 4, 2],
  :MAGMARIZER         => ["Item010", 4, 3],
  :DUBIOUSDISC        => ["Item010", 6, 0],
  :REAPERCLOTH        => ["Item010", 6, 1],
  :RAZORFANG          => ["Item010", 6, 2],
  :RAZORCLAW          => ["Item010", 6, 3],
  :TOWNMAP            => ["Item010", 8, 0],
  :LETTER             => ["Item010", 8, 1],
  :PARCEL             => ["Item010", 8, 2],
  :CARDKEY            => ["Item010", 8, 3],
  # Item011   
  :SQUIRTBOTTLE       => ["Item011", 2, 0],
  :MYSTERYEGG         => ["Item011", 2, 1],
  :REDAPRICORN        => ["Item011", 2, 2],
  :BLUEAPRICORN       => ["Item011", 2, 3],
  :YELLOWAPRICORN     => ["Item011", 4, 0],
  :GREENAPRICORN      => ["Item011", 4, 1],
  :PINKAPRICORN       => ["Item011", 4, 2],
  :WHITEAPRICORN      => ["Item011", 4, 3],
  :BLACKAPRICORN      => ["Item011", 6, 0],
  :FASTBALL           => ["Item011", 6, 1],
  :LEVELBALL          => ["Item011", 6, 2],
  :LUREBALL           => ["Item011", 6, 3],
  :HEAVYBALL          => ["Item011", 8, 0],
  :LOVEBALL           => ["Item011", 8, 1],
  :FRIENDBALL         => ["Item011", 8, 2],
  :MOONBALL           => ["Item011", 8, 3],
  # Item012   
  :SPORTBALL          => ["Item012", 2, 0],
  :PARKBALL           => ["Item012", 2, 1],
  :PRISMSCALE         => ["Item012", 2, 2],
  :ROCKYHELMET        => ["Item012", 2, 3],
  :FIREGEM            => ["Item012", 4, 0],
  :WATERGEM           => ["Item012", 4, 1],
  :ELECTRICGEM        => ["Item012", 4, 2],
  :GRASSGEM           => ["Item012", 4, 3],
  :ICEGEM             => ["Item012", 6, 0],
  :FIGHTINGGEM        => ["Item012", 6, 1],
  :POISONGEM          => ["Item012", 6, 2],
  :GROUNDGEM          => ["Item012", 6, 3],
  :FLYINGGEM          => ["Item012", 8, 0],
  :PSYCHICGEM         => ["Item012", 8, 1],
  :BUGGEM             => ["Item012", 8, 2],
  :ROCKGEM            => ["Item012", 8, 3],
  # Item013   
  :GHOSTGEM           => ["Item013", 2, 0],
  :DRAGONGEM          => ["Item013", 2, 1],
  :DARKGEM            => ["Item013", 2, 2],
  :STEELGEM           => ["Item013", 2, 3],
  :NORMALGEM          => ["Item013", 4, 0],
  :PRETTYFEATHER      => ["Item013", 4, 1],
  :COVERFOSSIL        => ["Item013", 4, 2],
  :PLUMEFOSSIL        => ["Item013", 4, 3],
  :DREAMBALL          => ["Item013", 6, 0],
  :DRAGONSKULL        => ["Item013", 6, 1],
  :BALMMUSHROOM       => ["Item013", 6, 2],
  :BIGNUGGET          => ["Item013", 6, 3],
  :PEARLSTRING        => ["Item013", 8, 0],
  :COMETSHARD         => ["Item013", 8, 1],
  :PIXIEPLATE         => ["Item013", 8, 2],
  :WHIPPEDDREAM       => ["Item013", 8, 3],
  # Item014   
  :SATCHET            => ["Item014", 2, 0],
  :POKEFLUTE          => ["Item014", 2, 1],
  :JAWFOSSIL          => ["Item014", 2, 2],
  :SAILFOSSIL         => ["Item014", 2, 3],
  :FAIRYGEM           => ["Item014", 4, 0],
  :BLACKSLUDGE        => ["Item014", 4, 1],
  :REDORB             => ["Item014", 4, 2],
  :BLUEORB            => ["Item014", 4, 3],
  :NORMALIUMZ         => ["Item014", 6, 0],
  :FIRIUMZ            => ["Item014", 6, 1],
  :WATERIUMZ          => ["Item014", 6, 2],
  :ELECTRIUMZ         => ["Item014", 6, 3],
  :GRASSIUMZ          => ["Item014", 8, 0],
  :ICIUMZ             => ["Item014", 8, 1],
  :FIGHTINIUMZ        => ["Item014", 8, 2],
  :POISONIUMZ         => ["Item014", 8, 3],
  # Item015   
  :GROUNDIUMZ         => ["Item015", 2, 0],
  :FLYINIUMZ          => ["Item015", 2, 1],
  :PSYCHIUMZ          => ["Item015", 2, 2],
  :BUGINIUMZ          => ["Item015", 2, 3],
  :ROCKIUMZ           => ["Item015", 4, 0],
  :GHOSTIUMZ          => ["Item015", 4, 1],
  :DRAGONIUMZ         => ["Item015", 4, 2],
  :DARKINIUMZ         => ["Item015", 4, 3],
  :STEELIUMZ          => ["Item015", 6, 0],
  :FAIRIUMZ           => ["Item015", 6, 1],
  :ZRING              => ["Item015", 6, 2],
  :SPARKLINGSTONE     => ["Item015", 6, 3],
  :ZYGARDECUBE        => ["Item015", 8, 0],
  :ICESTONE           => ["Item015", 8, 1],
  :BEASTBALL          => ["Item015", 8, 2],
  :SUNFLUTE           => ["Item015", 8, 3],
  # Item016   
  :MOONFLUTE          => ["Item016", 2, 0],
  :GOLDTEETH          => ["Item016", 2, 1],
  :FLAMEORB           => ["Item016", 2, 2],
  :TOXICORB           => ["Item016", 2, 3],
  :EVIOLITE           => ["Item016", 4, 0],
  :EJECTBUTTON        => ["Item016", 4, 1],
  :ABILITYCAPSULE     => ["Item016", 4, 2],
  :LIFEORB            => ["Item016", 4, 3],
  # empty space       => ["Item016", 6, 0],
  # empty space       => ["Item016", 6, 1],
  # empty space       => ["Item016", 6, 2],
  # empty space       => ["Item016", 6, 3],
  # empty space       => ["Item016", 8, 0],
  :machine_SHADOW     => ["Item016", 8, 1],
  :machine_WATER      => ["Item016", 8, 2],
  :machine_STEEL      => ["Item016", 8, 3],
  # Item017   
  :machine_DRAGON     => ["Item017", 2, 0],
  :machine_BUG        => ["Item017", 2, 1],
  :machine_DARK       => ["Item017", 2, 2],
  :machine_ELECTRIC   => ["Item017", 2, 3],
  :machine_FAIRY      => ["Item017", 4, 0],
  :machine_FIGHTING   => ["Item017", 4, 1],
  :machine_FIRE       => ["Item017", 4, 2],
  :machine_FLYING     => ["Item017", 4, 3],
  :machine_GHOST      => ["Item017", 6, 0],
  :machine_GRASS      => ["Item017", 6, 1],
  :machine_GROUND     => ["Item017", 6, 2],
  :machine_ICE        => ["Item017", 6, 3],
  :machine_NORMAL     => ["Item017", 8, 0],
  :machine_POISON     => ["Item017", 8, 1],
  :machine_PSYCHIC    => ["Item017", 8, 2],
  :machine_ROCK       => ["Item017", 8, 3]
}

def itemGraphic(item_id)
  return ITEM_GRAPHICS[:POKEBALL] if !ITEM_GRAPHICS[item_id]
  return ITEM_GRAPHICS[item_id]
end

