module SecretBaseMethods
  # @return [Boolean] the if this base has an active id
  def self.is_active_secret_base?(base_id)
    return false unless base_id
    return $PokemonGlobal.secret_base_list.any? {|base| base.id == base_id}
  end
  
  # @return [SecretBase, nil] the active base with this id
  def self.get_base_from_id(base_id)
    return nil unless base_id
    return $PokemonGlobal.secret_base_list.find {|base| base.id == base_id}
  end
  def self.is_player_base?(base_id)
    return false unless base_id
    return $PokemonGlobal.secret_base_list[0].id == base_id
  end
end

def pbGetPlayerBaseLocation(mapname=-1,mapid=-1)
  player_base = $PokemonGlobal.secret_base_list[0]
  if player_base.id.nil?
    location = -1
  else
    location = GameData::SecretBase.get(player_base.id).location[0]
  end
  name = (location > 0) ? pbGetMapNameFromId(location) : ""
  pbSet(mapid,location) if mapid>0
  pbSet(mapname,name) if mapname>0
  return [name, location]
end

# This method is the player touch warp stuff
def pbSecretBase(base_id)
  # No warps if the player isn't entering facing up
  return if $game_player.direction != 8
  # No warps if the base is closed
  return if !SecretBaseMethods.is_active_secret_base?(base_id)
  base_data = GameData::SecretBase.get(base_id)
  template_data = GameData::SecretBaseTemplate.get(base_data.map_template)
  dx,dy = template_data.door_location
  # set current_base_id so secret base setup can proceed.
  pbFadeOutIn(99999){
    $PokemonMap.current_base_id = base_id
    $game_temp.player_transferring   = true
    $game_temp.transition_processing = true
    $game_temp.player_new_map_id    = SecretBaseSettings::SECRET_BASE_MAP
    $game_temp.player_new_x         = dx
    $game_temp.player_new_y         = dy-1
    $game_temp.player_new_direction = 8
    $scene.transfer_player
    # it gets reset when we enter a map, but we still need to know this value.
    $PokemonMap.current_base_id = base_id
  }
end

# This is the method for the talk to base.
def pbNewSecretBase(base_id)
  # no prompt if this is an open base.
  return if SecretBaseMethods.is_active_secret_base?(base_id)
  move = SecretBaseSettings::SECRET_BASE_MOVE_NEEDED
  movefinder = $player.get_pokemon_with_move(move)
  base_data = GameData::SecretBase.get(base_id)
  template_data = GameData::SecretBaseTemplate.get(base_data.map_template)
  messages_anim = SecretBaseSettings::SECRET_BASE_MESSAGES_ANIM[template_data.type]
  if (!$DEBUG && !movefinder)
    # No mon that can use the Secret Base Move, abort.
    pbMessage(_INTL(messages_anim[0]))
    return
  end
  player_base = $PokemonGlobal.secret_base_list[0]
  moved_bases = false
  if player_base.id && player_base.id != base_id
    # semi-redundant check, but if the player has a base at all (id is not nil), and it's not this one.
    map_name = pbGetMapNameFromId(GameData::SecretBase.get(player_base.id).location[0])
    pbMessage(_INTL("You may only make one Secret Base.\\1"))
    if pbConfirmMessage(_INTL("Would you like to move from the Secret Base near {1}?",map_name))
      pbMessage(_INTL("All decorations and furniture in your Secret Base will be returned to your PC.\\1"))
      if pbConfirmMessage(_INTL("Is that okay?"))
        # Pack up the base.
        pbFadeOutIn {
          player_base.remove_decorations((0...SecretBaseSettings::SECRET_BASE_MAX_DECORATIONS).to_a)
          $secret_bag.unplace_all
          player_base.id = nil
        }
        pbMessage(_INTL("Moving completed.\\1"))
        $stats.moved_secret_base_count+=1
        moved_bases = true
      else
        return
      end
    else
      return
    end
  end
  if !moved_bases
    pbMessage(_INTL(messages_anim[0]+"\\1"))
  end
  # Now we ask to use the Secret Base Move.
  if pbConfirmMessage(_INTL("Would you like to use the {1}?",GameData::Move.get(move).name))
    speciesname = (movefinder) ? movefinder.name : $player.name
    pbMessage(_INTL("{1} used {2}!", speciesname, GameData::Move.get(move).name))
    pbHiddenMoveAnimation(movefinder)
    _, x, y = pbFacingTile
    spriteset = $scene.spriteset($game_map.map_id)
    spriteset&.addUserAnimation(messages_anim[2], x, y, true, 1)
    pbWait(10)
    # set so that it will appear during the animation
    $PokemonMap.current_base_id = base_id if messages_anim[3]
    pbWait(20)
    $PokemonMap.current_base_id = base_id
    pbMessage(_INTL(messages_anim[1]))
    pbSEPlay("Door Exit", 80, 100)
    dx,dy = template_data.door_location
    pbFadeOutIn(99999){
      $game_temp.player_transferring   = true
      $game_temp.transition_processing = true
      $game_temp.player_new_map_id    = SecretBaseSettings::SECRET_BASE_MAP
      $game_temp.player_new_x         = dx
      $game_temp.player_new_y         = dy-1
      $game_temp.player_new_direction = 8
      $scene.transfer_player
    }
    move_route=[]
    template_data.preview_steps.times do
      move_route.push(PBMoveRoute::Up)
    end
    pbMoveRoute($game_player,move_route)
    loop do
      Graphics.update
      Input.update
      pbUpdateSceneMap
      break unless $game_player.move_route_forcing
    end
    if !pbConfirmMessage(_INTL("Want to make your Secret Base here?"))
      pbFadeOutIn(99999){
        $game_temp.player_transferring   = true
        $game_temp.transition_processing = true
        $game_temp.player_new_map_id    = base_data.location[0]
        $game_temp.player_new_x         = base_data.location[1]
        $game_temp.player_new_y         = base_data.location[2]+1
        $game_temp.player_new_direction = 2
        $scene.transfer_player
      }
    else
      px,py = template_data.pc_location
      pbFadeOutIn(99999){
        $PokemonMap.current_base_id = base_id
        player_base.id = base_id
        $game_temp.player_transferring   = true
        $game_temp.transition_processing = true
        $game_temp.player_new_map_id    = SecretBaseSettings::SECRET_BASE_MAP
        $game_temp.player_new_x         = px
        $game_temp.player_new_y         = py+1
        $game_temp.player_new_direction = 8
        $scene.transfer_player
      }
    end
  end
end

EventHandlers.add(:on_player_interact, :secret_base_event,
  proc {
    next if $game_player.direction!=8 # must face up
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/SecretBase\((\w+)\)/]
      pbNewSecretBase($~[1].to_sym)
    end
  }
)

HiddenMoveHandlers::CanUseMove.add(SecretBaseSettings::SECRET_BASE_MOVE_NEEDED,
  proc { |move, pkmn, showmsg|
    if $game_player.direction!=8
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
    facingEvent = $game_player.pbFacingEvent
    if !facingEvent || !facingEvent.name[/SecretBase\(\w+\)/]
      pbMessage(_INTL("You can't use that here.")) if showmsg
      next false
    end
    next true
  }
)

HiddenMoveHandlers::UseMove.add(SecretBaseSettings::SECRET_BASE_MOVE_NEEDED,
  proc { |move, pokemon|
    facingEvent = $game_player.pbFacingEvent
    if facingEvent && facingEvent.name[/SecretBase\((\w+)\)/]
      pbNewSecretBase($~[1].to_sym)
    end
  }
)