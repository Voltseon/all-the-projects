#===============================================================================
# Stomp
#===============================================================================
STOMPITEMS = [:CHESTOBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY, :PERSIMBERRY,
  :ASPEARBERRY, :LUMBERRY, :ORANBERRY, :SITRUSBERRY, :LEPPABERRY, :ENIGMABERRY,
  :NESTBALL, :POKEBALL, :GREATBALL, :POTION, :SUPERPOTION, :MIRACLESEED, :STICKYBARB,
  :WIKIBERRY, :AGUAVBERRY, :FIGYBERRY, :IAPAPABERRY, :MAGOBERRY, :BLACKSLUDGE]

def pbStomp
  move = :STOMP
  movefinder = $Trainer.get_pokemon_with_move(move)
  if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT,false) || (!$DEBUG && !movefinder)
    pbMessage(_INTL("The weeds seem to be blocking the path."))
    return false
  end
  pbMessage(_INTL("The weeds look like they can be stomped down!\1"))
  if pbConfirmMessage(_INTL("Would you like to smash them?"))
    old_toggled = $PokemonGlobal.follower_toggled
    FollowingPkmn.toggle_off(true)
    speciesname = (movefinder) ? movefinder.name : $Trainer.name
    pbMessage(_INTL("{1} used {2}!",speciesname,GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    FollowingPkmn.toggle(old_toggled, false)
    return true
  end
  return false
end

HiddenMoveHandlers::CanUseMove.add(:STOMP,proc { |move,pkmn,showmsg|
  next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT,showmsg)
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/weeds/i]
    pbMessage(_INTL("Can't use that here.")) if showmsg
    next false
  end
  next true
})

HiddenMoveHandlers::UseMove.add(:STOMP,proc { |move,pokemon|
  if !pbHiddenMoveAnimation(pokemon)
    pbMessage(_INTL("{1} used {2}!",pokemon.name,GameData::Move.get(move).name))
  end
  pbStompEvent($game_player.pbFacingEvent)
  next true
})

def pbStompEvent(event)
  old_through = $game_player.through
  $game_player.through = true
  if pbJumpToward(1,true)
    $scene.spriteset.addUserAnimation(Settings::DUST_ANIMATION_ID,$game_player.x,$game_player.y,true,1)
    $game_player.increase_steps
    $game_player.check_event_trigger_here([1,2])
  end
  if event
    if event.name[/weeds/i]
      pbSEPlay(VoltseonsMarketPlace::STOMPSE,80)
    end
    pbMoveRoute(event,[
      PBMoveRoute::Wait,2,
      PBMoveRoute::TurnLeft,
      PBMoveRoute::Wait,2,
      PBMoveRoute::TurnRight,
      PBMoveRoute::Wait,2,
      PBMoveRoute::TurnUp,
      PBMoveRoute::Wait,2
   ])
   $game_player.through = old_through
   pbWait(Graphics.frame_rate*4/10)
   event.erase
   $PokemonMap.addErasedEvent(event.id) if $PokemonMap
   if (rand(10)==1)
    pbExclaim($game_player)
    pbWait(Graphics.frame_rate*4/10)
    vFI(STOMPITEMS[rand(0..STOMPITEMS.length-1)])
   end
  end
end