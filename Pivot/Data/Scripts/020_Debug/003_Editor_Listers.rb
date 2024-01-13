#===============================================================================
# Core lister script
#===============================================================================
def pbListWindow(cmds, width = Graphics.width / 2)
  list = Window_CommandPokemon.newWithSize(cmds, 0, 0, width, Graphics.height)
  list.index     = 0
  list.rowHeight = 24
  pbSetSmallFont(list.contents)
  list.refresh
  return list
end

def pbListScreen(title, lister)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  list = pbListWindow([])
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(
    title, Graphics.width / 2, 0, Graphics.width / 2, 64, viewport
  )
  title.z = 2
  lister.setViewport(viewport)
  selectedmap = -1
  commands = lister.commands
  selindex = lister.startIndex
  if commands.length == 0
    value = lister.value(-1)
    lister.dispose
    title.dispose
    list.dispose
    viewport.dispose
    return value
  end
  list.commands = commands
  list.index    = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index != selectedmap
      lister.refresh(list.index)
      selectedmap = list.index
    end
    if Input.trigger?(Input::BACK)
      selectedmap = -1
      break
    elsif Input.trigger?(Input::USE)
      break
    end
  end
  value = lister.value(selectedmap)
  lister.dispose
  title.dispose
  list.dispose
  viewport.dispose
  Input.update
  return value
end

def pbListScreenBlock(title, lister)
  viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
  viewport.z = 99999
  list = pbListWindow([], Graphics.width / 2)
  list.viewport = viewport
  list.z        = 2
  title = Window_UnformattedTextPokemon.newWithSize(
    title, Graphics.width / 2, 0, Graphics.width / 2, 64, viewport
  )
  title.z = 2
  lister.setViewport(viewport)
  selectedmap = -1
  commands = lister.commands
  selindex = lister.startIndex
  if commands.length == 0
    value = lister.value(-1)
    lister.dispose
    title.dispose
    list.dispose
    viewport.dispose
    return value
  end
  list.commands = commands
  list.index = selindex
  loop do
    Graphics.update
    Input.update
    list.update
    if list.index != selectedmap
      lister.refresh(list.index)
      selectedmap = list.index
    end
    if Input.trigger?(Input::ACTION)
      yield(Input::ACTION, lister.value(selectedmap))
      list.commands = lister.commands
      if list.index == list.commands.length
        list.index = list.commands.length
      end
      lister.refresh(list.index)
    elsif Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::USE)
      yield(Input::USE, lister.value(selectedmap))
      list.commands = lister.commands
      if list.index == list.commands.length
        list.index = list.commands.length
      end
      lister.refresh(list.index)
    end
  end
  lister.dispose
  title.dispose
  list.dispose
  viewport.dispose
  Input.update
end

#===============================================================================
#
#===============================================================================
class GraphicsLister
  def initialize(folder, selection)
    @sprite = IconSprite.new(0, 0)
    @sprite.bitmap = nil
    @sprite.x      = Graphics.width * 3 / 4
    @sprite.y      = ((Graphics.height - 64) / 2) + 64
    @sprite.z      = 2
    @folder = folder
    @selection = selection
    @commands = []
    @index = 0
  end

  def dispose
    @sprite.bitmap&.dispose
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    Dir.chdir(@folder) {
      Dir.glob("*.png") { |f| @commands.push(f) }
      Dir.glob("*.PNG") { |f| @commands.push(f) }
      Dir.glob("*.gif") { |f| @commands.push(f) }
      Dir.glob("*.GIF") { |f| @commands.push(f) }
#      Dir.glob("*.jpg") { |f| @commands.push(f) }
#      Dir.glob("*.JPG") { |f| @commands.push(f) }
#      Dir.glob("*.jpeg") { |f| @commands.push(f) }
#      Dir.glob("*.JPEG") { |f| @commands.push(f) }
#      Dir.glob("*.bmp") { |f| @commands.push(f) }
#      Dir.glob("*.BMP") { |f| @commands.push(f) }
    }
    @commands.sort!
    @commands.length.times do |i|
      @index = i if @commands[i] == @selection
    end
    pbMessage(_INTL("There are no files.")) if @commands.length == 0
    return @commands
  end

  def value(index)
    return (index < 0) ? "" : @commands[index]
  end

  def refresh(index)
    return if index < 0
    @sprite.setBitmap(@folder + @commands[index])
    sprite_width = @sprite.bitmap.width
    sprite_height = @sprite.bitmap.height
    @sprite.ox = sprite_width / 2
    @sprite.oy = sprite_height / 2
    scale_x = (Graphics.width / 2).to_f / sprite_width
    scale_y = (Graphics.height - 64).to_f / sprite_height
    if scale_x < 1.0 || scale_y < 1.0
      min_scale = [scale_x, scale_y].min
      @sprite.zoom_x = @sprite.zoom_y = min_scale
    else
      @sprite.zoom_x = @sprite.zoom_y = 1.0
    end
  end
end

