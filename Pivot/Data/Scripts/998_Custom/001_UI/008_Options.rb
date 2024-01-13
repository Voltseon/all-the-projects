#===============================================================================
#
#===============================================================================
class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :sendtoboxes
  attr_accessor :givenicknames
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :screensize
  attr_accessor :language
  attr_accessor :runstyle
  attr_accessor :bgmvolume
  attr_accessor :sevolume
  attr_accessor :voicevolume
  attr_accessor :textinput
  attr_accessor :loadtransition

  def initialize
    @loadtransition = false
    @textspeed      = 1     # Text speed (0=slow, 1=normal, 2=fast)
    @battlescene    = 0     # Battle effects (animations) (0=on, 1=off)
    @battlestyle    = 0     # Battle style (0=switch, 1=set)
    @sendtoboxes    = 0     # Send to Boxes (0=manual, 1=automatic)
    @givenicknames  = 0     # Give nicknames (0=give, 1=don't give)
    @frame          = 0     # Default window frame (see also Settings::MENU_WINDOWSKINS)
    @textskin       = 0     # Speech frame
    @screensize     = (Settings::SCREEN_SCALE * 2).floor - 1   # 0=half size, 1=full size, 2=full-and-a-half size, 3=double size
    @language       = 0     # Language (see also Settings::LANGUAGES in script PokemonSystem)
    @runstyle       = 0     # Default movement speed (0=walk, 1=run)
    @bgmvolume      = 50    # Volume of background music and ME
    @sevolume       = 50    # Volume of sound effects
    @voicevolume    = 50    # Volume of voice
    @textinput      = 1     # Text input mode (0=cursor, 1=keyboard)
  end
end

#===============================================================================
#
#===============================================================================
module PropertyMixin
  attr_reader :name

  def get
    return @get_proc&.call
  end

  def set(*args)
    @set_proc&.call(*args)
  end
end

#===============================================================================
#
#===============================================================================
class EnumOption
  include PropertyMixin
  attr_reader :values

  def initialize(name, values, get_proc, set_proc)
    @name     = name
    @values   = values.map { |val| _INTL(val) }
    @get_proc = get_proc
    @set_proc = set_proc
  end

  def next(current)
    index = current + 1
    index = @values.length - 1 if index > @values.length - 1
    return index
  end

  def prev(current)
    index = current - 1
    index = 0 if index < 0
    return index
  end
end

#===============================================================================
#
#===============================================================================
class NumberOption
  include PropertyMixin
  attr_reader :lowest_value
  attr_reader :highest_value

  def initialize(name, range, get_proc, set_proc)
    @name = name
    case range
    when Range
      @lowest_value  = range.begin
      @highest_value = range.end
    when Array
      @lowest_value  = range[0]
      @highest_value = range[1]
    end
    @get_proc = get_proc
    @set_proc = set_proc
  end

  def next(current)
    index = current + @lowest_value
    index += 1
    index = @lowest_value if index > @highest_value
    return index - @lowest_value
  end

  def prev(current)
    index = current + @lowest_value
    index -= 1
    index = @highest_value if index < @lowest_value
    return index - @lowest_value
  end
end

#===============================================================================
#
#===============================================================================
class SliderOption
  include PropertyMixin
  attr_reader :lowest_value
  attr_reader :highest_value

  def initialize(name, range, get_proc, set_proc)
    @name          = name
    @lowest_value  = range[0]
    @highest_value = range[1]
    @interval      = range[2]
    @get_proc      = get_proc
    @set_proc      = set_proc
  end

  def next(current)
    index = current + @lowest_value
    index += @interval
    index = @highest_value if index > @highest_value
    return index - @lowest_value
  end

  def prev(current)
    index = current + @lowest_value
    index -= @interval
    index = @lowest_value if index < @lowest_value
    return index - @lowest_value
  end
end

