class ButtonSprite < IconSprite
  def initialize(parent=nil,text=nil,bitmap=nil,bitmap_hover=nil,click_proc=nil,index=0,x,y,viewport)
    super(x,y,viewport)
    self.setBitmap(bitmap)
    @parent = parent
    @bitmaps = [bitmap, bitmap_hover]
    @click_proc = click_proc
    @text_offset = [0,0]
    @text_base_color = Color.new(248,248,248)
    @text_shadow_color = Color.new(64,64,64)
    @text = text
    @text_align = 2
    @text_bitmap = BitmapSprite.new(self.width,self.height,viewport)
    @highlighted = false
    @index = index
    @hidden = false
    pbSetSystemFont(@text_bitmap.bitmap)
    redrawText
  end

  def update
    return if self.disposed?
    return if @text_bitmap.bitmap.disposed?
    checkSelected
    return if self.disposed?
    return if @text_bitmap.bitmap.disposed?
    @text_bitmap.x = self.x
    @text_bitmap.y = self.y
    @text_bitmap.z = self.z + 1
    @text_bitmap.update
    super
  end

  def visible=(value)
    @text_bitmap.visible = value
    super(value)
  end

  def highlighted; @highlighted; end
  def highlighted=(value)
    @highlighted = value
    self.setBitmap((value ? @bitmaps[1] : @bitmaps[0]))
  end

  def hidden; @hidden; end
  def hidden=(value); @hidden = value; end

  def dispose
    @text_bitmap.dispose
    super
  end

  def setTextColor(base,shadow)
    @text_base_color = base
    @text_shadow_color = shadow
    @text_bitmap.opacity = 255
    redrawText
  end

  def setTextHighlightColor(base,shadow)
    @text_highlight_base_color = base
    @text_highlight_shadow_color = shadow
  end

  def setTextOffset(x,y)
    @text_offset = x,y
    redrawText
  end

  def text=(value)
    @text = value
    redrawText
  end

  def text_align=(value)
    @text_align=value
    redrawText
  end

  def redrawText
    @text_bitmap.bitmap.clear
    base = (@highlighted && @text_highlight_base_color) ? @text_highlight_base_color : @text_base_color
    shadow = (@highlighted && @text_highlight_shadow_color) ? @text_highlight_shadow_color : @text_shadow_color
    pbDrawTextPositions(@text_bitmap.bitmap, [[@text, self.width/2 + @text_offset[0], @text_offset[1], @text_align, base, shadow]])
  end

  def click_proc=(value)
    @click_proc = value
  end

  def checkSelected
    Mouse.update
    oldHighlighted = self.highlighted
    if Mouse.over_area?(self.x, self.y, self.width, self.height) && self.visible
      self.highlighted = true
      self.click if Mouse.click?
    else
      self.highlighted = false
    end
    if self.highlighted != oldHighlighted && @text_bitmap && !@text_bitmap.bitmap.disposed?
      redrawText
    end
    return self.highlighted
  end

  def click
    @click_proc.call(@parent) if @click_proc
  end
end

class PartySprite < ButtonSprite
  SLIDE_SPEED = 32

  def initialize(pokemon=nil,parent=nil,text=nil,bitmap=nil,bitmap_hover=nil,click_proc=nil,index=0,x,y,viewport)
    @pokemon = pokemon
    @pokesprite = PokemonIconSprite.new(@pokemon, viewport)
    @pokesprite.x = x
    @pokesprite.y = y
    @pokesprite.active = true
    @show_options = false
    @hpsprite = IconSprite.new(x+2, y+68, viewport)
    @hpsprite.setBitmap("Graphics/Pictures/Active HUD/hp")
    @expsprite = IconSprite.new(x+4, y+82, viewport)
    @expsprite.setBitmap("Graphics/Pictures/Active HUD/exp")
    @itemsprite = IconSprite.new(x+8, y+94, viewport)
    @shinyicon = IconSprite.new(x+48, y+44, viewport)
    @shinyicon.setBitmap("Graphics/Pictures/shiny")
    @statusicon = IconSprite.new(x+4, y+4, viewport)
    @statusicon.setBitmap("Graphics/Pictures/Active HUD/status")
    super(parent,text,bitmap,bitmap_hover,click_proc,index,x,y,viewport)
    pbSetSmallFont(@text_bitmap.bitmap)
  end

  def pokemon=(value)
    @pokemon = value
    @pokesprite.pokemon = @pokemon
  end

  def update
    @show_options = self.y == 384
    if @highlighted
      if self.y <= 384
        self.y = 384
      else
        self.y -= SLIDE_SPEED
      end
    elsif self.y < 512
      self.y += SLIDE_SPEED
    end
    
    @pokesprite.selected = @highlighted
    @pokesprite.x = self.x
    @pokesprite.y = self.y
    @pokesprite.z = self.z + 1
    @hpsprite.x = self.x + 2
    @hpsprite.y = self.y + 68
    @hpsprite.z = self.z + 1
    hprect = Rect.new(0,0,0,0)
    exprect = Rect.new(0,0,0,0)
    statusrect = Rect.new(0,0,0,0)
    itembmp = ""
    isShiny = false
    if @pokemon.is_a?(Pokemon)
      hppos = 0
      hppos = 12 if @pokemon.hp < @pokemon.totalhp/2
      hppos = 24 if @pokemon.hp < @pokemon.totalhp/4
      hprect = Rect.new(0,hppos,60*@pokemon.hp/@pokemon.totalhp,12)
      minexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level)
      currexp = @pokemon.exp - minexp
      maxexp = @pokemon.growth_rate.minimum_exp_for_level(@pokemon.level + 1) - minexp - 1
      exprect = Rect.new(0,0,56*currexp/maxexp,8)
      itembmp = (@pokemon.item.nil? ? "" : GameData::Item.icon_filename(@pokemon.item))
      isShiny = @pokemon.shiny?
      if @pokemon.status!=:NONE
        statuspos = GameData::Status.get(@pokemon.status).icon_position*16
        statusrect = Rect.new(0,statuspos,8,16)
      elsif @pokemon.fainted?
        statusrect = Rect.new(0,80,8,16)
      end
    end
    @hpsprite.src_rect = hprect
    @expsprite.x = self.x + 4
    @expsprite.y = self.y + 82
    @expsprite.z = self.z + 1
    @expsprite.src_rect = exprect
    @itemsprite.x = self.x + 8
    @itemsprite.y = self.y + 94
    @itemsprite.z = self.z + 1
    @itemsprite.setBitmap(itembmp)
    @shinyicon.x = self.x + 48
    @shinyicon.y = self.y + 44
    @shinyicon.z = self.z + 1
    @shinyicon.visible = isShiny && self.visible
    @statusicon.x = self.x + 4
    @statusicon.y = self.y + 4
    @statusicon.z = self.z + 1
    @statusicon.src_rect = statusrect
    @pokesprite.update
    @statusicon.update
    @shinyicon.update
    @expsprite.update
    @itemsprite.update
    @hpsprite.update
    super
  end

  def visible=(value)
    @pokesprite.visible = value
    @hpsprite.visible = value
    @expsprite.visible = value
    @itemsprite.visible = value
    @statusicon.visible = value
    @shinyicon.visible = false if !value
    super
  end
end