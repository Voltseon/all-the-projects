#===============================================================================
#
#===============================================================================
def pbDefaultMap
  return $game_map.map_id if $game_map
  return $data_system.edit_map_id if $data_system
  return 0
end

def pbWarpToMap
  mapid = pbListScreen(_INTL("WARP TO MAP"), MapLister.new(pbDefaultMap))
  if mapid > 0
    map = Game_Map.new
    map.setup(mapid)
    success = false
    x = 0
    y = 0
    100.times do
      x = rand(map.width)
      y = rand(map.height)
      next if !map.passableStrict?(x, y, 0, $game_player)
      blocked = false
      map.events.each_value do |event|
        if event.at_coordinate?(x, y) && !event.through && event.character_name != ""
          blocked = true
        end
      end
      next if blocked
      success = true
      break
    end
    if !success
      x = rand(map.width)
      y = rand(map.height)
    end
    return [mapid, x, y]
  end
  return nil
end



#===============================================================================
# Debug Variables screen
#===============================================================================
class SpriteWindow_DebugVariables < Window_DrawableCommand
  attr_reader :mode

  def initialize(viewport)
    super(0, 0, Graphics.width, Graphics.height, viewport)
  end

  def itemCount
    return (@mode == 0) ? $data_system.switches.size - 1 : $data_system.variables.size - 1
  end

  def mode=(mode)
    @mode = mode
    refresh
  end

  def shadowtext(x, y, w, h, t, align = 0, colors = 0)
    width = self.contents.text_size(t).width
    case align
    when 1 # Right aligned
      x += (w - width)
    when 2 # Centre aligned
      x += (w / 2) - (width / 2)
    end
    base = Color.new(12 * 8, 12 * 8, 12 * 8)
    case colors
    when 1 # Red
      base = Color.new(168, 48, 56)
    when 2 # Green
      base = Color.new(0, 144, 0)
    end
    pbDrawShadowText(self.contents, x, y, [width, w].max, h, t, base, Color.new(26 * 8, 26 * 8, 25 * 8))
  end

  def drawItem(index, _count, rect)
    pbSetNarrowFont(self.contents)
    colors = 0
    codeswitch = false
    if @mode == 0
      name = $data_system.switches[index + 1]
      codeswitch = (name[/^s\:/])
      val = (codeswitch) ? (eval($~.post_match) rescue nil) : $game_switches[index + 1]
      if val.nil?
        status = "[-]"
        colors = 0
        codeswitch = true
      elsif val   # true
        status = "[ON]"
        colors = 2
      else   # false
        status = "[OFF]"
        colors = 1
      end
    else
      name = $data_system.variables[index + 1]
      status = $game_variables[index + 1].to_s
      status = "\"__\"" if nil_or_empty?(status)
    end
    name ||= ""
    id_text = sprintf("%04d:", index + 1)
    rect = drawCursor(index, rect)
    totalWidth = rect.width
    idWidth     = totalWidth * 15 / 100
    nameWidth   = totalWidth * 65 / 100
    statusWidth = totalWidth * 20 / 100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x + idWidth, rect.y, nameWidth, rect.height, name, 0, (codeswitch) ? 1 : 0)
    self.shadowtext(rect.x + idWidth + nameWidth, rect.y, statusWidth, rect.height, status, 1, colors)
  end
end



def pbDebugSetVariable(id, diff)
  $game_variables[id] = 0 if $game_variables[id].nil?
  if $game_variables[id].is_a?(Numeric)
    pbPlayCursorSE
    $game_variables[id] = [$game_variables[id] + diff, 99_999_999].min
    $game_variables[id] = [$game_variables[id], -99_999_999].max
    $game_map.need_refresh = true
  end
end

def pbDebugVariableScreen(id)
  case $game_variables[id]
  when Numeric
    value = $game_variables[id]
    params = ChooseNumberParams.new
    params.setDefaultValue(value)
    params.setMaxDigits(8)
    params.setNegativesAllowed(true)
    value = pbMessageChooseNumber(_INTL("Set variable {1}.", id), params)
    $game_variables[id] = [value, 99_999_999].min
    $game_variables[id] = [$game_variables[id], -99_999_999].max
    $game_map.need_refresh = true
  when String
    value = pbMessageFreeText(_INTL("Set variable {1}.", id),
                              $game_variables[id], false, 250, Graphics.width)
    $game_variables[id] = value
    $game_map.need_refresh = true
  end
end

