#===============================================================================
# Data type properties
#===============================================================================
module UndefinedProperty
  def self.set(_settingname, oldsetting)
    pbMessage(_INTL("This property can't be edited here at this time."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



module ReadOnlyProperty
  def self.set(_settingname, oldsetting)
    pbMessage(_INTL("This property cannot be edited."))
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



class UIntProperty
  def initialize(maxdigits)
    @maxdigits = maxdigits
  end

  def set(settingname, oldsetting)
    params = ChooseNumberParams.new
    params.setMaxDigits(@maxdigits)
    params.setDefaultValue(oldsetting || 0)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.", settingname), params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end



class LimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname, oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0, @maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1} (0-#{@maxvalue}).", settingname), params)
  end

  def defaultValue
    return 0
  end

  def format(value)
    return value.inspect
  end
end



class LimitProperty2
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname, oldsetting)
    oldsetting = 0 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(0, @maxvalue)
    params.setDefaultValue(oldsetting)
    params.setCancelValue(-1)
    ret = pbMessageChooseNumber(_INTL("Set the value for {1} (0-#{@maxvalue}).", settingname), params)
    return (ret >= 0) ? ret : nil
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? value.inspect : "-"
  end
end



class NonzeroLimitProperty
  def initialize(maxvalue)
    @maxvalue = maxvalue
  end

  def set(settingname, oldsetting)
    oldsetting = 1 if !oldsetting
    params = ChooseNumberParams.new
    params.setRange(1, @maxvalue)
    params.setDefaultValue(oldsetting)
    return pbMessageChooseNumber(_INTL("Set the value for {1}.", settingname), params)
  end

  def defaultValue
    return 1
  end

  def format(value)
    return value.inspect
  end
end



module BooleanProperty
  def self.set(settingname, _oldsetting)
    return pbConfirmMessage(_INTL("Enable the setting {1}?", settingname)) ? true : false
  end

  def self.format(value)
    return value.inspect
  end
end



module BooleanProperty2
  def self.set(_settingname, _oldsetting)
    ret = pbShowCommands(nil, [_INTL("True"), _INTL("False")], -1)
    return (ret >= 0) ? (ret == 0) : nil
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value) ? _INTL("True") : (!value.nil?) ? _INTL("False") : "-"
  end
end



module StringProperty
  def self.set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.", settingname),
                             (oldsetting) ? oldsetting : "", false, 250, Graphics.width)
  end

  def self.format(value)
    return value
  end
end



class LimitStringProperty
  def initialize(limit)
    @limit = limit
  end

  def format(value)
    return value
  end

  def set(settingname, oldsetting)
    return pbMessageFreeText(_INTL("Set the value for {1}.", settingname),
                             (oldsetting) ? oldsetting : "", false, @limit)
  end
end



class EnumProperty
  def initialize(values)
    @values = values
  end

  def set(settingname, oldsetting)
    commands = []
    @values.each do |value|
      commands.push(value)
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.", settingname), commands, -1)
    return oldsetting if cmd < 0
    return cmd
  end

  def defaultValue
    return 0
  end

  def format(value)
    return (value) ? @values[value] : value.inspect
  end
end



# Unused
class EnumProperty2
  def initialize(value)
    @module = value
  end

  def set(settingname, oldsetting)
    commands = []
    (0..@module.maxValue).each do |i|
      commands.push(getConstantName(@module, i))
    end
    cmd = pbMessage(_INTL("Choose a value for {1}.", settingname), commands, -1, nil, oldsetting)
    return oldsetting if cmd < 0
    return cmd
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value) ? getConstantName(@module, value) : "-"
  end
end



