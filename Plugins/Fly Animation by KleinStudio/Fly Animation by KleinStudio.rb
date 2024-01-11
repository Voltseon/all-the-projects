#===============================================================================
# ■ Fly Animation by KleinStudio
# http://pokemonfangames.com
#===============================================================================
# bo4p5687 (update)
#===============================================================================
BIRD_ANIMATION_TIME = 10
def pbFlyToNewLocation(pkmn = nil, move = :FLY)
  return false if $game_temp.fly_destination.nil?
  pkmn = $player.get_pokemon_with_move(move) if !pkmn
  if !pkmn || !pbHiddenMoveAnimation(pkmn)
    name = pkmn&.name || $player.name
    pbMessage(_INTL("{1} used {2}!", name, GameData::Move.get(move).name))
  end
  old_toggled = $PokemonGlobal.follower_toggled
  FollowingPkmn.toggle_off
  $stats.fly_count += 1
	pbFlyAnimation
  pbFadeOutIn {
    $game_temp.skip_tip = true
    pbSEPlay("flybird")
    $game_temp.player_new_map_id    = $game_temp.fly_destination[0]
    $game_temp.player_new_x         = $game_temp.fly_destination[1]
    $game_temp.player_new_y         = $game_temp.fly_destination[2]
    $game_temp.player_new_direction = 2
    $game_temp.fly_destination = nil
    $scene.transfer_player
    $game_map.autoplay
    $game_map.refresh
    yield if block_given?
    pbWait(Graphics.frame_rate / 4)
  }
  FollowingPkmn.toggle(old_toggled, false)
	pbFlyAnimation(false)
  pbEraseEscapePoint
  return true
end
class Game_Character
  def set_opacity(value)
    @opacity = value
  end
end
def pbFlyAnimation(landing = true)
  if landing
    $game_player.turn_left
    pbSEPlay("flybird")
  end
	width  = Settings::SCREEN_WIDTH
	height = Settings::SCREEN_HEIGHT
	viewport = Viewport.new(0, 0, width, height)
  viewport.z = 999990
  flybird = Sprite.new(viewport)
  flybird.bitmap = RPG::Cache.picture("flybird")
  flybird.ox = flybird.bitmap.width/2
  flybird.oy = flybird.bitmap.height/2
  flybird.x  = width + flybird.bitmap.width
  flybird.y  = height/4
  loop do
    pbUpdateSceneMap
    if flybird.x > (width / 2 + 10)
      flybird.x -= (width + flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
      flybird.y -= (height / 4 - height / 2).div BIRD_ANIMATION_TIME
    elsif flybird.x <= (width / 2 + 10) && flybird.x >= 0
      flybird.x -= (width + flybird.bitmap.width - width / 2).div BIRD_ANIMATION_TIME
      flybird.y += (height / 4 - height / 2).div BIRD_ANIMATION_TIME
      $game_player.set_opacity(landing ? 0 : 255)
    else
      break
    end
    Graphics.update
  end
  flybird.dispose
	viewport.dispose
end