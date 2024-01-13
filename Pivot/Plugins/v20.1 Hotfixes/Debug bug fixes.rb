#===============================================================================
# "v20.1 Hotfixes" plugin
# This file contains fixes for bugs in Debug features in Essentials v20.1.
# These bug fixes are also in the dev branch of the GitHub version of
# Essentials:
# https://github.com/Maruno17/pokemon-essentials
#===============================================================================

#===============================================================================
# Fixed mispositioning of text in Debug features that edit Game Switches and
# Game Variables.
#===============================================================================
class SpriteWindow_DebugVariables < Window_DrawableCommand
  def shadowtext(x, y, w, h, t, align = 0, colors = 0)
    width = self.contents.text_size(t).width
    case align
    when 1   # Right aligned
      x += (w - width)
    when 2   # Centre aligned
      x += (w / 2) - (width / 2)
    end
    y += 8   # TEXT OFFSET
    base = Color.new(12 * 8, 12 * 8, 12 * 8)
    case colors
    when 1   # Red
      base = Color.new(168, 48, 56)
    when 2   # Green
      base = Color.new(0, 144, 0)
    end
    pbDrawShadowText(self.contents, x, y, [width, w].max, h, t, base, Color.new(26 * 8, 26 * 8, 25 * 8))
  end
end

#===============================================================================
# Fixed error messages appearing in the console because of some script switches
# in the "Switches" debug feature.
#===============================================================================
class SpriteWindow_DebugVariables < Window_DrawableCommand
  def drawItem(index, _count, rect)
    pbSetNarrowFont(self.contents)
    colors = 0
    codeswitch = false
    if @mode == 0
      name = $data_system.switches[index + 1]
      codeswitch = (name[/^s\:/])
      if codeswitch
        code = $~.post_match
        code_parts = code.split(/[(\[=<>. ]/)
        code_parts[0].strip!
        code_parts[0].gsub!(/^\s*!/, "")
        val = nil
        if code_parts[0][0].upcase == code_parts[0][0] &&
           (Kernel.const_defined?(code_parts[0]) rescue false)
          val = (eval(code) rescue nil)   # Code starts with a class/method name
        elsif code_parts[0][0].downcase == code_parts[0][0] &&
           !(Interpreter.method_defined?(code_parts[0].to_sym) rescue false) &&
           !(Game_Event.method_defined?(code_parts[0].to_sym) rescue false)
          val = (eval(code) rescue nil)   # Code starts with a method name (that isn't in Interpreter/Game_Event)
        end
      else
        val = $game_switches[index + 1]
      end
      if val.nil?
        status = "[-]"
        colors = 0
        codeswitch = true
      elsif val   # true
        status = "[ON]"
        colors = 2
      else   # false
        status = "[OFF]"
        colors = 1
      end
    else
      name = $data_system.variables[index + 1]
      status = $game_variables[index + 1].to_s
      status = "\"__\"" if nil_or_empty?(status)
    end
    name ||= ""
    id_text = sprintf("%04d:", index + 1)
    rect = drawCursor(index, rect)
    totalWidth = rect.width
    idWidth     = totalWidth * 15 / 100
    nameWidth   = totalWidth * 65 / 100
    statusWidth = totalWidth * 20 / 100
    self.shadowtext(rect.x, rect.y, idWidth, rect.height, id_text)
    self.shadowtext(rect.x + idWidth, rect.y, nameWidth, rect.height, name, 0, (codeswitch) ? 1 : 0)
    self.shadowtext(rect.x + idWidth + nameWidth, rect.y, statusWidth, rect.height, status, 1, colors)
  end
end
