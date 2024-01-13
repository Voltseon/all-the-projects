=begin
################################################################
#
# Base Template
#
################################################################
ListHandlers.add(:collectible, :base_template, {
  # =================================
  :name                   => "Base Template",
  :type                   => :generic, # :generic, :audiopack, :beam, :skin, :loadingscreen, :banner, :emote
  :internal               => :BASETEMPLATE,
  :description            => "A base template for a collectible.",
  :can_use                => false, # Automatically changes for specific types
  :use_proc               => proc { |collectible| next }, # Automatically changes for specific types
  :can_equip              => false, # Automatically changes for specific types
  :consume_on_use         => false, # Automatically changes for specific types
  # =================================
  :audio_pack             => nil, # Internal name of the pack (Audio Pack)
  :beam                   => nil, # Internal name of the Move (Beam)
  :character              => nil, # Internal name of the character (Skin)
  :skin                   => nil, # Folder name for the skin (Skin)
  :emote                  => nil, # Animation ID of the emote (Integer)
  # =================================
  :price                  => 0, # Price in the shop
  # =================================
})
=end

################################################################
#
# Miscellaneous
#
################################################################
ListHandlers.add(:collectible, :lootbox, {
  # =================================
  :name                   => "Lootbox",
  :type                   => :generic,
  :internal               => :lootbox,
  :description            => "A lootbox containing a random collectible.",
  :can_use                => true,
  :use_proc               => proc { |collectible| next }, # TODO: Add lootbox functionality
  :can_equip              => false,
  :consume_on_use         => true,
  # =================================
  :price                  => 500
  # =================================
})

ListHandlers.add(:collectible, :character_ticket, {
  # =================================
  :name                   => "Character Ticket",
  :type                   => :generic,
  :internal               => :character_ticket,
  :description            => "A ticket that allows you to unlock a new character.",
  :can_use                => true,
  :use_proc               => proc { |collectible| next }, # TODO: Add character ticket functionality
  :can_equip              => false,
  :consume_on_use         => true
  # =================================
})

ListHandlers.add(:collectible, :arena_ticket, {
  # =================================
  :name                   => "Arena Ticket",
  :type                   => :generic,
  :internal               => :arena_ticket,
  :description            => "A ticket that allows you to unlock a new arena.",
  :can_use                => true,
  :use_proc               => proc { |collectible| next }, # TODO: Add arena ticket functionality
  :can_equip              => false,
  :consume_on_use         => true
  # =================================
})

