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


################################################################################
#
# EXP Rare Candy Machine (Requires EXP Capsule Plugin)
#
################################################################################

# Opens EXP Capsule Machine
def pbDepositExp
  return if !PluginManager.installed?("EXP Capsule")
  if vHI("EXPCAPSULE")
    exp = $Trainer.expcapsule
    candyCost = 10000
    ableCandies = exp / candyCost
    params = ChooseNumberParams.new
    params.setRange(0, ableCandies)
    params.setCancelValue(-1)
    params.setInitialValue(ableCandies)
    pbMessage(_INTL("The Exp Capsule contains {1} Exp. Points.",exp))
    if ableCandies < 1
      pbMessage(_INTL("You need 10,000 Exp. Points to withdraw a Rare Candy."))
      return true
    elsif ableCandies == 1
      if pbConfirmMessage(_INTL("You can withdraw 1 Rare Candy. Withdraw?"))
        qty = 1
        vRI("RARECANDY",qty)
        expSpent = qty * 10000
        $Trainer.expcapsule -= expSpent
        return true
      else
        return true
      end
    elsif ableCandies > 1
      qty = pbMessageChooseNumber(_INTL("How many Rare Candies do you want to withdraw?"),params)
      return if qty < 1
      if pbConfirmMessage(_INTL("Withdraw {1} Rare Candies?",qty))
        vRI("RARECANDY",qty)
        expSpent = qty * 10000
        $Trainer.expcapsule -= expSpent
        return true
      else
        return true
      end
    end
  else
    pbMessage(_INTL("You need an Exp. Capsule to access this machine."))
    return true
  end
end




# Dance Mats
#when 2 then $game_player.jump(0, dist)    # down
#when 4 then $game_player.jump(-dist, 0)   # left
#when 6 then $game_player.jump(dist, 0)    # right
#when 8 then $game_player.jump(0, -dist)   # up

#moveroute1 = [6,8,2,4,4,4,8,6]
# Right,Up,Down,Left,Left,Left,Up,Right
#moveroute2 = [8,2,4,8,6,2,6,6]
# Up, Down, Left, Up, Right, Down, Right, Right
#moveroute3 = [6,8,6,2,4,4,8,4]
# Right, Up, Right, Down, Left, Left, Up, Left
def playDing
  case $game_variables[29]
  when 1 then pbSEPlay("ding1")
  when 2 then pbSEPlay("ding2")
  when 3 then pbSEPlay("ding3")
  when 4 then pbSEPlay("ding4")
  when 5 then pbSEPlay("ding5")
  when 6 then pbSEPlay("ding6")
  when 7 then pbSEPlay("ding7")
  when 8 then pbSEPlay("ding8")
  end
end

def pbMatTileCheck
  moveroute = $game_variables[28]
  if $game_player.direction == moveroute[0]
    $game_variables[28].delete_at(0)
    $game_variables[29] +=1
    playDing
    return true
  else
    return false
  end
end

echoln("Loaded plugin: ENLS's Random Utilities") if Essentials::VERSION != "19.1"