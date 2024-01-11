#-------------------------------------------------------------------------------
# Phenomenon: BW Style Grass Rustle, Water Drops, Cave Dust & Flying Birds
# v3.0 by Boonzeet with code help from Maruno & Marin, Grass graphic by DaSpirit
#-------------------------------------------------------------------------------
# Please give credit when using. Changes in this version:
# - Upgraded for Essentials v19
# - Block inaccessible tiles from showing phenomena
#===============================================================================
# Main code
#-------------------------------------------------------------------------------
# SUPPORT CAN'T BE PROVIDED FOR EDITS MADE TO THIS FILE.
#===============================================================================
class Game_Temp
  attr_accessor :phenomenon   # [x,y,type,timer]
  attr_accessor :phenomenonPossible # bool
  attr_accessor :phenomenonActivated #bool
end

class Array # Add quick random array fetch - by Marin
  def random
    return self[rand(self.size)]
  end
end

class Phenomenon
  attr_accessor :timer # number
  attr_accessor :x
  attr_accessor :y
  attr_accessor :type # symbol
  attr_accessor :active # bool
  attr_accessor :drawing # bool

  def initialize(types)
    Kernel.echoln("Initializing for map with types: #{types}")
    @x = nil
    @y = nil
    @types = types
    timer_val = PhenomenonConfig::Frequency <= 60 ? 60 : rand(PhenomenonConfig::Frequency - 60) + 6
    @timer = Graphics.frame_count + timer_val
    @active = false
  end

  def generate!
    Kernel.echo("Generating phenomena...\n")
    phenomenon_tiles = []   # x, y, type
    # limit range to around the player
    x_range = [[$game_player.x - 16, 0].max, [$game_player.x + 16, $game_map.width].min]
    y_range = [[$game_player.y - 16, 0].max, [$game_player.y + 16, $game_map.height].min]
    # list all grass tiles
    blocked_tiles = nil
    if PhenomenonConfig::BlockedTiles.key?($game_map.map_id)
      blocked_tiles = PhenomenonConfig::BlockedTiles[$game_map.map_id]
    end
    for x in x_range[0]..x_range[1]
      for y in y_range[0]..y_range[1]
        if !blocked_tiles.nil?
          next if blocked_tiles[:x] && blocked_tiles[:x].include?(x)
          next if blocked_tiles[:y] && blocked_tiles[:x].include?(y)
          next if blocked_tiles[:tiles] && blocked_tiles[:x].include?([x, y])
        end
        next if $game_map.check_event(x, y)
        next if !$MapFactory
        terrain_tag = $game_map.terrain_tag(x, y)
        if @types.include?(:PhenomenonGrass) && terrain_tag.id == :Grass
          phenomenon_tiles.push([x, y, :PhenomenonGrass])
        elsif @types.include?(:PhenomenonWater) && (terrain_tag.id == :Water || terrain_tag.id == :StillWater)
          phenomenon_tiles.push([x, y, :PhenomenonWater])
        elsif @types.include?(:PhenomenonCave) && !terrain_tag.can_surf && $MapFactory.isPassableStrict?($game_map.map_id, x, y, $game_player)
          phenomenon_tiles.push([x, y, :PhenomenonCave])
        elsif @types.include?(:PhenomenonBird) && terrain_tag.id == :BirdBridge && $MapFactory.isPassableStrict?($game_map.map_id, x, y, $game_player)
          phenomenon_tiles.push([x, y, :PhenomenonBird])
        end
      end
    end
    if phenomenon_tiles.length == 0
      Kernel.echoln("A phenomenon is set up but no compatible tiles are available! Phenomena: #{@types}")
      pbPhenomenonCancel
    else
      selected_tile = phenomenon_tiles.random
      @x = selected_tile[0]
      @y = selected_tile[1]
      @type = selected_tile[2]
      @timer = Graphics.frame_count + PhenomenonConfig::Timer
      @active = true
    end
  end

  def activate!
    return if $game_switches[63]
    Kernel.echoln("Activating phenomenon for #{@type}")
    encounter = nil
    item = nil
    chance = rand(10) # Different types have chance different effects, e.g. items in caves
    encounter = $PokemonEncounters.choose_wild_pokemon(@type)
    if @type == :PhenomenonCave && chance < (($PokemonGlobal.repel > 0) ? 8 : 5)
      item = chance > 0 ? PhenomenonConfig::Items[:commonCave].random : PhenomenonConfig::Items[:rareCave].random
    elsif @type == :PhenomenonBird && chance < 8
      item = chance > 0 ? PhenomenonConfig::Items[:bird].random : :PRETTYWING
    end
    if item != nil
      pbPhenomenonCancel
      Kernel.pbReceiveItem(item)
    elsif encounter != nil
      if PhenomenonConfig::BattleMusic != "" && FileTest.audio_exist?("Audio/BGM/#{PhenomenonConfig::BattleMusic}")
        $PokemonGlobal.nextBattleBGM = PhenomenonConfig::BattleMusic
      end
      $game_temp.phenomenonActivated = true
      WildBattle.start(encounter[0], encounter[1])
    end
  end

  def drawAnim(sound)
    return if !$scene || !$scene.spriteset
    return unless $scene.is_a?(Scene_Map)
    dist = (((@x - $game_player.x).abs + (@y - $game_player.y).abs) / 4).floor
    if dist <= 6 && dist >= 0
      animation = PhenomenonConfig::Types[@type]
      $scene.spriteset.addUserAnimation(animation[0], @x, @y, true, animation[2])
      pbSEPlay(animation[1], [75, 65, 55, 40, 27, 22, 15][dist]) if sound
    end
    pbWait(1)
    @drawing = false
  end
