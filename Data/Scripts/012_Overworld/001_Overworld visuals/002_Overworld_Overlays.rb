#===============================================================================
# Location signpost
#===============================================================================
class LocationWindow
  def initialize(name)
    @window = Window_AdvancedTextPokemon.new(name)
    @window.resizeToFit(name, Graphics.width)
    @window.x        = 0
    @window.y        = -@window.height
    @window.viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @window.viewport.z = 99999
    @currentmap = $game_map.map_id
    @frames = 0
  end

  def disposed?
    @window.disposed?
  end

  def dispose
    @window.dispose
  end

  def update
    return if @window.disposed?
    @window.update
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      @window.dispose
      return
    end
    if @frames > Graphics.frame_rate * 2
      @window.y -= 4
      @window.dispose if @window.y + @window.height < 0
    else
      @window.y += 4 if @window.y < 0
      @frames += 1
    end
  end
end



#===============================================================================
# Visibility circle in dark maps
#===============================================================================
class DarknessSprite < Sprite
  attr_reader :radius

  def initialize(viewport = nil)
    super(viewport)
    @darkness = BitmapWrapper.new(Graphics.width/2, Graphics.height/2)
    @radius = radiusMin
    self.bitmap = @darkness
    self.z      = 99998
    self.zoom_x = 2
    self.zoom_y = 2
    refresh
  end

  def dispose
    @darkness.dispose
    super
  end

  def radiusMin; return 32;  end   # Before using Flash
  def radiusMax; return 88; end   # After using Flash

  def radius=(value)
    @radius = value
    refresh
  end

  def refresh
    color = ($PokemonGlobal.diving ? Color.new(0, 20, 40, 208) : Color.new(0, 0, 0, 255))
    @darkness.fill_rect(0, 0, Graphics.width, Graphics.height, color)
    cx = Graphics.width / 4
    cy = Graphics.height / 4
    cradius = @radius
    numfades = 5
    (1..numfades).each do |i|
      (cx - cradius..cx + cradius).each do |j|
        diff2 = (cradius * cradius) - ((j - cx) * (j - cx))
        diff = Math.sqrt(diff2)
        @darkness.fill_rect(j, cy - diff, 1, diff * 2, Color.new(color.red, color.green, color.blue, color.alpha * (numfades - i) / numfades))
      end
      cradius = (cradius * 0.9).floor
    end
  end
end



#===============================================================================
# Light effects
#===============================================================================
class LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    @light = IconSprite.new(0, 0, viewport)
    if !nil_or_empty?(filename) && pbResolveBitmap("Graphics/Pictures/" + filename)
      @light.setBitmap("Graphics/Pictures/" + filename)
    else
      @light.setBitmap("Graphics/Pictures/LE")
    end
    @light.z = 1000
    @event = event
    @map = (map) ? map : $game_map
    @disposed = false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map = nil
    @event = nil
    @disposed = true
  end

  def update
    @light.update
  end
end



class LightEffect_Lamp < LightEffect
  def initialize(event, viewport = nil, map = nil)
    lamp = AnimatedBitmap.new("Graphics/Pictures/LE")
    @light = Sprite.new(viewport)
    @light.bitmap = Bitmap.new(128, 64)
    src_rect = Rect.new(0, 0, 64, 64)
    @light.bitmap.blt(0, 0, lamp.bitmap, src_rect)
    @light.bitmap.blt(20, 0, lamp.bitmap, src_rect)
    @light.visible = true
    @light.z       = 1000
    lamp.dispose
    @map = (map) ? map : $game_map
    @event = event
  end
end



class LightEffect_Basic < LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil)
    super
    @light.ox = @light.bitmap.width / 2
    @light.oy = @light.bitmap.height / 2
    @light.opacity = 100
  end

  def update
    return if !@light || !@event
    super
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x      = ScreenPosHelper.pbScreenX(@event)
      @light.y      = ScreenPosHelper.pbScreenY(@event) - (@event.height * Game_Map::TILE_HEIGHT / 2)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
      @light.zoom_y = @light.zoom_x
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y - (Game_Map::TILE_HEIGHT / 2)
    end
    @light.tone = $game_screen.tone
  end
end



