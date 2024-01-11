GameData::TerrainTag.register({
  :id                     => :PathWrong,
  :id_number              => 30
})

GameData::TerrainTag.register({
  :id                     => :PathRight,
  :id_number              => 31
})

GameData::TerrainTag.register({
  :id                     => :PathNormal,
  :id_number              => 32
})

def pbShowPath(path)
  return false unless $scene.is_a?(Scene_Map)
  path.each_with_index do |pa, i|
    pbSEPlay("se_step_note_0",70,100+2*i)
    $scene.spriteset.addUserAnimation(54, pa[0], pa[1], false, -64)
    pbWait(2)
  end
  return true
end

EventHandlers.add(:on_player_step_taken, :gym_path_behavior,
  proc {
    next unless $scene.is_a?(Scene_Map)
    thistile = $map_factory.getRealTilePos($game_player.map.map_id, $game_player.x, $game_player.y)
    map = $map_factory.getMap(thistile[0])
    tile_id = map.data[thistile[1], thistile[2], 0]
    next if tile_id.nil?
    current_tag = GameData::TerrainTag.try_get(map.terrain_tags[tile_id]).id
    next unless [:PathWrong, :PathRight, :PathNormal].include?(current_tag)
    case current_tag
    when :PathWrong
      if $player.badge_count > 7
        pbSEPlay("se_step_note_1",70,100+2*pbGet(30))
        $scene.spriteset.addUserAnimation(54, $game_player.x, $game_player.y, false, -64)
        pbSet(30, pbGet(30)+1)
        next
      end
      pbSet(30, 0)
      pbPlayBuzzerSE
      $scene.spriteset.addUserAnimation(56, $game_player.x, $game_player.y, false, -64)
      pbWait(4 * Graphics.frame_rate / 20)
      $game_screen.start_tone_change(Tone.new(-255,-255,-255), 4 * Graphics.frame_rate / 20)
      pbWait(4 * Graphics.frame_rate / 20)
      stored_loc = pbGet(31)
      if stored_loc.is_a?(Array)
        $game_player.moveto_transfer(stored_loc[0],stored_loc[1])
      else
        $game_player.moveto_transfer(20,28,8)
      end
      $game_screen.start_tone_change(Tone.new(0,0,0), 4 * Graphics.frame_rate / 20)
      pbWait(2 * Graphics.frame_rate / 20)
    when :PathRight
      pbSEPlay("se_step_note_5",70,100+2*pbGet(30))
      $scene.spriteset.addUserAnimation(55, $game_player.x, $game_player.y, false, -64)
      pbSet(30, pbGet(30)+1)
    when :PathNormal
      pbSet(30, 0)
      pbSet(31,[$game_player.x, $game_player.y])
    end
  }
)

def pbRandomTileGlimmer
  return unless $scene.is_a?(Scene_Map)
  return unless rand(5) == 1
  thistile = nil
  map = nil
  tile_id = nil
  current_tag = nil
  100.times do
    thistile = $map_factory.getRealTilePos($game_map.map_id, rand($game_player.x-4..$game_player.x+4), rand($game_player.y-4..$game_player.y+4))
    next if thistile.nil?
    map = $map_factory.getMap(thistile[0])
    tile_id = map.data[thistile[1], thistile[2], 0]
    current_tag = GameData::TerrainTag.try_get(map.terrain_tags[tile_id]).id
    break if [:PathWrong, :PathRight].include?(current_tag)
  end
  return if thistile.nil? || map.nil? || tile_id.nil? || current_tag.nil? || ![:PathWrong, :PathRight].include?(current_tag)
  case current_tag
  when :PathWrong then $scene.spriteset.addUserAnimation(56, thistile[1], thistile[2], false, -64)
  when :PathRight then $scene.spriteset.addUserAnimation(55, thistile[1], thistile[2], false, -64)
  end
end