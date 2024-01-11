def temst
  echoln "Key Items"
  echoln ""
  GameData::Item.each do |item|
    next unless item.is_key_item?
    echoln "#{item.name}"
  end
  echoln ""
  echoln "Mega Stones"
  echoln ""
  GameData::Item.each do |item|
    next unless item.is_mega_stone?
    echoln "#{item.name}"
  end
end

def pbBoat304
  following_active = FollowingPkmn.active?
  mr = [
    PBMoveRoute::ThroughOn,
    PBMoveRoute::Down,
    PBMoveRoute::TurnRight,
    PBMoveRoute::Graphic,"",0,0,0
  ]
  if following_active
    mr.push(PBMoveRoute::Script,"FollowingPkmn.move_route([PBMoveRoute::Down])")
    mr.push(PBMoveRoute::Wait,4)
    mr.push(PBMoveRoute::Script,"FollowingPkmn.toggle_off(false)")
  end
  mr += [
    PBMoveRoute::Wait,4,
    PBMoveRoute::Graphic,"NPC 37",0,6,0,
    PBMoveRoute::SwitchOn,63,
    PBMoveRoute::ChangeSpeed,2,
    PBMoveRoute::Right,
    PBMoveRoute::Right,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,3,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,4,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,5,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,6,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,5,
    PBMoveRoute::Down,
    PBMoveRoute::Left,
    PBMoveRoute::Left,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,4,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::ChangeSpeed,3,
    PBMoveRoute::Down,
    PBMoveRoute::Down,
    PBMoveRoute::SwitchOff,63,
    PBMoveRoute::Graphic,"trainer_#{$player.trainer_type}",0,0,0,
    PBMoveRoute::Down,
    PBMoveRoute::ThroughOff,
    PBMoveRoute::Down,
    PBMoveRoute::Script,"$game_map.autoplayAsCue"
  ]
  mr.push(PBMoveRoute::Script,"FollowingPkmn.toggle_on") if following_active
  pbBGMPlay("RSE 129 Crossing The Sea")
  pbMoveRoute($game_player,mr,true)
end