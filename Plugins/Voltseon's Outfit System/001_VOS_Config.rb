# TODO:
# Make some placeholder art
# Make src work with different sized images
# Fix clothes not going dark when the screen goes dark
# Add templates for items changing clothes and a sort of closet
# Make clothes overlay on other sprites as well (trainer card, battle, vs, map icon)
# Make sure reflections work
# Followers look weird with the z value? Decimal values for z?

#########################################################
#                                                       #
#            Voltseon's Outfit System (VOS)             #
#                    Version 1.0                        #
#                                                       #
#########################################################
#                                                       #
#     This is a script made to make more dynamic and    #
#         Configurable character customization          #
#  Useful for those willing to put in the time to make  #
#                All the seperate assets!               #
#                                                       #
#########################################################
#                                                       #
#                       Config                          #
#                                                       #
#########################################################
#                                                       #
#          You may configure your settings here         #
#                                                       #
#########################################################

# Use this command to change the player's outfit
# Please check VOS_LAYER_ORDER for 'cloth'
# Ex. vChangeOutfit("hat","bluecap_1",44)
def vChangeOutfit(cloth,id,hue=0)
  $player&.vos_outfit&.set(cloth,Vosclothing.new(id,id,hue))
  $scene.spritesetGlobal.playersprite.refresh_clothes if $scene.is_a?(Scene_Map)
end

# The order in which the outfits will appear on top of each other (highest to lowest)
VOS_LAYER_ORDER = [
  "extra",
  "hat",
  "accessory",
  "hair",
  "shoes",
  "shirt",
  "pants",
  "undershirt"
]

# Pokémon Essentials comes built in with 'outfits'. This switch is used to check for these outfits as well
# To use this name your outfits: OUTFITNAME_4.png (outfit number 4)
VOS_SEPERATE_BY_BUILTIN_OUTFITS = false

# Whether to show different spritesets depending on the player's gender (0 = male, 1 = female)
# To use this name your outfits: OUTFITNAME_1.png (female)
VOS_SEPERATE_BY_GENDER = false

# Whether to show different spritesets depending on the player's current state (walk, run, surf, etc)
# To use this name your outfits: OUTFITNAME_surf.png (surfing) (these suffixes are configured below)
VOS_SEPERATE_BY_STATES = true

# IMPORTANT NOTE:
# If you are using multiple of the above options
# Make sure you order them correctly
# The order goes as follows:
# Outfit, Gender, State
# So if you have all of these options enabled it should look like this:
# OUTFITNAME_4_1_surf.png (outfit number 4, female, surfing)

# If there is no diving spriteset use the surf spriteset instead if true
VOS_USE_SURF_IF_NO_DIVE = true

# The names used to suffix the different states
VOS_STATE_SUFFIXES = [
  "run",
  "surf",
  "bike",
  "dive",
  "fish"
]