################################################################
#
# Audio Packs
#
################################################################
ListHandlers.add(:collectible, :audiopack_PIVOT, {
  # =================================
  :name                   => "Audio Pack - Pivot",
  :type                   => :audiopack,
  :internal               => :audiopack_PIVOT,
  :description            => "A collection of music and sound effects. The default audio pack for the game.",
  # =================================
  :audio_pack             => :PIVOT,
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :audiopack_MELEE, {
  # =================================
  :name                   => "Audio Pack - Melee",
  :type                   => :audiopack,
  :internal               => :audiopack_MELEE,
  :description            => "A collection of music and sound effects. Contains audio from Super Smash Bros. Melee.",
  # =================================
  :audio_pack             => :MELEE,
  # =================================
  :price                  => 1000
  # =================================
})

################################################################
#
# Spawn Beams
#
################################################################
ListHandlers.add(:collectible, :beam_PURPLE, {
  # =================================
  :name                   => "Spawn Beam - Purple",
  :type                   => :beam,
  :internal               => :beam_PURPLE,
  :description            => "A beam of light that appears when the player spawns in.",
  # =================================
  :beam                   => :SPAWNPURPLE,
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :beam_PINK, {
  # =================================
  :name                   => "Spawn Beam - Pink",
  :type                   => :beam,
  :internal               => :beam_PINK,
  :description            => "A beam of light that appears when the player spawns in.",
  # =================================
  :beam                   => :SPAWNPINK,
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :beam_GREEN, {
  # =================================
  :name                   => "Spawn Beam - Green",
  :type                   => :beam,
  :internal               => :beam_GREEN,
  :description            => "A beam of light that appears when the player spawns in.",
  # =================================
  :beam                   => :SPAWNGREEN,
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :beam_BLUE, {
  # =================================
  :name                   => "Spawn Beam - Blue",
  :type                   => :beam,
  :internal               => :beam_BLUE,
  :description            => "A beam of light that appears when the player spawns in.",
  # =================================
  :beam                   => :SPAWNBLUE,
  # =================================
  :price                  => 0
  # =================================
})

################################################################
#
# Player Banner
#
################################################################
ListHandlers.add(:collectible, :banner_DEFAULT, {
  # =================================
  :name                   => "Player Banner - Default",
  :type                   => :banner,
  :internal               => :banner_DEFAULT,
  :description            => "The default banner for the player.",
  # =================================
  :banner                 => "default",
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :banner_TEST, {
  # =================================
  :name                   => "Player Banner - Test",
  :type                   => :banner,
  :internal               => :banner_TEST,
  :description            => "A test banner for the player.",
  # =================================
  :banner                 => "test",
  # =================================
  :price                  => 0
  # =================================
})

################################################################
#
# Loading Screens
#
################################################################
ListHandlers.add(:collectible, :loadingscreen_PIVOT, {
  # =================================
  :name                   => "Loading Screen - Pivot",
  :type                   => :loadingscreen,
  :internal               => :loadingscreen_PIVOT,
  :description            => "The image that appears when the game is loading. The default loading screen for the game."
  # =================================
})

ListHandlers.add(:collectible, :loadingscreen_LIGHTS, {
  # =================================
  :name                   => "Loading Screen - Lights",
  :type                   => :loadingscreen,
  :internal               => :loadingscreen_LIGHTS,
  :description            => "The image that appears when the game is loading. Taken at the Lights arena.",
  # =================================
  :price                  => 600
  # =================================
})

################################################################
#
# Character Skins
#
################################################################

# =================================
# Wobbuffet (Unobtainable)
# =================================
ListHandlers.add(:collectible, :skin_WOBBUFFET_shiny, {
  # =================================
  :name                   => "Character Skin - Wobbuffet (Shiny)",
  :type                   => :skin,
  :internal               => :skin_WOBBUFFET_shiny,
  :description            => "The shiny skin for Wobbuffet.",
  # =================================
  :character              => :WOBBUFFET,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Absol
# =================================
ListHandlers.add(:collectible, :skin_ABSOL_shiny, {
  # =================================
  :name                   => "Character Skin - Absol (Shiny)",
  :type                   => :skin,
  :internal               => :skin_ABSOL_shiny,
  :description            => "The shiny skin for Absol.",
  # =================================
  :character              => :ABSOL,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Zubat
# =================================
ListHandlers.add(:collectible, :skin_ZUBAT_shiny, {
  # =================================
  :name                   => "Character Skin - Zubat (Shiny)",
  :type                   => :skin,
  :internal               => :skin_ZUBAT_shiny,
  :description            => "The shiny skin for Zubat.",
  # =================================
  :character              => :ZUBAT,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Golbat
# =================================
ListHandlers.add(:collectible, :skin_GOLBAT_shiny, {
  # =================================
  :name                   => "Character Skin - Golbat (Shiny)",
  :type                   => :skin,
  :internal               => :skin_GOLBAT_shiny,
  :description            => "The shiny skin for Golbat.",
  # =================================
  :character              => :GOLBAT,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Crobat
# =================================
ListHandlers.add(:collectible, :skin_CROBAT_shiny, {
  # =================================
  :name                   => "Character Skin - Crobat (Shiny)",
  :type                   => :skin,
  :internal               => :skin_CROBAT_shiny,
  :description            => "The shiny skin for Crobat.",
  # =================================
  :character              => :CROBAT,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Ditto
# =================================
ListHandlers.add(:collectible, :skin_DITTO_shiny, {
  # =================================
  :name                   => "Character Skin - Ditto (Shiny)",
  :type                   => :skin,
  :internal               => :skin_DITTO_shiny,
  :description            => "The shiny skin for Ditto.",
  # =================================
  :character              => :DITTO,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Farfetch'd
# =================================
ListHandlers.add(:collectible, :skin_FARFETCHD_shiny, {
  # =================================
  :name                   => "Character Skin - Farfetch'd (Shiny)",
  :type                   => :skin,
  :internal               => :skin_FARFETCHD_shiny,
  :description            => "The shiny skin for Farfetch'd.",
  # =================================
  :character              => :FARFETCHD,
  :skin                   => "shiny"
  # =================================
})

# =================================
# Spiritomb
# =================================
ListHandlers.add(:collectible, :skin_SPIRITOMB_shiny, {
  # =================================
  :name                   => "Character Skin - Spiritomb (Shiny)",
  :type                   => :skin,
  :internal               => :skin_SPIRITOMB_shiny,
  :description            => "The shiny skin for Spiritomb.",
  # =================================
  :character              => :SPIRITOMB,
  :skin                   => "shiny"
  # =================================
})

################################################################
#
# Emotes
#
################################################################
ListHandlers.add(:collectible, :emote_NONE, {
  # =================================
  :name                   => "Emote - None",
  :type                   => :emote,
  :internal               => :emote_NONE,
  :description            => "",
  # =================================
  :emote                  => -1,
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :emote_HEART, {
  # =================================
  :name                   => "Emote - Heart",
  :type                   => :emote,
  :internal               => :emote_HEART,
  :description            => "An emote that displays a heart.",
  # =================================
  :emote                  => 9,
  # =================================
  :price                  => 0
  # =================================
})

ListHandlers.add(:collectible, :emote_EXCLAIM, {
  # =================================
  :name                   => "Emote - Exclaim",
  :type                   => :emote,
  :internal               => :emote_EXCLAIM,
  :description            => "An emote that displays an exclamation mark.",
  # =================================
  :emote                  => 19,
  # =================================
  :price                  => 0
  # =================================
})