#===============================================================================
#
#===============================================================================
class MusicFileLister
  def initialize(bgm, setting)
    @oldbgm = getPlayingBGM
    @commands = []
    @bgm = bgm
    @setting = setting
    @index = 0
  end

  def dispose
    pbPlayBGM(@oldbgm)
  end

  def setViewport(viewport)
  end

  def getPlayingBGM
    ($game_system) ? $game_system.getPlayingBGM : nil
  end

  def pbPlayBGM(bgm)
    (bgm) ? pbBGMPlay(bgm) : pbBGMStop
  end

  def startIndex
    return @index
  end

  def commands
    folder = (@bgm) ? "Audio/BGM/" : "Audio/ME/"
    @commands.clear
    Dir.chdir(folder) {
#      Dir.glob("*.mp3") { |f| @commands.push(f) }
      Dir.glob("*.ogg") { |f| @commands.push(f) }
      Dir.glob("*.wav") { |f| @commands.push(f) }
      Dir.glob("*.mid") { |f| @commands.push(f) }
      Dir.glob("*.midi") { |f| @commands.push(f) }
    }
    @commands.uniq!
    @commands.sort! { |a, b| a.downcase <=> b.downcase }
    @commands.length.times do |i|
      @index = i if @commands[i] == @setting
    end
    pbMessage(_INTL("There are no files.")) if @commands.length == 0
    return @commands
  end

  def value(index)
    return (index < 0) ? "" : @commands[index]
  end

  def refresh(index)
    return if index < 0
    if @bgm
      pbPlayBGM(@commands[index])
    else
      pbPlayBGM("../../Audio/ME/" + @commands[index])
    end
  end
end

#===============================================================================
#
#===============================================================================
class MetadataLister
  def initialize(sel_player_id = -1, new_player = false)
    @index = 0
    @commands = []
    @player_ids = []
    GameData::PlayerMetadata.each do |player|
      @index = @commands.length + 1 if sel_player_id > 0 && player.id == sel_player_id
      @player_ids.push(player.id)
    end
    @new_player = new_player
  end

  def dispose; end

  def setViewport(viewport); end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @commands.push(_INTL("[GLOBAL METADATA]"))
    @player_ids.each { |id| @commands.push(_INTL("Player {1}", id)) }
    @commands.push(_INTL("[ADD NEW PLAYER]")) if @new_player
    return @commands
  end

  # Cancel: -1
  # New player: -2
  # Global metadata: 0
  # Player character: 1+ (the player ID itself)
  def value(index)
    return index if index < 1
    return -2 if @new_player && index == @commands.length - 1
    return @player_ids[index - 1]
  end

  def refresh(index); end
end

#===============================================================================
#
#===============================================================================
class MapLister
  def initialize(selmap, addGlobal = false)
    @sprite = Sprite.new
    @sprite.bitmap = nil
    @sprite.x      = Graphics.width * 3 / 4
    @sprite.y      = ((Graphics.height - 64) / 2) + 64
    @sprite.z      = -2
    @commands = []
    @maps = pbMapTree
    @addGlobalOffset = (addGlobal) ? 1 : 0
    @index = 0
    @maps.length.times do |i|
      @index = i + @addGlobalOffset if @maps[i][0] == selmap
    end
  end

  def dispose
    @sprite.bitmap&.dispose
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    if @addGlobalOffset == 1
      @commands.push(_INTL("[GLOBAL]"))
    end
    @maps.length.times do |i|
      @commands.push(sprintf("%s%03d %s", ("  " * @maps[i][2]), @maps[i][0], @maps[i][1]))
    end
    return @commands
  end

  def value(index)
    return 0 if @addGlobalOffset == 1 && index == 0
    return (index < 0) ? -1 : @maps[index - @addGlobalOffset][0]
  end

  def refresh(index)
    @sprite.bitmap&.dispose
    return if index < 0
    return if index == 0 && @addGlobalOffset == 1
    @sprite.bitmap = createMinimap(@maps[index - @addGlobalOffset][0])
    @sprite.ox = @sprite.bitmap.width / 2
    @sprite.oy = @sprite.bitmap.height / 2
  end
end

#===============================================================================
#
#===============================================================================
class TrainerTypeLister
  def initialize(selection = 0, includeNew = false)
    @sprite = IconSprite.new(Graphics.width * 3 / 4, ((Graphics.height - 64) / 2) + 64)
    @sprite.z = 2
    @selection = selection
    @commands = []
    @ids = []
    @includeNew = includeNew
    @index = 0
  end

  def dispose
    @sprite.bitmap&.dispose
    @sprite.dispose
  end

  def setViewport(viewport)
    @sprite.viewport = viewport
  end

  def startIndex
    return @index
  end

  def commands
    @commands.clear
    @ids.clear
    cmds = []
    idx = 1
    GameData::TrainerType.each do |tr_type|
      cmds.push([idx, tr_type.id, tr_type.real_name])
      idx += 1
    end
    cmds.sort! { |a, b| a[2] == b[2] ? a[0] <=> b[0] : a[2].downcase <=> b[2].downcase }
    if @includeNew
      @commands.push(_INTL("[NEW TRAINER TYPE]"))
      @ids.push(true)
    end
    cmds.each do |t|
      @commands.push(sprintf("%03d: %s", t[0], t[2]))
      @ids.push(t[1])
    end
    @index = @selection
    @index = @commands.length - 1 if @index >= @commands.length
    @index = 0 if @index < 0
    return @commands
  end

  def value(index)
    return nil if index < 0
    return @ids[index]
  end

  def refresh(index)
    @sprite.bitmap&.dispose
    return if index < 0
    begin
      if @ids[index].is_a?(Symbol)
        @sprite.setBitmap(GameData::TrainerType.front_sprite_filename(@ids[index]), 0)
      else
        @sprite.setBitmap(nil)
      end
    rescue
      @sprite.setBitmap(nil)
    end
    if @sprite.bitmap
      @sprite.ox = @sprite.bitmap.width / 2
      @sprite.oy = @sprite.bitmap.height / 2
    end
  end
end