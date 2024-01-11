#===============================================================================
# Modern Questing System + UI
# If you like quests, this is the resource for you!
#===============================================================================
# Original implemenation by mej71
# Updated for v17.2 and v18/18.1 by derFischae
# Heavily edited for v19/19.1 by ThatWelshOne_
# Some UI components borrowed (with permission) from Marin's Easy Questing Interface
# 
#===============================================================================
# Things you can currently customise without editing the scripts themselves
#===============================================================================

# If true, includes a page of failed quests on the UI
# Set this to false if you don't want to have quests that can be failed
SHOW_FAILED_QUESTS = true

# Name of file in Audio/SE that plays when a quest is activated/advanced to new stage/completed
QUEST_JINGLE = "Mining found all.ogg"

# Name of file in Audio/SE that plays when a quest is failed
QUEST_FAIL = "GUI sel buzzer.ogg"

# Future plans are to add different backgrounds that can be chosen by you

#===============================================================================
# Utility method for setting colors
#===============================================================================

# Useful Hex to 15-bit color converter: http://www.budmelvin.com/dev/15bitconverter.html
# Add in your own colors here!
def colorQuest(color)
  colors = [
    "7E603D25", #blue
    "201F20EE", #red
    "33092967", #green
    "7FA845CA", #cyan
    "797B494E", #magenta
    "2B5F2E34", #yellow
    "5EF72529", #gray
    "7FFF2529", #white
    "7D74412A", #purple
    "01FF1974" #orange
  ]
  color = color.downcase if color
  return colors[0] if color == "blue"
  return colors[1] if color == "red"
  return colors[2] if color == "green"
  return colors[3] if color == "cyan"
  return colors[4] if color == "magenta"
  return colors[5] if color == "yellow"
  return colors[6] if color == "gray"
  return colors[7] if color == "white"
  return colors[8] if color == "purple"
  return colors[9] if color == "orange"
  return colors[rand(0...colors.length)] if color == "random"
  return colors[0] # Returns the default blue color if all other options are exhausted
end
