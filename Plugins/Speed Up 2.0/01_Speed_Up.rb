module Input

  def self.update
    update_KGC_ScreenCapture
    if trigger?(Input::F8)
      pbScreenCapture
    end
    if $CanToggle && trigger?(Input::AUX1) && ($game_temp.in_battle || $DEBUG || $stats.hall_of_fame_entry_count > 0) #remap your Q button on the F1 screen to change your speedup switch
      $GameSpeed += 1
      if $GameSpeed >= SPEEDUP_STAGES.size
        $GameSpeed = 0
      end
      $game_temp.speedup = $GameSpeed
    end
=begin
    if trigger?(Input::F6)
      $stats.instance_variables.each do |val|
        echoln "#{val} = #{$stats.instance_variable_get(val)}"
      end
    end
    if trigger?(Input::ACTION) && $game_temp.skip_scene
      $game_temp.skip_scene.pbSkip
    end
=end
  end
end

$InCommandLine = false

SPEEDUP_STAGES = [1,3]
$GameSpeed = 0
$frame = 0
$CanToggle = true

module Graphics
  class << Graphics
    alias fast_forward_update update
  end

  def self.update
    $frame += 1
    return unless $frame % SPEEDUP_STAGES[$GameSpeed] == 0
    fast_forward_update
    $frame = 0
  end
end

class Game_Temp
  attr_accessor :speedup

  def speedup
    @speedup = $GameSpeed if !@speedup
    return @speedup
  end
end