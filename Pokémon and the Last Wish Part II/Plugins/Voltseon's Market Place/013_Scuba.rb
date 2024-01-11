def vStartScuba
  pbCancelVehicles
  $PokemonEncounters.reset_step_count
  $PokemonGlobal.scuba = true
  pbUpdateVehicle
end

def vEndScuba
  pbCancelVehicles
  $PokemonEncounters.reset_step_count
  $PokemonGlobal.scuba = false
  pbUpdateVehicle
end

Events.onStepTaken += proc { |_sender,_e|
  $scene.spriteset.addUserAnimation(24,$game_player.x-1,$game_player.y-2,true,3) if $PokemonGlobal.scuba
}