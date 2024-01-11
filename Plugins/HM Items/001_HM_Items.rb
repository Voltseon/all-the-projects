FLYITEM = :FLYITEM
SURFITEM = :FLOATIE
STRENGTHITEM = :PRESSUREPISTON
CUTITEM = :THINBLADE
ROCKSMASHITEM = :STURDYPICKAXE
FLASHITEM = :LANTERN

####################
# Strength
####################
ItemHandlers::UseInField.add(STRENGTHITEM, proc { |item|
    $game_temp.in_menu = false
    pbStrength
    next true
})
  
ItemHandlers::UseFromBag.add(STRENGTHITEM, proc { |item|
    facingEvent = $game_player.pbFacingEvent
    next 2 if facingEvent && facingEvent.name[/strengthboulder/i]
})

####################
# Surf
####################
ItemHandlers::UseInField.add(SURFITEM, proc { |item|
    $game_temp.in_menu = false
    pbSurf
    next true
})
  
ItemHandlers::UseFromBag.add(SURFITEM, proc { |item|
    next if $PokemonGlobal.surfing
    next if GameData::MapMetadata.exists?($game_map.map_id) &&
            GameData::MapMetadata.get($game_map.map_id).always_bicycle
    next if !$game_player.pbFacingTerrainTag.can_surf_freely
    next if !$game_map.passable?($game_player.x,$game_player.y,$game_player.direction,$game_player)
    next 2
})

####################
# Rock Smash
####################
ItemHandlers::UseInField.add(ROCKSMASHITEM, proc { |item|
    pbRockSmash
    next true
})
  
ItemHandlers::UseFromBag.add(ROCKSMASHITEM, proc { |item|
    next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_ROCKSMASH,true)
    facingEvent = $game_player.pbFacingEvent
    if !facingEvent || !facingEvent.name[/smashrock/i]
        pbMessage(_INTL("Can't use that here.")) if true
        next false
    end
    next 2
})

####################
# Cut
####################
ItemHandlers::UseInField.add(CUTITEM, proc { |item|
    pbCut
    next true
})
  
ItemHandlers::UseFromBag.add(CUTITEM, proc { |item|
    next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_CUT,true)
  facingEvent = $game_player.pbFacingEvent
  if !facingEvent || !facingEvent.name[/cuttree/i]
    pbMessage(_INTL("Can't use that here.")) if true
    next false
  end
    next 2
})

####################
# Fly
####################
ItemHandlers::UseInField.add(FLYITEM, proc { |item|
    if !$PokemonTemp.flydata
        pbMessage(_INTL("Can't use that here."))
        next false
      end
      pbFadeOutIn {
        $game_temp.player_new_map_id    = $PokemonTemp.flydata[0]
        $game_temp.player_new_x         = $PokemonTemp.flydata[1]
        $game_temp.player_new_y         = $PokemonTemp.flydata[2]
        $game_temp.player_new_direction = 2
        $PokemonTemp.flydata = nil
        $scene.transfer_player
        $game_map.autoplay
        $game_map.refresh
      }
      pbEraseEscapePoint
      next true
})
  
ItemHandlers::UseFromBag.add(FLYITEM, proc { |item|
    next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLY,true)
  if $game_player.pbHasDependentEvents?
    pbMessage(_INTL("It can't be used when you have someone with you.")) if true
    next false
  end
  if !GameData::MapMetadata.exists?($game_map.map_id) ||
     !GameData::MapMetadata.get($game_map.map_id).outdoor_map
    pbMessage(_INTL("Can't use that here.")) if true
    next false
  end
    next 2
})

####################
# Flash
####################
ItemHandlers::UseInField.add(FLASHITEM, proc { |item|
      darkness = $PokemonTemp.darknessSprite
  next false if !darkness || darkness.disposed?
  $PokemonGlobal.flashUsed = true
  radiusDiff = 8*20/Graphics.frame_rate
  while darkness.radius<darkness.radiusMax
    Graphics.update
    Input.update
    pbUpdateSceneMap
    darkness.radius += radiusDiff
    darkness.radius = darkness.radiusMax if darkness.radius>darkness.radiusMax
  end
  next true
})
  
ItemHandlers::UseFromBag.add(FLASHITEM, proc { |item|
    next false if !pbCheckHiddenMoveBadge(Settings::BADGE_FOR_FLASH,true)
    if !GameData::MapMetadata.exists?($game_map.map_id) ||
        !GameData::MapMetadata.get($game_map.map_id).dark_map
        pbMessage(_INTL("Can't use that here.")) if true
        next false
    end
    if $PokemonGlobal.flashUsed
        pbMessage(_INTL("Flash is already being used.")) if true
        next false
    end
    next 2
})