class PokemonGlobalMetadata
  attr_writer   :light_spots
  attr_writer   :dark_screen

  def light_spots
    @light_spots = [] if !@light_spots
    return @light_spots
  end

  def dark_screen
    return @dark_screen if @dark_screen
  end
end

def pbAddLightSpot(event, radius=1)
  event = get_character(event) if event.is_a?(Integer)
  $PokemonGlobal.light_spots.push([event, radius])
  $PokemonGlobal.dark_screen.pbAddLight(event, radius) if $PokemonGlobal.dark_screen
end

def pbShowDarkScreen
  $PokemonGlobal.dark_screen = DarkScreen.new
end

def pbHideDarkScreen
  $PokemonGlobal.dark_screen.pbEnd
  $PokemonGlobal.dark_screen = nil
end

EventHandlers.add(:on_frame_update, :dark_screen,
  proc {
    next if !$PokemonGlobal.dark_screen
    $PokemonGlobal.dark_screen.pbUpdate
  }
)

EventHandlers.add(:on_leave_map, :dispose_dark_screen,
  proc {
    next if !$PokemonGlobal.dark_screen
    pbHideDarkScreen
  }
)
class DarkScreen
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["bg"] = IconSprite.new(0,0,@viewport)
    @sprites["bg"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["bg"].bitmap.fill_rect(0,0,Graphics.width,Graphics.height,Color.new(255,255,255))
    @sprites["bg"].blend_type = 2
    @light_spots = $PokemonGlobal.light_spots + [[$game_player, 1]]
    @light_spots.each do |ls|
      next if ls[0].map.map_id != $game_map.map_id
      @sprites["ls_#{ls[0].id}"] = LightSpot.new(ls[1], ls[0], ls[0].screen_x, ls[0].screen_y, @viewport)
    end
    pbUpdate
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbAddLight(event, radius)
    return if event.map.map_id != $game_map.map_id
    @sprites["ls_#{event.id}"] = LightSpot.new(radius, event, event.screen_x, event.screen_y, @viewport)
  end

  def pbEnd
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class LightSpot < IconSprite
  def initialize(radius, event, x, y, viewport)
    super(x, y, viewport)
    @layers = []
    @radius = radius
    @event = event
    self.setBitmap("Graphics/Pictures/bright_spot_0_#{@radius}")
    self.ox = self.width/2
    self.oy = self.width/2
    4.times do |i|
      ly = IconSprite.new(x, y, viewport)
      ly.setBitmap("Graphics/Pictures/bright_spot_#{i+1}_#{@radius}")
      ly.ox = ly.width/2
      ly.oy = ly.width/2
      @layers.push(ly)
    end
    self.blend_type = 2
    self.z = 10
  end

  def update
    super
    self.x = @event.screen_x
    self.y = @event.screen_y
    return unless @layers && @layers!=[]
    @layers.each { |l| l.update }
  end

  def x=(value)
    super(value)
    return unless @layers && @layers!=[]
    @layers.each { |l| l.x = value }
  end

  def y=(value)
    super(value)
    return unless @layers && @layers!=[]
    @layers.each { |l| l.y = value }
  end

  def z=(value)
    super(value)
    return unless @layers && @layers!=[]
    @layers.each_with_index { |l,i| l.z = value-i-1 }
  end

  def blend_type=(value)
    super(value)
    return unless @layers && @layers!=[]
    @layers.each_with_index { |l,i| l.blend_type = value }
  end

  def visible=(value)
    super(value)
    return unless @layers && @layers!=[]
    @layers.each { |l| l.visible = value }
  end

  def dispose
    super
    return unless @layers && @layers!=[]
    @layers.each { |l| l.dispose }
  end
end