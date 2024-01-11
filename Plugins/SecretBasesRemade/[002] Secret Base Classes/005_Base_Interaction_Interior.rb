def add_decorations_to_base(decor_id,x,y)
  base = $PokemonGlobal.secret_base_list[0]
  base.add_decoration(decor_id,x,y)
end

def pbSecretBasePC
  pbSEPlay("PC open")
  this_event = pbMapInterpreter.get_self
  this_event.turn_down
  pbWait(4)
  this_event.turn_left
  pbWait(4)
  this_event.turn_down
  pbWait(4)
  this_event.turn_left
  pbWait(4)
  this_event.turn_down
  pbWait(4)
  this_event.turn_left
  if SecretBaseMethods.is_player_base?($PokemonMap.current_base_id)
    pbSecretBasePCMenu
  else
    pbSecretBasePCRegisterMenu
  end
  pbSEPlay("PC close") if $PokemonMap.current_base_id
  this_event.turn_down
end

def pbSecretBasePCMenu
  pbMessage(_INTL("{1} booted up the PC.", $player.name))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:secret_base_pc_menu) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("What do you want to do?"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
end

MenuHandlers.add(:secret_base_pc_menu, :decoration, {
  "name"      => _INTL("Decoration"),
  "order"     => 10,
  "effect"    => proc { |menu|
    pbDecorationMenu
    next false
  }
})

MenuHandlers.add(:secret_base_pc_menu, :pack_up, {
  "name"      => _INTL("Pack Up"),
  "order"     => 20,
  "effect"    => proc { |menu|
    player_base = $PokemonGlobal.secret_base_list[0]
    base_data = GameData::SecretBase.get(player_base.id)
    pbMessage(_INTL("All decorations and furniture in your Secret Base will be returned to your PC.\\1"))
    if pbConfirmMessage(_INTL("Is that okay?"))
      # Pack up the base.
      pbFadeOutIn(99999) {
        player_base.remove_decorations((0...SecretBaseSettings::SECRET_BASE_MAX_DECORATIONS).to_a)
        $secret_bag.unplace_all
        player_base.id = nil
        $stats.moved_secret_base_count+=1
        $game_temp.player_transferring   = true
        $game_temp.transition_processing = true
        $game_temp.player_new_map_id    = base_data.location[0]
        $game_temp.player_new_x         = base_data.location[1]
        $game_temp.player_new_y         = base_data.location[2]+1
        $game_temp.player_new_direction = 2
        $scene.transfer_player
      }
      next true
    end
    next false
  }
})

MenuHandlers.add(:secret_base_pc_menu, :exit, {
  "name"      => _INTL("Exit"),
  "order"     => 30,
  "effect"    => proc { |menu| next true }
})

def pbSecretBasePCRegisterMenu
  pbMessage(_INTL("{1} booted up the PC.", $player.name))
  # Get all commands
  command_list = []
  commands = []
  MenuHandlers.each_available(:secret_base_pc_register_menu) do |option, hash, name|
    command_list.push(name)
    commands.push(hash)
  end
  # Main loop
  command = 0
  loop do
    choice = pbMessage(_INTL("What do you want to do?"), command_list, -1, nil, command)
    if choice < 0
      pbPlayCloseMenuSE
      break
    end
    break if commands[choice]["effect"].call
  end
end

MenuHandlers.add(:secret_base_pc_register_menu, :information, {
  "name"      => _INTL("Information"),
  "order"     => 30,
  "effect"    => proc { |menu|
    pbMessage(INTL("Once registered, a Secret Base will not\ndisappear unless the other Trainer\\1moves it to a different location.\\1"))
    pbMessage(INTL("If a Secret Base is deleted from the\nregistered list, another one may take its place.\\1"))
    pbMessage(INTL("Up to ten Secret Base locations\nmay be registered."))
    next false
  }
})

MenuHandlers.add(:secret_base_pc_register_menu, :exit, {
  "name"      => _INTL("Exit"),
  "order"     => 40,
  "effect"    => proc { |menu| next true }
})