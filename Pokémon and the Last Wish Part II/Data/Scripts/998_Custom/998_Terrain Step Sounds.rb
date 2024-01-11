#===============================================================================
# PE Terrain Step Sounds
# Version 1
# by Enurta
#-------------------------------------------------------------------------------
PluginManager.register({
  :name => "Terain Sounds",
  :version => "1.0",
  :credits => ["Enurta","gameguy"],
})
# Create nice aesthetics with terrain noise. As you walk across grass or sand,
# let it play a beautiful noise to add to the atmosphere and realism of the
# game.
#
# Features:
# Specific Sound for Each Terrain and Tileset
# Specify Volume and Pitch
#
# Instructions:
# Setup the config below, its pretty self explanatory, more instructions
# with config.
#===============================================================================   
module PETS
  SkipsSFX = false
  Tag = []
  Tileset  = []
  #===============================================================================
  # Enter in sounds for each terrain tag
  # Goes from 0-15 for Pokemon Essentials. Terrain Tag 1 won't be used as it is already coded within essentials.
  # Each terrain type is in the array below.
  #
  # You can specify the sound file, the volume, and pitch of the file.
  # Tag[2] = [["Filename",volume,pitch]
  # Filename - Replace with the name of the file that you want to use
  # Volume - 0-100; higher is louder
  # Pitch - 50-150; lower is deeper
  # If volume and pitch are not specified they will default to 100 for both.
  #======================================================================================
  Tag[0] = ["se_step_default"] # Nothing
  Tag[1] = [] # Ledge
  Tag[2] = ["se_step_grass"] # Grass
  Tag[3] = ['se_step_run_dirt'] # Sand
  Tag[4] = [] # Rock
  Tag[5] = [] # Deep Water
  Tag[6] = [] # Still Water
  Tag[7] = ["Water1"] # Water
  Tag[8] = [] # Waterfall
  Tag[9] = [] # Waterrfal Crest
  Tag[10] = [] # Tall Grass
  Tag[11] = [] # Underwater Grass
  Tag[12] = [] # Ice
  Tag[13] = [] # Neutral
  Tag[14] = [] # Sootgrass
  Tag[15] = [] # Bridge
  Tag[16] = [] # Puddle
  Tag[17] = [] # Stair Left
  Tag[18] = [] # Stair Right
  Tag[19] = [] # Whirlpool
  Tag[20] = [] # BounceLedge
  Tag[21] = [] # Extreme Speed Corner
  Tag[22] = [] # Extreme Speed Corner
  Tag[23] = [] # Extreme Speed Corner
  Tag[24] = [] # Extreme Speed Corner
  Tag[25] = ["se_step_deep"] # Deep Sand
  # With tilesets, you can set specific sounds for each tileset so you don't
  # have the same sounds. Add a new line and put
  # Tilesets[tileset id] = []
  # Then for each terrain put
  # Tilesets[tileset id][terrain id] = "sound file"
  # If a sound doesn't exist for a tileset, it will play a default sound,
  # if a default doesn't exist, no sound at all.
end
#========================================================================================
# Game Map
#========================================================================================
class Game_Map
  attr_accessor :map
end

#=================================================================================
# Event that triggers the sound
#=================================================================================
Events.onStepTakenFieldMovement += proc { |_sender,e|
  event = e[0] # Get the event affected by field movement
  if $scene.is_a?(Scene_Map) && event==$game_player && !$PokemonGlobal.bicycle
    step_sound = PETS::Tag[GameData::TerrainTag.get(event.pbTerrainTag).id_number]
    if PETS::Tileset[$game_map.map.tileset_id] != nil # Prevents crashing
    unless PETS::Tileset[$game_map.map.tileset_id][GameData::TerrainTag.get(event.pbTerrainTag).id_number] == nil
      step_sound = PETS::Tileset[$game_map.map.tileset_id][GameData::TerrainTag.get(event.pbTerrainTag).id_number]
      end
    end
    sound = step_sound[0]
    volume = 80
    pitch = rand(90..100)
    if event.move_speed == 7 && step_sound != PETS::Tag[2]
      PETS::SkipsSFX = !PETS::SkipsSFX
    else
      PETS::SkipsSFX = false
    end
    pbSEPlay(sound,volume,pitch) if !PETS::SkipsSFX
  end
}