class StringListProperty
  def self.set(_setting_name, old_setting)
    real_cmds = []
    real_cmds.push([_INTL("[ADD VALUE]"), -1])
    old_setting.length.times do
      real_cmds.push([old_setting[i], 0])
    end
    # Edit list
    cmdwin = pbListWindow([], 200)
    oldsel = nil
    ret = old_setting
    cmd = 0
    commands = []
    do_refresh = true
    loop do
      if do_refresh
        commands = []
        real_cmds.each_with_index do |entry, i|
          commands.push(entry[0])
          cmd = i if oldsel && entry[0] == oldsel
        end
      end
      do_refresh = false
      oldsel = nil
      cmd = pbCommands2(cmdwin, commands, -1, cmd, true)
      if cmd >= 0   # Chose a value
        entry = real_cmds[cmd]
        if entry[1] == -1   # Add new value
          new_value = pbMessageFreeText(_INTL("Enter the new value."),
                                        "", false, 250, Graphics.width)
          if !nil_or_empty?(new_value)
            if real_cmds.any? { |e| e[0] == new_value }
              oldsel = new_value   # Already have value; just move cursor to it
            else
              real_cmds.push([new_value, 0])
            end
            do_refresh = true
          end
        else   # Edit value
          case pbMessage(_INTL("\\ts[]Do what with this value?"),
                         [_INTL("Edit"), _INTL("Delete"), _INTL("Cancel")], 3)
          when 0   # Edit
            new_value = pbMessageFreeText(_INTL("Enter the new value."),
                                          entry[0], false, 250, Graphics.width)
            if !nil_or_empty?(new_value)
              if real_cmds.any? { |e| e[0] == new_value }   # Already have value; delete this one
                real_cmds.delete_at(cmd)
                cmd = [cmd, real_cmds.length - 1].min
              else   # Change value
                entry[0] = new_value
              end
              oldsel = new_value
              do_refresh = true
            end
          when 1   # Delete
            real_cmds.delete_at(cmd)
            cmd = [cmd, real_cmds.length - 1].min
            do_refresh = true
          end
        end
      else   # Cancel/quit
        case pbMessage(_INTL("Keep changes?"), [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0
          real_cmds.length.times do |i|
            real_cmds[i] = (real_cmds[i][1] == -1) ? nil : real_cmds[i][0]
          end
          real_cmds.compact!
          ret = real_cmds
          break
        when 1
          break
        end
      end
    end
    cmdwin.dispose
    return ret
  end

  def self.defaultValue
    return []
  end

  def self.format(value)
    return value.join(",")
  end
end



class GameDataProperty
  def initialize(value)
    raise _INTL("Couldn't find class {1} in module GameData.", value.to_s) if !GameData.const_defined?(value.to_sym)
    @module = GameData.const_get(value.to_sym)
  end

  def set(settingname, oldsetting)
    commands = []
    i = 0
    @module.each do |data|
      if data.respond_to?("id_number")
        commands.push([data.id_number, data.name, data.id])
      else
        commands.push([i, data.name, data.id])
      end
      i += 1
    end
    return pbChooseList(commands, oldsetting, oldsetting, -1)
  end

  def defaultValue
    return nil
  end

  def format(value)
    return (value && @module.exists?(value)) ? @module.get(value).real_name : "-"
  end
end



module BGMProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MusicFileLister.new(true, oldsetting))
    return (chosenmap && chosenmap != "") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module MEProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MusicFileLister.new(false, oldsetting))
    return (chosenmap && chosenmap != "") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module WindowskinProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, GraphicsLister.new("Graphics/Windowskins/", oldsetting))
    return (chosenmap && chosenmap != "") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module TrainerTypeProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, TrainerTypeLister.new(0, false))
    return chosenmap || oldsetting
  end

  def self.format(value)
    return (value && GameData::TrainerType.exists?(value)) ? GameData::TrainerType.get(value).real_name : "-"
  end
end

module TypeProperty
  def self.set(_settingname, oldsetting)
    ret = pbChooseTypeList(oldsetting || nil)
    return ret || oldsetting
  end

  def self.defaultValue
    return nil
  end

  def self.format(value)
    return (value && GameData::Type.exists?(value)) ? GameData::Type.get(value).real_name : "-"
  end
end


module CharacterProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, GraphicsLister.new("Graphics/Characters/", oldsetting))
    return (chosenmap && chosenmap != "") ? chosenmap : oldsetting
  end

  def self.format(value)
    return value
  end
end



module MapSizeProperty
  def self.set(settingname, oldsetting)
    oldsetting = [0, ""] if !oldsetting
    properties = [
      [_INTL("Width"),         NonzeroLimitProperty.new(30), _INTL("The width of this map in Region Map squares.")],
      [_INTL("Valid Squares"), StringProperty,               _INTL("A series of 1s and 0s marking which squares are part of this map (1=part, 0=not part).")]
    ]
    pbPropertyList(settingname, oldsetting, properties, false)
    return oldsetting
  end

  def self.format(value)
    return value.inspect
  end
end



