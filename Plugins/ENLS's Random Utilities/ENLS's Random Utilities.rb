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
 #pbMessageDisplay(msgwindow,_INTL("Please wait.\\wtnp[0]"))
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
  #pbMessageDisplay(msgwindow,_INTL("All text in the game was extracted and saved to credits.txt."))
  #pbDisposeMessageWindow(msgwindow)
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