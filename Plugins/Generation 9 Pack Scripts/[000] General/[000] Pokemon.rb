################################################################################
# 
# GameData::Species changes.
# 
################################################################################


#-------------------------------------------------------------------------------
# Edited so that moves can be set as learnable at Lvl -1.
# This is used for Move Reminder-exclusive moves.
#-------------------------------------------------------------------------------
module GameData
  class Species
    Species.singleton_class.alias_method :paldea_schema, :schema
    def self.schema(compiling_forms = false)
      ret = self.paldea_schema(compiling_forms)
      ret["Moves"] = [0, "*ie", nil, :Move]
      return ret
    end
  end
end


################################################################################
# 
# Pokemon class additions.
# 
################################################################################


class Pokemon
  alias paldea_initialize initialize
  def initialize(*args)
    paldea_initialize(*args)
    @evo_move_count   = {}
    @evo_crest_count  = {}
    @evo_recoil_count = 0
    @evo_step_count   = 0
  end
  
  #-----------------------------------------------------------------------------
  # Move count evolution utilities.
  #-----------------------------------------------------------------------------
  def init_evo_move_count(move)
    @evo_move_count = Hash.new if !@evo_move_count
    @evo_move_count[move] = 0 if !@evo_move_count[move]
  end
  
  def move_count_evolution(move, qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelUseMoveCount && evo[2] == move
        init_evo_move_count(move)
        @evo_move_count[move] += qty
        break
      end
    end
  end
  
  def evo_move_count(move)
    init_evo_move_count(move)
    return @evo_move_count[move]
  end
  
  def set_evo_move_count(move, value)
    init_evo_move_count(move)
    @evo_move_count[move] = value
  end
  
  #-----------------------------------------------------------------------------
  # Leader's crest evolution utilities.
  #-----------------------------------------------------------------------------
  def init_evo_crest_count(item)
    @evo_crest_count = Hash.new if !@evo_crest_count
    @evo_crest_count[item] = 0 if !@evo_crest_count[item]
  end
  
  def leaders_crest_evolution(item, qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelDefeatItsKindWithItem && evo[2] == item
        init_evo_crest_count(item)
        @evo_crest_count[item] += qty
        break
      end
    end
  end
  
  def evo_crest_count(item)
    init_evo_crest_count(item)
    return @evo_crest_count[item]
  end
  
  def set_evo_crest_count(item, value)
    init_crest_count(item)
    @evo_crest_count[item] = value
  end
  
  #-----------------------------------------------------------------------------
  # Recoil damage evolution utilities.
  #-----------------------------------------------------------------------------
  def recoil_evolution(qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelRecoilDamage
        @evo_recoil_count = 0 if !@evo_recoil_count
        @evo_recoil_count += qty
        break
      end
    end
  end
  
  def evo_recoil_count
    return @evo_recoil_count || 0
  end
  
  def evo_recoil_count=(value)
    @evo_recoil_count = value
  end
  
  #-----------------------------------------------------------------------------
  # Walking evolution utilities.
  #-----------------------------------------------------------------------------
  def walking_evolution(qty = 1)
    species_data.get_evolutions.each do |evo|
      if evo[1] == :LevelWalk
        @evo_step_count = 0 if !@evo_step_count
        @evo_step_count += qty
        break
      end
    end
  end
    
  def evo_step_count
    return @evo_step_count || 0
  end
  
  def evo_step_count=(value)
    @evo_step_count = value
  end
  
  #-----------------------------------------------------------------------------
  # Edited for Move Relearner-exclusive moves.
  #-----------------------------------------------------------------------------
  def reset_moves
    this_level = self.level
    moveset = self.getMoveList
    knowable_moves = []
    moveset.each { |m| knowable_moves.push(m[1]) if (0..this_level).include?(m[0]) }
    knowable_moves = knowable_moves.reverse
    knowable_moves |= []
    knowable_moves = knowable_moves.reverse
    @moves.clear
    first_move_index = knowable_moves.length - MAX_MOVES
    first_move_index = 0 if first_move_index < 0
    (first_move_index...knowable_moves.length).each do |i|
      @moves.push(Pokemon::Move.new(knowable_moves[i]))
    end
  end
end


################################################################################
# 
# New evolution methods.
# 
################################################################################


GameData::Evolution.register({
  :id            => :CollectItems,
  :parameter     => :Item,
  :minimum_level => 1,
  :level_up_proc => proc { |pkmn, parameter|
    next $bag.quantity(parameter) >= 999
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || $bag.quantity(parameter) < 999
    $bag.remove(parameter, 999)
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelWithPartner,
  :parameter     => Integer,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.level >= parameter && $PokemonGlobal.partner
  }
})

GameData::Evolution.register({
  :id            => :LevelUseMoveCount,
  :parameter     => :Move,
  :minimum_level => 1,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_move_count(parameter) >= 20
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_move_count(parameter) < 20
    pkmn.set_evo_move_count(parameter, 0)
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelDefeatItsKindWithItem,
  :parameter     => :Item,
  :minimum_level => 1,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_crest_count(parameter) >= 3
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_crest_count(parameter) < 3
    pkmn.set_evo_crest_count(parameter,0)
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelRecoilDamage,
  :parameter     => Integer,
  :minimum_level => 1,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_recoil_count >= parameter
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_recoil_count < parameter
    pkmn.evo_recoil_count = 0
    next true
  }
})

GameData::Evolution.register({
  :id            => :LevelWalk,
  :parameter     => Integer,
  :minimum_level => 1,
  :level_up_proc => proc { |pkmn, parameter|
    next pkmn.evo_step_count >= parameter
  },
  :after_evolution_proc => proc { |pkmn, new_species, parameter, evo_species|
    next false if evo_species != new_species || pkmn.evo_step_count < parameter
    pkmn.evo_step_count = 0
    next true
  }
})


################################################################################
# 
# Step-based event handlers.
# 
################################################################################


#-------------------------------------------------------------------------------
# Tracks steps taken to trigger walking evolutions for the lead Pokemon.
#-------------------------------------------------------------------------------
EventHandlers.add(:on_player_step_taken, :evolution_steps, proc {
  $player.first_able_pokemon.walking_evolution if $player.party_count > 0
})

#-------------------------------------------------------------------------------
# Initializes Mirror Herb step counter.
#-------------------------------------------------------------------------------
class PokemonGlobalMetadata
  attr_accessor :mirrorherb_steps
  alias paldea_initialize initialize
  def initialize
    @mirrorherb_steps = 0
    paldea_initialize
  end
end

#-------------------------------------------------------------------------------
# Tracks steps taken while Pokemon in the party are holding a Mirror Herb.
# Every 100 steps, inherits Egg moves from other party members if possible.
#-------------------------------------------------------------------------------
EventHandlers.add(:on_player_step_taken, :mirrorherb_step, proc {
  if $player.able_party.any? { |p| p&.hasItem?(:MIRRORHERB) }
    $PokemonGlobal.mirrorherb_steps = 0 if !$PokemonGlobal.mirrorherb_steps
    $PokemonGlobal.mirrorherb_steps += 1
    if $PokemonGlobal.mirrorherb_steps > 255
      found_eggMove = false
      $player.able_party.each_with_index do |pkmn, i|
        next if pkmn.item != :MIRRORHERB
        next if pkmn.numMoves == Pokemon::MAX_MOVES
        baby_species = pkmn.species_data.get_baby_species
        eggmoves = GameData::Species.get(baby_species).egg_moves.clone
        eggmoves.shuffle.each do |move|
          next if pkmn.hasMove?(move)
          next if !$player.get_pokemon_with_move(move)
          pkmn.learn_move(move)
          found_eggMove = true
          break
        end
        break if found_eggMove
      end
      $PokemonGlobal.mirrorherb_steps = 0
    end
  else
    $PokemonGlobal.mirrorherb_steps = 0
  end
})


################################################################################
# 
# Form handlers.
# 
################################################################################


#-------------------------------------------------------------------------------
# Regional forms upon creating an egg.
#-------------------------------------------------------------------------------
MultipleForms.copy(:RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE, :GRIMER,      # Alolan
                   :PONYTA, :FARFETCHD, :CORSOLA, :ZIGZAGOON, :DARUMAKA, :YAMASK, :STUNFISK, # Galarian                                   
                   :SLOWPOKE, :ARTICUNO, :ZAPDOS, :MOLTRES,                                  # Galarian (DLC)
                   :PETILIL, :RUFFLET, :GOOMY, :BERGMITE,                                    # Hisuian
                   :WOOPER, :TAUROS                                                          # Paldean
                  )                                                       

#-------------------------------------------------------------------------------
# Species with regional evolutions (Hisuian forms).
#-------------------------------------------------------------------------------			  
MultipleForms.register(:QUILAVA, {
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_pos = $game_map.metadata&.town_map_position
      next 1 if map_pos && map_pos[0] == 3   # Hisui region
    end
    next 0
  }
})

MultipleForms.copy(:QUILAVA, :DEWOTT, :DARTRIX)

#-------------------------------------------------------------------------------
# Dundunsparce - Segment sizes.
#-------------------------------------------------------------------------------
MultipleForms.register(:DUNSPARCE, {
  "getFormOnCreation" => proc { |pkmn|
    next (pkmn.personalID % 100 == 0) ? 1 : 0
  }
})

MultipleForms.copy(:DUNSPARCE, :DUDUNSPARCE)

#-------------------------------------------------------------------------------
# Dialga - Origin Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:DIALGA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:ADAMANTCRYSTAL)
    next 0
  }
})

