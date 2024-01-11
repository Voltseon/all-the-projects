Battle::AI::Handlers::AbilityRanking.add(:ARMORTAIL,
  proc { |ability, score, battler, ai|
    next 5
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ROCKYPAYLOAD,
  proc { |ability, score, battler, ai|
    next 5 if battler.has_damaging_move_of_type?(:ROCK)
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SHARPNESS,
  proc { |ability, score, battler, ai|
    next 5 if battler.check_for_move { |m| m.slicingMove? }
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SUPREMEOVERLORD,
  proc { |ability, score, battler, ai|
    next battler.effects[PBEffects::SupremeOverlord]
  }
)

Battle::AI::Handlers::AbilityRanking.add(:PURIFYINGSALT,
  proc { |ability, score, battler, ai|
    next 4
  }
)

Battle::AI::Handlers::AbilityRanking.add(:EARTHEATER,
  proc { |ability, score, battler, ai|
    next 7
  }
)

Battle::AI::Handlers::AbilityRanking.add(:WELLBAKEDBODY,
  proc { |ability, score, battler, ai|
    next 4
  }
)

Battle::AI::Handlers::AbilityRanking.add(:WINDRIDER,
  proc { |ability, score, battler, ai|
    next 3
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ANGERSHELL,
  proc { |ability, score, battler, ai|
    next 4 if battler.hp > battler.totalhp/2
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:ELECTROMORPHOSIS,
  proc { |ability, score, battler, ai|
    next 4
  }
)

Battle::AI::Handlers::AbilityRanking.add(:LINGERINGAROMA,
  proc { |ability, score, battler, ai|
    next 5
  }
)

Battle::AI::Handlers::AbilityRanking.add(:SEEDSOWER,
  proc { |ability, score, battler, ai|
    next 6
  }
)

Battle::AI::Handlers::AbilityRanking.add(:THERMALEXCHANGE,
  proc { |ability, score, battler, ai|
    next 8
  }
)

Battle::AI::Handlers::AbilityRanking.add(:TOXICDEBRIS,
  proc { |ability, score, battler, ai|
    next 7
  }
)

Battle::AI::Handlers::AbilityRanking.copy(:ELECTROMORPHOSIS,:WINDPOWER)

Battle::AI::Handlers::AbilityRanking.add(:CUDCHEW,
  proc { |ability, score, battler, ai|
    next 5 if battler.item && battler.item.is_berry?
    next 0
  }
)

Battle::AI::Handlers::AbilityRanking.add(:OPPORTUNIST,
  proc { |ability, score, battler, ai|
    next 6
  }
)

Battle::AI::Handlers::AbilityRanking.add(:TABLETSOFRUIN,
  proc { |ability, score, battler, ai|
    next 3
  }
)

Battle::AI::Handlers::AbilityRanking.copy(:TABLETSOFRUIN, :SWORDOFRUIN, :VESSELOFRUIN, :BEADSOFRUIN)


Battle::AI::Handlers::AbilityRanking.add(:ORICHALCUMPULSE,
  proc { |ability, score, battler, ai|
    next 9 if battler.check_for_move { |m| m.physicalMove? && [:Sun, :HarshSun].include?(battler.battler.effectiveWeather) }
    next 8
  }
)

Battle::AI::Handlers::AbilityRanking.add(:HADRONENGINE,
  proc { |ability, score, battler, ai|
    next 9 if battler.check_for_move { |m| m.specialMove? && battler.battler.battle.field.terrain == :Electric }
    next 8
  }
)

Battle::AI::Handlers::AbilityRanking.add(:PROTOSYNTHESIS,
  proc { |ability, score, battler, ai|
    next 7
  }
)

Battle::AI::Handlers::AbilityRanking.copy(:PROTOSYNTHESIS,:QUARKDRIVE)

Battle::AI::Handlers::AbilityRanking.add(:PROTOSYNTHESIS,
  proc { |ability, score, battler, ai|
    next 7
  }
)

#===============================================================================
#
#===============================================================================

Battle::AI::Handlers::ItemRanking.add(:ADAMANTCRYSTAL,
  proc { |item, score, battler, ai|
    next 6 if battler.battler.isSpecies?(:DIALGA) &&
              battler.has_damaging_move_of_type?(:DRAGON, :STEEL)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:LUSTROUSGLOBE,
  proc { |item, score, battler, ai|
  next 6 if battler.battler.isSpecies?(:PALKIA) &&
            battler.has_damaging_move_of_type?(:DRAGON, :WATER)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:GRISEOUSCORE,
  proc { |item, score, battler, ai|
    next 6 if battler.battler.isSpecies?(:GIRATINA) &&
              battler.has_damaging_move_of_type?(:DRAGON, :GHOST)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:LEGENDPLATE,
  proc { |item, score, battler, ai|
    next 6 if battler.battler.isSpecies?(:ARCEUS) &&
              battler.target.has_move_with_function?("TypeDependsOnUserPlate")
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:BOOSTERENERGY,
  proc { |item, score, battler, ai|
    next 6 if [:PROTOSYNTHESIS, :QUARKDRIVE].include?(battler.ability_id)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:BLANKPLATE,
  proc { |item, score, battler, ai|
    next 5 if battler.has_damaging_move_of_type?(:NORMAL)
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:HOPOBERRY,
  proc { |item, score, battler, ai|
    next 3
  }
)

Battle::AI::Handlers::ItemRanking.add(:PUNCHINGGLOVE,
  proc { |item, score, battler, ai|
    next 5 if battler.check_for_move { |m| m.punchingMove? }
    next 0
  }
)

Battle::AI::Handlers::ItemRanking.add(:CLEARAMULET,
  proc { |item, score, battler, ai|
    next 2
  }
)

Battle::AI::Handlers::ItemRanking.add(:MIRRORHERB,
  proc { |item, score, battler, ai|
    next 3
  }
)

Battle::AI::Handlers::ItemRanking.add(:LOADEDDICE,
  proc { |item, score, battler, ai|
    score = 6
    if ai.trainer.high_skill?
      score += 1 if battler.check_for_move { |m| m.multiHitMove? }
    end
    next score
  }
)

Battle::AI::Handlers::ItemRanking.add(:COVERTCLOAK,
  proc { |item, score, battler, ai|
    next 3
  }
)