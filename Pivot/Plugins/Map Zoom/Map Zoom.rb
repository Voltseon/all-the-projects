class ZoomMap
  attr_accessor :goal
  attr_accessor :speed
  attr_accessor :zoom

  def initialize(goal,speed,zoom="in")
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99998
    self.goal = goal
    self.speed = speed
    self.zoom = zoom.downcase
    @sprites = {}
    @sprites["map"] = Sprite.new(@viewport)
    @sprites["map"].bitmap =  Graphics.snap_to_bitmap
    @sprites["map"].center_origins
    @sprites["map"].x = Graphics.width/2
    @sprites["map"].y = Graphics.height/2
    Graphics.update
  end
 
 
  def update
    if @sprites
      @sprites["map"].bitmap.clear
      messagewindow = $game_temp.message_window
      cmdwindow = $game_temp.cmd_window
      pausemenu = $game_temp.pause_menu_scene
      messagewindow.visible = false if messagewindow
      cmdwindow.visible = false if cmdwindow
      pausemenu.pbHideMenu if pausemenu
      cursor_visible = Mouse.cursor_visible
      game_end_state_visible = $scene.active_hud.game_end_state_visible
      $scene.active_hud.game_end_state_visible = false if game_end_state_visible
      Mouse.hideCursor if cursor_visible
      Mouse.ui.visible = false
      @sprites["map"].bitmap =  Graphics.snap_to_bitmap
      @sprites["map"].center_origins
      @sprites["map"].x = Graphics.width/2
      @sprites["map"].y = Graphics.height/2
      Mouse.ui.visible = true
      Mouse.showCursor if cursor_visible
      $scene.active_hud.game_end_state_visible = game_end_state_visible
      messagewindow.visible = true if messagewindow
      cmdwindow.visible = true if cmdwindow
      pausemenu.pbShowMenu if pausemenu
      case self.zoom
        when "in"
          if @sprites["map"].zoom < self.goal
            altspeed = self.goal - @sprites["map"].zoom
            @sprites["map"].zoom+=[self.speed,altspeed].min
          end
        when "out"
          if @sprites["map"].zoom > @goal
            altspeed = @sprites["map"].zoom - self.goal
            @sprites["map"].zoom-=[self.speed,altspeed].min
          end
        end
    else
      dispose
    end
  end
 
 
  def dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
 
end


def pbZoomMap(goal,speed,zoom="in")
  if !$game_temp.background_zoom
    $game_temp.background_zoom = ZoomMap.new(goal,speed,zoom)
  else
    $game_temp.background_zoom.goal = goal
    $game_temp.background_zoom.speed = speed
    $game_temp.background_zoom.zoom = zoom
  end
end


def pbDisposeZoomMap
  if $game_temp.background_zoom
    $game_temp.background_zoom.dispose
    $game_temp.background_zoom = nil
  end
      Graphics.update
end


EventHandlers.add(:on_frame_update,:map_zoom,
  proc {
  next if !$player
  if $game_temp.background_zoom.is_a?(ZoomMap)
  $game_temp.background_zoom.update
  sprites = $game_temp.background_zoom.instance_variable_get(:@sprites)
    if $game_temp.background_zoom.goal == 1 && sprites["map"].zoom == 1
      pbDisposeZoomMap
    end
  end
  }
)


#===============================================================================
#Sprite Utilities
#===============================================================================
#If you have these utilities defined elsewhere, you can delete this section.
class Sprite
  #Utility from Marin
  # Centers the sprite by setting the origin points to half the width and height
  def center_origins
    return if !self.bitmap
    self.ox = self.bitmap.width / 2
    self.oy = self.bitmap.height / 2
  end
 
  #Utility from Luka
  #-----------------------------------------------------------------------------
  #  gets zoom
  #-----------------------------------------------------------------------------
  def zoom
    return self.zoom_x
  end
  #-----------------------------------------------------------------------------
  #  sets all zoom values
  #-----------------------------------------------------------------------------
  def zoom=(val)
    self.zoom_x = val
    self.zoom_y = val
  end
 
end



#===============================================================================
#Game Temp and Message Window rewriting
#===============================================================================
#This code is to allow the ZoomMap class to hide these windows
#when taking a screenshot, so that the text won't be zoomed in.
class Game_Temp
  attr_accessor :background_zoom
  attr_accessor :message_window
  attr_accessor :cmd_window
  attr_accessor :pause_menu_scene
  attr_accessor :pause_menu_screen
 
