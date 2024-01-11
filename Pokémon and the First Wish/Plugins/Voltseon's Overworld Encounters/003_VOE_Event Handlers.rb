def pbStartOverworldCapture(ballType, event, distance)
  oldname = event.character_name
  olddir = event.direction
  return if event.variable.nil?
  pkmn = event.variable.pokemon
  ball_graphics = {
    :POKEBALL => [2, 0],
    :GREATBALL => [2, 1],
    :ULTRABALL => [2, 2],
    :ORIGINBALL => [2, 3],
    :FEATHERBALL => [4, 0],
    :WINGBALL => [4, 1],
    :JETBALL => [4, 2],
    :HEAVYBALL => [6, 0],
    :LEADENBALL => [6, 1],
    :GIGATONBALL => [6, 2],
    :PREMIERBALL => [8, 0]
  }
  ballModifier = {
    :POKEBALL => 1,
    :GREATBALL => 1.5,
    :ULTRABALL => 2,
    :ORIGINBALL => Float::INFINITY,
    :FEATHERBALL => distance.to_f/3.0,
    :WINGBALL => distance.to_f/2.5,
    :JETBALL => distance.to_f/2.0,
    :HEAVYBALL => 1.5/distance.to_f,
    :LEADENBALL => 2.0/distance.to_f,
    :GIGATONBALL => 2.5/distance.to_f,
    :PREMIERBALL => 1
  }
  mod = (ballModifier[ballType] == Float::INFINITY ? 500 : ballModifier[ballType].round)
  catch_rate = pkmn.species_data.catch_rate * mod
  catch_rate *= 2 if $bag.has?(:CATCHINGCHARM)
  catch_rate *= event.variable.catchRateModifier
  event.character_name = "[FW] Balls"
  pbMoveRoute(event, [PBMoveRoute::StepAnimeOff])
  event.direction = ball_graphics[ballType][0]
  event.pattern = ball_graphics[ballType][1]
  event.lock_pattern = true
  pbMoveRoute(event,[PBMoveRoute::DirectionFixOn])
  x = (4 * catch_rate.to_f) / 6
  y = (65_536 / ((255.0 / x)**0.1875)).floor
  50.times do |i|
    $scene.update
    Graphics.update
    Input.update
    distance = (Math.sqrt(($game_player.x.to_f - event.x.to_f)**2 + ($game_player.y.to_f - event.y.to_f)**2)).round / 4
    if i % 10 != 0 || i == 0
      pbSEPlay("Battle ball shake", [75, 65, 55, 40, 27, 22, 15][distance]) if distance <= 6 && distance >= 0 && i%15 == 0
      next
    end
    if rand(65536) > y
      event.character_name = oldname
      event.direction = olddir
      event.lock_pattern = false
      pbSEPlay("Battle recall", [75, 65, 55, 40, 27, 22, 15][distance]) if distance <= 6 && distance >= 0
      pbMoveRoute(event,[PBMoveRoute::DirectionFixOff])
      break
    end
  end
  if event.character_name == "[FW] Balls"
    event.animation_id = 8
    60.times do
      $scene.update
      Graphics.update
      Input.update
    end
    $player.pokedex.register_caught(pkmn.species)
    pbStorePokemon(pkmn)
    pbItemBall(pbSelectPokedrop(pkmn.species), rand(2)+1) if rand(3) == 1 # 33.3% chance of dropping an item
    itemAnim(pkmn,1,true)
    event.lock_pattern = false
    pbMoveRoute(event,[PBMoveRoute::DirectionFixOff])
    pbDestroyOverworldEncounter(event, false, false)
  end
  pbMoveRoute(event, [PBMoveRoute::StepAnimeOn])
end

