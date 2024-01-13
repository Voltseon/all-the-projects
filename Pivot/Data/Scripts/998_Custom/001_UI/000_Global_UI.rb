class Overlay
  attr_accessor :faded_out

  def initialize
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 100000
    @black_overlay = IconSprite.new(0,0,@viewport)
    @black_overlay.setBitmap("Graphics/Pictures/Loading Screens/loadingscreen_PIVOT")
    @black_overlay.opacity = 0
    @black_overlay.z = 100000
  end

  def faded_out?
    @black_overlay.opacity == 255
  end

  def pbFadeIn(duration, loading_screen = false, update_scene = nil)
    return if self.faded_out?
    graphic = "loadingscreen_PIVOT"
    if loading_screen && $player.equipped_collectibles[:loadingscreen]
      graphic = Collectible.get($player.equipped_collectibles[:loadingscreen]).internal.to_s
    end
    @black_overlay.setBitmap("Graphics/Pictures/Loading Screens/#{graphic}")
    Mouse.hideCursor if loading_screen
    duration.times do |i|
      @black_overlay.opacity = lerp(@black_overlay.opacity, 255, (i+1)/duration.to_f)
      Graphics.update
      Input.update
      if update_scene && update_scene.sprites["bg"]
        update_scene.frame += 1
        frame = update_scene.frame
        bg = MainMenu::ANIMATED_BGS[MainMenu::BG_GRAPHIC]
        update_scene.sprites["bg"].changeBitmap(frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]) if update_scene.sprites["bg"].currentKey != frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]
      end
    end
  end

  def pbFadeOut(duration, update_scene = nil)
    return unless self.faded_out?
    duration.times do |i|
      @black_overlay.opacity = lerp(@black_overlay.opacity, 0, (i+1)/duration.to_f)
      Graphics.update
      Input.update
      if update_scene && update_scene.sprites["bg"]
        update_scene.frame += 1
        frame = update_scene.frame
        bg = MainMenu::ANIMATED_BGS[MainMenu::BG_GRAPHIC]
        update_scene.sprites["bg"].changeBitmap(frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]) if update_scene.sprites["bg"].currentKey != frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]
      end
    end
    Mouse.showCursor
    #@black_overlay.dispose
    #@viewport.dispose
  end
end