def pbDebugVariables(mode)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  sprites = {}
  sprites["right_window"] = SpriteWindow_DebugVariables.new(viewport)
  right_window = sprites["right_window"]
  right_window.mode     = mode
  right_window.active   = true
  loop do
    Graphics.update
    Input.update
    pbUpdateSpriteHash(sprites)
    if Input.trigger?(Input::BACK)
      pbPlayCancelSE
      break
    end
    current_id = right_window.index + 1
    case mode
    when 0 # Switches
      if Input.trigger?(Input::USE)
        pbPlayDecisionSE
        $game_switches[current_id] = !$game_switches[current_id]
        right_window.refresh
        $game_map.need_refresh = true
      end
    when 1 # Variables
      if Input.repeat?(Input::LEFT)
        pbDebugSetVariable(current_id, -1)
        right_window.refresh
      elsif Input.repeat?(Input::RIGHT)
        pbDebugSetVariable(current_id, 1)
        right_window.refresh
      elsif Input.trigger?(Input::ACTION)
        case $game_variables[current_id]
        when 0
          $game_variables[current_id] = ""
        when ""
          $game_variables[current_id] = 0
        else
          case $game_variables[current_id]
          when Numeric
            $game_variables[current_id] = 0
          when String
            $game_variables[current_id] = ""
          end
        end
        right_window.refresh
        $game_map.need_refresh = true
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        pbDebugVariableScreen(current_id)
        right_window.refresh
      end
    end
  end
  pbDisposeSpriteHash(sprites)
  viewport.dispose
end

#===============================================================================
# Text import/export for localisation
#===============================================================================
def pbExtractText
  msgwindow = pbCreateMessageWindow
  if safeExists?("intl.txt") &&
     !pbConfirmMessageSerious(_INTL("intl.txt already exists. Overwrite it?"))
    pbDisposeMessageWindow(msgwindow)
    return
  end
  pbMessageDisplay(msgwindow, _INTL("Please wait.\\wtnp[0]"))
  MessageTypes.extract("intl.txt")
  pbMessageDisplay(msgwindow, _INTL("All text in the game was extracted and saved to intl.txt.\1"))
  pbMessageDisplay(msgwindow, _INTL("To localize the text for a particular language, translate every second line in the file.\1"))
  pbMessageDisplay(msgwindow, _INTL("After translating, choose \"Compile Text.\""))
  pbDisposeMessageWindow(msgwindow)
end

def pbCompileTextUI
  msgwindow = pbCreateMessageWindow
  pbMessageDisplay(msgwindow, _INTL("Please wait.\\wtnp[0]"))
  begin
    pbCompileText
    pbMessageDisplay(msgwindow, _INTL("Successfully compiled text and saved it to intl.dat.\1"))
    pbMessageDisplay(msgwindow, _INTL("To use the file in a game, place the file in the Data folder under a different name, and edit the Settings::LANGUAGES array in the scripts."))
  rescue RuntimeError
    pbMessageDisplay(msgwindow, _INTL("Failed to compile text: {1}", $!.message))
  end
  pbDisposeMessageWindow(msgwindow)
end

#===============================================================================
# Properly erases all non-existent tiles in maps (including event graphics)
#===============================================================================
def pbDebugFixInvalidTiles
  total_errors = 0
  num_error_maps = 0
  tilesets = $data_tilesets
  mapData = Compiler::MapData.new
  t = Time.now.to_i
  Graphics.update
  total_maps = mapData.mapinfos.keys.length
  Console.echo_h1 _INTL("Checking {1} maps for invalid tiles", total_maps)
  mapData.mapinfos.keys.sort.each do |id|
    if Time.now.to_i - t >= 5
      Graphics.update
      t = Time.now.to_i
    end
    map_errors = 0
    map = mapData.getMap(id)
    next if !map || !mapData.mapinfos[id]
    passages = mapData.getTilesetPassages(map, id)
    # Check all tiles in map for non-existent tiles
    map.data.xsize.times do |x|
      map.data.ysize.times do |y|
        map.data.zsize.times do |i|
          tile_id = map.data[x, y, i]
          next if pbCheckTileValidity(tile_id, map, tilesets, passages)
          map.data[x, y, i] = 0
          map_errors += 1
        end
      end
    end
    # Check all events in map for page graphics using a non-existent tile
    map.events.each_key do |key|
      event = map.events[key]
      event.pages.each do |page|
        next if page.graphic.tile_id <= 0
        next if pbCheckTileValidity(page.graphic.tile_id, map, tilesets, passages)
        page.graphic.tile_id = 0
        map_errors += 1
      end
    end
    next if map_errors == 0
    # Map was changed; save it
    Console.echoln_li _INTL("{1} error tile(s) found on map {2}: {3}.", map_errors, id, mapData.mapinfos[id].name)
    total_errors += map_errors
    num_error_maps += 1
    mapData.saveMap(id)
  end
  if num_error_maps == 0
    Console.echo_h2(_INTL("Done. No errors found."), text: :green)
    pbMessage(_INTL("No invalid tiles were found."))
  else
    echoln ""
    Console.echo_h2(_INTL("Done. {1} errors found and fixed.", total_errors), text: :green)
    Console.echo_warn _INTL("RMXP data was altered. Close RMXP now to ensure changes are applied.")
    echoln ""
    pbMessage(_INTL("{1} error(s) were found across {2} map(s) and fixed.", total_errors, num_error_maps))
    pbMessage(_INTL("Close RPG Maker XP to ensure the changes are applied properly."))
  end
