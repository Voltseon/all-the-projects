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
    $PokemonTemp.dependentEvents.refresh_sprite(true)
    return true
  end
  # Example: pbSetPartyPosition("Jirachi",0,1) - Finds first Jirachi of form 1 in party and swaps it with the Pokemon with id 0 (1st pos)
end

# Remove First of a Species from Party | Variables: pok = The Pokemon, f
def pbRemoveFromParty(pok,form=0)
  index = pbPartyIndex(pok,form)
  return if index.nil?
  $Trainer.party.delete_at(index)
  # Example: pbRemoveFromParty("Celebi") - Finds first Celebi in part and deletes
end

def getPendant(pendant)
  $Trainer.pendants[pendant] = true
  pbMessage(_INTL("\\me[HGSS 237 Third Place in the Bug-Catching Contest]You found a pendant!\\wtnp[40]"))
  $game_variables[33]+=1
  case $game_variables[33]
  when 1
    pbMessage(_INTL("Pendants are small collectibles that can be found all over the region."))
    pbMessage(_INTL("\\v[33]/8 pendants found."))
  when 8
    pbMessage(_INTL("\\v[33]/8 pendants found."))
    pbMessage(_INTL("You've found all of the pendants!"))
    pbMessage(_INTL("\\me[DPPT 103 Get Accessory]You unlocked a new Trainer Card!\\wtnp[40]"))
  else
    pbMessage(_INTL("\\v[33]/8 pendants found."))
  end
end

def pokedexCheck
  $game_variables[40] = [false] * 6 if !$game_variables[40].is_a?(Array)
  dexowned = $Trainer.pokedex.owned_count
  rewards = [:SMOKEBALL,:RELICCOPPER,:RELICSILVER,:OVALCHARM,:RELICGOLD,:SHINYCHARM]
  case
  when dexowned > 150
    pbMessage(_INTL("\\me[Bug catching 1st]\\bAmazing work! You have caught a huge amount of Pokémon."))
    if !$game_variables[40][5]
      $game_variables[40][5] = true
      pbMessage(_INTL("\\bHere, take this as a reward!"))
      vRI(rewards[5])
      for i in 0..4
        if !$game_variables[40][i]
          $game_variables[40][i] = true
          vRI(rewards[i])
        end
      end
    end
  when dexowned > 120
    pbMessage(_INTL("\\me[Bug catching 2nd]\\bGreat job! You have caught a lot of the Peskan Pokémon."))
    if !$game_variables[40][4]
      $game_variables[40][4] = true
      pbMessage(_INTL("\\bHere, take this as a reward!"))
      vRI(rewards[4])
      for i in 0..3
        if !$game_variables[40][i]
          $game_variables[40][i] = true
          vRI(rewards[i])
        end
      end
    end
  when dexowned > 100
    pbMessage(_INTL("\\me[Bug catching 3rd]\\bGreat work! You have caught many of the Peskan Pokémon."))
    if !$game_variables[40][3]
      $game_variables[40][3] = true
      pbMessage(_INTL("\\bHere, take this as a reward!"))
      vRI(rewards[3])
      for i in 0..2
        if !$game_variables[40][i]
          $game_variables[40][i] = true
          vRI(rewards[i])
        end
      end
    end
  when dexowned > 80
    pbMessage(_INTL("\\me[Bug catching 3rd]\\bCongratulations! You have caught over half of the Peskan Pokémon."))
    if !$game_variables[40][2]
      $game_variables[40][2] = true
      pbMessage(_INTL("\\bHere, take this as a reward!"))
      vRI(rewards[2])
      for i in 0..1
        if !$game_variables[40][i]
          $game_variables[40][i] = true
          vRI(rewards[i])
        end
      end
    end
  when dexowned > 50
    pbMessage(_INTL("\\me[Bug catching 3rd]\\bHeck yeah! You have caught a huge portion of the Peskan Pokémon."))
    if !$game_variables[40][1]
      $game_variables[40][1] = true
      pbMessage(_INTL("\\bHere, take this as a reward!"))
      vRI(rewards[1])
      if !$game_variables[40][0]
        $game_variables[40][0] = true
        vRI(rewards[0])
      end
    end
  when dexowned > 20
    pbMessage(_INTL("\\me[Bug catching 3rd]\\bNice! You are well on your way to catch all of the Peskan Pokémon."))
    if !$game_variables[40][0]
      $game_variables[40][0] = true
      pbMessage(_INTL("\\bHere, take this as a reward!"))
      vRI(rewards[0])
    end
  else
    pbMessage(_INTL("\\bI see that you are on your way to catch some of the Peskan Pokémon."))
    pbMessage(_INTL("\\bBut I'll have to unfortunately see some more progress to reward you."))
  end
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
  pbMessageDisplay(msgwindow,_INTL("All text in the game was extracted and saved to credits.txt.\1"))
  pbDisposeMessageWindow(msgwindow)
end

# Adds Extract Credits button to Debug menu
DebugMenuCommands.register("extractcredits", {
  "parent"      => "othermenu",
  "name"        => _INTL("Extract Credits"),
  "description" => _INTL("Extract the credits to a single file."),
  "always_show" => true,
  "effect"      => proc {
    pbExtractCredits(true, true)
  }
})

def calendarEvent(mine=true)
  t = Time.now
  dayEndings = ["th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "th", "st", "nd", "rd", "th", "th", "th", "th", "th", "th", "th", "st"]
  pbMessage(_INTL("It's my calendar!")) if mine
  pbMessage(_INTL("Today is {1}{2}, {3}.",t.strftime("%B %d"),dayEndings[t.day], t.year))
  case t.month
  when 1
    pbMessage(_INTL("Happy New Year!")) if t.day == 1
    pbMessage(_INTL("January is probably my favorite winter month.")) if t.day != 1
    return
  when 2
    pbMessage(_INTL("My dad's birthday is this month, on Valentine's Day!"))
    pbMessage(_INTL("That's today! Happy birthday, Dad!")) if t.day == 14
    return
  when 3
    pbMessage(_INTL("Nothing interesting ever happens in March..."))
    return
  when 4
    pbMessage(_INTL("April is probably my least favorite month."))
    return
  when 5
    pbMessage(_INTL("It's almost summer!"))
    return
  when 6
    pbMessage(_INTL("It's the start of the summer!"))
    return
  when 7
    pbMessage(_INTL("My birthday is this month!"))
    return
  when 8
    pbMessage(_INTL("Summer is ending soon."))
    return
  when 9
    pbMessage(_INTL("It's getting colder..."))
    return
  when 10
    pbMessage(_INTL("It's almost Halloween!")) if t.day != 31
    pbMessage(_INTL("I love Halloween!")) if t.day == 31
    return
  when 11
    pbMessage(_INTL("Winter is approaching!"))
    return
  when 12
    pbMessage(_INTL("It's Christmas month!")) if t.day <= 12
    pbMessage(_INTL("It's almost Christmas!")) if t.day > 12 && t.day < 24
    pbMessage(_INTL("I love Christmas!")) if t.day >= 24
    return
  end
end

echoln("Loaded plugin: ENLS's Random Utilities") if Essentials::VERSION != "19.1"
