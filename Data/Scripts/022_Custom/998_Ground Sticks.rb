def pbGroundStick(id, message, trainer)
  return false if $game_switches[6] # Beaten gym 3
  return false if pbGetSelfSwitch(id)
  event = get_character(id)
  event.through = true unless $game_player.y == event.y
  event.turn_toward_player
  pbWait(4)
  pbTrainerIntro(trainer[0])
  pbNoticePlayer(event)
  unless $game_player.y == event.y
    case event.x - $game_player.x
    when -1 then event.move_right
    when 1 then event.move_left
    end
  end
  commands = []
  if $game_player.y > event.y
    ($game_player.y-event.y-1).times { commands.push(PBMoveRoute::Down) }
    pbMoveRoute(event, commands, true)
    $game_player.turn_up
  elsif $game_player.y < event.y
    (event.y-$game_player.y-1).times { commands.push(PBMoveRoute::Up) }
    pbMoveRoute(event, commands, true)
    $game_player.turn_up
  else
    event.turn_toward_player
    (event.x < $game_player.x) ? $game_player.turn_left : $game_player.turn_right
  end
  pbWait(20*commands.length)
  pbCallBub(2, id)
  pbMessage(_INTL("\\r{1}",message))
  vSST(id) if TrainerBattle.start_core(trainer[0], trainer[1])==1
  pbTrainerEnd
  event.through = false
end