end

def pbCheckTileValidity(tile_id, map, tilesets, passages)
  return false if !tile_id
  if tile_id > 0 && tile_id < 384
    # Check for defined autotile
    autotile_id = (tile_id / 48) - 1
    autotile_name = tilesets[map.tileset_id].autotile_names[autotile_id]
    return true if autotile_name && autotile_name != ""
  else
    # Check for tileset data
    return true if passages[tile_id]
  end
  return false
end



#===============================================================================
# Pseudo-party screen for editing Pokémon being set up for a wild battle
#===============================================================================
class PokemonDebugPartyScreen
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @messageBox = Window_AdvancedTextPokemon.new("")
    @messageBox.viewport       = @viewport
    @messageBox.visible        = false
    @messageBox.letterbyletter = true
    pbBottomLeftLines(@messageBox, 2)
    @helpWindow = Window_UnformattedTextPokemon.new("")
    @helpWindow.viewport = @viewport
    @helpWindow.visible  = true
    pbBottomLeftLines(@helpWindow, 1)
  end

  def pbEndScreen
    @messageBox.dispose
    @helpWindow.dispose
    @viewport.dispose
  end

  def pbDisplay(text)
    @messageBox.text    = text
    @messageBox.visible = true
    @helpWindow.visible = false
    pbPlayDecisionSE
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @messageBox.busy?
        if Input.trigger?(Input::USE)
          pbPlayDecisionSE if @messageBox.pausing?
          @messageBox.resume
        end
      else
        if Input.trigger?(Input::BACK) || Input.trigger?(Input::USE)
          break
        end
      end
    end
    @messageBox.visible = false
    @helpWindow.visible = true
  end

  def pbConfirm(text)
    ret = -1
    @messageBox.text    = text
    @messageBox.visible = true
    @helpWindow.visible = false
    using(cmdwindow = Window_CommandPokemon.new([_INTL("Yes"), _INTL("No")])) {
      cmdwindow.visible = false
      pbBottomRight(cmdwindow)
      cmdwindow.y -= @messageBox.height
      cmdwindow.z = @viewport.z + 1
      loop do
        Graphics.update
        Input.update
        cmdwindow.visible = true if !@messageBox.busy?
        cmdwindow.update
        pbUpdate
        if !@messageBox.busy?
          if Input.trigger?(Input::BACK)
            ret = false
            break
          elsif Input.trigger?(Input::USE) && @messageBox.resume
            ret = (cmdwindow.index == 0)
            break
          end
        end
      end
    }
    @messageBox.visible = false
    @helpWindow.visible = true
    return ret
  end

  def pbShowCommands(text, commands, index = 0)
    ret = -1
    @helpWindow.visible = true
    using(cmdwindow = Window_CommandPokemonColor.new(commands)) {
      cmdwindow.z     = @viewport.z + 1
      cmdwindow.index = index
      pbBottomRight(cmdwindow)
      @helpWindow.resizeHeightToFit(text, Graphics.width - cmdwindow.width)
      @helpWindow.text = text
      pbBottomLeft(@helpWindow)
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    }
    return ret
  end

  def pbChooseMove(pkmn, text, index = 0)
    moveNames = []
    pkmn.moves.each do |i|
      if i.total_pp <= 0
        moveNames.push(_INTL("{1} (PP: ---)", i.name))
      else
        moveNames.push(_INTL("{1} (PP: {2}/{3})", i.name, i.pp, i.total_pp))
      end
    end
    return pbShowCommands(text, moveNames, index)
  end

  def pbRefreshSingle(index); end

  def update
    @messageBox.update
    @helpWindow.update
  end
  alias pbUpdate update
end
