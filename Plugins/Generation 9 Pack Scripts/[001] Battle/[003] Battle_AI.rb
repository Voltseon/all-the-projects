################################################################################
# 
# Battle::AI class changes.
# 
################################################################################


class Battle::AI
  attr_reader :using_item_on_party
  
  #-----------------------------------------------------------------------------
  # Initializes check for AI trainers using an item on a Pokemon in the party.
  #-----------------------------------------------------------------------------
  alias paldea_initialize initialize
  def initialize(battle)
    paldea_initialize(battle)
    @using_item_on_party = false
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to allow AI trainers to use revival items in battle.
  #-----------------------------------------------------------------------------
  alias paldea_pbEnemyItemToUse pbEnemyItemToUse
  def pbEnemyItemToUse(idxBattler)
    return nil if !@battle.internalBattle
    items = @battle.pbGetOwnerItems(idxBattler)
    return nil if !items || items.length == 0
    numFainted = 0
    party = @battle.pbParty(idxBattler)
    party.each { |b| numFainted += 1 if b.fainted? }
    idxFainted = pbDefaultChooseReviveEnemy(idxBattler, party)
    if numFainted > 0 && idxFainted >= 0
      pkmn = party[idxFainted]
      reviveItems = {
        :REVIVE      => 3, 
        :MAXREVIVE   => 5, 
        :REVIVALHERB => 5,
        :MAXHONEY    => 5
      }
      usableReviveItems = []
      items.each do |i|
        next if !i
        next if !@battle.pbCanUseItemOnPokemon?(i, pkmn, nil, @battle.scene, false)
        next if !ItemHandlers.triggerCanUseInBattle(i, pkmn, nil, nil, false, self, @battle.scene, false)
        if reviveItems[i]
          usableReviveItems.push([i, reviveItems[i]])
          next
        end	
      end
      remaining = party.length - numFainted
      useChance = (remaining == 1) ? 100 : ((numFainted.to_f / party.length.to_f) * 100).floor
      if usableReviveItems.length > 0 && pbAIRandom(100) < useChance
        usableReviveItems.sort! { |a, b| a[1] <=> b[1] }
        @using_item_on_party = true
        return usableReviveItems[0][0], idxFainted
      end
    end
	@using_item_on_party = false
    return paldea_pbEnemyItemToUse(idxBattler)
  end
  
  #-----------------------------------------------------------------------------
  # Edited so that items that are used on the party are registered properly.
  #-----------------------------------------------------------------------------
  def pbEnemyShouldUseItem?(idxBattler)
    user = @battle.battlers[idxBattler]
    item, idxTarget = pbEnemyItemToUse(idxBattler)
    return false if !item
    useType = GameData::Item.get(item).battle_use
    if [1, 2, 3].include?(useType) && !@using_item_on_party
      idxTarget = @battle.battlers[idxTarget].pokemonIndex
    end
    @battle.pbRegisterItem(idxBattler, item, idxTarget)
    PBDebug.log("[AI] #{user.pbThis} (#{user.index}) will use item #{GameData::Item.get(item).name}")
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Used to allow an AI trainer to select a Pokemon in the party to revive.
  #-----------------------------------------------------------------------------
  def pbDefaultChooseReviveEnemy(idxBattler, party)
    enemies = []
    idxPartyStart, idxPartyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    party.each_with_index { |p, i| enemies.push(i) if !p.egg? && p.fainted? }
    return pbChooseBestNewEnemy(idxBattler, party, enemies)
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to encourage AI trainers to switch out to trigger Zero to Hero.
  #-----------------------------------------------------------------------------
  alias paldea_pbEnemyShouldWithdrawEx? pbEnemyShouldWithdrawEx?
  def pbEnemyShouldWithdrawEx?(idxBattler, forceSwitch)
    return false if @battle.wildBattle?
    battler = @battle.battlers[idxBattler]
    if battler.hasActiveAbility?(:ZEROTOHERO) && battler.form == 0
      switchFunctions = [
        "SwitchOutUserStatusMove",           # Teleport
        "SwitchOutUserDamagingMove",         # U-Turn/Volt Switch
        "SwitchOutUserPassOnEffects",        # Baton Pass
        "LowerTargetAtkSpAtk1SwitchOutUser", # Parting Shot
        "StartHailWeatherSwitchOutUser",     # Chilly Reception
        "UserMakeSubstituteSwitchOut"        # Shed Tail
      ]
      battler.eachMoveWithIndex do |m, i|
        next if !switchFunctions.include?(m.function)
        next if !@battle.pbCanChooseMove?(idxBattler, i, false)
        forceSwitch = true
        break
      end
    end
    return paldea_pbEnemyShouldWithdrawEx?(idxBattler, forceSwitch)
  end
  
  #-----------------------------------------------------------------------------
  # Aliased so AI trainers can recognize immunities from Gen 9 abilities.
  #-----------------------------------------------------------------------------
  alias paldea_pbCheckMoveImmunity pbCheckMoveImmunity
  def pbCheckMoveImmunity(score, move, user, target, skill)
    return true if target.hasActiveAbility?(:COMMANDER) && target.isCommander?
    if skill >= PBTrainerAI.mediumSkill
      type = pbRoughType(move, user, skill)
      return true if type == :GROUND   && target.hasActiveAbility?(:EARTHEATER)
      return true if type == :FIRE     && target.hasActiveAbility?(:WELLBAKEDBODY)
      return true if move.windMove?    && target.hasActiveAbility?(:WINDRIDER)
      return true if move.statusMove?  && target.hasActiveAbility?(:GOODASGOLD) && 
                                          !user.hasActiveAbility?(:MYCELIUMMIGHT)
      return true if move.priority > 0 && target.opposes?(user) && 
                     target.hasActiveAbility?([:DAZZLING, :QUEENLYMAJESTY, :ARMORTAIL]) 
    end
    return paldea_pbCheckMoveImmunity(score, move, user, target, skill)
  end
  
  #-----------------------------------------------------------------------------
  # Edited to add a variety of new effects that affect damage calculation.
  #  -Applies the effects of the various "of Ruin" abilities.
  #  -Negates the damage reduction the move Hydro Steam would have in the Sun.
  #  -Increases the Defense of Ice-types during Snow weather (Gen 9 version).
  #  -Halves the damage dealt by special attacks if the user has the Frostbite status.
  #  -Increases damage taken if the targer has the Drowsy status.
  #  -Doubles damage taken by a target still vulnerable due to Glaive Rush's effect.
  #-----------------------------------------------------------------------------
  def pbRoughDamage(move, user, target, skill, baseDmg)
    return baseDmg if move.is_a?(Battle::Move::FixedDamageMove)
    type = pbRoughType(move, user, skill)
    atk = pbRoughStat(user, :ATTACK, skill)
    if move.function == "UseTargetAttackInsteadOfUserAttack"
      atk = pbRoughStat(target, :ATTACK, skill)
    elsif move.function == "UseUserBaseDefenseInsteadOfUserBaseAttack"
      atk = pbRoughStat(user, :DEFENSE, skill)
    elsif move.specialMove?(type)
      if move.function == "UseTargetAttackInsteadOfUserAttack"
        atk = pbRoughStat(target, :SPECIAL_ATTACK, skill)
      else
        atk = pbRoughStat(user, :SPECIAL_ATTACK, skill)
      end
    end
    defense = pbRoughStat(target, :DEFENSE, skill)
    if move.specialMove?(type) && move.function != "UseTargetDefenseInsteadOfTargetSpDef"
      defense = pbRoughStat(target, :SPECIAL_DEFENSE, skill)
    end
    multipliers = {
      :base_damage_multiplier  => 1.0,
      :attack_multiplier       => 1.0,
      :defense_multiplier      => 1.0,
      :final_damage_multiplier => 1.0
    }
    moldBreaker = false
    if skill >= PBTrainerAI.highSkill && target.hasMoldBreaker?
      moldBreaker = true
    end
    if skill >= PBTrainerAI.mediumSkill && user.abilityActive?
      abilityBlacklist = [:ANALYTIC, :SNIPER, :TINTEDLENS, :AERILATE, :PIXILATE, :REFRIGERATE]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromUser(
          user.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.mediumSkill && !moldBreaker
      user.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromAlly(
          b.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.bestSkill && !moldBreaker && target.abilityActive?
      abilityBlacklist = [:FILTER, :SOLIDROCK]
      canCheck = true
      abilityBlacklist.each do |m|
        next if move.id != m
        canCheck = false
        break
      end
      if canCheck
        Battle::AbilityEffects.triggerDamageCalcFromTarget(
          target.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.bestSkill && !moldBreaker
      target.allAllies.each do |b|
        next if !b.abilityActive?
        Battle::AbilityEffects.triggerDamageCalcFromTargetAlly(
          b.ability, user, target, move, multipliers, baseDmg, type
        )
      end
    end
    if skill >= PBTrainerAI.mediumSkill && user.itemActive?
      itemBlacklist = [:EXPERTBELT, :LIFEORB]
      if !itemBlacklist.include?(user.item_id)
        Battle::ItemEffects.triggerDamageCalcFromUser(
          user.item, user, target, move, multipliers, baseDmg, type
        )
        user.effects[PBEffects::GemConsumed] = nil
      end
    end
    if skill >= PBTrainerAI.bestSkill &&
       target.itemActive? && target.item && !target.item.is_berry?
      Battle::ItemEffects.triggerDamageCalcFromTarget(
        target.item, user, target, move, multipliers, baseDmg, type
      )
    end
    if skill >= PBTrainerAI.mediumSkill &&
       ((@battle.pbCheckGlobalAbility(:DARKAURA) && type == :DARK) ||
        (@battle.pbCheckGlobalAbility(:FAIRYAURA) && type == :FAIRY))
      if @battle.pbCheckGlobalAbility(:AURABREAK)
        multipliers[:base_damage_multiplier] *= 2 / 3.0
      else
        multipliers[:base_damage_multiplier] *= 4 / 3.0
      end
    end
    #---------------------------------------------------------------------------
    # Added for "of Ruin" abilities
    #---------------------------------------------------------------------------
    if skill >= PBTrainerAI.mediumSkill
      [:TABLETSOFRUIN, :SWORDOFRUIN, :VESSELOFRUIN, :BEADSOFRUIN].each_with_index do |abil, i|
        category = (i < 2) ? move.physicalMove? : move.specialMove?
        category = !category if i.odd? && @battle.field.effects[PBEffects::WonderRoom] > 0
        mult = (i.even?) ? multipliers[:attack_multiplier] : multipliers[:defense_multiplier]
        mult *= 0.75 if @battle.pbCheckGlobalAbility(abil) && !user.hasActiveAbility?(abil) && category
      end
    end
    #---------------------------------------------------------------------------
    if skill >= PBTrainerAI.mediumSkill && user.hasActiveAbility?(:PARENTALBOND)
      multipliers[:base_damage_multiplier] *= 1.25
    end
    if skill >= PBTrainerAI.mediumSkill &&
       user.effects[PBEffects::Charge] > 0 && type == :ELECTRIC
      multipliers[:base_damage_multiplier] *= 2
    end
    if skill >= PBTrainerAI.mediumSkill
      if type == :ELECTRIC
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::MudSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::MudSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
      if type == :FIRE
        if @battle.allBattlers.any? { |b| b.effects[PBEffects::WaterSport] }
          multipliers[:base_damage_multiplier] /= 3
        end
        if @battle.field.effects[PBEffects::WaterSportField] > 0
          multipliers[:base_damage_multiplier] /= 3
        end
      end
    end
    if skill >= PBTrainerAI.mediumSkill
      case @battle.field.terrain
      when :Electric
        multipliers[:base_damage_multiplier] *= 1.5 if type == :ELECTRIC && user.affectedByTerrain?
		multipliers[:base_damage_multiplier] *= 1.5 if move.function == "IncreasePowerInElectricTerrain" && user.affectedByTerrain?
      when :Grassy
        multipliers[:base_damage_multiplier] *= 1.5 if type == :GRASS && user.affectedByTerrain?
      when :Psychic
        multipliers[:base_damage_multiplier] *= 1.5 if type == :PSYCHIC && user.affectedByTerrain?
      when :Misty
        multipliers[:base_damage_multiplier] /= 2 if type == :DRAGON && target.affectedByTerrain?
      end
    end
    if skill >= PBTrainerAI.highSkill && @battle.internalBattle && target.pbOwnedByPlayer?
      if move.physicalMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_DEFENSE
        multipliers[:defense_multiplier] *= 1.1
      elsif move.specialMove?(type) && @battle.pbPlayer.badge_count >= Settings::NUM_BADGES_BOOST_SPDEF
        multipliers[:defense_multiplier] *= 1.1
      end
    end
    if skill >= PBTrainerAI.highSkill && pbTargetsMultiple?(move, user)
      multipliers[:final_damage_multiplier] *= 0.75
    end
    if skill >= PBTrainerAI.mediumSkill
      case user.effectiveWeather
      when :Sun, :HarshSun
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] *= 1.5
        when :WATER                                  # Added for Hydro Steam
          multipliers[:final_damage_multiplier] /= 2 if move.function != "IncreasePowerInSunWeather"
        end
      when :Rain, :HeavyRain
        case type
        when :FIRE
          multipliers[:final_damage_multiplier] /= 2
        when :WATER
          multipliers[:final_damage_multiplier] *= 1.5
        end
      when :Sandstorm
        if target.pbHasType?(:ROCK) && move.specialMove?(type) &&
           move.function != "UseTargetDefenseInsteadOfTargetSpDef"
          multipliers[:defense_multiplier] *= 1.5
        end
      #-------------------------------------------------------------------------
      # Added for Gen 9 Snow
      #-------------------------------------------------------------------------
      when :Hail
        if Settings::HAIL_WEATHER_TYPE > 0 && target.pbHasType?(:ICE) && move.physicalMove?(type) && 
           (move.physicalMove?(type) || move.function == "UseTargetDefenseInsteadOfTargetSpDef")
          multipliers[:defense_multiplier] *= 1.5
        end
      #-------------------------------------------------------------------------
      end
    end	
    if skill >= PBTrainerAI.mediumSkill && type && user.pbHasType?(type)
      if user.hasActiveAbility?(:ADAPTABILITY)
        multipliers[:final_damage_multiplier] *= 2
      else
        multipliers[:final_damage_multiplier] *= 1.5
      end
    end
    if skill >= PBTrainerAI.mediumSkill
      typemod = pbCalcTypeMod(type, user, target)
      multipliers[:final_damage_multiplier] *= typemod.to_f / Effectiveness::NORMAL_EFFECTIVE
    end
    if skill >= PBTrainerAI.highSkill && move.physicalMove?(type) &&
       user.status == :BURN && !user.hasActiveAbility?(:GUTS) &&
       !(Settings::MECHANICS_GENERATION >= 6 &&
         move.function == "DoublePowerIfUserPoisonedBurnedParalyzed")
      multipliers[:final_damage_multiplier] /= 2
    end
    #---------------------------------------------------------------------------
    # Added for Drowsy
    #---------------------------------------------------------------------------
    if skill >= PBTrainerAI.highSkill && user.status == :DROWSY
      multipliers[:final_damage_multiplier] *= 4 / 3.0
    end
    #---------------------------------------------------------------------------
    # Added for Frostbite
    #---------------------------------------------------------------------------
    if skill >= PBTrainerAI.highSkill && move.specialMove?(type) && user.status == :FROSTBITE
      multipliers[:final_damage_multiplier] /= 2
    end
    #---------------------------------------------------------------------------
    if skill >= PBTrainerAI.highSkill && !move.ignoresReflect? && !user.hasActiveAbility?(:INFILTRATOR)
      if target.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::Reflect] > 0 && move.physicalMove?(type)
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      elsif target.pbOwnSide.effects[PBEffects::LightScreen] > 0 && move.specialMove?(type)
        if @battle.pbSideBattlerCount(target) > 1
          multipliers[:final_damage_multiplier] *= 2 / 3.0
        else
          multipliers[:final_damage_multiplier] /= 2
        end
      end
    end
    if skill >= PBTrainerAI.highSkill && target.effects[PBEffects::Minimize] && move.tramplesMinimize?
      multipliers[:final_damage_multiplier] *= 2
    end
    #---------------------------------------------------------------------------
    # Added for Glaive Rush
    #---------------------------------------------------------------------------
    if skill >= PBTrainerAI.highSkill && target.effects[PBEffects::GlaiveRush] > 0
      multipliers[:final_damage_multiplier] *= 2
    end
    #---------------------------------------------------------------------------
    baseDmg = [(baseDmg * multipliers[:base_damage_multiplier]).round, 1].max
    atk     = [(atk     * multipliers[:attack_multiplier]).round, 1].max
    defense = [(defense * multipliers[:defense_multiplier]).round, 1].max
    damage  = ((((2.0 * user.level / 5) + 2).floor * baseDmg * atk / defense).floor / 50).floor + 2
    damage  = [(damage * multipliers[:final_damage_multiplier]).round, 1].max
    if skill >= PBTrainerAI.mediumSkill
      c = 0
      if c >= 0 && user.abilityActive?
        c = Battle::AbilityEffects.triggerCriticalCalcFromUser(user.ability, user, target, c)
      end
      if skill >= PBTrainerAI.bestSkill && c >= 0 && !moldBreaker && target.abilityActive?
        c = Battle::AbilityEffects.triggerCriticalCalcFromTarget(target.ability, user, target, c)
      end
      if c >= 0 && user.itemActive?
        c = Battle::ItemEffects.triggerCriticalCalcFromUser(user.item, user, target, c)
      end
      if skill >= PBTrainerAI.bestSkill && c >= 0 && target.itemActive?
        c = Battle::ItemEffects.triggerCriticalCalcFromTarget(target.item, user, target, c)
      end
      c = -1 if target.pbOwnSide.effects[PBEffects::LuckyChant] > 0
      if c >= 0
        c += 1 if move.highCriticalRate?
        c += user.effects[PBEffects::FocusEnergy]
        c += 1 if user.inHyperMode? && move.type == :SHADOW
      end
      if c >= 0
        c = 4 if c > 4
        damage += damage * 0.1 * c
      end
    end
    return damage.floor
  end
end