#===============================================================================
# Main options list
#===============================================================================
class Window_PokemonOption < Window_DrawableCommand
  attr_reader :value_changed

  SEL_NAME_BASE_COLOR    = Color.new(192, 120, 0)
  SEL_NAME_SHADOW_COLOR  = Color.new(248, 176, 80)
  SEL_VALUE_BASE_COLOR   = Color.new(255, 194, 0)
  SEL_VALUE_SHADOW_COLOR = Color.new(153, 68, 0)

  def initialize(options, x, y, width, height)
    @options = options
    @values = []
    @options.length.times { |i| @values[i] = 0 }
    @value_changed = false
    super(x, y, width, height)
    self.rowHeight = 56
    @index = @options.length
  end

  def [](i)
    return @values[i]
  end

  def []=(i, value)
    @values[i] = value
    refresh
  end

  def setValueNoRefresh(i, value)
    @values[i] = value
  end

  def itemCount
    return @options.length + 1
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    sel_index = self.index
    # Draw option's name
    optionname = (index == @options.length) ? _INTL("Close") : @options[index].name
    optionwidth = 408
    pbDrawShadowText(self.contents, rect.x, rect.y, optionwidth, rect.height, optionname,
                     (index == sel_index) ? SEL_NAME_BASE_COLOR : MainMenu::BASE_COLOR,
                     (index == sel_index) ? SEL_NAME_SHADOW_COLOR : MainMenu::SHADOW_COLOR)
    return if index == @options.length
    # Draw option's values
    case @options[index]
    when EnumOption
      if @options[index].values.length > 1
        totalwidth = 0
        @options[index].values.each do |value|
          totalwidth += self.contents.text_size(value).width
        end
        spacing = 100
        spacing = 0 if spacing < 0
        xpos = 318
        ivalue = 0
        @options[index].values.each do |value|
          pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                           (ivalue == self[index]) ? SEL_VALUE_BASE_COLOR : self.baseColor,
                           (ivalue == self[index]) ? SEL_VALUE_SHADOW_COLOR : self.shadowColor)
          xpos += self.contents.text_size(value).width
          xpos += spacing
          ivalue += 1
        end
      else
        pbDrawShadowText(self.contents, rect.x + optionwidth, rect.y, optionwidth, rect.height,
                         optionname, self.baseColor, self.shadowColor)
      end
    when NumberOption
      value = _INTL("Type {1}/{2}", @options[index].lowest_value + self[index],
                    @options[index].highest_value - @options[index].lowest_value + 1)
      xpos = optionwidth - 86
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR, 1)
    when SliderOption
      value = sprintf(" %d", @options[index].highest_value)
      sliderlength = 332
      xpos = 320
      offset = 0
      self.contents.fill_rect(xpos-2, rect.y - 12 + (rect.height / 2) - 2, sliderlength, 4+2, Color.new(219, 97, 15))
      self.contents.fill_rect(xpos-2, rect.y - 12 + (rect.height / 2) + 4, sliderlength, 2, Color.new(255, 124, 43))
      self.contents.fill_rect(xpos+sliderlength-4, rect.y - 12 + (rect.height / 2), 2, 4, Color.new(255, 124, 43))
      self.contents.fill_rect(xpos, rect.y - 12 + (rect.height / 2), sliderlength-4, 4, Color.new(183, 70, 13))
      if Mouse.press? && Mouse.over_area?(xpos+132 ,rect.y+100, sliderlength+58, 32)
        offset = Mouse.x-(20+xpos-142 + ((sliderlength) * (@options[index].lowest_value + self[index]) / @options[index].highest_value))
        oldindex = self[index]
        newindex = [[((Mouse.x-xpos-142-20).to_f/(sliderlength - 8).to_f * @options[index].highest_value.to_f).round, @options[index].lowest_value].max, @options[index].highest_value].min
        self[index] = newindex if newindex != oldindex && newindex.is_a?(Integer) && newindex >= @options[index].lowest_value && newindex <= @options[index].highest_value
      end
=begin
      self.contents.fill_rect(
        xpos + ((sliderlength - 8) * (@options[index].lowest_value + self[index]) / @options[index].highest_value),
        rect.y - 18 + (rect.height / 2),
        8, 16, SEL_VALUE_BASE_COLOR
      )
