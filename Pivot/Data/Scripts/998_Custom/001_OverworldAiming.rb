EventHandlers.add(:on_frame_update, :overworld_aiming,
  proc {
    next if pbMapInterpreterRunning?
    next if $game_player.moving?
    next if $PokemonGlobal.sliding
    next if $PokemonGlobal.fishing
    next if $game_player.on_middle_of_stair?
    next unless $game_switches[79]
    next if $game_temp.in_menu
    next if $player.has_state
    next if $player.current_hp < 1
    next if !$game_temp.in_a_match && !$game_temp.training
    Mouse.update
    if Mouse.press?(nil,:right) && !$scene.active_hud.pause_menu_showing
      next unless Input.dir8==0
      stopAiming if !startAiming
    else
      stopAiming
    end
  }
)

def startAiming
  return true if $scene.active_hud.aiming
  Mouse.hideCursor
  $game_player.clear_stair_data
  mousepos = Mouse.getMousePos(true)
  mousepos[0] -= Graphics.width / 2
  mousepos[1] -= Graphics.height / 2
  return false if mousepos[0].abs < 32 && mousepos[1].abs < 32
  return true if Input.release?(Input::MOUSERIGHT)
  $scene.active_hud.aiming = true
end

def stopAiming
  return false unless $scene.active_hud.aiming
  Mouse.showCursor
  $scene.active_hud.aiming = false
  $scene.active_hud.aim_offset = [0,0]
  pbCameraReset(2)
end