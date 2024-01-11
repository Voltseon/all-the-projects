EventHandlers.add(:on_enter_map, :clear_previous_overworld_encounters,
  proc { |old_map_id|
    next if $game_map.map_id < 2
    next if old_map_id.nil? || old_map_id < 2
    next unless $MapFactory
    map = $MapFactory.getMapNoAdd(old_map_id)
    map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      pbDistroyOverworldEncounter(event, true, false)
    end
    pbGenerateOverworldEncounters
  }
)

EventHandlers.add(:on_new_spriteset_map, :fix_exisitng_overworld_encounters,
  proc {
    next if $game_map.map_id < 2
    next if !$PokemonEncounters
    $game_map.events.each_value do |event|
      next unless event.name[/OverworldPkmn/i]
      pkmn = event.variable
      next if pkmn.nil?
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
      next if event.variable.nil?
      pbPokemonIdle(event)
    end
    next unless rand(8) == 1
    pbGenerateOverworldEncounters
  }
)

def appear_anim; return ($PokemonGlobal.diving ? 21 : 20); end

def pbGenerateOverworldEncounters
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  return if !$PokemonEncounters
  return if $player.able_pokemon_count == 0
  return if $PokemonGlobal.surfing
  $game_map.events.each_value do |event|
    next unless event.name[/OverworldPkmn/i]
    next unless event.variable.nil?
    tile = get_grass_tile
    next if tile == []
    enc_type = $PokemonEncounters.encounter_type
    enc_type = $PokemonEncounters.find_valid_encounter_type_for_time(:Land, pbGetTimeNow) if enc_type.nil?
    next if enc_type.nil?
    next if rand(3) == 1
    pkmn = $PokemonEncounters.choose_wild_pokemon(enc_type)
    pkmn = Pokemon.new(pkmn[0],pkmn[1], nil, false)
    pkmn.level = (pkmn.level + rand(-2..2)).clamp(2,GameData::GrowthRate.max_level)
    new_evo_mon = pbCheckEvolveDevolve(pkmn.species, pkmn.level)
    pkmn.species = new_evo_mon[0]
    pkmn.calc_stats
    if $player.murphyslaw
      pkmn.shiny = !player_has_balls
    end
    pkmn.reset_moves
    event.moveto(tile[0], tile[1])
    event.setVariable(pkmn)
    spriteset = $scene.spriteset($game_map.map_id)
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    if pkmn.shiny?
      pbSEPlay("Anim/PRSFX- Shiny", [75, 65, 55, 40, 27, 22, 15][dist], 100) if dist <= 6 && dist >= 0
      spriteset&.addUserAnimation(7, event.x, event.y, true, 1)
    end
    pbChangeEventSprite(event,pkmn)
    event.direction = rand(1..4) * 2
    event.through = false
    spriteset&.addUserAnimation(appear_anim, event.x, event.y, true, 1)
    GameData::Species.play_cry_from_pokemon(pkmn, [75, 65, 55, 40, 27, 22, 15][dist]*($PokemonSystem.owpkmn_volume/100)) if dist <= 6 && dist >= 0 && rand(20) == 1
    break if rand(2) == 1
  end
end

def pbInteractOverworldEncounter
  return if $PokemonGlobal.bridge>0
  $game_temp.overworld_encounter = true
  evt = pbMapInterpreter.get_self
  evt.lock
  pkmn = evt.variable
  return pbDistroyOverworldEncounter(evt) if pkmn.nil?
  GameData::Species.play_cry_from_pokemon(pkmn)
  name = pkmn.name
  name_half = (name.length.to_f / 2).ceil
  textcol = (pkmn.genderless?) ? "" : (pkmn.male?) ? "\\b" : "\\r"
  pbCallBub(2,evt.id)
  pbMessage(_INTL("{1}{2}!",textcol,name[0,name_half]+name[name_half]+name[name_half]))
  pkmn.reset_moves
  decision = WildBattle.start(pkmn)
  $game_temp.overworld_encounter = false
  pbDistroyOverworldEncounter(evt,decision == 4,decision != 4)