def chooseMapPoint(map, rgnmap = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  title = Window_UnformattedTextPokemon.newWithSize(
    _INTL("Click a point on the map."), 0, Graphics.height - 64, Graphics.width, 64, viewport
  )
  title.z = 2
  if rgnmap
    sprite = RegionMapSprite.new(map, viewport)
  else
    sprite = MapSprite.new(map, viewport)
  end
  sprite.z = 2
  ret = nil
  loop do
    Graphics.update
    Input.update
    xy = sprite.getXY
    if xy
      ret = xy
      break
    end
    if Input.trigger?(Input::BACK)
      ret = nil
      break
    end
  end
  sprite.dispose
  title.dispose
  return ret
end



module MapCoordsProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap >= 0
      mappoint = chooseMapPoint(chosenmap)
      return (mappoint) ? [chosenmap, mappoint[0], mappoint[1]] : oldsetting
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module MapCoordsFacingProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MapLister.new((oldsetting) ? oldsetting[0] : 0))
    if chosenmap >= 0
      mappoint = chooseMapPoint(chosenmap)
      if mappoint
        facing = pbMessage(_INTL("Choose the direction to face in."),
                           [_INTL("Down"), _INTL("Left"), _INTL("Right"), _INTL("Up")], -1)
        return (facing >= 0) ? [chosenmap, mappoint[0], mappoint[1], [2, 4, 6, 8][facing]] : oldsetting
      else
        return oldsetting
      end
    else
      return oldsetting
    end
  end

  def self.format(value)
    return value.inspect
  end
end



module WeatherEffectProperty
  def self.set(_settingname, oldsetting)
    oldsetting = [:None, 100] if !oldsetting
    options = []
    ids = []
    default = 0
    GameData::Weather.each do |w|
      default = ids.length if w.id == oldsetting[0]
      options.push(w.real_name)
      ids.push(w.id)
    end
    cmd = pbMessage(_INTL("Choose a weather effect."), options, -1, nil, default)
    return nil if cmd < 0 || ids[cmd] == :None
    params = ChooseNumberParams.new
    params.setRange(0, 100)
    params.setDefaultValue(oldsetting[1])
    number = pbMessageChooseNumber(_INTL("Set the probability of the weather."), params)
    return [ids[cmd], number]
  end

  def self.format(value)
    return (value) ? GameData::Weather.get(value[0]).real_name + ",#{value[1]}" : "-"
  end
end



module MapProperty
  def self.set(settingname, oldsetting)
    chosenmap = pbListScreen(settingname, MapLister.new(oldsetting || 0))
    return (chosenmap > 0) ? chosenmap : oldsetting
  end

  def self.defaultValue
    return 0
  end

  def self.format(value)
    return value.inspect
  end
end