=end
      # Display a sprite instead of a rectangle
      @sprites["slider#{index}"].dispose if @sprites["slider#{index}"]
      @sprites["slider#{index}"] = IconSprite.new(154+xpos + ((sliderlength - 8) * (@options[index].lowest_value + self[index]) / @options[index].highest_value), 80 + rect.y - 4 + (rect.height / 2), @viewport)
      @sprites["slider#{index}"].setBitmap("Graphics/Pictures/Menu/options_slider_indicator")
      @sprites["slider#{index}"].z = 99999
      value = sprintf("%d", (@options[index].lowest_value + self[index]))
      xpos += (rect.width - rect.x - optionwidth) - self.contents.text_size(value).width
      pbDrawShadowText(self.contents, xpos-36, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    else
      value = @options[index].values[self[index]]
      xpos = optionwidth + rect.x
      pbDrawShadowText(self.contents, xpos, rect.y, optionwidth, rect.height, value,
                       SEL_VALUE_BASE_COLOR, SEL_VALUE_SHADOW_COLOR)
    end
  end

  def update
    oldindex = self.index
    @value_changed = false
    Mouse.update
    if Mouse.over_area?(self.x+4, self.y+8, self.width-16, self.height-84)
      new_index = (Mouse.y - self.y - 16) / self.rowHeight
      if new_index != self.index
        self.index = new_index
        if $april_fools
          case self.index
          when 0
            pbAnnounce(:fools_music_volume)
          when 1
            pbAnnounce(:fools_se_volume)
          when 2
            pbAnnounce(:fools_announcer_volume)
          when 3
            pbAnnounce(:fools_screen_size)
          when 4
            pbAnnounce(:fools_configure_controls)
          when 5
            pbAnnounce(:fools_close)
          end
        end
      end
    else
      self.index = @options.length+1
    end
    #self.index = @options.length if self.index > @options.length
    self.index = 0 if self.index < 0
    super
    dorefresh = (self.index != oldindex)
    if self.active && self.index < @options.length
      if Mouse.press? && Mouse.over_area?(454, self.y+8, 416, self.height-84) && self.index == 3
        self[self.index] = ((Mouse.x-454)/115)
        dorefresh = true
        @value_changed = true
      elsif Mouse.press?
        dorefresh = true
        @value_changed = true
      end
    end
    refresh if dorefresh
  end
end

#===============================================================================
# Options main screen
#===============================================================================
class PokemonOption_Scene
  attr_accessor :sprites
  attr_accessor :frame
  attr_reader :in_load_screen

  def pbStartScene(in_load_screen = false)
    @disposed = false
    @in_load_screen = in_load_screen
    # Get all options
    @options = []
    @hashes = []
    ListHandlers.each_available(:options_menu) do |option, hash, name|
      @options.push(
        hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
      )
      @hashes.push(hash)
    end
    # Create sprites
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @overlay = nil
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    @smalltext = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @smalltext.z = 99999
    pbSetSystemFont(@overlay.bitmap)
    pbSetSmallFont(@smalltext.bitmap)
    @sprites["bg"] = ChangelingSprite.new(0,0,@viewport)
    MainMenu::ANIMATED_BGS[MainMenu::BG_GRAPHIC]["frames"].times do |i|
      @sprites["bg"].addBitmap(i, "Graphics/Pictures/Animated Backgrounds/#{MainMenu::BG_GRAPHIC}_#{i}")
    end
    @sprites["bg"].changeBitmap(0)
    @sprites["top_bar"] = IconSprite.new(0,0,@viewport)
    @sprites["top_bar"].setBitmap("Graphics/Pictures/Menu/topbar")
    @sprites["name"] = ButtonSprite.new(self,"",MainMenu::PATH+"empty",MainMenu::PATH+"empty",proc{ },0,Graphics.width-174, 0,@viewport, nil, proc{pbAnnounce(:fools_rename) if $april_fools}, "#{$player.name} Lv. #{$player.level}")
    @sprites["name"].setTextOffset(0,4)
    @sprites["name"].text_align = 1
    @sprites["options_bg"] = IconSprite.new(146,86,@viewport)
    @sprites["options_bg"].setBitmap("Graphics/Pictures/Menu/options_bg")
    @sprites["option"] = Window_PokemonOption.new(
      @options, 142, 80, Graphics.width-142, Graphics.height-156
    )
    @sprites["option"].viewport = @viewport
    @sprites["option"].setSkin("Graphics/Windowskins/choice 0")
    @sprites["option"].visible  = true
    @sprites["credits"] = ButtonSprite.new(self, "Play Credits",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; @disposed = true; Credits.new},0,(Graphics.width/2)-268,480,@viewport, nil, proc{pbAnnounce(:fools_play_credits) if $april_fools})
    @sprites["credits"].setTextOffset(0,24)
    @sprites["credits"].visible = !$game_temp.in_a_lobby
    @sprites["patch_notes"] = ButtonSprite.new(self,"Patch Notes",MainMenu::PATH+"button",MainMenu::PATH+"button_highlight",proc{pbPlayDecisionSE; System.launch("https://cdn.discordapp.com/attachments/1078275182201929748/1090929839999041556/image.png")},0,(Graphics.width/2)+4,480,@viewport,nil,proc{pbAnnounce(:fools_patch_notes) if $april_fools})
    @sprites["patch_notes"].setTextOffset(0,24)
    @sprites["patch_notes"].visible = !$game_temp.in_a_lobby
    @sprites["back"] = ButtonSprite.new(self,"",MainMenu::PATH+"back",MainMenu::PATH+"back_highlight",proc{pbPlayCloseMenuSE; @disposed = true},0,24,80,@viewport, nil, proc{pbAnnounce(:fools_back) if $april_fools})
    # Get the values of each option
    @options.length.times { |i|  @sprites["option"].setValueNoRefresh(i, @options[i].get || 0) }
    @sprites["option"].refresh
    pbChangeSelection
    pbDeactivateWindows(@sprites)
  end

  def pbChangeSelection
    hash = @hashes[@sprites["option"].index]
    # Call selected option's "on_select" proc (if defined)
    hash["on_select"]&.call(self) if hash
    # Set descriptive text
    description = ""
    if hash
      if hash["description"].is_a?(Proc)
        description = hash["description"].call
      elsif !hash["description"].nil?
        description = _INTL(hash["description"])
      end
    else
      description = _INTL("Close the screen.")
    end
  end

  def pbOptions
    pbActivateWindow(@sprites, "option") {
      index = -1
      pbAnnounce(:fools_options) if $april_fools
      @frame = 0
      loop do
        break if @disposed
        bg = MainMenu::ANIMATED_BGS[MainMenu::BG_GRAPHIC]
        @sprites["bg"].changeBitmap(@frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]) if @sprites["bg"].currentKey != @frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]
        Graphics.update
        Input.update
        pbUpdate
        textpos = []
        smalltextpos = []
        #@sprites["option"].index -= Input::scroll_v unless Input::scroll_v == 0 || (@sprites["option"].index - Input::scroll_v) < 0 || (@sprites["option"].index - Input::scroll_v) > @options.length
        if @sprites["option"].index != index
          pbChangeSelection
          index = @sprites["option"].index
        end
        # Draw top bar info
        @sprites["name"].subtitle = "#{$player.name} Lv. #{$player.level}"
        #textpos.push(["#{$player.name} Lv. #{$player.level}",Graphics.width-16, 16, 1, BASE_COLOR, SHADOW_COLOR])
        @overlay.bitmap.fill_rect(Graphics.width-112,46,96,8,MainMenu::EXP_EMPTY)
        part = ($player.exp.to_f-$player.exp_to_current_level.to_f)/($player.total_exp_to_next_level.to_f-$player.exp_to_current_level.to_f)
        @overlay.bitmap.fill_rect(Graphics.width-112,46,part*96,8,MainMenu::EXP_FULL)
        textpos.push(["Options",Graphics.width/2+48, 24, 1, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
        smalltextpos.push(["Pivot v#{Settings::GAME_VERSION}",8, Graphics.height-24, 0, MainMenu::BASE_COLOR, MainMenu::SHADOW_COLOR])
        pbDrawTextPositions(@overlay.bitmap, textpos)
        pbDrawTextPositions(@smalltext.bitmap, smalltextpos)
        @options[index].set(@sprites["option"][index], self) if @sprites["option"].value_changed
        if Input.trigger?(Input::BACK)
          break
        elsif Input.trigger?(Input::USE) || Mouse.trigger?
          if @sprites["option"].index == @options.length
            break
          elsif @sprites["option"].index == @options.length-1
            pbPlayDecisionSE
            open_set_controls_ui
          end
        end
        pbGlobalFadeIn(24, self) if $overlay.faded_out?
        @frame += 1
      end
    }
  end

  def pbEndScene
    @disposed = true
    pbPlayCloseMenuSE
    pbGlobalFadeOut
    # Set the values of each option, to make sure they're all set
    @options.length.times do |i|
      @options[i].set(@sprites["option"][i], self)
    end
    Game.save unless $game_temp.tutorial_calling
    pbDisposeSpriteHash(@sprites)
    pbUpdateSceneMap
    @viewport.dispose
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonOptionScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen(in_load_screen = false)
    pbGlobalFadeOut
    @scene.pbStartScene(in_load_screen)
    @scene.pbOptions
    @scene.pbEndScene
  end
end

#===============================================================================
# Options Menu commands
#===============================================================================
ListHandlers.add(:options_menu, :bgm_volume, {
  "name"        => _INTL("Music Volume"),
  "order"       => 10,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of the background music."),
  "get_proc"    => proc { next $PokemonSystem.bgmvolume },
  "set_proc"    => proc { |value, scene|
    next if $PokemonSystem.bgmvolume == value
    $PokemonSystem.bgmvolume = value
    pbBGMPlay("BR 31 Reception Desk", 80) if scene.in_load_screen
    next if scene.in_load_screen || $game_system.playing_bgm.nil?
    playingBGM = $game_system.getPlayingBGM
    $game_system.bgm_pause
    $game_system.bgm_resume(playingBGM)
  }
})

ListHandlers.add(:options_menu, :se_volume, {
  "name"        => _INTL("SE Volume"),
  "order"       => 20,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of sound effects."),
  "get_proc"    => proc { next $PokemonSystem.sevolume },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.sevolume == value
    $PokemonSystem.sevolume = value
    if $game_system.playing_bgs
      $game_system.playing_bgs.volume = value
      playingBGS = $game_system.getPlayingBGS
      $game_system.bgs_pause
      $game_system.bgs_resume(playingBGS)
    end
    pbPlayCursorSE
  }
})