end

def pbTrainersSeePkmn
  result = false
  # If event is running
  return result if $game_system.map_interpreter.running?
  # All event loops
  $game_map.events.each_value do |event|
    next if !event.name[/trainer\((\d+)\)/i] && !event.name[/sight\((\d+)\)/i]
    distance = $~[1].to_i
    next if !pbEventCanReachPlayer?(event, self, distance)
    next if event.jumping? || event.over_trigger?
    result = true
  end
  return result
end

def get_grass_tile
  tile = []
  500.times do
    x = rand([$game_player.x-8,0].max...[$game_player.x+8,$game_map.width].max)
    y = rand([$game_player.y-8,0].max...[$game_player.y+8,$game_map.height].max)
    next if (x-$game_player.x).abs < 1
    next if (y-$game_player.y).abs < 1
    if ([:Grass, :TallGrass, :DeepSand, :UnderwaterGrass].include?($game_map.terrain_tag(x, y).id) || $PokemonEncounters.has_cave_encounters?) && $game_map.passable?(x, y, 0) && !$game_map.check_event(x,y)
      tile = [x, y]
      break
    end
  end
  return tile
end

def pbDistroyOverworldEncounter(event,animation=true,play_sound=false)
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  if play_sound
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    pbSEPlay("Door exit", [75, 65, 55, 40, 27, 22, 15][dist], 150) if dist <= 6 && dist >= 0
  end
  spriteset = $scene.spriteset($game_map.map_id)
  spriteset&.addUserAnimation(appear_anim, event.x, event.y, true, 1) if animation
  event.through = true
  event.setVariable(nil)
  event.character_name = ""
end

def pbPokemonIdle(evt)
  return if rand(3) == 1
  return if !evt
  return if evt.lock?
  return pbDistroyOverworldEncounter(evt) if evt.variable.nil?
  if rand(50)==1 || pbTrainersSeePkmn || (![:Grass, :TallGrass, :DeepSand].include?($game_map.terrain_tag(evt.x, evt.y).id) && !$PokemonEncounters.has_cave_encounters? && !$PokemonGlobal.diving) || ($game_map.terrain_tag(evt.x, evt.y).id != :UnderwaterGrass && $PokemonGlobal.diving)
    unless evt.variable.shiny?
      pbDistroyOverworldEncounter(evt)
      return
    end
  end
  evt.move_random
  dist = (((evt.x - $game_player.x).abs + (evt.y - $game_player.y).abs) / 4).floor
  pbDistroyOverworldEncounter(evt) if dist > 6 && !evt.variable.shiny?
  GameData::Species.play_cry_from_pokemon(evt.variable, [75, 65, 55, 40, 27, 22, 15][dist]*($PokemonSystem.owpkmn_volume/100)) if dist <= 6 && dist >= 0 && rand(20) == 1
end

def pbChangeEventSprite(event,pkmn)
  shiny = pkmn.shiny?
  shiny = pkmn.superVariant if (pkmn.respond_to?(:superVariant) && !pkmn.superVariant.nil? && pkmn.super_shiny?)
  form = pkmn.form
  form = 0 if pkmn.species == :MINIOR
  fname = GameData::Species.ow_sprite_filename(pkmn.species, form,
    pkmn.gender, shiny, pkmn.shadow, pkmn.super_shiny?)
  fname.gsub!("Graphics/Characters/", "")
  event.character_name = fname
  if event.move_route_forcing
    hue = pkmn.respond_to?(:superHue) && pkmn.super_shiny? ? pkmn.superHue : 0
    event.character_hue  = hue
  end
end

class Game_Temp
  attr_accessor :overworld_encounter
  attr_accessor :frames_updated

  def overworld_encounter
    @overworld_encounter = false if !@overworld_encounter
    return @overworld_encounter
  end

  def overworld_encounter=(val)
    @overworld_encounter = val
  end

  def frames_updated
    @frames_updated = 0 if !@frames_updated
    return @frames_updated
  end

  def frames_updated=(val)
    @frames_updated = val
  end
end