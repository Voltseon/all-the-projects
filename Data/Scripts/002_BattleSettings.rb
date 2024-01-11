module Settings
  # Whether any Pokémon (originally owned by the player or foreign) can disobey
  # the player's commands if the Pokémon is too high a level compared to the
  # number of Gym Badges the player has.
  ANY_HIGH_LEVEL_POKEMON_CAN_DISOBEY          = false
  # Whether foreign Pokémon can disobey the player's commands if the Pokémon is
  # too high a level compared to the number of Gym Badges the player has.
  FOREIGN_HIGH_LEVEL_POKEMON_CAN_DISOBEY      = true

  #=============================================================================

  # Whether Pokémon with high happiness will gain more Exp from battles, have a
  # chance of avoiding/curing negative effects by themselves, resisting
  # fainting, etc.
  AFFECTION_EFFECTS        = false
  # Whether a Pokémon's happiness is limited to 179, and can only be increased
  # further with friendship-raising berries. Related to AFFECTION_EFFECTS by
  # default because affection effects only start applying above a happiness of
  # 179. Also lowers the happiness evolution threshold to 160.
  APPLY_HAPPINESS_SOFT_CAP = AFFECTION_EFFECTS

  #=============================================================================

  # The minimum number of badges required to boost each stat of a player's
  # Pokémon by 1.1x, in battle only.
  NUM_BADGES_BOOST_ATTACK  = 999
  NUM_BADGES_BOOST_DEFENSE = 999
  NUM_BADGES_BOOST_SPATK   = 999
  NUM_BADGES_BOOST_SPDEF   = 999
  NUM_BADGES_BOOST_SPEED   = 999

  #=============================================================================

  # The Game Switch which, while ON, prevents all Pokémon in battle from Mega
  # Evolving even if they otherwise could.
  NO_MEGA_EVOLUTION = 34

  #=============================================================================

  # The Game Switch which, whie ON, prevents the player from losing money if
  # they lose a battle (they can still gain money from trainers for winning).
  NO_MONEY_LOSS                       = 33
  # Whether fainted Pokémon can try to evolve after a battle.
  CHECK_EVOLUTION_FOR_FAINTED_POKEMON = true

  #=============================================================================

  # Whether wild Pokémon with the "Legendary", "Mythical" or "UltraBeast" flag
  # (as defined in pokemon.txt) have a smarter AI. Their skill level is set to
  # 32, which is a medium skill level.
  SMARTER_WILD_LEGENDARY_POKEMON = true
end
