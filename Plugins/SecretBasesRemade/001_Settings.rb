module SecretBaseSettings
  # Map ID used to load secret bases on
  # It is a dummy map, and can be left completely blank
  SECRET_BASE_MAP = 9
  # Map ID where items events are allocated
  SECRET_BASE_DECOR_MAP = 37
  # Tileset ID used for Secret Bases.
  SECRET_BASE_TILESET = 30
  # Move needed to make Secret Bases.
  SECRET_BASE_MOVE_NEEDED = :SECRETPOWER
  # Maximum number of decorations that can be placed at once.
  SECRET_BASE_MAX_DECORATIONS = 16
  # Allows placing :decor type decorations on the floor (true)
  # or if they can only be placed on SECRET_BASE_DECOR_FLOOR_TAG.
  SECRET_BASE_DECOR_ANYWHERE = false
  # Filename in Characters folder that the graphic of the PC.
  SECRET_BASE_PC_FILENAME = "secret_base_pc"
  # Messages and animation IDs for the secret entrances
  # the type of entrance set for the template in GameData::SecretBaseTemplate is used here
  #  to determine the messages and the animation when opening it.
  # :type => ["On Interact", "On Opening", Animation ID, Appear at Midpoint]
  SECRET_BASE_MESSAGES_ANIM={
                    :cave=>[_INTL("There's a small indent in the wall."),
                            _INTL("Discovered a small cavern!"),
                            8,true],
                    :vines=>[_INTL("If some vines drop down, this tree can be climbed."),
                             _INTL("A thick vine dropped down!"),
                             9,false],
                    :shrub=>[_INTL("If this clump of grass can be moved, it might be possible to go inside."),
                             _INTL("Discovered a small entrance!"),
                             10,true]
                   }
  # Hole Locations in the Secret Base Tileset
  # [tile id, width in tiles, height in tiles]
  # Holes need to be in Layer 2.
  SECRET_BASE_HOLES=[
    [144,1,2],
    [146,2,1],
    [148,2,2],
  ]
  # Terrain tag for ground decorations that already are in    
  # base, for example rocks or bushes in layer 1
  # if your ground decoration is in layer 2 or 3, don't worry
  # about this.
  SECRET_BASE_GROUND_DECOR_TAG = :SecretGroundDecor
  # Terrain tag for walls                                     
  # You can post posters in every tile with this terrain tag
  SECRET_BASE_WALL_TAG = :SecretWall
  # Terrain tag for special items that can be used
  # to place :decor type decorations (if SECRET_BASE_DECOR_ANYWHERE is false)
  SECRET_BASE_DECOR_FLOOR_TAG = :SecretDecorFloor
  
  # The names of each pocket of the Secret Base Bag.
  def self.secret_bag_pocket_names
    return [
      _INTL("Desk"),
      _INTL("Chair"),
      _INTL("Plant"),
      _INTL("Ornament"),
      _INTL("Mat"),
      _INTL("Poster"),
      _INTL("Doll"),
      _INTL("Cushion")
    ]
  end
  # The maximum number of slots per pocket (-1 means infinite number).
  SECRET_BAG_MAX_POCKET_SIZE  = [10, 10, 10, 30, 30, 10, 40, 10]
end

module MessageTypes
  SecretBaseDecorations            = 28
  SecretBaseDecorationDescriptions = 29
end


GameData::TerrainTag.register({
  :id                     => :SecretGroundDecor,
  :id_number              => 40
})

GameData::TerrainTag.register({
  :id                     => :SecretWall,
  :id_number              => 41
})

GameData::TerrainTag.register({
  :id                     => :SecretDecorFloor,
  :id_number              => 42
})