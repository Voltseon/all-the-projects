def move_pad(event=get_self,e=-1,check_passable=true)
  mover = get_character(e)
  return unless mover.at_coordinate?(event.x, event.y)
  return if !mover.can_move_in_direction?(event.direction, false) && check_passable
  mr = [PBMoveRoute::WalkAnimeOff]
  case event.direction
  when 2 then mr.push(PBMoveRoute::Down)
  when 4 then mr.push(PBMoveRoute::Left)
  when 6 then mr.push(PBMoveRoute::Right)
  when 8 then mr.push(PBMoveRoute::Up)
  end
  mr.push(PBMoveRoute::WalkAnimeOn)
  pbSEPlay("se_door_slide",100,150) if e==-1
  mover.through = true unless check_passable
  pbMoveRoute(mover, mr, true)
  mover.through = false unless check_passable
  $PokemonMap&.addMovedEvent(e) unless e == -1
end

def change_pads(eventIDs,type)
  pbSEPlay("Battle catch click",100,150)
  eventIDs.each do |id|
    e = get_event(id)
    pbMoveRoute(e, [PBMoveRoute::DirectionFixOff])
    case type
    when 0 # turn left
      case e.direction
      when 2 then e.direction = 6
      when 4 then e.direction = 2
      when 6 then e.direction = 8
      when 8 then e.direction = 4
      end
    when 1 # turn right
      case e.direction
      when 2 then e.direction = 4
      when 4 then e.direction = 8
      when 6 then e.direction = 2
      when 8 then e.direction = 6
      end
    when 2 # turn 180
      case e.direction
      when 2 then e.direction = 8
      when 4 then e.direction = 6
      when 6 then e.direction = 4
      when 8 then e.direction = 2
      end
    end
    pbMoveRoute(e, [PBMoveRoute::DirectionFixOn, PBMoveRoute::ThroughOn])
    e.through = true
  end
end

def use_pads(eventIDs)
  pbSEPlay("Battle catch click",100,150)
  pbSEPlay("se_door_slide",100,150)
  movers = []
  events = []
  eventIDs.each do |id|
    e = get_event(id)
    $game_map.events.each_value do |event|
      next unless event.at_coordinate?(e.x, e.y) && event.id != id
      next if movers.include?(event.id)
      movers.push(event.id)
      events.push(e)
    end
  end
  movers.each_with_index do |m, index|
    move_pad(events[index],m,false)
  end
end

def boxend(range)
  for i in range[0]..range[1]
    e = get_character(i)
    e.moveto(e.x,e.y-21)
    $PokemonMap&.addMovedEvent(e.id)
  end
end

def leaders(isLiz)
  eliz = get_character(6)
  earnold = get_character(1)
  eliz.turn_down
  earnold.turn_down
  vSST(174)
  if $game_switches[12] && !pbGetSelfSwitch(get_self.id)
    if isLiz 
      liz("Congrats on becoming the champion!")
      liz("Here's a little gift from me.")
      pkmn = Pokemon.new($player.special_pokemon[:LIZARNOLDGIFT][0],80) if !$player.rocketmode
      pkmn.item = :LATIASITE
    else
      arnold("Congratulations! You did it! You became a champ!")
      arnold("Please take this little gift.")
      pbReceiveItem(:SOULDEW)
      arnold("And also this could come in handy...")
      pkmn = Pokemon.new($player.special_pokemon[:LIZARNOLDGIFT][1],80) if !$player.rocketmode
      pkmn.item = :LATIOSITE
    end
    pbAddPokemon(pkmn)
    vSST(get_self.id)
    return
  end
  if $game_switches[10]
    isLiz ? liz("Thank you again for an amazing battle!") : arnold("That was an amazing battle!")
    return
  end
  return if !check_sbq(7)
  if $player.able_pokemon_count < 2
    if isLiz
      liz("I'm sorry, but you're going to need more Pokémon to challenge us...")
      liz("Please come back when you do!")
    else
      arnold("I'm sorry, but you're going to need more Pokémon to challenge us...")
      arnold("Please come back when you do!")
    end
    return
  end
  $stats.gym_leader_attempts[6] += 1
  if !$player.nostory
    $game_screen.start_tone_change(Tone.new(-255,-255,-255), 8 * Graphics.frame_rate / 20)
    pbWait(10 * Graphics.frame_rate / 20)
    $game_player.moveto_transfer(112,7,8)
    $game_screen.start_tone_change(Tone.new(0,0,0), 8 * Graphics.frame_rate / 20)
    pbWait(8 * Graphics.frame_rate / 20)
    liz("Welcome challenger, you were expected!")
    arnold("As you may have noticed, this gym is all about double battles.")
    liz("So instead of one Gym Leader, you will be challenging the both of us!")
    arnold("Good luck \\PN! Let's battle!")
  end
  setBattleRule("double")
  if TrainerBattle.start(:LEADER_LizArnold, "Liz & Arnold")
    $stats.set_time_to_badge(6)
    liz("That was an amazing battle! Congratulations!")
    arnold("Good job! Liz will now grant you your badge, which will allow you to use the move Fire Lash outside of battle.")
    pbMoveRoute(eliz,[PBMoveRoute::Left, PBMoveRoute::TurnDown],true) if !$player.nostory
    $player.badges[6] = true
    $game_switches[10] = true
    if !$player.nostory
      pbMessage("\\me[RSE 152 Obtained a Badge!]\\PN received the \\rBond Badge\\c[0]!\\wtnp[60]")
      pbMoveRoute(eliz,[PBMoveRoute::Right, PBMoveRoute::TurnDown],true)
      liz("That should help you get through Route 313 and to Upil City, your next goal. I assume.")
      arnold("We also heard that another challenger, Borad was on his way here.")
      pbExclaim(eliz)
      pbWait(14)
      eliz.turn_left
      liz("Wait, aren't you forgetting something Arnold?")
      pbExclaim(earnold)
      pbWait(14)
      earnold.turn_right
      arnold("Right! The TM!")
      eliz.turn_down
      pbMoveRoute(earnold,[PBMoveRoute::Right, PBMoveRoute::TurnDown],true)
    end
    pbReceiveItem(:TM59)
    if !$player.nostory
      liz("That's the TM for Dragon Pusle, it should come in useful. Though not that useful against Upsilon.")
      pbMoveRoute(earnold,[PBMoveRoute::Left, PBMoveRoute::TurnDown],true)
      arnold("Wait, you know nothing about Upsilon, do you?")
      liz("Maybe it's best you don't. I mean, Upsilon wouldn't want us talking about them anyways.")
      arnold("In any case, good luck on the rest of your gym challenge \\PN!")
      liz("Good luck!")
    end
  end
end

def arnold(message)
  return if $player.nostory
  pbCallBub(2,1)
  pbMessage("\\b" + message)
end

def liz(message)
  return if $player.nostory
  pbCallBub(2,6)
  pbMessage("\\r" + message)
end

def teleport_up
  pbSEPlay("sfx_teleport_away")
  32.times do |i|
    $game_player.y_offset -= 8
    $game_player.turn_right_90
    pbWait(1)
  end
end

def teleport_down
  pbSEPlay("sfx_teleport_back")
  32.times do |i|
    $game_player.y_offset += 8
    $game_player.turn_right_90
    pbWait(1)
  end
end