end

# Cancels the phenomenon
def pbPhenomenonCancel
  $game_temp.phenomenon = nil
end

def pbPhenomenonLoadTypes
  types = []
  PhenomenonConfig::Types.each do |(key, value)|
    # Kernel.echo("Testing map #{$game_map.map_id}, against #{key}, with value #{value}...\n")
    types.push(key) if $PokemonEncounters && $PokemonEncounters.map_has_encounter_type?($game_map.map_id, key)
  end
  $game_temp.phenomenonPossible = types.size > 0 && $Trainer.party.length > 0 # set to false if no encounters for map or trainer has no pokemon
  $game_temp.phenomenonTypes = types
end

def pbPhenomenonInactive?
  return defined?($game_temp.phenomenon) && $game_temp.phenomenon != nil && !$game_temp.phenomenon.active
end

# Returns true if an existing phenomenon has been set up and exists
def pbPhenomenonActive?
  return defined?($game_temp.phenomenon) && $game_temp.phenomenon != nil && $game_temp.phenomenon.active
end

# Returns true if there's a phenomenon and the player is on top of it
def pbPhenomenonPlayerOn?
  return pbPhenomenonActive? && ($game_player.x == $game_temp.phenomenon.x && $game_player.y == $game_temp.phenomenon.y)
end

################################################################################
# Event handlers
################################################################################
class Game_Temp
  attr_accessor :phenomenonExp
  attr_accessor :phenomenonTypes
  attr_accessor :phenomenon
end

# Cancels phenomenon on battle start to stop animation during battle intro
EventHandlers.add(:on_start_battle, :phenomenon_stop,
  proc {
    $game_temp.phenomenonExp = true if PhenomenonConfig::Pokemon[:expBoost] && pbPhenomenonPlayerOn?
    pbPhenomenonCancel
  }
)

EventHandlers.add(:on_end_battle, :phenomenon_end,
  proc {
    $game_temp.phenomenonExp = false
    $game_temp.phenomenonActivated = false
  }
)

# Generate the phenomenon or process the player standing on it
EventHandlers.add(:on_step_taken, :phenomenon_create,
  proc {
    if $game_temp.phenomenonPossible
      if pbPhenomenonPlayerOn?
        $game_temp.phenomenon.activate!
      elsif pbPhenomenonInactive?
        if Graphics.frame_count >= $game_temp.phenomenon.timer
          $game_temp.phenomenon.generate!
        end
      elsif $game_temp.phenomenon == nil && $game_temp.phenomenonTypes.size && (PhenomenonConfig::Switch == -1 || $game_switches[PhenomenonConfig::Switch])
        $game_temp.phenomenon = Phenomenon.new($game_temp.phenomenonTypes)
      end
    end
  }
)

# Remove any phenomenon events on map change
EventHandlers.add(:on_map_or_spriteset_change, :phenomenon_delete,
  proc {
    pbPhenomenonCancel
  }
)

# Process map available encounters on map change
EventHandlers.add(:on_game_map_setup, :phenomenon_load,
  proc {
    pbPhenomenonLoadTypes
  }
)

# Modify the wild encounter based on the settings above
EventHandlers.add(:on_wild_pokemon_created, :phenomenon_activate,
  proc { |pokemon|
    if $game_temp.phenomenonActivated
      if PhenomenonConfig::Pokemon[:shiny] # 4x the normal shiny chance
        pokemon.shiny = true if rand(65536) <= $player.shinyodds * 4
      end
      if PhenomenonConfig::Pokemon[:ivs] > -1 && rand(PhenomenonConfig::Pokemon[:ivs]) == 0
        ivs = [:HP, :ATTACK, :SPECIAL_ATTACK, :DEFENSE, :SPECIAL_DEFENSE, :SPEED]
        ivs.shuffle!
        ivs[0..1].each do |i|
          pokemon.iv[i] = 31
        end
      end
      if PhenomenonConfig::Pokemon[:eggMoves] > -1 && rand(PhenomenonConfig::Pokemon[:eggMoves]) == 0
        moves = GameData::Species.get_species_form(pokemon.species, pokemon.form).egg_moves
        pokemon.learn_move(moves.random) if moves.length > 0
      end
      if PhenomenonConfig::Pokemon[:hiddenAbility] > -1 && rand(PhenomenonConfig::Pokemon[:hiddenAbility]) == 0
        a = GameData::Species.get(pokemon.species).hidden_abilities
        if !a.nil? && a.kind_of?(Array)
          pokemon.ability = a.random
        end
      end
    end
  }
)

################################################################################
# Class modifiers
################################################################################
class Spriteset_Map
  alias update_phenomenon update

  def update
    if $game_temp.phenomenonPossible && pbPhenomenonActive? && !$game_temp.in_menu
      phn = $game_temp.phenomenon
      if (PhenomenonConfig::Switch != -1 &&
          !$game_switches[PhenomenonConfig::Switch]) || Graphics.frame_count >= phn.timer
        pbPhenomenonCancel
      elsif !phn.drawing && Graphics.frame_count % 40 == 0 # play animation every 140 update ticks
        phn.drawing = true
        sound = phn.type == :PhenomenonGrass ? (Graphics.frame_count % 80 == 0) : true
        phn.drawAnim(sound)
      end
    end
    update_phenomenon
  end
end
