class BushBitmap
  def initialize(bitmap, isTile, depth)
    @bitmaps  = []
    @bitmap   = bitmap
    @isTile   = isTile
    @isBitmap = @bitmap.is_a?(Bitmap)
    @depth    = depth
  end

  def dispose
    @bitmaps.each { |b| b&.dispose }
  end

  def bitmap
    thisBitmap = (@isBitmap) ? @bitmap : @bitmap.bitmap
    current = (@isBitmap) ? 0 : @bitmap.currentIndex
    if !@bitmaps[current]
      if @isTile
        @bitmaps[current] = pbBushDepthTile(thisBitmap, @depth)
      else
        @bitmaps[current] = pbBushDepthBitmap(thisBitmap, @depth)
      end
    end
    return @bitmaps[current]
  end

  def pbBushDepthBitmap(bitmap, depth)
    ret = Bitmap.new(bitmap.width, bitmap.height)
    charheight = ret.height / 4
    cy = charheight - depth - 2
    4.times do |i|
      y = i * charheight
      if cy >= 0
        ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
        ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
      end
      ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
    end
    return ret
  end

  def pbBushDepthTile(bitmap, depth)
    ret = Bitmap.new(bitmap.width, bitmap.height)
    charheight = ret.height
    cy = charheight - depth - 2
    y = charheight
    if cy >= 0
      ret.blt(0, y, bitmap, Rect.new(0, y, ret.width, cy))
      ret.blt(0, y + cy, bitmap, Rect.new(0, y + cy, ret.width, 2), 170)
    end
    ret.blt(0, y + cy + 2, bitmap, Rect.new(0, y + cy + 2, ret.width, 2), 85) if cy + 2 >= 0
    return ret
  end
end



