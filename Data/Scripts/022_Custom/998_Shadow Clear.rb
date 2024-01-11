class Game_Temp
  attr_accessor :shadow_clear
  attr_accessor :opaque

  def shadow_clear?
    return @shadow_clear && !@opaque
  end
end

def pbShadowClear
  $game_temp.shadow_clear = !$game_temp.shadow_clear
  unless $game_temp.shadow_clear
    $game_player.opacity = 255
    FollowingPkmn.get_event.opacity = 255 if FollowingPkmn.get_event
  end
end

EventHandlers.add(:on_frame_update, :shadow_clear,
  proc {
    next unless $scene.is_a?(Scene_Map)
    next unless $PokemonGlobal
    next unless $game_player
    next if $game_map.map_id < 2
    next if $PokemonGlobal.bicycle
    next if $PokemonGlobal.mounted_pkmn > -1
    next unless $game_temp.shadow_clear
    $game_temp.opaque = $game_player.move_speed > 3 || pbMapInterpreterRunning?
    $game_player.opacity = $game_temp.opaque ? 160 : 64
    FollowingPkmn.get_event.opacity = $game_player.opacity if FollowingPkmn.get_event
  }
)