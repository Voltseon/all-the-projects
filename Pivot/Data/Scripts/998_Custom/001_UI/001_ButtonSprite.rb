class ButtonSprite < IconSprite
  attr_accessor :hoverable, :tooltip

  def initialize(parent=nil,text=nil,bitmap=nil,bitmap_hover=nil,click_proc=nil,index=0,x=0,y=0,viewport=nil,bitmap_disabled=nil,hover_proc=nil,subtitle=nil)
    super(x,y,viewport)
    self.setBitmap(bitmap)
    @parent = parent
    @bitmaps = [bitmap, bitmap_hover, bitmap_disabled]
    @click_proc = click_proc
    @hover_proc = hover_proc
    @text_offset = [0,0]
    @text_base_color = Color.new(248,248,248)
    @text_shadow_color = Color.new(64,64,64)
    @text_disabled_color = Color.new(212,212,212)
    @subtitle_base_color = @text_base_color
    @subtitle_shadow_color = @text_shadow_color
    @text = text
    @subtitle = subtitle || ""
    @text_align = 2
    @text_bitmap = BitmapSprite.new(self.width,self.height,viewport)
    @subtitle_bitmap = BitmapSprite.new(self.width,self.height,viewport)
    @tooltip = nil
    @highlighted = false
    @index = index
    @hidden = false
    @enabled = true
    @hover_time = 0
    self.hoverable = true
    pbSetSystemFont(@text_bitmap.bitmap)
    pbSetSmallFont(@subtitle_bitmap.bitmap)
    redrawText
  end

  def update
    return if self.disposed?
    return if @text_bitmap.bitmap.disposed?
    return if @subtitle_bitmap.bitmap.disposed?
    return if $game_temp.message_window_showing
    checkSelected
    return if self.disposed?
    return if @text_bitmap.bitmap.disposed?
    return if @subtitle_bitmap.bitmap.disposed?
    @text_bitmap.x = self.x
    @text_bitmap.y = self.y
    @text_bitmap.y -= 10 if @subtitle && @subtitle.length > 0
    @text_bitmap.z = self.z
    @subtitle_bitmap.x = self.x
    @subtitle_bitmap.y = self.y + 16
    @subtitle_bitmap.z = self.z
    @subtitle_bitmap.update
    @text_bitmap.update
    @tooltip.update unless @tooltip.nil?
    super
  end

  def visible=(value)
    @text_bitmap.visible = value
    @subtitle_bitmap.visible = value
    super(value)
  end

  def bitmaps=(value)
    @bitmaps = value
  end
  
  def bitmaps
    return @bitmaps
  end

  def highlighted; @highlighted; end
  def highlighted=(value)
    @highlighted = value
    if self.enabled
      self.setBitmap((value ? @bitmaps[1] : @bitmaps[0]))
    else
      self.setBitmap(@bitmaps[2])
    end
  end

  def hidden; @hidden; end
  def hidden=(value); @hidden = value; end
  def text_bitmap; @text_bitmap; end
  def subtitle_bitmap; @subtitle_bitmap; end
  def text; @text; end
  def subtitle; @subtitle; end

  def dispose
    @text_bitmap.dispose
    @subtitle_bitmap.dispose
    @tooltip.dispose unless @tooltip.nil?
    super
  end

  def setTextColor(base,shadow)
    @text_base_color = base
    @text_shadow_color = shadow
    @text_bitmap.opacity = 255
    redrawText
  end

  def setSubtitleColor(base,shadow)
    @subtitle_base_color = base
    @subtitle_shadow_color = shadow
    @subtitle_bitmap.opacity = 255
    redrawText
  end

  def enabled=(value)
    @enabled = value
    self.setBitmap((value ? @bitmaps[0] : @bitmaps[2]))
  end
  def enabled; @enabled; end

  def setTextOffset(x,y)
    @text_offset = x,y
    redrawText
  end

  def text=(value)
    @text = value
    redrawText
  end

  def subtitle=(value)
    @subtitle = value
    redrawText
  end

  def text_align=(value)
    @text_align=value
    redrawText
  end

  def redrawText
    @text_bitmap.bitmap.clear
    @subtitle_bitmap.bitmap.clear
    text_color = self.enabled ? @text_base_color : @text_disabled_color
    subtitle_color = self.enabled ? @subtitle_base_color : @text_disabled_color
    pbDrawTextPositions(@text_bitmap.bitmap, [[@text, self.width/2 + @text_offset[0], @text_offset[1], @text_align, text_color, @text_shadow_color]])
    pbDrawTextPositions(@subtitle_bitmap.bitmap, [[@subtitle, self.width/2 + @text_offset[0], @text_offset[1], @text_align, subtitle_color, @subtitle_shadow_color]])
  end

  def setTooltip(body_text, header_text = "", text_align = 0)
    @tooltip = TooltipOverlay.new
    @tooltip.create(body_text, header_text, text_align, self)
  end

  def click_proc=(value)
    @click_proc = value
  end

  def click_proc; @click_proc; end

  def hover_proc=(value)
    @hover_proc = value
  end

  def hover_proc; @hover_proc; end

  def checkSelected
    Mouse.update
    if Mouse.over_area?(self.x + self.viewport.rect.x, self.y + self.viewport.rect.y, self.width, self.height) && self.visible && self.enabled && self.hoverable
      self.show_tooltip if @tooltip && !@tooltip.visible && @hover_time > @tooltip.delay
      self.hover_proc.call(@parent) if self.hover_proc && !self.highlighted
      pbPlayCursorSE if !self.highlighted
      self.highlighted = true
      self.click if Mouse.click_short?
      @hover_time += 1
    else
      self.hide_tooltip if @tooltip && @tooltip.visible
      self.highlighted = false
      @hover_time = 0 if @hover_time > 0
    end
    return self.highlighted
  end

  def click
    @tooltip.tooltip.visible = false unless @tooltip.nil?
    @tooltip.visible = false unless @tooltip.nil?
    @click_proc.call(@parent) if @click_proc
  end

  def show_tooltip
    return if @tooltip.nil?
    @tooltip.visible = true
    @tooltip.update
  end

  def hide_tooltip
    return if @tooltip.nil?
    @tooltip.visible = false
  end
end