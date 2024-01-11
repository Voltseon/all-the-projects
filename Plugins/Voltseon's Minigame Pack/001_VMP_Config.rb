#-------------------------------------------------------------------------------
# Voltseon's Minigame Pack v1.0
# A collection of cool custom minigames
#-------------------------------------------------------------------------------
#
# Special thanks to:
#
# 
#-------------------------------------------------------------------------------
#
# Config file: configure personal settings.
#
#-------------------------------------------------------------------------------

# General Settings
TEXTBASECOLOR    = Color.new(248,248,248)
TEXTSHADOWCOLOR  = Color.new(81,34,6)
DIRECTORY = "Graphics/Pictures/Voltseon's Minigame Pack"

# Hit Diglett Hit Settings
HDHMONEYREWARD = false # Whether you should get money for Hit Diglett Hit, true = get money, false = get coins

#-------------------------------------------------------------------------------
# Call minigame functions
#-------------------------------------------------------------------------------

# Calls Hit Diglett Hit
def vHitDiglettHit
  scene = HitDiglettHit_Scene.new
  screen = HitDiglettHit_Screen.new(scene)
  screen.pbStartScreen
end