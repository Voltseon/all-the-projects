=begin
def pbAllowSkipping(skip_proc = nil)
  return unless $game_switches[82] || $DEBUG
  $game_temp.skip_scene = SkipScene.new(skip_proc, get_self)
end

def pbDisallowSkipping
  $game_temp.skip_scene.pbEndScene
  $game_temp.skip_scene = nil
end

EventHandlers.add(:on_frame_update, :update_skip_scene,
  proc {
    next if $game_temp.skip_scene.nil?
    $game_temp.skip_scene.pbUpdate
  }
)

class SkipScene
  def initialize(skip_proc, event=self)
    @skip_proc = skip_proc
    @event = event
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @baseColor = Color.new(248,248,248)
    @shadowColor = Color.new(16, 16, 16)
    pbSetNarrowFont(@sprites["overlay"].bitmap)
    pbTransparentAndShow(@sprites) { pbUpdate }
  end

  def pbUpdate
    @sprites["overlay"].bitmap.clear
    @yPos = ($game_system.message_position == 2) ? Graphics.height - 24 : 8
    pbDrawOutlineText(@sprites["overlay"].bitmap, 8, @yPos, Graphics.width-16, 32, "Press Z to skip.", @baseColor, @shadowColor)
  end

  def pbSkip
    pbFadeOutIn {
      @skip_proc.call(@event) if @skip_proc
      $game_system.map_interpreter.command_end
       $game_system.map_interpreter.index = 0
      pbClearBub
    }
    pbDisallowSkipping
  end

  def pbEndScene
    pbTransparentAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class Game_Temp
  attr_accessor :skip_scene
  def skip_scene; return @skip_scene; end
end
=end