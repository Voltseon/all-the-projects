#########################################
#                                       #
# Easy Debug Terminal                   #
# by ENLS                               #
# no clue what to write here honestly   #
#                                       #
#########################################

###########################
#      Configuration      #
###########################

# Enable or disable the debug terminal
TERMINAL_ENABLED = true

# Always print returned value from script
TERMINAL_ECHO = true

# Button used to open the terminal
TERMINAL_KEYBIND = :F3
# Uses SDL scancodes, without the SDL_SCANCODE_ prefix.
# https://github.com/mkxp-z/mkxp-z/wiki/Extensions-(RGSS,-Modules)#detecting-key-states





###########################
#       Code Stuff        #
###########################

module Input
  unless defined?(update_Debug_Terminal)
    class << Input
      alias update_Debug_Terminal update
    end
  end

  def self.update
    update_Debug_Terminal
    if $player && $game_map.map_id != 1 && $player.current_hp > 0
      if Input.press?(Input::SPECIAL) && !$player.has_state && $game_temp.guard_timer < $player.character.guard_cooldown && ($game_temp.in_a_match || $game_temp.training) && $game_switches[80]
        if $player.transformed != :NONE
          $player.transformed_time = 0 
          $player.transformed = :NONE
        else
          $player.guarding = true
          $game_temp.guard_timer = $player.character.guard_time
          if $player.character.dash_distance > 0
            pbDash($player.character.dash_distance,$player.character.dash_speed)
          else
            pbSEPlay("Anim/Guard")
          end
        end
      elsif Input.release?(Input::SPECIAL) && $player.guarding && $player.character.dash_distance == 0
        $game_temp.guard_timer = 0
        $player.reset_state
      elsif $player.guarding && $game_temp.guard_timer <= $player.character.unguard_time
        $player.reset_state
      elsif !$player.using_ranged && !$player.guarding && !$game_temp.character_lock && !$scene.active_hud.aiming && ($game_temp.in_a_match || $game_temp.training) && !$scene.active_hud.pause_menu_showing && $game_switches[78]
        if Mouse.click?
          mousepos = Mouse.getMousePos(true)
          mousepos[0] -= Graphics.width/2
          mousepos[1] -= Graphics.height/2
          mousepos[0] /= 10
          mousepos[1] /= 10
          $game_player.direction = (mousepos[0].abs>3 && mousepos[1].abs>3 ? (mousepos[0]> 0 ? mousepos[1]>0 ? 3 : 9 : mousepos[1]>0 ? 1 : 7) : (mousepos[0].abs > mousepos[1].abs ? mousepos[0]>0 ? 6 : 4 : mousepos[1]>0 ? 2 : 8))
          $player.using_melee = true
        elsif Input.releaseex?(:NUMBER_1) && $game_player.animation_id == 0
          pbEmote(1)
        elsif Input.releaseex?(:NUMBER_2) && $game_player.animation_id == 0
          pbEmote(2)
        elsif Input.releaseex?(:NUMBER_3) && $game_player.animation_id == 0
          pbEmote(3)
        end
      end
    end
    if triggerex?(TERMINAL_KEYBIND) && $DEBUG && !$InCommandLine && TERMINAL_ENABLED
      $InCommandLine = true
      #script = Console.readInput2.to_s
      backup_array = $game_temp.lastcommand.clone
      script = pbFreeTextNoWindow("",false,256,Graphics.width)
      $game_temp.lastcommand = backup_array
      $game_temp.lastcommand.insert(0, script) unless nil_or_empty?(script)
      begin
        if TERMINAL_ECHO && !script.include?("echoln")
          echoln(pbMapInterpreter.execute_script(script)) unless nil_or_empty?(script)
        else
          pbMapInterpreter.execute_script(script) unless nil_or_empty?(script)
        end
      rescue Exception
      end
      $InCommandLine = false
    end
  end
end

def pbDash(tiles=2, speed=100, sound=true, this=nil)
  $game_temp.dash_location = [0,0]
  $game_temp.dash_distance = 0
  new_x = $game_player.x
  new_y = $game_player.y
  pbSEPlay("Teleport") if sound
  tiles.times do |i|
    new_x_temp = $game_player.directional_offset[0]
    new_y_temp = $game_player.directional_offset[1]
    break if this.is_a?(AttackSprite) && !this.playing
    break if new_x_temp+new_x < 0 || new_x_temp+new_x >= $game_map.width || new_y_temp+new_y < 0 || new_y_temp+new_y >= $game_map.height
    break unless $game_map.playerPassable?(new_x_temp+new_x, new_y_temp+new_y, $game_player.direction_real, $game_player)
    oldthrough = $game_player.through
    $game_player.through = true
    $game_player.move_speed = speed
    if new_x_temp != 0
      # left or right
      if new_y_temp != 0
        # diagonal up and down
        if new_y_temp > 0
          # moves down
          new_x_temp > 0 ? $game_player.move_lower_right : $game_player.move_lower_left
        else
          # moves up
          new_x_temp > 0 ? $game_player.move_upper_right : $game_player.move_upper_left
        end
      else
        # left and right
        new_x_temp > 0 ? $game_player.move_right : $game_player.move_left
      end
    else
      # up and down
      new_y_temp > 0 ? $game_player.move_down : $game_player.move_up
    end
    new_x_temp += new_x
    new_y_temp += new_y
    $game_temp.dash_location = [new_x-new_x_temp, new_y-new_y_temp]
    $game_temp.dash_distance += 1
    new_x = new_x_temp
    new_y = new_y_temp
    while $game_player.moving?
      Graphics.update
      $scene.update
    end
    $game_player.through = oldthrough
  end
