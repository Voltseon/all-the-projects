ITEM_POOL = {
  3 => { # Sylvanor
    :COMMON => [:SYLVENBRANCH, :SYLVENBRANCH, :SYLVENBRANCH, :SYLVENBRANCH, :TWINE, :TWINE, :TWINE, :SYLVENSTONES, :SYLVENSTONES, :FERRICIODIDE],
    :UNCOMMON => [:SYLVENBRANCH, :TWINE, :SYLVENSTONES, :FERRICIODIDE],
    :RARE => [:SYLVENBRANCH, :SYLVENSTONES, :FERRICIODIDE, :FERRICIODIDE]
  },
  4 => { # Glinterra
    :COMMON => [:COARSESAND, :COARSESAND, :COARSESAND, :SANDSTONE, :SANDSTONE, :SILICATESHARD],
    :UNCOMMON => [:SANDSTONE, :SILICATESHARD],
    :RARE => [:SILICATESHARD, :SILICATECRYSTAL]
  },
  5 => { # Vulkamos
    :COMMON => [:COPPERNUGGET, :COPPERNUGGET, :COPPERNUGGET, :PIECEOFIRON],
    :UNCOMMON => [:COPPERNUGGET, :PIECEOFIRON, :GOLDHAIR],
    :RARE => [:PIECEOFIRON, :GOLDHAIR]
  },
  6 => { # Lusatia (Asteroid)
    :COMMON => [:MUSHROOMCAP],
    :UNCOMMON => [:METEORITE],
    :RARE => [:NEBULASPORES]
  },
  7 => { # Digirelm (Digital)
    :COMMON => [:CHROME, :CHROME, :DATASTRAND],
    :UNCOMMON => [:DATASTRAND, :MUON, :RAWDATA],
    :RARE => [:RAWDATA]
  },
  8 => { # Lunin (Moon)
    :COMMON => [:MOONSTONE],
    :UNCOMMON => [:MOONSTONE],
    :RARE => [:MOONSTONE]
  }
}

SPAWN_ODDS = { # out of 100
  :COMMON => 30,
  :UNCOMMON => 50,
  :RARE => 70
}

EventHandlers.add(:on_enter_map, :setup_random_items,
  proc { |old_map_id|
    $game_map.events.each_value do |event|
      next unless event.name[/RandomItem/i]
      item = nil
      quantity = nil
      list = event.event.pages[0].list
      if list.length > 1
        if list[0].code == 108
          data = list[0].parameters[0].split(",")
          item = data[0].upcase.to_sym
          if data[1].include?(":")
            range = data[1].gsub("(","").gsub(")","").split(":")
            quantity = rand(range[0].to_i..range[1].to_i)
          else
            quantity = data[1].to_i
          end
        else
          next
        end
      else
        next if event.name[/Rare/i] && rand(100) > SPAWN_ODDS[:RARE]
        next if event.name[/Uncommon/i] && rand(100) > SPAWN_ODDS[:UNCOMMON]
        next if event.name[/Common/i] && !event.name[/Uncommon/i] && rand(100) > SPAWN_ODDS[:COMMON]
      end
      event.character_name = "[SG] Item"
      event.step_anime = true
      event.through = true
      event.trigger = 1
      event.event.pages[0].trigger = 1
      event.event.pages[0].condition.self_switch_valid = true
      event.event.pages[0].condition.self_switch_ch = "A"
      if item.nil? || quantity.nil?
        possible_items = ITEM_POOL[$game_map.tileset_id]
        case
        when event.name[/Rare/i]
          event.character_hue = 140
          event.event.pages[0].move_frequency = 5
          event.move_frequency = 5
          event.event.pages[0].move_speed = 5
          event.move_speed = 5
          item = possible_items[:RARE].sample
          quantity = rand(3..5)
        when event.name[/Uncommon/i]
          event.character_hue = 340
          event.event.pages[0].move_frequency = 4
          event.move_frequency = 4
          event.event.pages[0].move_speed = 4
          event.move_speed = 4
          item = possible_items[:UNCOMMON].sample
          quantity = rand(2..3)
        when event.name[/Common/i]
          event.character_hue = 0
          event.event.pages[0].move_frequency = 3
          event.move_frequency = 3
          event.event.pages[0].move_speed = 3
          event.move_speed = 3
          item = possible_items[:COMMON].sample
          quantity = rand(1..2)
        end
        if item.nil? || quantity.nil?
          event.character_name = ""
          next
        end
      end
      pbMapInterpreter.pbSetSelfSwitch(event.id, "A", true, event.map_id)
      Compiler.push_branch(list, "can_add_item(:#{item}, #{quantity})")
      Compiler.push_script(list, "add_item(:#{item}, #{quantity})", 1)
      Compiler.push_self_switch(list, "A", false, 1)
      Compiler.push_else(list, 1)
      Compiler.push_event(list, 250, ["GUI sel buzzer"], 1)
      Compiler.push_branch_end(list, 1)
      Compiler.push_end(list)
    end
  }
)