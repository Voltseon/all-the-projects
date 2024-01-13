module Compiler
  module_function

  #=============================================================================
  # Add new map files to the map tree.
  #=============================================================================
  def import_new_maps
    return false if !$DEBUG
    mapfiles = {}
    # Get IDs of all maps in the Data folder
    Dir.chdir("Data") {
      mapData = sprintf("Map*.rxdata")
      Dir.glob(mapData).each do |map|
        mapfiles[$1.to_i(10)] = true if map[/map(\d+)\.rxdata/i]
      end
    }
    mapinfos = pbLoadMapInfos
    maxOrder = 0
    # Exclude maps found in mapinfos
    mapinfos.each_key do |id|
      next if !mapinfos[id]
      mapfiles.delete(id) if mapfiles[id]
      maxOrder = [maxOrder, mapinfos[id].order].max
    end
    # Import maps not found in mapinfos
    maxOrder += 1
    imported = false
    count = 0
    mapfiles.each_key do |id|
      next if id == 999   # Ignore 999 (random dungeon map)
      mapinfo = RPG::MapInfo.new
      mapinfo.order = maxOrder
      mapinfo.name  = sprintf("MAP%03d", id)
      maxOrder += 1
      mapinfos[id] = mapinfo
      imported = true
      count += 1
    end
    if imported
      save_data(mapinfos, "Data/MapInfos.rxdata")
      $game_temp.map_infos = nil
      pbMessage(_INTL("{1} new map(s) copied to the Data folder were successfully imported.", count))
    end
    return imported
  end

  #=============================================================================
  # Generate and modify event commands.
  #=============================================================================
  def generate_move_route(commands)
    route           = RPG::MoveRoute.new
    route.repeat    = false
    route.skippable = true
    route.list.clear
    i = 0
    while i < commands.length
      case commands[i]
      when PBMoveRoute::Wait, PBMoveRoute::SwitchOn, PBMoveRoute::SwitchOff,
           PBMoveRoute::ChangeSpeed, PBMoveRoute::ChangeFreq, PBMoveRoute::Opacity,
           PBMoveRoute::Blending, PBMoveRoute::PlaySE, PBMoveRoute::Script
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1]]))
        i += 1
      when PBMoveRoute::ScriptAsync
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Script, [commands[i + 1]]))
        route.list.push(RPG::MoveCommand.new(PBMoveRoute::Wait, [0]))
        i += 1
      when PBMoveRoute::Jump
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2]]))
        i += 2
      when PBMoveRoute::Graphic
        route.list.push(RPG::MoveCommand.new(commands[i], [commands[i + 1], commands[i + 2], commands[i + 3], commands[i + 4]]))
        i += 4
      else
        route.list.push(RPG::MoveCommand.new(commands[i]))
      end
      i += 1
    end
    route.list.push(RPG::MoveCommand.new(0))
    return route
  end

  def push_move_route(list, character, route, indent = 0)
    route = generate_move_route(route) if route.is_a?(Array)
    route.list.length.times do |i|
      list.push(
        RPG::EventCommand.new((i == 0) ? 209 : 509, indent,
                              (i == 0) ? [character, route] : [route.list[i - 1]])
      )
    end
  end

  def push_move_route_and_wait(list, character, route, indent = 0)
    push_move_route(list, character, route, indent)
    push_event(list, 210, [], indent)
  end

  def push_wait(list, frames, indent = 0)
    push_event(list, 106, [frames], indent)
  end

  def push_event(list, cmd, params = nil, indent = 0)
    list.push(RPG::EventCommand.new(cmd, indent, params || []))
  end

  def push_end(list)
    list.push(RPG::EventCommand.new(0, 0, []))
  end

  def push_comment(list, cmt, indent = 0)
    textsplit2 = cmt.split(/\n/)
    textsplit2.length.times do |i|
      list.push(RPG::EventCommand.new((i == 0) ? 108 : 408, indent, [textsplit2[i].gsub(/\s+$/, "")]))
    end
  end

  def push_text(list, text, indent = 0)
    return if !text
    textsplit = text.split(/\\m/)
    textsplit.each do |t|
      first = true
      textsplit2 = t.split(/\n/)
      textsplit2.length.times do |i|
        textchunk = textsplit2[i].gsub(/\s+$/, "")
        if textchunk && textchunk != ""
          list.push(RPG::EventCommand.new((first) ? 101 : 401, indent, [textchunk]))
          first = false
        end
      end
    end
  end

  def push_script(list, script, indent = 0)
    return if !script
    first = true
    textsplit2 = script.split(/\n/)
    textsplit2.length.times do |i|
      textchunk = textsplit2[i].gsub(/\s+$/, "")
      if textchunk && textchunk != ""
        list.push(RPG::EventCommand.new((first) ? 355 : 655, indent, [textchunk]))
        first = false
      end
    end
  end

  def push_exit(list, indent = 0)
    list.push(RPG::EventCommand.new(115, indent, []))
  end

  def push_else(list, indent = 0)
    list.push(RPG::EventCommand.new(0, indent, []))
    list.push(RPG::EventCommand.new(411, indent - 1, []))
  end

  def push_branch(list, script, indent = 0)
    list.push(RPG::EventCommand.new(111, indent, [12, script]))
  end

  def push_branch_end(list, indent = 0)
    list.push(RPG::EventCommand.new(0, indent, []))
    list.push(RPG::EventCommand.new(412, indent - 1, []))
  end

  def push_self_switch(list, swtch, switchOn, indent = 0)
    list.push(RPG::EventCommand.new(123, indent, [swtch, switchOn ? 0 : 1]))
  end

  def apply_pages(page, pages)
    pages.each do |p|
      p.graphic       = page.graphic
      p.walk_anime    = page.walk_anime
      p.step_anime    = page.step_anime
      p.direction_fix = page.direction_fix
      p.through       = page.through
      p.always_on_top = page.always_on_top
    end
  end

  def add_passage_list(event, mapData)
    return if !event || event.pages.length == 0
    page                         = RPG::Event::Page.new
    page.condition.switch1_valid = true
    page.condition.switch1_id    = mapData.registerSwitch('s:tsOff?("A")')
    page.graphic.character_name  = ""
    page.trigger                 = 3   # Autorun
    page.list.clear
    list = page.list
    push_branch(list, "get_self.onEvent?")
    push_event(list, 208, [0], 1)   # Change Transparent Flag
    push_wait(list, 6, 1)          # Wait
    push_event(list, 208, [1], 1)   # Change Transparent Flag
    push_move_route_and_wait(list, -1, [PBMoveRoute::Down], 1)
    push_branch_end(list, 1)
    push_script(list, "setTempSwitchOn(\"A\")")
    push_end(list)
    event.pages.push(page)
  end

  #=============================================================================
  #
  #=============================================================================
  def safequote(x)
    x = x.gsub(/\"\#\'\\/) { |a| "\\" + a }
    x = x.gsub(/\t/, "\\t")
    x = x.gsub(/\r/, "\\r")
    x = x.gsub(/\n/, "\\n")
    return x
  end

  def safequote2(x)
    x = x.gsub(/\"\#\'\\/) { |a| "\\" + a }
    x = x.gsub(/\t/, "\\t")
    x = x.gsub(/\r/, "\\r")
    x = x.gsub(/\n/, " ")
    return x
  end

  def pbEventId(event)
    list = event.pages[0].list
    return nil if list.length == 0
    codes = []
    i = 0
    while i < list.length
      codes.push(list[i].code)
      i += 1
    end
  end

  def pbEachPage(e)
    return true if !e
    if e.is_a?(RPG::CommonEvent)
      yield e
    else
      e.pages.each { |page| yield page }
    end
  end

  #=============================================================================
  #
  #=============================================================================
  class MapData
    attr_reader :mapinfos

    def initialize
      @mapinfos = pbLoadMapInfos
      @system   = load_data("Data/System.rxdata")
      @tilesets = load_data("Data/Tilesets.rxdata")
      @mapxy      = []
      @mapWidths  = []
      @mapHeights = []
      @maps       = []
      @registeredSwitches = {}
    end

    def switchName(id)
      return @system.switches[id] || ""
    end

    def mapFilename(mapID)
      return sprintf("Data/map%03d.rxdata", mapID)
    end

    def getMap(mapID)
      return @maps[mapID] if @maps[mapID]
      begin
        @maps[mapID] = load_data(mapFilename(mapID))
        return @maps[mapID]
      rescue
        return nil
      end
    end

    def getEventFromXY(mapID, x, y)
      return nil if x < 0 || y < 0
      mapPositions = @mapxy[mapID]
      return mapPositions[(y * @mapWidths[mapID]) + x] if mapPositions
      map = getMap(mapID)
      return nil if !map
      @mapWidths[mapID]  = map.width
      @mapHeights[mapID] = map.height
      mapPositions = []
      width = map.width
      map.events.each_value do |e|
        mapPositions[(e.y * width) + e.x] = e if e
      end
      @mapxy[mapID] = mapPositions
      return mapPositions[(y * width) + x]
    end

    def getEventFromID(mapID, id)
      map = getMap(mapID)
      return nil if !map
      return map.events[id]
    end

    def getTilesetPassages(map, mapID)
      begin
        return @tilesets[map.tileset_id].passages
      rescue
        raise "Tileset data for tileset number #{map.tileset_id} used on map #{mapID} was not found. " +
              "The tileset was likely deleted, but one or more maps still use it."
      end
    end

    def getTilesetPriorities(map, mapID)
      begin
        return @tilesets[map.tileset_id].priorities
      rescue
        raise "Tileset data for tileset number #{map.tileset_id} used on map #{mapID} was not found. " +
              "The tileset was likely deleted, but one or more maps still use it."
      end
    end

    def isPassable?(mapID, x, y)
      map = getMap(mapID)
      return false if !map
      return false if x < 0 || x >= map.width || y < 0 || y >= map.height
      passages   = getTilesetPassages(map, mapID)
      priorities = getTilesetPriorities(map, mapID)
      [2, 1, 0].each do |i|
        tile_id = map.data[x, y, i]
        return false if tile_id.nil?
        passage = passages[tile_id]
        if !passage
          raise "The tile used on map #{mapID} at coordinates (#{x}, #{y}) on layer #{i + 1} doesn't exist in the tileset. " +
                "It should be deleted to prevent errors."
        end
        return false if passage & 0x0f == 0x0f
        return true if priorities[tile_id] == 0
      end
      return true
    end

    def isCounterTile?(mapID, x, y)
      map = getMap(mapID)
      return false if !map
      passages = getTilesetPassages(map, mapID)
      [2, 1, 0].each do |i|
        tile_id = map.data[x, y, i]
        return false if tile_id.nil?
        passage = passages[tile_id]
        if !passage
          raise "The tile used on map #{mapID} at coordinates (#{x}, #{y}) on layer #{i + 1} doesn't exist in the tileset. " +
                "It should be deleted to prevent errors."
        end
        return true if passage & 0x80 == 0x80
      end
      return false
    end

    def setCounterTile(mapID, x, y)
      map = getMap(mapID)
      return if !map
      passages = getTilesetPassages(map, mapID)
      [2, 1, 0].each do |i|
        tile_id = map.data[x, y, i]
        next if tile_id == 0
        passages[tile_id] |= 0x80
        break
      end
    end

    def registerSwitch(switch)
      return @registeredSwitches[switch] if @registeredSwitches[switch]
      (1..5000).each do |id|
        name = @system.switches[id]
        next if name && name != "" && name != switch
        @system.switches[id] = switch
        @registeredSwitches[switch] = id
        return id
      end
      return 1
    end

    def saveMap(mapID)
      save_data(getMap(mapID), mapFilename(mapID)) rescue nil
    end

    def saveTilesets
      save_data(@tilesets, "Data/Tilesets.rxdata")
      save_data(@system, "Data/System.rxdata")
    end
  end

  #=============================================================================
  # Checks whether a given event is likely to be a door. If so, rewrite it to
  # include animating the event as though it was a door opening and closing as the
  # player passes through.
  #=============================================================================
  def update_door_event(event, mapData)
    changed = false
    return false if event.is_a?(RPG::CommonEvent)
    # Check if event has 2+ pages and the last page meets all of these criteria:
    #   - Has a condition of a Switch being ON
    #   - The event has a charset graphic
    #   - There are more than 5 commands in that page, the first of which is a
    #     Conditional Branch
    lastPage = event.pages[event.pages.length - 1]
    if event.pages.length >= 2 &&
       lastPage.condition.switch1_valid &&
       lastPage.graphic.character_name != "" &&
       lastPage.list.length > 5 &&
       lastPage.list[0].code == 111
      # This bit of code is just in case Switch 22 has been renamed/repurposed,
      # which is highly unlikely. It changes the Switch used in the condition to
      # whichever is named 's:tsOff?("A")'.
      if lastPage.condition.switch1_id == 22 &&
         mapData.switchName(lastPage.condition.switch1_id) != 's:tsOff?("A")'
        lastPage.condition.switch1_id = mapData.registerSwitch('s:tsOff?("A")')
        changed = true
      end
      # If the last page's Switch condition uses a Switch named 's:tsOff?("A")',
      # check the penultimate page. If it contains exactly 1 "Transfer Player"
      # command and does NOT contain a "Change Transparent Flag" command, rewrite
      # both the penultimate page and the last page.
      if mapData.switchName(lastPage.condition.switch1_id) == 's:tsOff?("A")'
        list = event.pages[event.pages.length - 2].list
        transferCommand = list.find_all { |cmd| cmd.code == 201 }   # Transfer Player
        if transferCommand.length == 1 && list.none? { |cmd| cmd.code == 208 }   # Change Transparent Flag
          # Rewrite penultimate page
          list.clear
          push_move_route_and_wait(   # Move Route for door opening
            list, 0,
            [PBMoveRoute::PlaySE, RPG::AudioFile.new("Door enter"), PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnUp, PBMoveRoute::Wait, 2]
          )
          push_move_route_and_wait(   # Move Route for player entering door
            list, -1,
            [PBMoveRoute::ThroughOn, PBMoveRoute::Up, PBMoveRoute::ThroughOff]
          )
          push_event(list, 208, [0])   # Change Transparent Flag (invisible)
          push_script(list, "Followers.follow_into_door")
          push_event(list, 210, [], indent)   # Wait for Move's Completion
          push_move_route_and_wait(   # Move Route for door closing
            list, 0,
            [PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnDown, PBMoveRoute::Wait, 2]
          )
          push_event(list, 223, [Tone.new(-255, -255, -255), 6])   # Change Screen Color Tone
          push_wait(list, 8)   # Wait
          push_event(list, 208, [1])   # Change Transparent Flag (visible)
          push_event(list, transferCommand[0].code, transferCommand[0].parameters)   # Transfer Player
          push_event(list, 223, [Tone.new(0, 0, 0), 6])   # Change Screen Color Tone
          push_end(list)
          # Rewrite last page
          list = lastPage.list
          list.clear
          push_branch(list, "get_self.onEvent?")   # Conditional Branch
          push_event(list, 208, [0], 1)   # Change Transparent Flag (invisible)
          push_script(list, "Followers.hide_followers", 1)
          push_move_route_and_wait(   # Move Route for setting door to open
            list, 0,
            [PBMoveRoute::TurnLeft, PBMoveRoute::Wait, 6],
            1
          )
          push_event(list, 208, [1], 1)   # Change Transparent Flag (visible)
          push_move_route_and_wait(list, -1, [PBMoveRoute::Down], 1)   # Move Route for player exiting door
          push_script(list, "Followers.put_followers_on_player", 1)
          push_move_route_and_wait(   # Move Route for door closing
            list, 0,
            [PBMoveRoute::TurnUp, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnRight, PBMoveRoute::Wait, 2,
             PBMoveRoute::TurnDown, PBMoveRoute::Wait, 2],
            1
          )
          push_branch_end(list, 1)
          push_script(list, "setTempSwitchOn(\"A\")")
          push_end(list)
          changed = true
        end
      end
    end
    return changed
  end

  #=============================================================================
  # Fix up standard code snippets
  #=============================================================================
  def event_is_empty?(e)
    return true if !e
    return false if e.is_a?(RPG::CommonEvent)
    return e.pages.length == 0
  end

  # Checks if the event has exactly 1 page, said page has no graphic, it has
  # less than 12 commands and at least one is a Transfer Player, and the tiles
  # to the left/right/upper left/upper right are not passable but the event's
  # tile is. Causes a second page to be added to the event which is the "is
  # player on me?" check that occurs when the map is entered.
  def likely_passage?(thisEvent, mapID, mapData)
    return false if !thisEvent || thisEvent.pages.length == 0
    return false if thisEvent.pages.length != 1
    if thisEvent.pages[0].graphic.character_name == "" &&
       thisEvent.pages[0].list.length <= 12 &&
       thisEvent.pages[0].list.any? { |cmd| cmd.code == 201 } &&   # Transfer Player
#       mapData.isPassable?(mapID,thisEvent.x,thisEvent.y+1) &&
       mapData.isPassable?(mapID, thisEvent.x, thisEvent.y) &&
       !mapData.isPassable?(mapID, thisEvent.x - 1, thisEvent.y) &&
       !mapData.isPassable?(mapID, thisEvent.x + 1, thisEvent.y) &&
       !mapData.isPassable?(mapID, thisEvent.x - 1, thisEvent.y - 1) &&
       !mapData.isPassable?(mapID, thisEvent.x + 1, thisEvent.y - 1)
      return true
    end
    return false
  end

  # Splits the given code string into an array of parameters (all strings),
  # using "," as the delimiter. It will not split in the middle of a string
  # parameter. Used to extract parameters from a script call in an event.
  def split_string_with_quotes(str)
    ret = []
    new_str = ""
    in_msg = false
    str.scan(/./) do |s|
      if s == "," && !in_msg
        ret.push(new_str.strip)
        new_str = ""
      else
        in_msg = !in_msg if s == "\""
        new_str += s
      end
    end
    new_str.strip!
    ret.push(new_str) if !new_str.empty?
    return ret
  end

  def replace_old_battle_scripts(event, list, index)
    changed = false
    script = list[index].parameters[1]
    if script[/^\s*pbWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      list[index].parameters[1] = sprintf("WildBattle.start(#{battle_params[0]}, #{battle_params[1]})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[3][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[4][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[2] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[2]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbDoubleWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      pkmn1 = "#{battle_params[0]}, #{battle_params[1]}"
      pkmn2 = "#{battle_params[2]}, #{battle_params[3]}"
      list[index].parameters[1] = sprintf("WildBattle.start(#{pkmn1}, #{pkmn2})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[5][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[6][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[4] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[4]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTripleWildBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      pkmn1 = "#{battle_params[0]}, #{battle_params[1]}"
      pkmn2 = "#{battle_params[2]}, #{battle_params[3]}"
      pkmn3 = "#{battle_params[4]}, #{battle_params[5]}"
      list[index].parameters[1] = sprintf("WildBattle.start(#{pkmn1}, #{pkmn2}, #{pkmn3})")
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && battle_params[7][/false/]
        push_script(new_events, "setBattleRule(\"cannotRun\")", old_indent)
      end
      if battle_params[4] && battle_params[8][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[2] && battle_params[6] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[6]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTrainerBattle\((.+)\)\s*$/]
      echoln ""
      echoln $1
      battle_params = split_string_with_quotes($1)   # Split on commas
      echoln battle_params
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[4]}" if battle_params[4] && battle_params[4] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[2] && !battle_params[2].empty? && battle_params[2] != "nil"
        echoln battle_params[2]
        speech = battle_params[2].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        echoln speech
        push_comment(new_events, "EndSpeech: #{speech.strip}", old_indent)
      end
      if battle_params[3] && battle_params[3][/true/]
        push_script(new_events, "setBattleRule(\"double\")", old_indent)
      end
      if battle_params[5] && battle_params[5][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[6] && battle_params[6] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[6]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbDoubleTrainerBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[2]}" if battle_params[2] && battle_params[2] != "nil"
      trainer2 = "#{battle_params[4]}, #{battle_params[5]}"
      trainer2 += ", #{battle_params[6]}" if battle_params[6] && battle_params[6] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1}, #{trainer2})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && !battle_params[3].empty? && battle_params[3] != "nil"
        speech = battle_params[3].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech1: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[7] != "nil"
        speech = battle_params[7].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech2: #{speech.strip}", old_indent)
      end
      if battle_params[8] && battle_params[8][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[9] && battle_params[9] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[9]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    elsif script[/^\s*pbTripleTrainerBattle\((.+)\)\s*$/]
      battle_params = split_string_with_quotes($1)   # Split on commas
      trainer1 = "#{battle_params[0]}, #{battle_params[1]}"
      trainer1 += ", #{battle_params[2]}" if battle_params[2] && battle_params[2] != "nil"
      trainer2 = "#{battle_params[4]}, #{battle_params[5]}"
      trainer2 += ", #{battle_params[6]}" if battle_params[6] && battle_params[6] != "nil"
      trainer3 = "#{battle_params[8]}, #{battle_params[9]}"
      trainer3 += ", #{battle_params[10]}" if battle_params[10] && battle_params[10] != "nil"
      list[index].parameters[1] = "TrainerBattle.start(#{trainer1}, #{trainer2}, #{trainer3})"
      old_indent = list[index].indent
      new_events = []
      if battle_params[3] && !battle_params[3].empty? && battle_params[3] != "nil"
        speech = battle_params[3].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech1: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[7] != "nil"
        speech = battle_params[7].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech2: #{speech.strip}", old_indent)
      end
      if battle_params[7] && !battle_params[7].empty? && battle_params[11] != "nil"
        speech = battle_params[11].gsub(/^\s*_I\(\s*"\s*/, "").gsub(/\"\s*\)\s*$/, "")
        push_comment(new_events, "EndSpeech3: #{speech.strip}", old_indent)
      end
      if battle_params[12] && battle_params[12][/true/]
        push_script(new_events, "setBattleRule(\"canLose\")", old_indent)
      end
      if battle_params[13] && battle_params[13] != "1"
        push_script(new_events, "setBattleRule(\"outcome\", #{battle_params[13]})", old_indent)
      end
      list[index, 0] = new_events if new_events.length > 0
      changed = true
    end
    return changed
  end

  #=============================================================================
  # Convert events used as counters into proper counters.
  #=============================================================================
  # Checks if the event has just 1 page, which has no conditions and no commands
  # and whose movement type is "Fixed".
  def plain_event?(event)
    return false unless event
    return false if event.pages.length > 1
    return false if event.pages[0].move_type != 0
    return false if event.pages[0].condition.switch1_valid ||
                    event.pages[0].condition.switch2_valid ||
                    event.pages[0].condition.variable_valid ||
                    event.pages[0].condition.self_switch_valid
    return true if event.pages[0].list.length <= 1
    return false
  end

  # Checks if the event has just 1 page, which has no conditions and whose
  # movement type is "Fixed". Then checks if there are no commands, or it looks
  # like a simple Mart or a Poké Center nurse event.
  def plain_event_or_mart?(event)
    return false unless event
    return false if event.pages.length > 1
    return false if event.pages[0].move_type != 0
    return false if event.pages[0].condition.switch1_valid ||
                    event.pages[0].condition.switch2_valid ||
                    event.pages[0].condition.variable_valid ||
                    event.pages[0].condition.self_switch_valid
    # No commands in the event
    return true if event.pages[0].list.length <= 1
    # pbPokemonMart events
    return true if event.pages[0].list.length <= 12 &&
                   event.pages[0].graphic.character_name != "" &&   # Has charset
                   event.pages[0].list[0].code == 355 &&   # First line is Script
                   event.pages[0].list[0].parameters[0][/^pbPokemonMart/]
    # pbSetPokemonCenter events
    return true if event.pages[0].list.length > 8 &&
                   event.pages[0].graphic.character_name != "" &&   # Has charset
                   event.pages[0].list[0].code == 355 &&   # First line is Script
                   event.pages[0].list[0].parameters[0][/^pbSetPokemonCenter/]
    return false
  end

  # Given two events that are next to each other, decides whether otherEvent is
  # likely to be a "counter event", i.e. is placed on a tile with the Counter
  # flag, or is on a non-passable tile between two passable tiles (e.g. a desk)
  # where one of those two tiles is occupied by thisEvent.
  def likely_counter?(thisEvent, otherEvent, mapID, mapData)
    # Check whether otherEvent is on a counter tile
    return true if mapData.isCounterTile?(mapID, otherEvent.x, otherEvent.y)
    # Check whether otherEvent is between an event with a graphic (e.g. an NPC)
    # and a spot where the player can be
    yonderX = otherEvent.x + (otherEvent.x - thisEvent.x)
    yonderY = otherEvent.y + (otherEvent.y - thisEvent.y)
    return thisEvent.pages[0].graphic.character_name != "" &&    # Has charset
           otherEvent.pages[0].graphic.character_name == "" &&   # Has no charset
           otherEvent.pages[0].trigger == 0 &&                   # Action trigger
           mapData.isPassable?(mapID, thisEvent.x, thisEvent.y) &&
           !mapData.isPassable?(mapID, otherEvent.x, otherEvent.y) &&
           mapData.isPassable?(mapID, yonderX, yonderY)
  end

  # Checks all events in the given map to see if any look like they've been
  # placed on a desk with an NPC behind it, where the event on the desk is the
  # actual interaction with the NPC. In other words, it's not making proper use
  # of the counter flag (which lets the player interact with an event on the
  # other side of counter tiles).
  # Any events found to be like this have their contents merged into the NPC
  # event and the counter event itself is deleted. The tile below the counter
  # event gets its counter flag set (if it isn't already).
  def check_counters(map, mapID, mapData)
    toDelete = []
    changed = false
    map.events.each_key do |key|
      event = map.events[key]
      next if !plain_event_or_mart?(event)
      # Found an event that is empty or looks like a simple Mart or a Poké
      # Center nurse. Check adjacent events to see if they are "counter events".
      neighbors = []
      neighbors.push(mapData.getEventFromXY(mapID, event.x, event.y - 1))
      neighbors.push(mapData.getEventFromXY(mapID, event.x, event.y + 1))
      neighbors.push(mapData.getEventFromXY(mapID, event.x - 1, event.y))
      neighbors.push(mapData.getEventFromXY(mapID, event.x + 1, event.y))
      neighbors.compact!
      neighbors.each do |otherEvent|
        next if plain_event?(otherEvent)   # Blank/cosmetic-only event
        next if !likely_counter?(event, otherEvent, mapID, mapData)
        # Found an adjacent event that looks like it's supposed to be a counter.
        # Set the counter flag of the tile beneath the counter event, copy the
        # counter event's pages to the NPC event, and delete the counter event.
        mapData.setCounterTile(mapID, otherEvent.x, otherEvent.y)
        savedPage = event.pages[0]
        event.pages = otherEvent.pages
        apply_pages(savedPage, event.pages)   # Apply NPC's visuals to new event pages
        toDelete.push(otherEvent.id)
        changed = true
      end
    end
    toDelete.each { |key| map.events.delete(key) }
    return changed
  end
end
