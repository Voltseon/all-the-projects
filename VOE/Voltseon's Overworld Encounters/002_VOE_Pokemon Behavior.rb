def pbInteractOverworldEncounter
  return if $PokemonGlobal.bridge>0
  $game_temp.overworld_encounter = true
  evt = pbMapInterpreter.get_self
  evt.lock
  pkmn = evt.variable[0]
  return pbDestroyOverworldEncounter(evt) if pkmn.nil?
  GameData::Species.play_cry_from_pokemon(pkmn)
  name = pkmn.name
  name_half = (name.length.to_f / 2).ceil
  textcol = (pkmn.genderless?) ? "" : (pkmn.male?) ? "\\b" : "\\r"
  pbMessage(_INTL("{1}{2}!",textcol,name[0,name_half]+name[name_half]+name[name_half]))
  decision = WildBattle.start(pkmn)
  $game_temp.overworld_encounter = false
  pbDestroyOverworldEncounter(evt,decision == 4,decision != 4)
end

def pbTrainersSeePkmn(evt)
  result = false
  # If event is running
  return result if $game_system.map_interpreter.running?
  # All event loops
  $game_map.events.each_value do |event|
    next if !event.name[/trainer\((\d+)\)/i] && !event.name[/sight\((\d+)\)/i]
    distance = $~[1].to_i
    next if !pbEventCanReachPlayer?(event, evt, distance)
    next if event.jumping? || event.over_trigger?
    result = true
  end
  return result
end

def get_grass_tile
  possible_tiles = []
  possible_distance = (VoltseonsOverworldEncounters::MAX_DISTANCE*0.75).round
  (($game_player.x-possible_distance)..($game_player.x+possible_distance)).each do |x|
    # Don't check if out of bounds
    next if x < 0 || x >= $game_map.width
    (($game_player.y-possible_distance)..($game_player.y+possible_distance)).each do |y|
      # Don't check if out of bounds
      next if y < 0 || y >= $game_map.height
      # Don't check if on top of the player
      next if x == $game_player.x && y == $game_player.y
      # Don't spawn on impassable tiles
      next unless $game_map.passable?(x, y, 0)
      # Don't spawn if on top of an event
      on_top = false
      $game_map.events.each_value do |event|
        next unless event.at_coordinate?(x, y)
        on_top = true
        break
      end
      next if on_top
      # Don't spawn if a trainer can see it
      next if pbTrainersSeePkmn(Temp_Event.new(x, y))
      # Spawn only if on an encounter tile
      next unless VoltseonsOverworldEncounters::GRASS_TILES.include?($game_map.terrain_tag(x, y).id) || $PokemonEncounters.has_cave_encounters?
      # Add to possible tiles
      possible_tiles.push([x,y])
    end
  end
  return (possible_tiles.empty? ? [] : possible_tiles.sample)
end

def pbDestroyOverworldEncounter(event,animation=true,play_sound=false)
  return if $scene.is_a?(Scene_Intro) || $scene.is_a?(Scene_DebugIntro)
  return if event.variable.nil?
  echoln "Despawning #{event.variable[0].name}" if VoltseonsOverworldEncounters::LOG_SPAWNS
  if play_sound
    dist = (((event.x - $game_player.x).abs + (event.y - $game_player.y).abs) / 4).floor
    pbSEPlay(VoltseonsOverworldEncounters::FLEE_SOUND, [75, 65, 55, 40, 27, 22, 15][dist], 150) if dist <= 6 && dist >= 0
  end
  spriteset = $scene.spriteset($game_map.map_id)
  spriteset&.addUserAnimation(VoltseonsOverworldEncounters::SPAWN_ANIMATION, event.x, event.y, true, 1) if animation
  if VoltseonsOverworldEncounters::DELETE_EVENTS
    Rf.delete_event(event.variable[1])
  else
    event.setVariable(nil)
    event.moveto(0,0)
    event.through = true
    event.character_name = ""
  end
  VoltseonsOverworldEncounters.current_encounters -= 1
end

def pbDistanceToPlayer(evt)
  return if !evt
  dx = evt.x - $game_player.x
  dy = evt.y - $game_player.y
  return Math.sqrt(dx*dx + dy*dy).round
end

def pbPokemonIdle(evt)
  return if rand(3) == 1
  return if !evt
  return if evt.lock?
  return pbDestroyOverworldEncounter(evt) if evt.variable.nil?
  if rand(50)==1 || (!VoltseonsOverworldEncounters::GRASS_TILES.include?($game_map.terrain_tag(evt.x, evt.y).id) && !$PokemonEncounters.has_cave_encounters? && !$PokemonGlobal.diving) || ($game_map.terrain_tag(evt.x, evt.y).id != :UnderwaterGrass && $PokemonGlobal.diving)
    unless evt.variable[0].shiny?
      pbDestroyOverworldEncounter(evt)
      return
    end
  end
  evt.move_random
  dist = (((evt.x - $game_player.x).abs + (evt.y - $game_player.y).abs) / 4).floor
  pbDestroyOverworldEncounter(evt) if pbDistanceToPlayer(evt) > VoltseonsOverworldEncounters::MAX_DISTANCE && !evt.variable[0].shiny?
  GameData::Species.play_cry_from_pokemon(evt.variable[0], [75, 65, 55, 40, 27, 22, 15][dist]) if dist <= 6 && dist >= 0 && rand(20) == 1
end

def pbChangeEventSprite(event,pkmn)
  shiny = pkmn.shiny?
  shiny = pkmn.superVariant if (pkmn.respond_to?(:superVariant) && !pkmn.superVariant.nil? && pkmn.super_shiny?)
  fname = ""
  if PluginManager.installed?("Essentials Deluxe")
    fname = GameData::Species.check_graphic_file("Graphics/Characters/", {:species => pkmn.species, :form => pkmn.form, :gender => pkmn.gender, :shiny => shiny, :shadow => pkmn.shadow}, "Followers")
  else
    fname = GameData::Species.check_graphic_file("Graphics/Characters/", pkmn.species, pkmn.form, pkmn.gender, shiny, pkmn.shadow, "Followers")
  end
  raise "Following Pokémon sprites were not found." if nil_or_empty?(fname)
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

class Temp_Event
  attr_reader :x, :y
  def initialize(x, y)
    @x = x
    @y = y
  end
end