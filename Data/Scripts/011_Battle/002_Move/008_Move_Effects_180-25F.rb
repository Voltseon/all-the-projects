#===============================================================================
# Deals damage based on the opponent's lost HP. (Future Manipulate)
#===============================================================================
class PokeBattle_Move_180 < PokeBattle_FixedDamageMove
    def pbFixedDamage(user,target)
        lostHP = target.initialHP - target.hp
        lostHP = 1 if lostHP < 1
        return lostHP
    end
end

#===============================================================================
# Power increases with the user's positive stat changes (ignores negative ones).
# It also has a slight chance to burn.
# (Hot Competition)
#===============================================================================
class PokeBattle_Move_181 < PokeBattle_BurnMove
    def pbBaseDamage(baseDmg,user,target)
      mult = 1
      GameData::Stat.each_battle { |s| mult += user.stages[s.id] if user.stages[s.id] > 0 }
      return 10 * mult + baseDmg
    end
  end

#===============================================================================
# Clears weather and changes form. (Midnight Howl)
#===============================================================================
class PokeBattle_Move_182 < PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :None
  end

  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    return if user.fainted? || user.effects[PBEffects::Transform]
    return if !user.isSpecies?(:CANIGHT)
    return if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect>0
    user.pbChangeForm(1,_INTL("{1} transformed!",user.pbThis))
  end
end

#===============================================================================
# Starts sunny weather and changes form. (High Noon Call)
#===============================================================================
class PokeBattle_Move_183 < PokeBattle_WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Sun
  end

  def pbEndOfMoveUsageEffect(user,targets,numHits,switchedBattlers)
    return if user.fainted? || user.effects[PBEffects::Transform]
    return if !user.isSpecies?(:HOWLIGHT)
    return if user.hasActiveAbility?(:SHEERFORCE) && @addlEffect>0
    user.pbChangeForm(1,_INTL("{1} transformed!",user.pbThis))
  end
end

#===============================================================================
# Gives parental bond for the next turn. (Bug Cry)
#===============================================================================
class PokeBattle_Move_184 < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::BugCry]>=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::BugCry] = 1
    @battle.pbDisplay(_INTL("{1} is getting support!",user.pbThis))
  end
end

#===============================================================================
# Starts rainy weather and deals damage. (Weather Report)
#===============================================================================
class PokeBattle_Move_185 < PokeBattle_WeatherMove2
  def initialize(battle,move)
    super
    @weatherType = :Rain
  end
end

#===============================================================================
# Becomes completely random type. (Hit or Miss)
#===============================================================================
class PokeBattle_Move_186 < PokeBattle_Move
  def initialize(battle,move)
    super
    @typeArray = [:NORMAL, :FIRE, :WATER, :ELECTRIC, :GRASS, :ICE, :FIGHTING, :POISON, :GROUND, :FLYING, :PSYCHIC, :BUG, :ROCK, :GHOST, :DRAGON, :DARK, :STEEL, :FAIRY]
  end

  def pbBaseType(user)
    ret = @typeArray[rand(@typeArray.length)]
    ret = :NORMAL if !GameData::Type.exists?(ret)
    return ret
  end
end

