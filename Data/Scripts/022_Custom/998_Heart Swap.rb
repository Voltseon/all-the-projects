AVAILABLE_CHARACTERS = [
  "[SL] Annie", "[SL] Arnold", "[SL] Ashley", "[SL] Borad", "[SL] Derek", "[SL] Dev-ENLS", "[SL] Dev-Tristan", "[SL] Dev-Voltseon",
  "[SL] Hashil", "[SL] Herman", "[SL] Ingrid", "[SL] Jackson", "[SL] June", "[SL] Liz", "[SL] Marguerite", "[SL] Mother_0", "[SL] Mother_1",
  "[SL] Mother_2", "[SL] Olaf", "[SL] Old Rocket", "[SL] Optus", "[SL] Pascal", "[SL] Professor Orchid", "[SL] Radsel", "[SL] Rocket Grunt F",
  "[SL] Rocket Grunt M", "[SL] Silver Distorted", "[SL] Silver", "[SL] Susanne", "[SL] Tommy", "[SL] Tyler", "[SL] Upsilon",
  "NPC 01", "NPC 02", "NPC 03", "NPC 04", "NPC 05", "NPC 06", "NPC 07", "NPC 08", "NPC 09", "NPC 10", "NPC 11", "NPC 12",
  "NPC 14", "NPC 15", "NPC 16", "NPC 17", "NPC 18", "NPC 19", "NPC 20", "NPC 21", "NPC 22", "NPC 23", "NPC 24", "NPC 25", "NPC 26",
  "NPC 27", "NPC 28", "NPC 29", "NPC 31", "NPC 32", "NPC 33", "NPC 34"
]

AVAILABLE_PARTS = [
  "trchar", "pokemon_"
]

EXCLUDE_CHARACTERS = [
  "trchar046_1", "trchar045", "trchar045_1", "trchar046"
]

class Game_Temp
  attr_accessor :heart_swapped
  attr_accessor :heart_swap_character
end

EventHandlers.add(:on_map_or_spriteset_change, :end_heart_swap,
  proc {
    |scene, _map_changed|
    next if !scene || !scene.spriteset
    pbResetHeartSwap
  }
)

def pbHeartSwap
  swapped = $game_temp.heart_swapped
  # get closest event to the player with a valid character_name
  closest_event = nil
  $game_map.events.each_value do |event|
    next if event.character_name.empty?
    next if EXCLUDE_CHARACTERS.include?(event.character_name)
    next if !AVAILABLE_CHARACTERS.include?(event.character_name) && !AVAILABLE_PARTS.any? { |part| event.character_name.include?(part) }
    next if closest_event && distance_between_events($game_player, event) > distance_between_events($game_player, closest_event)
    closest_event = event
  end
  swapped = !closest_event.nil?
  $game_temp.heart_swapped = swapped
  if swapped
    $game_temp.heart_swap_character = [closest_event.map.map_id, closest_event.id]
    $game_player.character_name = closest_event.character_name
    $game_player.character_hue = closest_event.character_hue
  else
    pbResetHeartSwap
  end
end

def distance_between_events(event1, event2)
  return Math.sqrt((event1.x - event2.x)**2 + (event1.y - event2.y)**2)
end

def pbResetHeartSwap
  return unless $game_temp.heart_swapped
  $game_temp.heart_swapped = false
  $game_player.character_name = GameData::PlayerMetadata.get($player&.character_ID || 1).walk_charset
  $game_player.character_hue = 0
  $game_temp.heart_swap_character = [0, 0]
end