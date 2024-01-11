def fixt
  new_text = ""
  File.open("PBS/tttt.txt", "rb") do |f|
    current_mon = nil
    doneIvs = false
    f.each_line do |line|
      if line.include?("IV = ")
        line.gsub!(/  IV =.*\r/, "  IV = 31,31,31,31,31,31\r")
        doneIvs = true
      end
=begin
      line.gsub!(/  AbilityIndex =.*\r/, "")
      line.gsub!(/  Nature = .*\r/, "")
      if line.include?("Items = ")
        final_items = []
        items = line.split("Items = ")[1].split(",")
        items.each do |item|
          next unless item[/MEGA/]
          final_items.push(item)
        end
        line = "Items = " + final_items.join(",") + "\n"
        line = "" if final_items.length == 0
      end
=end
      if line.include?("Pokemon = ")
        new_text += "  IV = 31,31,31,31,31,31\r" if !doneIvs
        pokemon = line.split("Pokemon = ")[1].split(",")
        current_mon = pokemon[0]
        pokemon[1] = [(pokemon[1].to_i * 1.5).round, 100].min
        line = "Pokemon = " + pokemon.join(",") + "\n"
        doneIvs = false
      end
=begin
      if line.include?("Moves = ") && current_mon
        moves = line.split("Moves = ")[1].gsub("\r", "").gsub("\n", "").split(",")
        moves.each_with_index do |move, index|
          move_data = GameData::Move.get(move.to_sym)
          valid_weaker_moves = []
          mon_data = GameData::Species.get(current_mon.to_sym)
          [mon_data.moves, mon_data.tutor_moves, mon_data.egg_moves].each do |mmm|
            mmm.each do |learn_move|
              learn_move = learn_move[1] if learn_move.is_a?(Array)
              learn_move = GameData::Move.get(learn_move) if learn_move.is_a?(Symbol)
              next unless learn_move.type == move_data.type
              next unless learn_move.base_damage < move_data.base_damage
              valid_weaker_moves.push([learn_move.id, learn_move.base_damage])
            end
          end
          valid_weaker_moves.sort! { |a, b| b[1] <=> a[1] }
          moves[index] = valid_weaker_moves[0][0] if valid_weaker_moves[0]
        end
        line = "  Moves = " + moves.join(",") + "\n"
      end
=end
      new_text += line
    end
  end
  File.open("PBS/tttt.txt", "wb") do |f|
    f.write(new_text)
  end
end

class Destination
  attr_accessor :x
  attr_accessor :y
  attr_accessor :direction
  attr_accessor :map_id
  attr_accessor :event_id

  def initialize(map_id, event_id, x, y, direction=nil)
    @map_id = map_id
    @event_id = event_id
    @x = x
    @y = y
    @direction = direction
  end

  def to_params
    return [@map_id, @x, @y, @direction]
  end

  def to_key
    return [@map_id, @event_id]
  end
end

class Player < Trainer
  attr_accessor :warps

  def warps
    @warps = {} if @warps.nil?
    return @warps
  end
end

class Game_Temp
  attr_accessor :warp_offset

  def warp_offset
    @warp_offset = [0,0] if !@warp_offset
    return @warp_offset
  end
end

def pbActivateWarp(event_id, offset = [0,0])
  $game_temp.warp_offset = offset
  $game_map.events[event_id].start
end

def pbLoadWarps
  # Get all maps
  mapData = Compiler::MapData.new
  maps = mapData.mapinfos.keys.sort
  do_echo = false
  maps.each do |id|
    map = mapData.getMap(id)
    echoln "* Loading warps for map #{id}" if do_echo
    map.events.each_pair do |event_id, event|
      echoln "** Loading warps for event #{event_id}" if do_echo
      event.pages.each do |page|
        next if page.list.nil?
        echoln "*** Loading warps for page #{page}" if do_echo
        page.list.each do |command|
          break if command.code == 108 && command.parameters[0][/NoRandomizer/i]
          if command.code == 201
            # Find transfer event near this event
            transfer_event = nil
            next if command.parameters[1].nil?
            echoln "**** Found transfer, looking for valid destination event" if do_echo
            mapData.getMap(command.parameters[1]).events.each_pair do |etransfer_event, transfer_event_id|
              [0,-1,1,-2,2].each do |x|
                next unless transfer_event.nil?
                [0,-1,1,-2,2].each do |y|
                  next unless transfer_event.nil?
                  etransfer_event = mapData.getMap(command.parameters[1]).events[etransfer_event] if etransfer_event.is_a?(Integer)
                  next if etransfer_event.x + x != command.parameters[2] || etransfer_event.y + y != command.parameters[3]
                  etransfer_event.pages.each do |transfer_page|
                    next if transfer_page.list.nil?
                    transfer_page.list.each do |transfer_command|
                      break if transfer_command.code == 108 && transfer_command.parameters[0][/NoRandomizer/i]
                      if transfer_command.code == 201 && transfer_command.parameters[1] == id
                        transfer_event = transfer_event_id
                        echoln "***** Found valid destination event #{etransfer_event}" if do_echo
                      end
                    end
                  end
                end
              end
            end
            next if transfer_event.nil?
            echoln "**** Adding warp" if do_echo
            # Get destination
            destination = Destination.new(command.parameters[1], transfer_event.id, command.parameters[2], command.parameters[3], command.parameters[4])
            # Add to list
            $player.warps[[id, event_id]] = destination
          end
        end
      end
    end
  end
end

def pbSetWarps
  return
  mapData = Compiler::MapData.new
  maps = mapData.mapinfos.keys.sort
  $player.warps.each_pair do |key, value|
    map_id = key[0]
    event_id = key[1]
    destination = value
    # Get event
    event = mapData.getMap(map_id).events[event_id]
    # Get event page
    page = event.pages[0]
    # Get event page list
    commands = page.list
    # Get event page list command
    commands.each do |command|
      if command.code == 201
        # Change destination
        command.parameters[1] = destination.map_id
        command.parameters[2] = destination.x
        command.parameters[3] = destination.y
        command.parameters[4] = destination.direction
        break
      end
    end
  end
end

def pbWarpRandomizer
  pbLoadWarps
  mapData = Compiler::MapData.new
  old_warps = $player.warps.clone
  possible_values = $player.warps.values.shuffle
  keys_done = []
  values_done = []
  same_maps = [[24,25], [24,24], [25,25], [25,24]]
  $player.warps.each do |key, value|
    next if keys_done.include?(key)
    new_value = possible_values[0]
    possible_values.each do |possible_value|
      next if values_done.include?(possible_value)
      break unless keys_done.include?(new_value.to_key) || new_value.map_id == key[0] ||
        ((mapData.getMap(key[0]).tileset_id == mapData.getMap(new_value.map_id).tileset_id ||
        same_maps.include?([mapData.getMap(key[0]).tileset_id, mapData.getMap(new_value.map_id).tileset_id])) &&
        mapData.getMap(new_value.map_id).tileset_id != 23 && mapData.getMap(new_value.map_id).tileset_id != 23)
      new_value = possible_value
    end
    $player.warps[key] = new_value
    other_side = $player.warps[key].to_key
    $player.warps[other_side] = old_warps[value.to_key]
    keys_done.push(key)
    keys_done.push(other_side)
    values_done.push(value)
    values_done.push(old_warps[value.to_key])
  end
  pbSetWarps
end