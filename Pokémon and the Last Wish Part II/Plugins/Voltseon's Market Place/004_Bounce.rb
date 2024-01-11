GameData::TerrainTag.register({
  :id                     => :BounceLedge,
  :id_number              => 20,
  :bounce                 => true
})

class PokemonMapMetadata
  attr_accessor :bounceUsed

  def clear
    @erasedEvents   = {}
    @movedEvents    = {}
    @bounceUsed   = false
    @blackFluteUsed = false
    @whiteFluteUsed = false
    @bounceUsed     = false
  end
end

class Game_Player < Game_Character
  def move_generic(dir, turn_enabled = true)
    turn_generic(dir, true) if turn_enabled
    if !$PokemonTemp.encounterTriggered
      if can_move_in_direction?(dir)
        x_offset = (dir == 4) ? -1 : (dir == 6) ? 1 : 0
        y_offset = (dir == 8) ? -1 : (dir == 2) ? 1 : 0
        return if pbBounce(x_offset, y_offset)
        return if pbLedge(x_offset, y_offset)
        return if pbEndSurf(x_offset, y_offset)
        turn_generic(dir, true)
        if !$PokemonTemp.encounterTriggered
          @x += x_offset
          @y += y_offset
          $PokemonTemp.dependentEvents.pbMoveDependentEvents
          increase_steps
        end
      elsif !check_event_trigger_touch(dir)
        bump_into_object
      end
    end
    $PokemonTemp.encounterTriggered = false
  end
end

class Game_Player
  alias move_generic_stairs move_generic
  def move_generic(dir, turn_enabled = true)
    old_tag = self.map.terrain_tag(@x, @y).id
    old_through = self.through
    old_x = @x
    if dir == 4
      if old_tag == :StairLeft
        if passable?(@x - 1, @y + 1, 4) && self.map.terrain_tag(@x - 1, @y + 1) == :StairLeft
          @y += 1
          self.through = true
        end
      elsif old_tag == :StairRight
        if passable?(@x - 1, @y - 1, 6)
          @y -= 1
          self.through = true
        end
      end
    elsif dir == 6
      if old_tag == :StairLeft && passable?(@x + 1, @y - 1, 4)
        @y -= 1
        self.through = true
      elsif old_tag == :StairRight && passable?(@x + 1, @y + 1, 6) && self.map.terrain_tag(@x + 1, @y + 1) == :StairRight
        @y += 1
        self.through = true
      end
    end
    move_generic_stairs(dir, turn_enabled)
    new_tag = self.map.terrain_tag(@x, @y)
    if old_x != @x
      if old_tag != :StairLeft && new_tag == :StairLeft ||
         old_tag != :StairRight && new_tag == :StairRight
        self.offset_y = -16
        @y += 1 if (new_tag == :StairLeft && dir == 4) || (new_tag == :StairRight && dir == 6)
      elsif old_tag == :StairLeft && new_tag != :StairLeft ||
            old_tag == :StairRight && new_tag != :StairRight
        self.offset_y = 0
      end
    end
    self.through = old_through
  end
end

def pbBounce(_xOffset,_yOffset)
  if $game_player.pbFacingTerrainTag.id == :BounceLedge && $PokemonMap.bounceUsed
    hasFollower = $PokemonGlobal.follower_toggled
    FollowingPkmn.toggle_off(true) if hasFollower
    if pbJumpToward(VoltseonsMarketPlace::BounceAmount,true)
      $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,$game_player.x,$game_player.y,true,1)
      $game_player.increase_steps
      $game_player.check_event_trigger_here([1,2])
    end
    FollowingPkmn.toggle_on(true) if hasFollower
    return true
  end
  return false
end

def pbUseBounce
  if $PokemonMap.bounceUsed
    pbMessage(_INTL("Bounce made it possible to hop across gaps."))
    return false
  end
  move = :BOUNCE
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH,false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("It's a big gap, but a Pokémon may be able to hop across it."))
    return false
  end
  pbMessage(_INTL("It's a big gap, but a Pokémon may be able to hop across it.\1"))
  if pbConfirmMessage(_INTL("Would you like to use Bounce?"))
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    pbMessage(_INTL("{1}'s Bounce made it possible to hop across gaps!",speciesname))
    $PokemonMap.bounceUsed = true
    return true
  end
  return false
end

Events.onAction += proc { |_sender,_e|
  facingEvent = $game_player.pbFacingTerrainTag.id == :BounceLedge
  pbUseBounce if facingEvent
}

HiddenMoveHandlers::CanUseMove.add(:BOUNCE,proc { |move,pkmn,showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH,showmsg)
  if $PokemonMap.bounceUsed
    pbMessage(_INTL("Bounce is already active.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:BOUNCE,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!\1",pokemon.name,GameData::Move.get(move).name))
  end
  pbMessage(_INTL("{1}'s Bounce made it possible to hop across gaps!",pokemon.name))
  $PokemonMap.bounceUsed = true
  next true
})