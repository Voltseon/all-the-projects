class Sprite_SurfBase
  attr_reader   :visible
  attr_accessor :event

  def initialize(sprite,event,viewport=nil)
    @rsprite  = sprite
    @sprite   = nil
    @diveoverlay = nil
    @event    = event
    @viewport = viewport
    @disposed = false
    @surfbitmap = AnimatedBitmap.new("Graphics/Characters/base_surf")
    @divebitmap = AnimatedBitmap.new("Graphics/Characters/base_dive")
    @diveoverlaybitmap = AnimatedBitmap.new("Graphics/Characters/overlay_dive")
    @diveoverlaybitmapfe = AnimatedBitmap.new("Graphics/Characters/overlay_dive_f")
    RPG::Cache.retain("Graphics/Characters/base_surf")
    RPG::Cache.retain("Graphics/Characters/base_dive")
    RPG::Cache.retain("Graphics/Characters/overlay_dive")
    RPG::Cache.retain("Graphics/Characters/overlay_dive_f")
    @cws = @surfbitmap.width/4
    @chs = @surfbitmap.height/4
    @cwd = @divebitmap.width/4
    @chd = @divebitmap.height/4
    update
  end

  def dispose
    return if @disposed
    @sprite.dispose if @sprite
    @sprite   = nil
    @surfbitmap.dispose
    @divebitmap.dispose
    @diveoverlay.dispose if @diveoverlay
    @diveoverlay = nil
    @disposed = true
  end

  def disposed?
    @disposed
  end

  def visible=(value)
    @visible = value
    @sprite.visible = value if @sprite && !@sprite.disposed?
    @diveoverlay.visible = value if @diveoverlay && !diveoverlay.disposed?
  end

  def update
    return if disposed?
    if !$PokemonGlobal.surfing && !$PokemonGlobal.diving
      # Just-in-time disposal of sprite
      if @sprite
        @sprite.dispose
        @sprite = nil
      end
      return
    end
    if !$PokemonGlobal.diving
      # Dive overlay
      if @diveoverlay
        @diveoverlay.dispose
        @diveoverlay = nil
      end
    end
    # Just-in-time creation of sprite
    @sprite = Sprite.new(@viewport) if !@sprite
    if @sprite
      if $PokemonGlobal.surfing
        @sprite.bitmap = @surfbitmap.bitmap
        cw = @cws
        ch = @chs
      elsif $PokemonGlobal.diving
        @sprite.bitmap = @divebitmap.bitmap
        cw = @cwd
        ch = @chd
      end
      sx = @event.pattern_surf*cw
      sy = ((@event.direction-2)/2)*ch
      @sprite.src_rect.set(sx,sy,cw,ch)
      if $PokemonTemp.surfJump
        @sprite.x = ($PokemonTemp.surfJump[0]*Game_Map::REAL_RES_X-@event.map.display_x+3)/4+(Game_Map::TILE_WIDTH/2)
        @sprite.y = ($PokemonTemp.surfJump[1]*Game_Map::REAL_RES_Y-@event.map.display_y+3)/4+(Game_Map::TILE_HEIGHT/2)+16
      else
        @sprite.x = @rsprite.x
        @sprite.y = @rsprite.y
      end
      @sprite.ox      = cw/2
      @sprite.oy      = ch-16   # Assume base needs offsetting
      @sprite.oy      -= @event.bob_height
      @sprite.z       = @event.screen_z(ch)-1
      @sprite.zoom_x  = @rsprite.zoom_x
      @sprite.zoom_y  = @rsprite.zoom_y
      @sprite.tone    = @rsprite.tone
      @sprite.color   = @rsprite.color
      @sprite.opacity = @rsprite.opacity
    end
    # Dive overlay (Scuba Gear , scubagear)
    if $PokemonGlobal.diving
      if !@diveoverlay
        @diveoverlay = Sprite.new(@viewport)
        if $Trainer && $Trainer.female?
          @diveoverlay.bitmap = @diveoverlaybitmapfe.bitmap
        else
          @diveoverlay.bitmap = @diveoverlaybitmap.bitmap
        end
      else
        dx = @event.pattern_surf*cw
        dy = ((@event.direction-2)/2)*ch
        @diveoverlay.src_rect.set(dx,dy,cw,ch)
        @diveoverlay.x = @rsprite.x
        @diveoverlay.y = @rsprite.y
        @diveoverlay.ox      = cw/2
        @diveoverlay.oy      = ch
        @diveoverlay.oy      -= @event.bob_height
        @diveoverlay.z       = @event.screen_z(ch)+1
        @diveoverlay.zoom_x  = @rsprite.zoom_x
        @diveoverlay.zoom_y  = @rsprite.zoom_y
        @diveoverlay.tone    = @rsprite.tone
        @diveoverlay.color   = @rsprite.color
        @diveoverlay.opacity = @rsprite.opacity
      end
    end
  end
end