end

$InCommandLine = false

# Custom Message Input Box Stuff
def pbFreeTextNoWindow(currenttext, passwordbox, maxlength, width = 240)
  window = Window_TextEntry_Keyboard_Terminal.new(currenttext, 0, 0, width, 64)
  ret = ""
  window.maxlength = maxlength
  window.visible = true
  window.z = 99999
  window.text = currenttext
  window.passwordChar = "*" if passwordbox
  Input.text_input = true
  loop do
    Graphics.update
    Input.update
    if Input.triggerex?(:ESCAPE)
      ret = currenttext
      break
    elsif Input.triggerex?(:RETURN)
      ret = window.text
      break
    end
    window.update
    yield if block_given?
  end
  Input.text_input = false
  window.dispose
  Input.update
  return ret
end

class Window_TextEntry_Keyboard_Terminal < Window_TextEntry
  def update
    @frame += 1
    @frame %= 20
    self.refresh if (@frame % 10) == 0
    return if !self.active
    # Moving cursor
    if Input.triggerex?(:LEFT) || Input.repeatex?(:LEFT)
      if @helper.cursor > 0
        if Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)
          @helper.cursor -= 1
          # Calculate distance to previous word
          word = self.text[0..@helper.cursor].split(/\s+/).last
          @helper.cursor -= word.length
        else
          @helper.cursor -= 1
        end
        @frame = 0
        self.refresh
      end
      return
    elsif Input.triggerex?(:RIGHT) || Input.repeatex?(:RIGHT)
      if @helper.cursor < self.text.scan(/./m).length
        if Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)
          @helper.cursor += 1
          # Calculate distance to next word
          word = self.text[@helper.cursor..-1].split(/\s+/).first
          @helper.cursor += word.length
        else
          @helper.cursor += 1
        end
        @frame = 0
        self.refresh
      end
      return
    elsif Input.triggerex?(:BACKSPACE) || Input.repeatex?(:BACKSPACE)
      return unless @helper.cursor > 0
      if Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)
        word = self.text[0..@helper.cursor].split(/\s+/).last
        word += " " if word != self.text
        word.length.times { self.delete }
      else
        self.delete if @helper.cursor > 0
      end
      return
    elsif Input.triggerex?(:UP) && $InCommandLine && !$game_temp.lastcommand.empty?
      self.text = $game_temp.lastcommand.shift.to_s
      @helper.cursor = self.text.scan(/./m).length
      $game_temp.lastcommand.push(self.text)
      return
    elsif Input.triggerex?(:DOWN) && $InCommandLine && !$game_temp.lastcommand.empty?
      $game_temp.lastcommand.insert(0, $game_temp.lastcommand.pop)
      self.text = $game_temp.lastcommand.pop.to_s
      @helper.cursor = self.text.scan(/./m).length
      $game_temp.lastcommand.push(self.text)
      return
    elsif Input.triggerex?(:RETURN) || Input.triggerex?(:ESCAPE)
      return
    elsif Input.pressex?(:LCTRL) || Input.pressex?(:RCTRL)
      Input.clipboard = self.text if Input.triggerex?(:C)
      Console.echoln "Saved \"#{self.text}\" to clipboard." if Input.triggerex?(:C)
      if Input.triggerex?(:V)
        self.text << Input.clipboard
        @helper.cursor = self.text.scan(/./m).length
      elsif Input.triggerex?(:X)
        Input.clipboard = self.text
        Console.echoln "Saved \"#{self.text}\" to clipboard."
        self.text = ""
        @helper.cursor = 0
      end
    end
    Input.gets.each_char { |c| insert(c) }
  end
end

# Saving the last executed command
class Game_Temp
  attr_accessor :lastcommand

  def lastcommand
    if !@lastcommand
      if File.exist?(System.data_directory + "/lastcommand.dat")
        File.open(System.data_directory + "/lastcommand.dat", "rb") { |f| @lastcommand = Marshal.load(f) }
      else
        @lastcommand = []
      end
    end
    return @lastcommand
  end

  def lastcommand=(value)
    @lastcommand = value
    File.open(System.data_directory + "/lastcommand.dat", "wb") { |f| Marshal.dump(@lastcommand, f) }
  end
end