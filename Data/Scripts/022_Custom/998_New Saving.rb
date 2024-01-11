MAP_DATA_VARIABLE = 100

class << Game
  alias oldsave save
  def save(*args)
    map_data = []
    $game_map.events.each do |event|
      next if (event[1].x == event[1].original_x && event[1].y == event[1].original_y) || event[1].erased
      map_data.push([event[0], event[1].x, event[1].y, event[1].direction, event[1].erased])
    end
    pbSet(MAP_DATA_VARIABLE, map_data)
    oldsave(*args)
  end

  alias oldload load
  def load(*args)
    oldload(*args)
    unless nil_or_empty?($TempFileName)
      $player.save_file_name = $TempFileName
      $TempFileName = ""
    end
    map_data = pbGet(MAP_DATA_VARIABLE)
    return unless map_data.is_a?(Array)
    map_data.each do |event_data|
      event = pbMapInterpreter.get_character(event_data[0])
      next unless event.is_a?(Game_Event)
      event.moveto(event_data[1], event_data[2])
      event.direction = event_data[3]
      if event_data[4]
        event.erase
        $PokemonMap&.addErasedEvent(event.id)
      end
    end
  end
end