class TooltipOverlay
  attr_accessor :header_text, :body_text, :tooltip, :fade_out, :fade_in, :text_alignment,
                :snap_x, :snap_y, :placement, :delay, :do_fade, :parent

  def initialize
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 100001
    @header_text = ""
    @body_text = ""
    @tooltip = nil
    @fade_out = false
    @fade_in = false
    @text_alignment = 0 # 0 = left, 1 = center, 2 = right
    @snap_x = nil
    @snap_y = nil
    @placement = :default # :default, :centered
    @delay = 30
    @do_fade = true
    @parent = nil
  end

  def create(body_text, header_text = "", text_alignment = 0, parent = nil)
    @header_text = header_text
    @body_text = body_text
    @text_alignment = text_alignment
    @parent = parent
    text = ""
    if @header_text == ""
      text += "<ac>"+@body_text+"</ac>"
    else
      case @text_alignment
      when 1 then text += "<ac>"
      when 2 then text += "<ar>"
      end
      text += "<c2=039F2108>" + @header_text + "</c2>\n"
      text += @body_text
      case @text_alignment
      when 1 then text += "</ac>"
      when 2 then text += "</ar>"
      end
    end
    @tooltip = pbDisplayTooltipWindow(@viewport, text)
    @tooltip.visible = false
    self.opacity = 0 if @do_fade
    update_position
  end

  def update
    return if @tooltip.nil?
    @tooltip.update
    if @fade_in
      self.opacity += 255/5
      if self.opacity >= 254
        self.opacity = 255
        @fade_in = false
      end
    elsif @fade_out
      distance_to_mouse = Math.sqrt((Mouse.x - (@parent.x + @parent.width/2))**2 + (Mouse.y - (@parent.y + @parent.height/2))**2)
      if distance_to_mouse > 100
        self.opacity -= distance_to_mouse
      else
        self.opacity -= 255/5
      end
      if self.opacity <= 1
        self.opacity = 0
        @tooltip.visible = false
        @fade_out = false
      end
    end
    update_position
  end

  def dispose
    @tooltip.dispose unless @tooltip.nil?
    @viewport.dispose
  end

  def opacity=(value)
    return if @tooltip.nil?
    @tooltip.back_opacity = value
    @tooltip.contents_opacity = value
  end

  def opacity
    return 0 if @tooltip.nil?
    return @tooltip.back_opacity
  end

  def update_position
    return if @tooltip.nil?
    offset_x = (@placement == :centered ? @tooltip.width/2 : -4)
    offset_y = (@placement == :centered ? @tooltip.height/2 : -4)
    x = Mouse.x - @tooltip.width + offset_x
    x = Mouse.x + 24 if x < 0
    x = Graphics.width - @tooltip.width if x + @tooltip.width > Graphics.width
    y = Mouse.y - @tooltip.height + offset_y
    y = Mouse.y + 24 if y < 0
    y = Graphics.height - @tooltip.height if y + @tooltip.height > Graphics.height
    x = @snap_x if !@snap_x.nil?
    y = @snap_y if !@snap_y.nil?
    @tooltip.x = x
    @tooltip.y = y
  end

  def visible=(value)
    if self.do_fade
      if value == true
        self.opacity = 0
        @tooltip.visible = true
        @fade_in = true
        @fade_out = false
      else
        @fade_in = false
        @fade_out = true
      end
    else
      self.opacity = 255
      @tooltip.visible = value
    end
  end

  def visible
    return false if @tooltip.nil?
    if self.do_fade
      return self.opacity > 0
    else
      return @tooltip.visible
    end
  end

  def delay
    return 0 if @tooltip.nil?
    return @delay
  end

  def delay=(value)
    return if @tooltip.nil?
    @delay = value
  end

  def do_fade
    return false if @tooltip.nil?
    return @do_fade
  end

  def do_fade=(value)
    return if @tooltip.nil?
    @do_fade = value
  end
end

def pbGlobalFadeOut(duration = 24, loading_screen = false, update_scene = nil)
  $overlay = Overlay.new if $overlay.nil?
  $overlay.pbFadeIn(duration, loading_screen, update_scene)
end

def pbGlobalFadeIn(duration = 24, update_scene = nil)
  $overlay.pbFadeOut(duration, update_scene)
end

class Game_Temp
  attr_accessor :main_menu_calling, :arena_select_calling, :character_select_calling, :start_match_calling,
                :lobby_calling, :credits_calling, :tutorial_calling, :in_a_lobby, :solo_mode, :logout_calling

  def main_menu_calling; @main_menu_calling = false if !@main_menu_calling; return @main_menu_calling; end
  def arena_select_calling; @arena_select_calling = false if !@arena_select_calling; return @arena_select_calling; end
  def character_select_calling; @character_select_calling = false if !@character_select_calling; return @character_select_calling; end
  def start_match_calling; @start_match_calling = false if !@start_match_calling; return @start_match_calling; end
  def lobby_calling; @lobby_calling = false if !@lobby_calling; return @lobby_calling; end
  def credits_calling; @credits_calling = false if !@credits_calling; return @credits_calling; end
  def tutorial_calling; @tutorial_calling = false if !@tutorial_calling; return @tutorial_calling; end
  def logout_calling; @logout_calling = false if !@logout_calling; return @logout_calling; end
  def in_a_lobby; @in_a_lobby = false if !@in_a_lobby; return @in_a_lobby; end
  def solo_mode; @solo_mode = false if !@solo_mode; return @solo_mode; end
end