class GameDataPoolProperty
  def initialize(game_data, allow_multiple = true, auto_sort = false)
    if !GameData.const_defined?(game_data.to_sym)
      raise _INTL("Couldn't find class {1} in module GameData.", game_data.to_s)
    end
    @game_data = game_data
    @game_data_module = GameData.const_get(game_data.to_sym)
    @allow_multiple = allow_multiple
    @auto_sort = auto_sort   # Alphabetically
  end

  def set(setting_name, old_setting)
    ret = old_setting
    old_setting.uniq! if !@allow_multiple
    old_setting.sort! if @auto_sort
    # Get all values already in the pool
    values = []
    values.push([nil, _INTL("[ADD VALUE]")])   # Value ID, name
    old_setting.each do |value|
      values.push([value, @game_data_module.get(value).real_name])
    end
    # Set things up
    command_window = pbListWindow([], 200)
    cmd = [0, 0]   # [input type, list index] (input type: 0=select, 1=swap up, 2=swap down)
    commands = []
    need_refresh = true
    # Edit value pool
    loop do
      if need_refresh
        if @auto_sort
          values.sort! { |a, b| (a[0].nil?) ? -1 : b[0].nil? ? 1 : a[1] <=> b[1] }
        end
        commands = values.map { |entry| entry[1] }
        need_refresh = false
      end
      # Choose a value
      cmd = pbCommands3(command_window, commands, -1, cmd[1], true)
      case cmd[0]   # 0=selected/cancelled, 1=pressed Action+Up, 2=pressed Action+Down
      when 1   # Swap value up
        if cmd[1] > 0 && cmd[1] < values.length - 1
          values[cmd[1] + 1], values[cmd[1]] = values[cmd[1]], values[cmd[1] + 1]
          need_refresh = true
        end
      when 2   # Swap value down
        if cmd[1] > 1
          values[cmd[1] - 1], values[cmd[1]] = values[cmd[1]], values[cmd[1] - 1]
          need_refresh = true
        end
      when 0
        if cmd[1] >= 0   # Chose an entry
          entry = values[cmd[1]]
          if entry[0].nil?   # Add new value
            new_value = pbChooseFromGameDataList(@game_data)
            if new_value
              if !@allow_multiple && values.any? { |val| val[0] == new_value }
                cmd[1] = values.index { |val| val[0] == new_value }
                next
              end
              values.push([new_value, @game_data_module.get(new_value).real_name])
              need_refresh = true
            end
          else   # Edit existing value
            case pbMessage(_INTL("\\ts[]Do what with this value?"),
                           [_INTL("Change value"), _INTL("Delete"), _INTL("Cancel")], 3)
            when 0   # Change value
              new_value = pbChooseFromGameDataList(@game_data, entry[0])
              if new_value && new_value != entry[0]
                if !@allow_multiple && values.any? { |val| val[0] == new_value }
                  values.delete_at(cmd[1])
                  cmd[1] = values.index { |val| val[0] == new_value }
                  need_refresh = true
                  next
                end
                entry[0] = new_value
                entry[1] = @game_data_module.get(new_value).real_name
                if @auto_sort
                  values.sort! { |a, b| a[1] <=> b[1] }
                  cmd[1] = values.index { |val| val[0] == new_value }
                end
                need_refresh = true
              end
            when 1   # Delete
              values.delete_at(cmd[1])
              cmd[1] = [cmd[1], values.length - 1].min
              need_refresh = true
            end
          end
        else   # Cancel/quit
          case pbMessage(_INTL("Apply changes?"),
                         [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
          when 0
            values.shift   # Remove the "add value" option
            values.length.times do |i|
              values[i] = values[i][0]
            end
            values.compact!
            ret = values
            break
          when 1
            break
          end
        end
      end
    end
    command_window.dispose
    return ret
  end

  def defaultValue
    return []
  end

  def format(value)
    return value.map { |val| @game_data_module.get(val).real_name }.join(",")
  end
end

#===============================================================================
# Core property editor script
#===============================================================================
def pbPropertyList(title, data, properties, saveprompt = false)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], Graphics.width / 2)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(
    title, list.width, 0, Graphics.width / 2, 64, viewport
  )
  title.z = 2
  desc = Window_UnformattedTextPokemon.newWithSize(
    "", list.width, title.height, Graphics.width / 2, Graphics.height - title.height, viewport
  )
  desc.z = 2
  selectedmap = -1
  retval = nil
  commands = []
  properties.length.times do |i|
    propobj = properties[i][1]
    commands.push(sprintf("%s=%s", properties[i][0], propobj.format(data[i])))
  end
  list.commands = commands
  list.index    = 0
  loop do
    loop do
      Graphics.update
      Input.update
      list.update
      desc.update
      if list.index != selectedmap
        desc.text = properties[list.index][2]
        selectedmap = list.index
      end
      if Input.trigger?(Input::ACTION)
        propobj = properties[selectedmap][1]
        if propobj != ReadOnlyProperty && !propobj.is_a?(ReadOnlyProperty) &&
           pbConfirmMessage(_INTL("Reset the setting {1}?", properties[selectedmap][0]))
          if propobj.respond_to?("defaultValue")
            data[selectedmap] = propobj.defaultValue
          else
            data[selectedmap] = nil
          end
        end
        commands.clear
        properties.length.times do |i|
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s", properties[i][0], propobj.format(data[i])))
        end
        list.commands = commands
      elsif Input.trigger?(Input::BACK)
        selectedmap = -1
        break
      elsif Input.trigger?(Input::USE)
        propobj = properties[selectedmap][1]
        oldsetting = data[selectedmap]
        newsetting = propobj.set(properties[selectedmap][0], oldsetting)
        data[selectedmap] = newsetting
        commands.clear
        properties.length.times do |i|
          propobj = properties[i][1]
          commands.push(sprintf("%s=%s", properties[i][0], propobj.format(data[i])))
        end
        list.commands = commands
        break
      end
    end
    if selectedmap == -1 && saveprompt
      cmd = pbMessage(_INTL("Save changes?"),
                      [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
      if cmd == 2
        selectedmap = list.index
      else
        retval = (cmd == 0)
      end
    end
    break unless selectedmap != -1
  end
  title.dispose
  list.dispose
  desc.dispose
  Input.update
  return retval
end