class Sprite_Character < RPG::Sprite
  attr_accessor :character

  def initialize(viewport, character = nil)
    super(viewport)
    @character    = character
    @oldbushdepth = 0
    @spriteoffset = false
    @reflection = Sprite_Reflection.new(self, character, viewport)
    if character == $game_player || (character.is_a?(Game_Event) && character.name[/partner(\d)/i])
      @surfbase = Sprite_SurfBase.new(self, character, viewport)
      @cloak = IconSprite.new(0,0,viewport)
      @pants = IconSprite.new(0,0,viewport)
      @clip = IconSprite.new(0,0,viewport)
      @hue_applied = false
    end
    self.zoom_x = TilemapRenderer::ZOOM_X
    self.zoom_y = TilemapRenderer::ZOOM_Y
    update
  end

  def groundY
    return @character.screen_y_ground
  end

  def visible=(value)
    super(value)
    @reflection.visible = value if @reflection
  end

  def dispose
    @bushbitmap&.dispose
    @bushbitmap = nil
    @charbitmap&.dispose
    @charbitmap = nil
    @reflection&.dispose
    @reflection = nil
    @surfbase&.dispose
    @surfbase = nil
    @cloak&.dispose
    @cloak = nil
    @pants&.dispose
    @pants = nil
    @clip&.dispose
    @clip = nil
    super
  end

  def update
    return if @character.is_a?(Game_Event) && !@character.should_update?
    super
    if @tile_id != @character.tile_id ||
       @character_name != @character.character_name ||
       @character_hue != @character.character_hue ||
       @oldbushdepth != @character.bush_depth
      @tile_id        = @character.tile_id
      @character_name = @character.character_name
      @character_hue  = @character.character_hue
      @oldbushdepth   = @character.bush_depth
      @charbitmap&.dispose
      if @tile_id >= 384
        @charbitmap = pbGetTileBitmap(@character.map.tileset_name, @tile_id,
                                      @character_hue, @character.width, @character.height)
        @charbitmapAnimated = false
        @bushbitmap&.dispose
        @bushbitmap = nil
        @spriteoffset = false
        @cw = Game_Map::TILE_WIDTH * @character.width
        @ch = Game_Map::TILE_HEIGHT * @character.height
        self.src_rect.set(0, 0, @cw, @ch)
        self.ox = @cw / 2
        self.oy = @ch
      else
        @charbitmap = AnimatedBitmap.new(
          "Graphics/Characters/" + @character_name, @character_hue
        )
        RPG::Cache.retain("Graphics/Characters/", @character_name, @character_hue) if @character == $game_player
        @charbitmapAnimated = true
        @bushbitmap&.dispose
        @bushbitmap = nil
        @spriteoffset = @character_name[/offset/i]
        @cw = @charbitmap.width / 4
        @ch = @charbitmap.height / 4
        self.ox = @cw / 2
      end
      @character.sprite_size = [@cw, @ch]
    end
    @charbitmap.update if @charbitmapAnimated
    bushdepth = @character.bush_depth
    if bushdepth == 0
      self.bitmap = (@charbitmapAnimated) ? @charbitmap.bitmap : @charbitmap
    else
      @bushbitmap = BushBitmap.new(@charbitmap, (@tile_id >= 384), bushdepth) if !@bushbitmap
      self.bitmap = @bushbitmap.bitmap
    end
    self.visible = !@character.transparent
    if @tile_id == 0
      sx = @character.pattern * @cw
      sy = ((@character.direction - 2) / 2) * @ch
      self.src_rect.set(sx, sy, @cw, @ch)
      self.oy = (@spriteoffset rescue false) ? @ch - 16 : @ch
      self.oy -= @character.bob_height
    end
    if self.visible
      if @character.is_a?(Game_Event) && @character.name[/regulartone/i]
        self.tone.set(0, 0, 0, 0)
      else
        pbDayNightTint(self)
      end
    end
    this_x = @character.screen_x
    this_x = ((this_x - (Graphics.width / 2)) * TilemapRenderer::ZOOM_X) + (Graphics.width / 2) if TilemapRenderer::ZOOM_X != 1
    self.x          = this_x
    this_y = @character.screen_y
    this_y = ((this_y - (Graphics.height / 2)) * TilemapRenderer::ZOOM_Y) + (Graphics.height / 2) if TilemapRenderer::ZOOM_Y != 1
    self.y          = this_y
    self.z          = @character.screen_z(@ch)
    self.opacity    = @character.opacity
    self.blend_type = @character.blend_type
    if @character.animation_id != 0
      animation = $data_animations[@character.animation_id]
      animation(animation, true)
      @character.animation_id = 0
    end
    if @cloak
      if @character == $game_player
        @cloak.visible = !@character_name.include?("_1") && !@character_name.include?("_2")
        @pants.visible = !@character_name.include?("_1") && !@character_name.include?("_2")
        @clip.visible = !@character_name.include?("_1") && !@character_name.include?("_2")
        return unless pbResolveBitmap("Graphics/Characters/#{@character_name}_cloak")
        sx = @character.pattern * @cw
        sy = ((@character.direction - 2) / 2) * @ch
        @cloak.setBitmap("Graphics/Characters/#{@character_name}_cloak")
        @cloak.bitmap.hue_change($player.outfit_hues[0])
        @cloak.src_rect.set(sx, sy, @cw, @ch)
        @cloak.ox = self.ox
        @cloak.oy = self.oy
        @cloak.x = self.x
        @cloak.y = self.y
        @cloak.z = @character.screen_z(@ch) + 2
        @cloak.opacity    = @character.opacity
        @cloak.blend_type = @character.blend_type
        pbDayNightTint(@cloak)
        @cloak.visible = !@character.transparent
        @pants.setBitmap("Graphics/Characters/#{@character_name}_pants")
        @pants.bitmap.hue_change($player.outfit_hues[1])
        @pants.src_rect.set(sx, sy, @cw, @ch)
        @pants.ox = self.ox
        @pants.oy = self.oy
        @pants.x = self.x
        @pants.y = self.y
        @pants.z = @character.screen_z(@ch) + 1
        @pants.opacity    = @character.opacity
        @pants.blend_type = @character.blend_type
        pbDayNightTint(@pants)
        @pants.visible = !@character.transparent
        @clip.setBitmap("Graphics/Characters/#{@character_name}_clip")
        @clip.bitmap.hue_change($player.outfit_hues[2])
        @clip.src_rect.set(sx, sy, @cw, @ch)
        @clip.ox = self.ox
        @clip.oy = self.oy
        @clip.x = self.x
        @clip.y = self.y
        @clip.z = @character.screen_z(@ch) + 1
        @clip.opacity    = @character.opacity
        @clip.blend_type = @character.blend_type
        pbDayNightTint(@clip)
        @clip.visible = !@character.transparent
        @hue_applied = true
      elsif @character.name[/partner(\d)/i]
        partner_number = $1.to_i
        if $Partners[partner_number-1].is_a?(Partner) && $Partners[partner_number-1].outfit_hues.is_a?(Array) && $Partners[partner_number-1].map_id == $game_map.map_id
          sx = @character.pattern * @cw
          sy = ((@character.direction - 2) / 2) * @ch
          @cloak.setBitmap("Graphics/Characters/#{@character_name}_cloak")
          @cloak.bitmap.hue_change($Partners[partner_number-1].outfit_hues[0]) unless @hue_applied
          @cloak.src_rect.set(sx, sy, @cw, @ch)
          @cloak.ox = self.ox
          @cloak.oy = self.oy
          @cloak.x = self.x
          @cloak.y = self.y
          @cloak.z = @character.screen_z(@ch) + 2
          @cloak.opacity    = @character.opacity
          @cloak.blend_type = @character.blend_type
          pbDayNightTint(@cloak)
          @cloak.visible = !@character.transparent
          @pants.setBitmap("Graphics/Characters/#{@character_name}_pants")
          @pants.bitmap.hue_change($Partners[partner_number-1].outfit_hues[1]) unless @hue_applied
          @pants.src_rect.set(sx, sy, @cw, @ch)
          @pants.ox = self.ox
          @pants.oy = self.oy
          @pants.x = self.x
          @pants.y = self.y
          @pants.z = @character.screen_z(@ch) + 1
          @pants.opacity    = @character.opacity
          @pants.blend_type = @character.blend_type
          pbDayNightTint(@pants)
          @pants.visible = !@character.transparent
          @clip.setBitmap("Graphics/Characters/#{@character_name}_clip")
          @clip.bitmap.hue_change($Partners[partner_number-1].outfit_hues[2]) unless @hue_applied
          @clip.src_rect.set(sx, sy, @cw, @ch)
          @clip.ox = self.ox
          @clip.oy = self.oy
          @clip.x = self.x
          @clip.y = self.y
          @clip.z = @character.screen_z(@ch) + 1
          @clip.opacity    = @character.opacity
          @clip.blend_type = @character.blend_type
          pbDayNightTint(@clip)
          @clip.visible = !@character.transparent
          @hue_applied = true
        end
      end
    end
    @reflection&.update
    @surfbase&.update
    @cloak&.update
    @pants&.update
    @clip&.update
  end
end