class LightEffect_DayNight < LightEffect
  def initialize(event, viewport = nil, map = nil, filename = nil, z = 1000)
    super(event, viewport, map, filename)
    @light.ox = @light.bitmap.width / 2
    @light.oy = @light.bitmap.height / 2
    @light.z = z
  end

  def update
    return if !@light || !@event
    super
    if (@event.move_speed == 6)
      shade = PBDayNight.getShade
      if shade >= 144   # If light enough, call it fully day
        shade = 255
      elsif shade <= 64   # If dark enough, call it fully night
        shade = 0
      else
        shade = 255 - (255 * (144 - shade) / (144 - 64))
      end
    else
      shade = (PBDayNight.isDark?) ? 0 : 255
    end
    @light.opacity = 255 - shade
    if @light.opacity > 0
      if (Object.const_defined?(:ScreenPosHelper) rescue false)
        @light.x      = ScreenPosHelper.pbScreenX(@event)
        @light.y      = ScreenPosHelper.pbScreenY(@event) - (@event.height * Game_Map::TILE_HEIGHT / 2)
        @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
        @light.zoom_y = ScreenPosHelper.pbScreenZoomY(@event)
      else
        @light.x = @event.screen_x
        @light.y = @event.screen_y - (Game_Map::TILE_HEIGHT / 2)
      end
      @light.tone.set($game_screen.tone.red,
                      $game_screen.tone.green,
                      $game_screen.tone.blue,
                      $game_screen.tone.gray)
    end
  end
end



EventHandlers.add(:on_new_spriteset_map, :add_light_effects,
  proc { |spriteset, viewport|
    map = spriteset.map   # Map associated with the spriteset (not necessarily the current map)
    map.events.each_key do |i|
      if map.events[i].name[/^outdoorlight\((\w+)\)$/i]
        filename = $~[1].to_s
        spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map, filename, 320))
      elsif map.events[i].name[/^outdoorlight$/i]
        spriteset.addUserSprite(LightEffect_DayNight.new(map.events[i], viewport, map))
      elsif map.events[i].name[/^light\((\w+)\)$/i]
        filename = $~[1].to_s
        spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map, filename))
      elsif map.events[i].name[/^light$/i]
        spriteset.addUserSprite(LightEffect_Basic.new(map.events[i], viewport, map))
      end
    end
    spriteset.addUserSprite(Particle_Engine.new(viewport, map))
  }
)

EventHandlers.add(:on_frame_update, :check_lamp_events,
  proc {
    next if $game_temp.lamp_events_on == PBDayNight.isDark?
    set_lamp_events(PBDayNight.isDark?)
  }
)

def set_lamp_events(setter)
  set_daynight_tileset(setter)
  $game_temp.lamp_events_on = setter
  $game_map.events.each_value do |event|
    # Check each page (unloaded)
    pages = (event.is_a?(RPG::Event) ? event.pages : event.instance_eval { @event.pages })
    pages.each do |page|
      new_file_name = (setter ? page.graphic.character_name + "_night" : page.graphic.character_name.gsub("_night", ""))
      next unless safeExists?("./Graphics/Characters/#{new_file_name}.png")
      next if new_file_name.include?("_night") && !PBDayNight.isDark?
      page.graphic.character_name = new_file_name
    end
    # Check each event (loaded)
    new_file_name = (setter ? event.character_name + "_night" : event.character_name.gsub("_night", ""))
    next unless safeExists?("./Graphics/Characters/#{new_file_name}.png")
    next if new_file_name.include?("_night") && !PBDayNight.isDark?
    event.character_name = new_file_name
  end
end

def set_daynight_tileset(setter)
  new_file_name = (setter ? $game_map.tileset_name + "_night" : $game_map.tileset_name.gsub("_night", ""))
  return unless safeExists?("./Graphics/Tilesets/#{new_file_name}.png")
  return if new_file_name.include?("_night") && !PBDayNight.isDark?
  RPG::Cache.tileset($game_map.tileset_name.gsub("_night", "")).add_frame(Bitmap.new("Graphics/Tilesets/#{new_file_name}"))
  RPG::Cache.tileset($game_map.tileset_name.gsub("_night", "")).next_frame
  RPG::Cache.tileset($game_map.tileset_name.gsub("_night", "")).remove_frame(0)
end

class Game_Temp
  attr_accessor :lamp_events_on

  def lamp_events_on
    @lamp_events_on = false if !@lamp_events_on
    return @lamp_events_on
  end

  def lamp_events_on=(value)
    @lamp_events_on = value
  end
end
