class Character
  attr_accessor :name, :internal, :melee, :ranged, :speed, :hp, :melee_damage, 
                :ranged_damage, :aim_range, :aim_type, :movement_type, :hitbox, :guard_time, :guard_cooldown,
                :unguard_time, :dash_distance, :dash_speed, :unlock_proc, :playable, :evolution, :evolution_exp, :description,
                :sketched_melee, :sketched_ranged, :sketched_melee_damage, :sketched_ranged_damage

  def initialize(name, internal, melee, ranged, speed, hp, melee_damage, ranged_damage,
                 aim_range, aim_type, movement_type, hitbox, guard_time, guard_cooldown,
                 unguard_time, dash_distance, dash_speed, unlock_proc, playable, evolution,
                 evolution_exp, description)

    @name = name
    @internal = internal
    @melee = melee
    @ranged = ranged
    @speed = speed
    @hp = hp
    @melee_damage = melee_damage
    @ranged_damage = ranged_damage
    @aim_range = aim_range
    @aim_type = aim_type
    @movement_type = movement_type
    @hitbox = hitbox
    @guard_time = guard_time
    @guard_cooldown = guard_cooldown
    @unguard_time = unguard_time
    @dash_distance = dash_distance
    @dash_speed = dash_speed
    @unlock_proc = unlock_proc
    @playable = playable
    @evolution = evolution
    @evolution_exp = evolution_exp
    @description = description
    @sketched_melee = nil
    @sketched_ranged = nil
    @sketched_melee_damage = nil
    @sketched_ranged_damage = nil
  end

  def melee
    return @sketched_melee if @sketched_melee
    return @melee
  end

  def ranged
    return @sketched_ranged if @sketched_ranged
    return @ranged
  end

  def melee_damage
    return @sketched_melee_damage if @sketched_melee_damage
    return @melee_damage
  end

  def ranged_damage
    return @sketched_ranged_damage if @sketched_ranged_damage
    return @ranged_damage
  end

  def sketched_melee=(value)
    @sketched_melee = value
  end

  def sketched_ranged=(value)
    @sketched_ranged = value
  end

  def sketched_melee_damage=(value)
    @sketched_melee_damage = value
  end

  def sketched_ranged_damage=(value)
    @sketched_ranged_damage = value
  end

  def attack
    return (@melee_damage+@ranged_damage)/2
  end

  def evolution_line
    return true if @evolution
    return is_evolution
  end

  def is_evolution
    Character.each do |character|
      next unless character.evolution == @internal
      return true 
    end
    return false
  end

  def evolution_stages
    return get_prevos + get_evos + 1
  end

  def prevo
    Character.each do |child|
      if child.evolution == @internal
        return child.internal
        break
      end
    end
    return nil
  end

  def get_prevos
    child_count = 0
    evo_check = @internal
    while evo_check
      did_evo = false
      Character.each do |child|
        if child.evolution == evo_check
          child_count += 1
          evo_check = child.internal
          did_evo = true
          break
        end
      end
      break unless did_evo
    end
    return child_count
  end

  def get_evos
    evo_count = 0
    if @evolution
      evo_count += 1
      parent = Character.get(@evolution)
      while parent.evolution
        evo_count += 1
        parent = Character.get(parent.evolution)
      end
    end
    return evo_count
  end
end