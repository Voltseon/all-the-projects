GameData::TerrainTag.register({
  :id                     => :DeepSand,
  :id_number              => 29,
  :land_wild_encounters   => true,
  :double_wild_encounters => true,
  :battle_environment     => :Sand,  
  :must_walk              => true
})

def pbJune
  pbSEPlay("Cut", 100)
  pbWait(2)
  [1,2,3,5,7,8,9,11,12,13].each do |i|
    get_character(i).turn_left
  end
  pbWait(2)
  [1,2,3,5,7,8,9,11,12,13].each do |i|
    get_character(i).turn_right
  end
  pbWait(2)
  [1,2,3,5,7,8,9,11,12,13].each do |i|
    get_character(i).turn_up
  end
  pbWait(2)
  pbWait(Graphics.frame_rate * 4 / 20)
  [1,2,3,5,7,8,9,11,12,13].each do |i|
    get_character(i).erase
    $PokemonMap&.addErasedEvent(i)
  end
end

def pbGetSelfSwitch(event_id)
  return $game_self_switches[[$game_map.map_id,event_id,"A"]]
end

def on_lazer
  return false if $game_temp.message_window_showing
  $game_map.events.each_value do |event|
    next if event.name[/FakeTrainer/]
    next if event.character_name != ""
    next if !event.at_coordinate?($game_player.x, $game_player.y)
    return true
  end
  return false
end

def scroll_to(x,y,speed,waitforcomplete=false)
  disx = $game_map.display_x/128+8 - x
  disy = $game_map.display_y/128+6 - y
  dir1 = 0
  dir2 = 0
  dis1 = 0
  dis2 = 0
  if disy.abs > disx.abs
    dir1 = (disy > 0 ? 8 : 2)
    dis1 = disy.abs
    dir2 = (disx > 0 ? 4 : 6)
    dis2 = disx.abs
  else
    dir1 = (disx > 0 ? 4 : 6)
    dis1 = disx.abs
    dir2 = (disy > 0 ? 8 : 2)
    dis2 = disy.abs
  end
  $game_map.start_scroll(dir1, dis1, speed)
  pbWait((3*dis1/(0.1*speed)+1).round)
  $game_map.start_scroll(dir2, dis2, speed)
  pbWait((3*dis2/(0.1*speed)+1).round) if waitforcomplete
end

EventHandlers.add(:on_step_taken, :dive_bubbles,
  proc { |event|
    next if !$scene.is_a?(Scene_Map)
    next if $scene.spriteset.nil?
    next unless $PokemonGlobal&.diving
    next if event.is_a?(Game_FollowingPkmn) && !FollowingPkmn.active?
    next if rand(8) != 0
    spriteset = $scene.spriteset(event.map_id)
    spriteset&.addUserAnimation([23,24].sample, event.x, event.y, true, 1)
  }
)