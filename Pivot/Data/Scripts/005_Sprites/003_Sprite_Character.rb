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

  HP_COLORS = [Color.new(180, 20, 0), Color.new(255, 210, 0), Color.new(30, 255, 120), Color.new(0, 32, 0, 128)]
  EXP_COLORS = [Color.new(0, 20, 180), Color.new(0, 210, 255), Color.new(1200, 255, 30), Color.new(0, 0, 32, 128)]
  DITTO_COLORS = [Color.new(120, 0, 140), Color.new(40, 0, 60, 128)]

  def initialize(viewport, character = nil)
    super(viewport)
    @character    = character
    @oldbushdepth = 0
    @spriteoffset = false
    @reflection = Sprite_Reflection.new(self, character, viewport)
    if character == $game_player || (character.is_a?(Game_Event) && (character.name[/partner/i] || character.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]))
      @character_outline = nil
      @overlay = BitmapSprite.new(Graphics.width, Graphics.height, viewport)
      @overlay.ox = @overlay.bitmap.width/2
      @overlay.oy = @overlay.bitmap.height/2
      pbSetSmallFont(@overlay.bitmap)
      @overlay.z = 99999
    end
    self.zoom_x = TilemapRenderer::ZOOM_X
    self.zoom_y = TilemapRenderer::ZOOM_Y
    update
  end

  def name
    return @character.name unless @character == $game_player
    return "player"
  end

  def overlay; @overlay; end

  def groundY
    return @character.screen_y_ground
  end

  def visible=(value)
    super(value)
    @reflection.visible = value if @reflection
    @hp.visible = value if @hp
  end

  def dispose
    @overlay.bitmap.clear if @overlay
    @bushbitmap&.dispose
    @bushbitmap = nil
    @charbitmap&.dispose
    @charbitmap = nil
    @reflection&.dispose
    @reflection = nil
    @hp&.dispose
    @hp = nil
    @overlay&.dispose
    @overlay = nil
    @character_outline&.dispose
    @character_outline = nil
    super
  end

  def update
    @overlay.bitmap.clear if @overlay
    @character_outline&.dispose if @character_outline && Settings::OUTLINES
    ai = nil
    ai = AI.ais[@character.id] if !@character.is_a?(Game_Player) && @character.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
    return if @character.is_a?(Game_Event) && (!@character.should_update? || (@character.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i] && ai.nil?))
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
    if !@character.transparent
      if @character == $game_player
        if $game_temp.in_a_match && $player.current_hp > 0 || $game_temp.training
          maxhp = $player.transformed == :NONE ? $player.max_hp : Character.get(:DITTO).hp
          hpfrag = $player.current_hp.to_f/maxhp.to_f
          hpbar_width = maxhp*1.5
          if !$game_temp.training || $game_map.map_id == 2 || $game_map.map_id == 4
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-hpbar_width/2, @overlay.oy-48, hpbar_width, 4, HP_COLORS[3])
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-hpbar_width/2, @overlay.oy-48, (hpfrag*hpbar_width.to_f).round, 4, HP_COLORS[(hpfrag > 0.5 ? 2 : hpfrag > 0.25 ? 1 : 0)])
          end
          if $player.character.evolution_line && $player.transformed == :NONE && $game_map.map_id != 9
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-24, @overlay.oy-44, 48, 4, EXP_COLORS[3])
            expfrag = $game_temp.match_exp.to_f/100.0
            exp_color = 0
            exp_color = ($player.character.evolution ? 1 : 2) if $player.character.is_evolution
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-24, @overlay.oy-44, expfrag*48, 4, EXP_COLORS[exp_color])
          elsif $player.transformed != :NONE
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-24, @overlay.oy-44, 48, 4, DITTO_COLORS[1])
            transform_frag = $player.transformed_time.to_f/45.0
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-24, @overlay.oy-44, transform_frag*48, 4, DITTO_COLORS[0])
          end
          self.tone.set(128,0,255) if $player.transformed != :NONE
          unless $player.hitbox_active
            self.opacity *= 0.5
            self.tone.set(255,255,255) if $player.hurt_frame>0 && $player.hurt_frame%6!=1 && $player.hurt_frame<Player::FLASH_FRAMES
          end
          if $game_temp.dash_location != [0,0] && $player.character.dash_distance > 0
            if $game_temp.guard_timer.abs < 0.3
              after_images = $game_temp.dash_distance * 2
              pbCameraSpeed(1.75)
              after_images.times do |i|
                x_pos = @character.screen_x-self.width/2+(i+1)*$game_temp.dash_location[0]*16
                y_pos = @character.screen_y-self.height+(i+1)*$game_temp.dash_location[1]*16
                opac = (128+(after_images-1-i)*64)*($game_temp.guard_timer+0.3)
                @overlay.bitmap.blt(x_pos, y_pos, self.bitmap, self.src_rect, opac)
              end
            end
          end
        end
      elsif @character.name[/ai_character\(:([^,]+),:([^,]+),(\d+),(\d+)\)/i]
        pbDrawTextPositions(@overlay.bitmap, [[ai.name, @overlay.bitmap.width/2, @overlay.oy-44, 2, Color.new(248,248,248), Color.new(64,64,64)]]) if ai.movement_type == :PIVOT
        if ai.died
          if ai.movement_type == :PIVOT
            self.opacity *= 0.5
          else
            @character.through = true
            if self.opacity == 0
              @character.moveto(0,0)
            else
              @character.opacity *= 0.99
            end
          end
        else
          if !ai.is_dummy?
            if $game_temp.spectating
              hpfrag = ai.current_hp.to_f/ai.max_hp.to_f
              hpbar_width = ai.max_hp*1.5
              @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-hpbar_width/2, @overlay.oy-48, hpbar_width, 4, HP_COLORS[3])
              @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-hpbar_width/2, @overlay.oy-48, (hpfrag*hpbar_width.to_f).round, 4, HP_COLORS[(hpfrag > 0.5 ? 2 : hpfrag > 0.25 ? 1 : 0)])
            end
            if ai.dash_location != [0,0] && ai.character.dash_distance > 0
              if ai.state == :guard
                after_images = ai.dash_distance * 2
                after_images.times do |i|
                  x_pos = @overlay.ox-self.width/2+(i+1)*ai.dash_location[0]*16
                  y_pos = @overlay.oy-self.height/2+(i+1)*ai.dash_location[1]*16
                  opac = (128+(after_images-1-i)*64)*ai.guard_timer
                  @overlay.bitmap.blt(x_pos, y_pos, self.bitmap, self.src_rect, opac)
                end
              end
            end
          end
          unless ai.hitbox_active
            self.opacity *= 0.5 if !ai.is_dummy?
            self.tone.set(255,255,255) if ai.hurt_frame>0 && ai.hurt_frame%6!=1 && ai.hurt_frame<Player::FLASH_FRAMES
          end
          self.tone.set(128,0,255) if ai.transformed != :NONE
        end
      elsif @character.name[/partner(\d)/i]
        partner_number = $1.to_i
        if $Partners[partner_number-1].is_a?(Partner)
          partner = $Partners[partner_number-1]
          tone = partner.sprite_color
          if tone.is_a?(Array)
            self.tone.set(tone[0],tone[1],tone[2],tone[3])
            self.opacity = tone[4]
            pbDrawTextPositions(@overlay.bitmap, [[partner.name, @overlay.bitmap.width/2, @overlay.oy-44, 2, Color.new(248,248,248), Color.new(64,64,64)]])
          end
          if partner.dash_location != [0,0] && partner.character.dash_distance > 0
            if partner.guard_timer.abs < 0.3
              after_images = partner.dash_distance * 2
              after_images.times do |i|
                x_pos = @overlay.ox-self.width/2+(i+1)*partner.dash_location[0]*16
                y_pos = @overlay.oy-self.height/2+(i+1)*partner.dash_location[1]*16
                opac = (128+(after_images-1-i)*64)*(partner.guard_timer+0.3)
                @overlay.bitmap.blt(x_pos, y_pos, self.bitmap, self.src_rect, opac)
              end
            end
          end
          if $game_temp.spectating
            maxhp = partner.transformed == :NONE ? partner.max_hp : Character.get(:DITTO).hp
            hpfrag = partner.current_hp.to_f/maxhp.to_f
            hpbar_width = maxhp*1.5
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-hpbar_width/2, @overlay.oy-48, hpbar_width, 4, HP_COLORS[3])
            @overlay.bitmap.fill_rect(@overlay.bitmap.width/2-hpbar_width/2, @overlay.oy-48, (hpfrag*hpbar_width.to_f).round, 4, HP_COLORS[(hpfrag > 0.5 ? 2 : hpfrag > 0.25 ? 1 : 0)])
          end
        end
      end
    end
    $game_temp.sprite_color = [self.tone.red, self.tone.green, self.tone.blue, self.tone.gray, self.opacity]
    if @overlay
      @overlay.visible = $game_map.map_id != 1 if self.visible
      @overlay.x = @character.screen_x
      @overlay.y = @character.screen_y-24
    end
    if Settings::OUTLINES && (@character == $game_player || @character.name[/partner(\d)/i])
      @character_outline = self.create_outline_sprite(2, [255,0,0])
    end
    @overlay&.update
    @reflection&.update
    @cloak&.update
    @pants&.update
    @clip&.update
    @character_outline&.update
  end
end