ListHandlers.add(:options_menu, :voice_volume, {
  "name"        => _INTL("Announcer Volume"),
  "order"       => 30,
  "type"        => SliderOption,
  "parameters"  => [0, 100, 5],   # [minimum_value, maximum_value, interval]
  "description" => _INTL("Adjust the volume of sound effects."),
  "get_proc"    => proc { next $PokemonSystem.voicevolume },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.voicevolume == value
    $PokemonSystem.voicevolume = value
    pbAnnounce(:that_hurt) # Change this later to a shorter voice clip
  }
})

ListHandlers.add(:options_menu, :screen_size, {
  "name"        => _INTL("Screen Size"),
  "order"       => 120,
  "type"        => EnumOption,
  "parameters"  => [_INTL("S"), _INTL("M"), _INTL("L"), _INTL("Full")],
  "description" => _INTL("Choose the size of the game window."),
  "get_proc"    => proc { next [$PokemonSystem.screensize, 4].min },
  "set_proc"    => proc { |value, _scene|
    next if $PokemonSystem.screensize == value
    $PokemonSystem.screensize = value
    pbSetResizeFactor($PokemonSystem.screensize)
  }
})

ListHandlers.add(:options_menu, :open_controls, {
  "name"        => _INTL("Configure Controls"),
  "order"       => 500,
  "type"        => EnumOption,
  "parameters"  => [_INTL(""), _INTL("")],
  "description" => _INTL("Configure the game controls."),
  "get_proc"    => proc {  },
  "set_proc"    => proc {  }
})