#-------------------------------------------------------------------------------
# Palkia - Origin Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:PALKIA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:LUSTROUSGLOBE)
    next 0
  }
})

#-------------------------------------------------------------------------------
# Giratina - Origin Forme.
#-------------------------------------------------------------------------------
MultipleForms.register(:GIRATINA, {
  "getForm" => proc { |pkmn|
    next 1 if pkmn.hasItem?(:GRISEOUSORB) || pkmn.hasItem?(:GRISEOUSCORE)
    if $game_map &&
       GameData::MapMetadata.get($game_map.map_id)&.has_flag?("DistortionWorld")
      next 1
    end
    next 0
  }
})

#-------------------------------------------------------------------------------
# Basculegion - Gender forms.
#-------------------------------------------------------------------------------
MultipleForms.register(:BASCULEGION, {
  "getForm" => proc { |pkmn|
    next pkmn.gender
  },
  "getFormOnCreation" => proc { |pkmn|
    next pkmn.gender
  }
})

#-------------------------------------------------------------------------------
# Oinkologne - Gender forms.
#-------------------------------------------------------------------------------
MultipleForms.register(:LECHONK, {
  "getForm" => proc { |pkmn|
    next pkmn.gender
  }
})

MultipleForms.copy(:LECHONK, :OINKOLOGNE)

#-------------------------------------------------------------------------------
# Maushold - Family sizes.
#-------------------------------------------------------------------------------
MultipleForms.register(:TANDEMAUS, {
  "getFormOnCreation" => proc { |pkmn|
    next (pkmn.personalID % 100 == 0) ? 1 : 0
  }
})

MultipleForms.copy(:TANDEMAUS, :MAUSHOLD)

#-------------------------------------------------------------------------------
# Squawkabilly - Plumage colors.
#-------------------------------------------------------------------------------
MultipleForms.register(:SQUAWKABILLY, {
  "getFormOnCreation" => proc { |pkmn|
    next rand(4)
  }
})

#-------------------------------------------------------------------------------
# Palafin - Zero Form.
#-------------------------------------------------------------------------------
MultipleForms.register(:PALAFIN, {
  "getFormOnLeavingBattle" => proc { |pkmn, battle, usedInBattle, endBattle|
    next 0 if endBattle
  }
})