#===============================================================================
# Random 2nd effect. (Wonder Call)
#===============================================================================
class PokeBattle_Move_187 < PokeBattle_Move
  def pbEffectAfterAllHits(user,target)
    return if target.fainted?
    return if target.damageState.unaffected || target.damageState.substitute
    chance = pbAdditionalEffectChance(user,target)
    return if @battle.pbRandom(100)>=chance
    case rand(19)
    when 1
      target.pbSleep if target.pbCanSleep?(user,false,self)
    when 2
      target.pbBurn(user) if target.pbCanBurn?(user,false,self)
    when 3
      target.pbParalyze(user) if target.pbCanParalyze?(user,false,self)
    when 4
      target.pbFreeze if target.pbCanFreeze?(user,false,self)
    when 5
      target.pbPetrify if target.pbCanPetrify?(user,false,self)
    when 6
      target.pbPoison if target.pbCanPoison?(user,false,self)
    when 7
      target.pbConfuse if target.pbCanConfuse?(user,false,self)
    when 8
      if target.pbCanLowerStatStage?(:ATTACK,user,self)
        target.pbLowerStatStage(:ATTACK,1,user)
      end
    when 9
      if target.pbCanLowerStatStage?(:DEFENSE,user,self)
        target.pbLowerStatStage(:DEFENSE,1,user)
      end
    when 10
      if target.pbCanLowerStatStage?(:SPECIAL_ATTACK,user,self)
        target.pbLowerStatStage(:SPECIAL_ATTACK,1,user)
      end
    when 11
      if target.pbCanLowerStatStage?(:SPEED,user,self)
        target.pbLowerStatStage(:SPEED,1,user)
      end
    when 12
      if target.pbCanLowerStatStage?(:ACCURACY,user,self)
        target.pbLowerStatStage(:ACCURACY,1,user)
      end
    when 13
      if user.pbCanRaiseStatStage?(:ATTACK,user,self)
        user.pbRaiseStatStage(:ATTACK,1,user)
      end
    when 14
      if user.pbCanRaiseStatStage?(:DEFENSE,user,self)
        user.pbRaiseStatStage(:DEFENSE,1,user)
      end
    when 15
      if user.pbCanRaiseStatStage?(:SPECIAL_ATTACK,user,self)
        user.pbRaiseStatStage(:SPECIAL_ATTACK,1,user)
      end
    when 16
      if user.pbCanRaiseStatStage?(:SPEED,user,self)
        user.pbRaiseStatStage(:SPEED,1,user)
      end
    when 17
      if user.pbCanRaiseStatStage?(:ACCURACY,user,self)
        user.pbRaiseStatStage(:ACCURACY,1,user)
      end
    when 18
      target.pbFlinch(user)
    when 19
      user.pbPurify if user.pbCanPurify?(user,false,self)
    end
  end
end

#===============================================================================
# Poisons the target if not water type. (Acid Rain)
#===============================================================================
class PokeBattle_Move_188 < PokeBattle_PoisonMove
  def pbFailsAgainstTarget?(user,target)
    if target.pbHasType?(:WATER)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",target.pbThis(true)))
      return true
    end
    return super
  end
end

#===============================================================================
# Traps and paralyzes the target. (Zap Grapple)
#===============================================================================
class PokeBattle_Move_189 < PokeBattle_ParalysisMove
  def pbEffectAgainstTarget(user,target)
    return if target.fainted? || target.damageState.substitute
    return if target.effects[PBEffects::Trapping]>0
    # Set trapping effect duration and info
    if user.hasActiveItem?(:GRIPCLAW)
      target.effects[PBEffects::Trapping] = (Settings::MECHANICS_GENERATION >= 5) ? 8 : 6
    else
      target.effects[PBEffects::Trapping] = 5+@battle.pbRandom(2)
    end
    target.effects[PBEffects::TrappingMove] = @id
    target.effects[PBEffects::TrappingUser] = user.index
    @battle.pbDisplay(_INTL("{1} was grappled!",target.pbThis))
    return super
  end
end

#===============================================================================
# For 5 rounds, swaps the user's base Defense with base Special Defense.
# (Polarity Swap)
#===============================================================================
class PokeBattle_Move_18A < PokeBattle_Move
  def pbMoveFailed?(user,targets)
    if user.effects[PBEffects::PolaritySwap]>=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.effects[PBEffects::PolaritySwap] = 5
    @battle.pbDisplay(_INTL("{1} swapped their polarity!",user.pbThis))
  end
end

#===============================================================================
# Deals damage based on the user's defensive stats, depending on the move's
# Physical or Special damage (Positive Charge, Negative Charge)
#===============================================================================
class PokeBattle_Move_18B < PokeBattle_Move
  def pbGetAttackStats(user,target)
    if specialMove?
      return user.spdef, user.stages[:SPECIAL_DEFENSE]+6
    end
    return user.defense, user.stages[:DEFENSE]+6
  end
end

#===============================================================================
# Powers up Fire attacks. (Ignite)
#===============================================================================
class PokeBattle_Move_09D < PokeBattle_BurnMove
  def pbMoveFailed?(user,targets)
    if Settings::MECHANICS_GENERATION >= 6
      if @battle.field.effects[PBEffects::IgniteField]>0
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    else
      @battle.eachBattler do |b|
        next if !b.effects[PBEffects::Ignite]
        @battle.pbDisplay(_INTL("But it failed!"))
        return true
      end
    end
    return false
  end

  def pbEffectGeneral(user)
    if Settings::MECHANICS_GENERATION >= 6
      @battle.field.effects[PBEffects::IgniteField] = 5
    else
      user.effects[PBEffects::Ignite] = true
    end
    @battle.pbDisplay(_INTL("Fire type moves have been powered up!"))
  end
end