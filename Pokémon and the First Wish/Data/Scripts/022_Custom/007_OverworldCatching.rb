EventHandlers.add(:on_frame_update, :overworld_catching,
  proc {
    next if pbMapInterpreterRunning?
    if Mouse.scroll_direction > 0
      $scene.active_hud.swapBall(false)
    elsif Mouse.scroll_direction < 0
      $scene.active_hud.swapBall
    end
    next if $game_player.moving?
    next if $PokemonGlobal.sliding
    next if $PokemonGlobal.fishing
    next if $game_player.on_middle_of_stair?
    next if $game_temp.in_menu
    Mouse.update
    if Mouse.press?(nil,:right)
      next unless Input.dir4==0
      stopAiming if !startAiming
    else
      stopAiming
    end
  }
)

def startAiming
  return true if $scene.active_hud.aiming
  $game_player.clear_stair_data
  mousepos = Mouse.getMousePos(true)
  return false if mousepos[0].abs < 3 && mousepos[1].abs < 3
  return true if Input.release?(Input::MOUSERIGHT)
  $scene.active_hud.aiming = true
end

def stopAiming
  return false unless $scene.active_hud.aiming
  $scene.active_hud.aiming = false
  $scene.active_hud.showPause
  $scene.active_hud.showParty
  $game_player.lock_pattern = false
  $scene.active_hud.aim_offset = [0,0]
  $game_player.set_movement_type($PokemonGlobal.bicycle ? :cycling : $PokemonGlobal.surfing ? :surfing : :walking)
  $game_player.center($game_player.x, $game_player.y)
end

Battle::PokeBallEffects::ModifyCatchRate.add(:FEATHERBALL, proc { |ball, catchRate, battle, battler|
  mod = 1
  mod = 1.25 if battler.pokemon.types.include?(:FLYING)
  next catchRate * mod
})

Battle::PokeBallEffects::ModifyCatchRate.add(:WINGBALL, proc { |ball, catchRate, battle, battler|
  mod = 1.25
  mod = 2 if battler.pokemon.types.include?(:FLYING)
  next catchRate * mod
})

Battle::PokeBallEffects::ModifyCatchRate.add(:JETBALL, proc { |ball, catchRate, battle, battler|
  mod = 2
  mod = 2.75 if battler.pokemon.types.include?(:FLYING)
  next catchRate * mod
})

Battle::PokeBallEffects::ModifyCatchRate.add(:HEAVYBALL, proc { |ball, catchRate, battle, battler|
  mod = 1
  battle.allSameSideBattlers.each { |b| mod = 1.25 if b.species_data.weight < battler.pokemon.species_data.weight }
  next catchRate * mod
})

Battle::PokeBallEffects::ModifyCatchRate.add(:LEADENBALL, proc { |ball, catchRate, battle, battler|
  mod = 1.75
  battle.allSameSideBattlers.each { |b| mod = 2 if b.species_data.weight < battler.pokemon.species_data.weight }
  next catchRate * mod
})

Battle::PokeBallEffects::ModifyCatchRate.add(:GIGATONBALL, proc { |ball, catchRate, battle, battler|
  mod = 2.5
  battle.allSameSideBattlers.each { |b| mod = 2.75 if b.species_data.weight < battler.pokemon.species_data.weight }
  next catchRate * mod
})

Battle::PokeBallEffects::IsUnconditional.add(:ORIGINBALL, proc { |ball, battle, battler|
  next true
})