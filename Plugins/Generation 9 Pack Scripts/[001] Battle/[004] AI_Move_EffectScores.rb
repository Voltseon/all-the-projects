################################################################################
# 
# Battle::AI - Move Effect Scores.
# 
################################################################################


class Battle::AI
  #-----------------------------------------------------------------------------
  # -Aliased to add move scores for Gen 9 function codes.
  # -Edits several old function codes to consider Gen 9 mechanics.
  #-----------------------------------------------------------------------------
  alias paldea_pbGetMoveScoreFunctionCode pbGetMoveScoreFunctionCode
  def pbGetMoveScoreFunctionCode(score, move, user, target, skill = 100)
    case move.function
    ############################################################################
    #
    # Old function codes.
    #
    ############################################################################
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetAsleepCureTarget"          # Wake-Up Slap   
    #---------------------------------------------------------------------------
	  score -= 20 if [:SLEEP, :DROWSY].include?(target.status) && target.statusCount > 1
    #---------------------------------------------------------------------------
    when "HealUserFullyAndFallAsleep"                   # Rest     
    #---------------------------------------------------------------------------
      if user.hp == user.totalhp || user.hasActiveAbility?(:PURIFYINGSALT) ||
	     !user.pbCanSleep?(user, false, nil, true)
        score -= 90
      else
        score += 70
        score -= user.hp * 140 / user.totalhp
        score += 30 if user.status != :NONE
      end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetStatusMove"                    # Roar, Whirlwind    
    #---------------------------------------------------------------------------
      if target.effects[PBEffects::Ingrain] ||
         (skill >= PBTrainerAI.highSkill && 
        target.hasActiveAbility?([:SUCTIONCUPS, :GUARDDOG]))
        score -= 90
      else
        ch = 0
        @battle.pbParty(target.index).each_with_index do |pkmn, i|
          ch += 1 if @battle.pbCanSwitchLax?(target.index, i)
        end
        score -= 90 if ch == 0
      end
      if score > 20
        score += 50 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
        score += 50 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score += 50 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end
    #---------------------------------------------------------------------------
    when "SwitchOutTargetDamagingMove"                  # Circle Throw, Dragon Tail   
    #---------------------------------------------------------------------------
      if !target.effects[PBEffects::Ingrain] &&
         !(skill >= PBTrainerAI.highSkill && target.hasActiveAbility?([:SUCTIONCUPS, :GUARDDOG]))
        score += 40 if target.pbOwnSide.effects[PBEffects::Spikes] > 0
        score += 40 if target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score += 40 if target.pbOwnSide.effects[PBEffects::StealthRock]
      end  
    #---------------------------------------------------------------------------
    when "UserSwapsPositionsWithAlly"                   # Ally Switch
    #---------------------------------------------------------------------------
      if skill >= PBTrainerAI.mediumSkill && user.effects[PBEffects::AllySwitch] == true
        score -= 100
      end  
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToSimple",                    # Simple Beam
         "SetTargetAbilityToInsomnia"                   # Worry Seed 
    #---------------------------------------------------------------------------
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        if target.unstoppableAbility? || 
		   target.hasActiveItem?(:ABILITYSHIELD) || 
		   [:TRUANT, :SLOWSTART, :SIMPLE].include?(target.ability) 
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetUserAbilityToTargetAbility"                # Role Play     
    #---------------------------------------------------------------------------
      score -= 40
      if skill >= PBTrainerAI.mediumSkill
        if !target.ability || user.ability == target.ability ||
		   user.unstoppableAbility? || target.uncopyableAbility? ||
           user.hasActiveItem?(:ABILITYSHIELD)
          score -= 90
        end
      end
      if skill >= PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "SetTargetAbilityToUserAbility"                # Entrainment 
    #---------------------------------------------------------------------------
      score -= 40
      if target.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif skill >= PBTrainerAI.mediumSkill
        if !user.ability || user.ability == target.ability ||
		   target.unstoppableAbility? || [:TRUANT, :SLOWSTART].include?(target.ability) || 
		   user.uncopyableAbility? || target.hasActiveItem?(:ABILITYSHIELD)
          score -= 90
        end
        if skill >= PBTrainerAI.highSkill
          if user.ability == :TRUANT && user.opposes?(target)
            score += 90
          elsif user.ability == :SLOWSTART && user.opposes?(target)
            score += 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "UserTargetSwapAbilities"                      # Skill Swap
    #---------------------------------------------------------------------------
      score -= 40
      if skill >= PBTrainerAI.mediumSkill
        if (!user.ability && !target.ability) || user.ability == target.ability ||
          user.uncopyableAbility? || target.uncopyableAbility? ||
          user.hasActiveItem?(:ABILITYSHIELD) || user.hasActiveItem?(:ABILITYSHIELD)
          score -= 90
        end
      end
      if skill >= PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "NegateTargetAbility"                          # Gastro Acid
    #---------------------------------------------------------------------------
      if target.effects[PBEffects::Substitute] > 0 ||
        target.effects[PBEffects::GastroAcid]
        score -= 90
      elsif skill >= PBTrainerAI.highSkill
        score -= 90 if target.unstoppableAbility? || target.hasActiveItem?(:ABILITYSHIELD)
      end
    #---------------------------------------------------------------------------
    when "OHKO", "OHKOIce", "OHKOHitsUndergroundTarget" # OHKO moves
    #---------------------------------------------------------------------------
      score -= 90 if target.hasActiveAbility?(:STURDY)
      score -= 90 if target.level > user.level
      score += 90 if target.effects[PBEffects::GlaiveRush] > 0
	#---------------------------------------------------------------------------
	when "TypeDependsOnUserPlate"                       # Judgment    
	#---------------------------------------------------------------------------
	  score += 20 if user.hasLegendPlateJudgment?
    ############################################################################
    #
    # New function codes.
    #
    ############################################################################
    #---------------------------------------------------------------------------
    when "DrowseTarget"                                 # Drowsy moves        
    #---------------------------------------------------------------------------
      if target.pbCanSleep?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "FrostbiteTarget"                              # Frostbite moves     
    #---------------------------------------------------------------------------
      if target.pbCanFrostbite?(user, false)
        score += 30
        if skill >= PBTrainerAI.highSkill
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET])
        end
      elsif skill >= PBTrainerAI.mediumSkill
        score -= 90 if move.statusMove?
      end
    #---------------------------------------------------------------------------
    when "PoisonParalyzeOrSleepTarget"                  # Dire Claw
    #---------------------------------------------------------------------------
      score -= 20 if target.pbHasAnyStatus?
      score -= 30 if target.effects[PBEffects::Yawn] > 0 && skill >= PBTrainerAI.mediumSkill
      if skill >= PBTrainerAI.bestSkill && 
         target.pbHasMoveFunction?("FlinchTargetFailsIfUserNotAsleep", "UseRandomUserMoveIfAsleep")
        score -= 30
      end
      if skill >= PBTrainerAI.highSkill
        score -= 30 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :QUICKFEET, :TOXICBOOST])
      end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetPoisonedPoisonTarget"      # Barb Barrage
    #---------------------------------------------------------------------------
      if target.status == :POISON
        score += 40
      elsif target.pbCanPoison?(user, false)
        score += 30
      end
    #---------------------------------------------------------------------------
    when "DoublePowerIfTargetStatusProblemBurnTarget"   # Infernal Parade
    #---------------------------------------------------------------------------
      if !target.pbHasAnyStatus?
        score += 40
      elsif target.pbCanBurn?(user, false)
        score += 30
      end
    #---------------------------------------------------------------------------
    when "DamageTargetAddSpikesToFoeSide"               # Ceaseless Edge (Gen 9)
    #---------------------------------------------------------------------------
      if user.pbOpposingSide.effects[PBEffects::Spikes] >= 3
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90
      else
        score += 10 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
        score += [40, 26, 13][user.pbOpposingSide.effects[PBEffects::Spikes]]
      end
    #---------------------------------------------------------------------------
    when "DamageTargetAddStealthRocksToFoeSide"         # Stone Axe (Gen 9)
    #---------------------------------------------------------------------------
      if user.pbOpposingSide.effects[PBEffects::StealthRock]
        score -= 90
      elsif user.allOpposing.none? { |b| @battle.pbCanChooseNonActive?(b.index) }
        score -= 90
      else
        score += 10 * @battle.pbAbleNonActiveCount(user.idxOpposingSide)
      end
    #---------------------------------------------------------------------------
    when "StartSplintersTarget"                         # Ceaseless Edge, Stone Axe (PLA)
    #---------------------------------------------------------------------------
      if move.statusMove?
        if target.effects[PBEffects::Splinters] > 0 ||
           target.effects[PBEffects::Substitute] > 0
          score -= 90
        else
          score += 40 if user.turnCount == 0
        end
      else
        score += 10 if user.turnCount == 0
        score += 20 if target.effects[PBEffects::Splinters]  == 0 &&
                       target.effects[PBEffects::Substitute] == 0
      end
    #---------------------------------------------------------------------------
    when "LowerTargetDefense1FlinchTarget"              # Triple Arrows
    #---------------------------------------------------------------------------
      score += 20 if target.stages[:DEFENSE] > 0
    #---------------------------------------------------------------------------
    when "RaiseUserAtkDefSpd1"                          # Victory Dance
    #---------------------------------------------------------------------------
      if user.statStageAtMax?(:SPEED) &&
         user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:DEFENSE)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:DEFENSE] * 10
        score -= user.stages[:SPEED] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          if aspeed < ospeed && aspeed * 2 > ospeed
            score += 20
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RaiseUserSpAtkSpDef1CureStatus"               # Take Heart
    #---------------------------------------------------------------------------
      score += 40 if user.pbHasAnyStatus?
      if user.statStageAtMax?(:SPECIAL_ATTACK) &&
         user.statStageAtMax?(:SPECIAL_DEFENSE)
        score -= 90
      else
        score += 40 if user.turnCount == 0
        score -= user.stages[:SPECIAL_ATTACK] * 10
        score -= user.stages[:SPECIAL_DEFENSE] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasSpecicalAttack = false
          user.eachMove do |m|
            next if !m.specialMove?(m.type)
            hasSpecicalAttack = true
            break
          end
          if hasSpecicalAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
      end
    #---------------------------------------------------------------------------
    when "RecoilHalfOfTotalHP"                          # Chloroblast
    #---------------------------------------------------------------------------
      score -= 50      
    #---------------------------------------------------------------------------
    when "TypeIsUserSecondTypeRemoveScreens"            # Raging Bull
    #---------------------------------------------------------------------------
      score += 20 if user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
      score += 20 if user.pbOpposingSide.effects[PBEffects::Reflect] > 0
      score += 20 if user.pbOpposingSide.effects[PBEffects::LightScreen] > 0
    #---------------------------------------------------------------------------
    when "IncreasePowerEachFaintedAlly"                 # Last Respects
    #---------------------------------------------------------------------------
      score += [@battle.pbFaintedAllyCount(user), 10].min * 10
    #---------------------------------------------------------------------------
    when "IncreasePowerEachTimeHit"                     # Rage Fist
    #---------------------------------------------------------------------------
      score += [@battle.pbRageHitCount(user), 10].min * 10
    #---------------------------------------------------------------------------
    when "IncreasePowerSuperEffective"                  # Collision Course, Electro Drift
    #---------------------------------------------------------------------------
      if Effectiveness.super_effective?(pbCalcTypeMod(move.type, user, target))
        score += 60 if skill >= PBTrainerAI.mediumSkill
      end
    #---------------------------------------------------------------------------
    when "IncreasePowerInSunWeather"                    # Hydro Steam
    #---------------------------------------------------------------------------
      score += 20 if [:Sun, :HarshSun].include?(user.effectiveWeather)
    #---------------------------------------------------------------------------
    when "IncreasePowerWhileElectricTerrain"            # Psyblade
    #---------------------------------------------------------------------------
      score += 20 if @battle.field.terrain == :Electric
    #---------------------------------------------------------------------------
    when "HitThreeTimes"                                # Triple Dive
    #---------------------------------------------------------------------------
    # N/A
    #---------------------------------------------------------------------------
    when "HitTenTimes"                                  # Population Bomb
    #---------------------------------------------------------------------------
      score += 20 if user.hasActiveItem?(:LOADEDDICE)
    #---------------------------------------------------------------------------
    when "CrashDamageIfFailsConfuseTarget"              # Axe Kick
    #---------------------------------------------------------------------------
      score += 10 * (user.stages[:ACCURACY] - target.stages[:EVASION])
    #---------------------------------------------------------------------------
    when "UserVulnerableUntilNextAction"                # Glaive Rush
    #---------------------------------------------------------------------------
      score -= 40
    #---------------------------------------------------------------------------
    when "CantSelectConsecutiveTurns"                   # Gigaton Hammer
    #---------------------------------------------------------------------------
      if user.hasActiveItem?([:CHOICEBAND, :CHOICESPECS, :CHOICESCARF]) ||
         user.hasActiveAbility?(:GORILLATACTICS) || user.effects[PBEffects::Encore] > 0
        score -= 90 
      end
    #---------------------------------------------------------------------------
    when "AddMoneyGainedFromBattleLowerUserSpAtk1"      # Make it Rain
    #---------------------------------------------------------------------------
      score += user.stages[:SPECIAL_ATTACK] * 10
    #---------------------------------------------------------------------------
    when "UserLosesElectricType"                        # Double Shock
    #---------------------------------------------------------------------------
      score -= 90 if !user.pbHasType?(:ELECTRIC)
    #---------------------------------------------------------------------------
    when "StartSaltCureTarget"                          # Salt Cure
    #---------------------------------------------------------------------------
      if target.effects[PBEffects::SaltCure]
        score -= 40
      else
        score += 60 if user.turnCount == 0
        if skill >= PBTrainerAI.mediumSkill
          score += 80 if target.pbHasType?(:WATER) || target.pbHasType?(:STEEL)
        end
      end
    #---------------------------------------------------------------------------
    when "ProtectUserFromDamagingMovesSilkTrap"         # Silk Trap
    #---------------------------------------------------------------------------
      if user.effects[PBEffects::ProtectRate] > 1 ||
         target.effects[PBEffects::HyperBeam] > 0
        score -= 90
      else
        if skill >= PBTrainerAI.mediumSkill
          score -= user.effects[PBEffects::ProtectRate] * 40
        end
        score += 50 if user.turnCount == 0
        score += 30 if target.effects[PBEffects::TwoTurnAttack]
      end
    #---------------------------------------------------------------------------
    when "RaiseUserStat1Commander"                      # Order Up
    #---------------------------------------------------------------------------
      if user.isCommanderHost?
        form = user.effects[PBEffects::Commander][1]
        stat = [:ATTACK, :DEFENSE, :SPEED][form]
        score += 20 if user.stages[stat] < 2
      else
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "RaiseTargetAtkLowerTargetDef2"                # Spicy Extract
    #---------------------------------------------------------------------------
      if target.pbCanLowerStatStage?(:DEFENSE, user)
        score -= target.stages[:ATTACK] * 20
        score += target.stages[:DEFENSE] * 20
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          target.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score -= 20
          elsif skill >= PBTrainerAI.highSkill
            score += 60
          end
        end
      else
        score -= 60
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtk2SpAtk2Speed2LoseHalfOfTotalHP"   # Fillet Away
    #---------------------------------------------------------------------------
      if (user.statStageAtMax?(:ATTACK) && 
          user.statStageAtMax?(:SPECIAL_ATTACK) && 
          user.statStageAtMax?(:SPEED)) || user.hp <= user.totalhp / 2
        score -= 100
      else
        score += (6 - user.stages[:ATTACK]) * 3
        score += (6 - user.stages[:SPECIAL_ATTACK]) * 3
        score += (6 - user.stages[:SPEED]) * 3
      end
    #---------------------------------------------------------------------------
    when "RaiseUserAtkSpd1RemoveHazardsSubstitutes"     # Tidy Up
    #---------------------------------------------------------------------------
      if @battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
        score += 30 if user.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
                       user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
                       user.pbOwnSide.effects[PBEffects::StealthRock] ||
                       user.pbOwnSide.effects[PBEffects::StickyWeb]
      end
      user.allAllies.each { |b| score -= 20 if b.effects[PBEffects::Substitute] > 0 }
      if @battle.pbAbleNonActiveCount(target.idxOwnSide) > 0
        score -= 30 if target.pbOwnSide.effects[PBEffects::Spikes] > 0 ||
                       target.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0 ||
                       target.pbOwnSide.effects[PBEffects::StealthRock] ||
                       target.pbOwnSide.effects[PBEffects::StickyWeb]
      end
      user.allOpposing.each { |b| score += 20 if b.effects[PBEffects::Substitute] > 0 }
      score += 40 if user.turnCount == 0
      if user.statStageAtMax?(:ATTACK) &&
         user.statStageAtMax?(:SPEED)
        score -= 90
      else
        score -= user.stages[:ATTACK] * 10
        score -= user.stages[:SPEED] * 10
        if skill >= PBTrainerAI.mediumSkill
          hasPhysicalAttack = false
          user.eachMove do |m|
            next if !m.physicalMove?(m.type)
            hasPhysicalAttack = true
            break
          end
          if hasPhysicalAttack
            score += 20
          elsif skill >= PBTrainerAI.highSkill
            score -= 90
          end
        end
        if skill >= PBTrainerAI.highSkill
          aspeed = pbRoughStat(user, :SPEED, skill)
          ospeed = pbRoughStat(target, :SPEED, skill)
          score += 20 if aspeed < ospeed && aspeed * 2 > ospeed
        end
      end
    #---------------------------------------------------------------------------
    when "RemoveUserBindingAndEntryHazardsPoisonTarget" # Mortal Spin
    #---------------------------------------------------------------------------
      score += 30 if user.effects[PBEffects::Trapping] > 0
      score += 30 if user.effects[PBEffects::LeechSeed] >= 0
      if @battle.pbAbleNonActiveCount(user.idxOwnSide) > 0
        score += 80 if user.pbOwnSide.effects[PBEffects::Spikes] > 0
        score += 80 if user.pbOwnSide.effects[PBEffects::ToxicSpikes] > 0
        score += 80 if user.pbOwnSide.effects[PBEffects::StealthRock]
      end
      if target.pbCanPoison?(user, false)
        score += 30
        if skill >= PBTrainerAI.mediumSkill
          score += 30 if target.hp <= target.totalhp / 4
          score += 50 if target.hp <= target.totalhp / 8
          score -= 40 if target.effects[PBEffects::Yawn] > 0
        end
        if skill >= PBTrainerAI.highSkill
          score += 10 if pbRoughStat(target, :DEFENSE, skill) > 100
          score += 10 if pbRoughStat(target, :SPECIAL_DEFENSE, skill) > 100
          score -= 40 if target.hasActiveAbility?([:GUTS, :MARVELSCALE, :TOXICBOOST])
        end
      end
    #---------------------------------------------------------------------------
    when "RemoveTerrainIceSpinner"                      # Ice Spinner
    #---------------------------------------------------------------------------
      score += 20 if @battle.field.terrain != :None
    #---------------------------------------------------------------------------
    when "StartHailWeatherSwitchOutUser"                # Chilly Reception
    #---------------------------------------------------------------------------
      if !@battle.pbCanChooseNonActive?(user.index) ||
         @battle.pbTeamAbleNonActiveCount(user.index) > 1
        score -= 100
      else
        score += 40 if user.effects[PBEffects::Confusion] > 0
        total = 0
        GameData::Stat.each_battle { |s| total += user.stages[s.id] }
        if total <= 0 || user.turnCount == 0
          score += 60
        else
          score -= total * 10
          hasDamagingMove = false
          user.eachMove do |m|
            next if !m.damagingMove?
            hasDamagingMove = true
            break
          end
          score += 75 if !hasDamagingMove
        end
      end
    #---------------------------------------------------------------------------
    when "UserMakeSubstituteSwitchOut"                  # Shed Tail
    #---------------------------------------------------------------------------
      if user.effects[PBEffects::Substitute] > 0
        score -= 90
      elsif user.hp <= user.totalhp / 2
        score -= 90
      end
    #---------------------------------------------------------------------------
    when "SetUserAlliesAbilityToTargetAbility"          # Doodle
    #---------------------------------------------------------------------------
      score -= 40
      if skill >= PBTrainerAI.mediumSkill
        if !target.ability || user.ability == target.ability ||
           user.unstoppableAbility? || target.uncopyableAbility? ||
           user.hasActiveItem?(:ABILITYSHIELD) || target.hasActiveItem?(:ABILITYSHIELD)
          score -= 90
        end
      end
      if skill >= PBTrainerAI.highSkill
        if target.ability == :TRUANT && user.opposes?(target)
          score -= 90
        elsif target.ability == :SLOWSTART && user.opposes?(target)
          score -= 90
        end
      end
    #---------------------------------------------------------------------------
    when "RevivePokemonHalfHP"                          # Revival Blessing
    #---------------------------------------------------------------------------
      numFainted = 0
      party = @battle.pbParty(user.idxOwnSide)
      party.each { |b| numFainted += 1 if b.fainted? }
      score += ((numFainted / party.length) * 100).round if numFainted > 0
    else
      return paldea_pbGetMoveScoreFunctionCode(score, move, user, target, skill)
    end
    return score
  end
end