def pbGenerateOverworldEncounters
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  return if !$PokemonEncounters
  return if $player.able_pokemon_count == 0
  enc_types = []
  enc_types.push(:Land) if $PokemonEncounters.has_land_encounters? || $PokemonEncounters.has_cave_encounters?
  enc_types.push(:Water) if $PokemonEncounters.has_water_encounters?
  return if enc_types.empty?
  chosen_enc = enc_types.sample
  if VoltseonsOverworldEncounters.check_encounter_possibility(chosen_enc)
    enc_type = $PokemonEncounters.encounter_type
    enc_type = $PokemonEncounters.find_valid_encounter_type_for_time(chosen_enc, pbGetTimeNow) if enc_type.nil?
    return if enc_type.nil?
    tile = get_viable_tile(chosen_enc)
    return if tile == []
    pkmn = $PokemonEncounters.choose_wild_pokemon(enc_type)
    pkmn = Pokemon.new(pkmn[0],pkmn[1])
    echoln "Spawning #{pkmn.name}" if VoltseonsOverworldEncounters::LOG_SPAWNS
    pkmn.level = (pkmn.level + rand(-2..2)).clamp(2,GameData::GrowthRate.max_level)
    pkmn.calc_stats
    pkmn.reset_moves
    pkmn.shiny = rand(VoltseonsOverworldEncounters::SHINY_RATE) == 1
    # create event
    r_event = Rf.create_event do |e|
      e.name = "OverworldPkmn"
      e.x = tile[0]
      e.y = tile[1]
      e.pages[0].step_anime = true
      e.pages[0].trigger = 0
      e.pages[0].list.clear
      Compiler.push_script(e.pages[0].list, "pbInteractOverworldEncounter")
      Compiler.push_end(e.pages[0].list)
    end
    event = r_event[:event]
    event.setVariable(OverworldPokemon.new(pkmn, r_event, chosen_enc))
    if chosen_enc == :Water
      event.bush_depth = 12
      event.skip_bush_check = true
    end
    spriteset = $scene.spriteset($game_map.map_id)
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    if pkmn.shiny?
      pbSEPlay(VoltseonsOverworldEncounters::SHINY_SOUND, [75, 65, 55, 40, 27, 22, 15][dist], 100) if dist <= 6 && dist >= 0
      spriteset&.addUserAnimation(VoltseonsOverworldEncounters::SHINY_ANIMATION, event.x, event.y, true, 1)
    end
    pbChangeEventSprite(event,pkmn)
    event.direction = rand(1..4) * 2
    event.through = false
    spriteset&.addUserAnimation(VoltseonsOverworldEncounters::SPAWN_ANIMATION[(event.variable.terrain == :Land ? 0 : 1)], event.x, event.y, true, 1)
    GameData::Species.play_cry_from_pokemon(pkmn, [75, 65, 55, 40, 27, 22, 15][dist]) if dist <= 6 && dist >= 0 && rand(20) == 1
    VoltseonsOverworldEncounters.current_encounters += 1
    event.variable.terrain == :Land ? VoltseonsOverworldEncounters.current_encounters_land += 1 : VoltseonsOverworldEncounters.current_encounters_water += 1
  end
end

EventHandlers.add(:on_enter_map, :clear_previous_overworld_encounters,
  proc { |old_map_id|
    next if $game_map.map_id < 2
    next if old_map_id.nil? || old_map_id < 2
    next unless $MapFactory
    map = $MapFactory.getMapNoAdd(old_map_id)
    map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.character_name == "[FW] Balls"
      pbDestroyOverworldEncounter(event, true, false)
    end
    VoltseonsOverworldEncounters.current_encounters = 0
    VoltseonsOverworldEncounters.current_encounters_land = 0
    VoltseonsOverworldEncounters.current_encounters_water = 0
    pbGenerateOverworldEncounters
  }
)

EventHandlers.add(:on_new_spriteset_map, :fix_exisitng_overworld_encounters,
  proc {
    next if $game_map.map_id < 2
    next if !$PokemonEncounters
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.variable.nil?
      pkmn = event.variable.pokemon
      next if pkmn.nil?
      next if event.character_name == "[FW] Balls"
      pbChangeEventSprite(event,pkmn)
    end
  }
)

EventHandlers.add(:on_frame_update, :move_overworld_encounters,
  proc {
    next if $game_map.map_id < 2
    next if $PokemonSystem.owpkmnenabled==1
    next if $game_temp.in_menu
    next if !$PokemonEncounters
    $game_temp.frames_updated += 1
    next if $game_temp.frames_updated < 100
    $game_temp.frames_updated = 0
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.character_name == "[FW] Balls"
      next if event.variable.nil?
      pbPokemonIdle(event)
    end
    pbGenerateOverworldEncounters
  }
)

EventHandlers.add(:on_step_taken, :despawn_on_trainer,
  proc { |event|
    next if $game_map.map_id < 2
    next if !$scene.is_a?(Scene_Map)
    next if $PokemonSystem.owpkmnenabled==1
    next if $game_temp.in_menu
    next if !$PokemonEncounters
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      next if event.variable.nil?
      pbDestroyOverworldEncounter(event) if pbTrainersSeePkmn(event)
    end
  }
)