end



def pbCreateMessageWindow(viewport=nil,skin=nil)
  $game_temp.message_window = Window_AdvancedTextPokemon.new("")
  msgwindow=$game_temp.message_window
  if !viewport
    msgwindow.z=99999
  else
    msgwindow.viewport=viewport
  end
  msgwindow.visible=true
  msgwindow.letterbyletter=true
  msgwindow.back_opacity=MessageConfig::WINDOW_OPACITY
  pbBottomLeftLines(msgwindow,2)
  $game_temp.message_window_showing=true if $game_temp
  skin=MessageConfig.pbGetSpeechFrame() if !skin
  msgwindow.setSkin(skin)
  return msgwindow
end

def pbDisposeMessageWindow(msgwindow)
  $game_temp.message_window_showing=false if $game_temp
  $game_temp.message_window.dispose if $game_temp.message_window
  msgwindow.dispose
end



def pbShowCommands(msgwindow,commands=nil,cmdIfCancel=0,defaultCmd=0)
  return 0 if !commands
  $game_temp.cmd_window = Window_CommandPokemonEx.new(commands)
  cmdwindow = $game_temp.cmd_window
  cmdwindow.z=99999
  cmdwindow.visible=true
  cmdwindow.resizeToFit(cmdwindow.commands)
  pbPositionNearMsgWindow(cmdwindow,msgwindow,:right)
  cmdwindow.index=defaultCmd
  command=0
  loop do
    Graphics.update
    Input.update
    Mouse.update
    if Mouse.over_area?(cmdwindow.x, cmdwindow.y, cmdwindow.width, cmdwindow.height)
      cmdwindow.index = (Mouse.y-cmdwindow.y)/(cmdwindow.height/cmdwindow.itemCount)
    end
    cmdwindow.update
    msgwindow.update if msgwindow
    yield if block_given?
    if Input.trigger?(Input::BACK)
      if cmdIfCancel>0
        command=cmdIfCancel-1
        break
      elsif cmdIfCancel<0
        command=cmdIfCancel
        break
      end
    end
    if Input.trigger?(Input::USE) || Mouse.click_short?
      command=cmdwindow.index
      pbPlayDecisionSE
      break
    end
    pbUpdateSceneMap
  end
  ret=command
  cmdwindow.dispose
  Input.update
  return ret
end

def pbShowCommandsWithHelp(msgwindow,commands,help,cmdIfCancel=0,defaultCmd=0)
  msgwin=msgwindow
  msgwin=pbCreateMessageWindow(nil) if !msgwindow
  oldlbl=msgwin.letterbyletter
  msgwin.letterbyletter=false
  if commands
    $game_temp.cmd_window = Window_CommandPokemonEx.new(commands)
    cmdwindow = $game_temp.cmd_window
    cmdwindow.z=99999
    cmdwindow.visible=true
    cmdwindow.resizeToFit(cmdwindow.commands)
    cmdwindow.height=msgwin.y if cmdwindow.height>msgwin.y
    cmdwindow.index=defaultCmd
    command=0
    msgwin.text=help[cmdwindow.index]
    msgwin.width=msgwin.width   # Necessary evil to make it use the proper margins
    loop do
      Graphics.update
      Input.update
      oldindex=cmdwindow.index
      cmdwindow.update
      if oldindex!=cmdwindow.index
        msgwin.text=help[cmdwindow.index]
      end
      msgwin.update
      yield if block_given?
      if Input.trigger?(Input::BACK)
        if cmdIfCancel>0
          command=cmdIfCancel-1
          break
        elsif cmdIfCancel<0
          command=cmdIfCancel
          break
        end
      end
      if Input.trigger?(Input::USE)
        command=cmdwindow.index
        break
      end
      pbUpdateSceneMap
    end
    ret=command
    cmdwindow.dispose
    Input.update
  end
  msgwin.letterbyletter=oldlbl
  msgwin.dispose if !msgwindow
  return ret
end

def setMinZoom(minzoom)
  pbSet(26, minzoom)
  currZoom = $game_temp.background_zoom.instance_variable_get(:@sprites)
  currZoom = (currZoom.nil?) ? 1 : currZoom["map"].zoom
  if currZoom < minzoom
    pbZoomMap(minzoom,0.01,"in")
  else
    pbZoomMap(minzoom,0.01,"out")
  end
end