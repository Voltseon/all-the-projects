# Name-box by By Theo/MrGela @ theo#7722
# Expected behaviour and use: 
# Use in a text command, with an added keyword like "\xn[Test]" in order to 
# display a small box to the top-left of the message window, displaying "Test".
# This window will rely on the user's choice of text frame unless there's one
# specified in DEFAULT_WINDOWSKIN below.
#===============================================================================
# HOW TO USE THIS?
# \xn[Text,baseColor,shadowColor,fontName,fontSize,textAlignment,windowX,windowY,windowSkin]
# EXAMPLES:
# \xn[Prof. Oak,0073ff,7bbdef,Power Clear,,2]Test.
# \wu\xn[Prof. Oak,,,,,2,18,162]Test.
#===============================================================================
# CONFIGURATION
#===============================================================================
# SHIFT NAMEWINDOW IN X AXIS (except when specifying a particular X location)
OFFSET_NAMEWINDOW_X=0 
# SHIFT NAMEWINDOW IN Y AXIS (except when specifying a particular Y location)
OFFSET_NAMEWINDOW_Y=0 
# WHETHER THE TEXT SHOULD BE CENTERED (0=right, 1=center, 2=right)
DEFAULT_ALIGNMENT=1   
# ENSURES A MIN. WIDTH OF THE WINDOW
MIN_WIDTH=200       
# DEFAULT FONT
DEFAULT_FONT="Power Green" # "Power Clear", etc.
# DEFAULT FONT SIZE
DEFAULT_FONT_SIZE=nil
# DEFAULT WINDOWSKIN (nil = based on the currently displayed message windowskin)
# (File inside Graphics/Windowskins/)
DEFAULT_WINDOWSKIN = "last wish 1"
#===============================================================================
# END CONFIGURATION / Don't touch anything below this point or you'll get a bonk
#===============================================================================
# Text Skipping is Allowed (Default = true)
ALLOW_TEXT_SKIP = true
# Even if you type false here, you can enable text skipping in-game with $PokemonSystem.text_skip
# Example: $PokemonSystem.text_skip = true (Allows the player to text skip)

# Button used for Text Skipping (Default = Input::BACK)
TEXT_SKIP_BUTTON = Input::BACK
# Possible Inputs:
# Input::USE, Input::BACK, Input::ACTION, Input::JUMPUP, Input::JUMPDOWN, Input::SPECIAL, Input::AUX1, Input::AUX2
# Params:
# 0       = msgwindow (required)
# 1       = string (required)
# 2       = use dark windowskin? (boolean) (defaults to false)
# 3       = color override
# 4       = shadow override
# 4       = font override
# 5       = font size override
# 6       = alignment (defaults to 0, left)
# 7 and 8 = forced X and Y of the namewindow
def pbDisplayNameWindow(params)
  name         = params[1]
  isDark       = params[2]  if params[2]
  colorBase    = colorToRgb32(MessageConfig::DARK_TEXT_MAIN_COLOR)
  colorBase    = colorToRgb32(MessageConfig::LIGHT_TEXT_MAIN_COLOR) if isDark==true
  colorBase    = params[3]  if !params[3].nil?
  colowShadow  = colorToRgb32(MessageConfig::DARK_TEXT_SHADOW_COLOR)
  colorShadow  = colorToRgb32(MessageConfig::LIGHT_TEXT_SHADOW_COLOR) if isDark==true
  colorShadow  = params[4]  if !params[4].nil?
  font         = params[5]  if !params[5].nil?
  font         = DEFAULT_FONT if font.nil? || font=="0"
  fontSize     = DEFAULT_FONT_SIZE
  fontSize     = params[6]  if !params[6].nil?
  position     = params[7]  if !params[7].nil?
  newX         = 0
  newY         = 0
  newX         = params[8]  if !params[8].nil?
  newY         = params[9]  if !params[9].nil?
  newSkin      = params[10] if params[10] != (nil || "0")
  newSkin      = Settings::SPEECH_WINDOWSKINS[$PokemonSystem.textskin] if newSkin=="nil" || (newSkin==nil || newSkin=="0") 
  msgwindow=params[0]
  fullName=(params[1].split(","))[0]
  # Handle text alignment
  align=""
  alignEnd=""
  case DEFAULT_ALIGNMENT
  when 0
    align="<al>"
    alignEnd="</al>"
  when 1
    align="<ac>"
    alignEnd="</ac>"
  when 2
    align="<ar>"
    alignEnd="</ar>"
  end
  # If position is defined, use that instead
  if !position.nil? || position!="nil"
    case position
    when "0"
      align="<al>"
      alignEnd="</al>"
    when "1", "", nil
      align="<ac>"
      alignEnd="</ac>"
    when "2"
      align="<ar>"
      alignEnd="</ar>"
    end
  end
  fullName.insert(0,align)
  fullName+=alignEnd
  # Handle text color
  # If base or shadow are empty somehow, load windowskin-sensitive colors
  if colorBase.nil? || colorBase.empty?
    colorBase=colorToRgb32(MessageConfig::DARK_TEXT_MAIN_COLOR)
    colorBase=colorToRgb32(MessageConfig::LIGHT_TEXT_MAIN_COLOR) if isDark==true
  end
  if colorShadow.nil? || colorShadow.empty?
    colorShadow=colorToRgb32(MessageConfig::DARK_TEXT_SHADOW_COLOR) 
    colorShadow=colorToRgb32(MessageConfig::LIGHT_TEXT_SHADOW_COLOR) if isDark==true
  end
  fullColor="<c3="+colorBase+","+colorShadow+">"
  fullName.insert(0,fullColor) unless fullColor=="<c3=0,0>"
  # Handle text font
  if font.nil? || font.empty?
  elsif font.is_a?(String)
    fullFont="<fn="+font+">"
    fullName.insert(0,fullFont)
    fullName+="</fn>"
  end
  # Handle text font size
  if fontSize.nil?
  elsif (fontSize.is_a?(Numeric) && fontSize!=0) || (fontSize.is_a?(String) && !fontSize.empty? && fontSize!="0")
    fullFontSize="<fs="+fontSize.to_s+">"
    fullName.insert(0,fullFontSize)
    fullName+="</fs>"
  end
  namewindow=Window_AdvancedTextPokemon.new(_INTL(fullName.to_s))
  if isDark==true
    namewindow.setSkin("Graphics/Windowskins/speech black")
  end
  if newSkin!=nil
    if newSkin==DEFAULT_WINDOWSKIN
      if isDark==true
      else
        namewindow.setSkin("Graphics/Windowskins/"+newSkin)
      end
    else
      namewindow.setSkin("Graphics/Windowskins/"+newSkin) 
    end
  end
  namewindow.resizeToFit(namewindow.text,Graphics.width)
  namewindow.width=MIN_WIDTH if namewindow.width<=MIN_WIDTH
  namewindow.width = namewindow.width
  namewindow.y=msgwindow.y-namewindow.height
  if newX != (nil || "0") && !newX.empty?
    namewindow.x=newX.to_i
  else
    namewindow.x+=OFFSET_NAMEWINDOW_X
  end
  if newY != (nil || "0") && !newY.empty?
    namewindow.y=newY.to_i
  else
    namewindow.y+=OFFSET_NAMEWINDOW_Y
  end
 
  namewindow.viewport=msgwindow.viewport
  namewindow.z=msgwindow.z
  return namewindow
end

def pbMessageDisplay(msgwindow,message,letterbyletter=true,commandProc=nil)
  return if !msgwindow
  oldletterbyletter=msgwindow.letterbyletter
  msgwindow.letterbyletter=(letterbyletter) ? true : false
  ret=nil
  commands=nil
  facewindow=nil
  goldwindow=nil
  coinwindow=nil
  namewindow=nil
  battlepointswindow=nil
  cmdvariable=0
  cmdIfCancel=0
  msgwindow.waitcount=0
  autoresume=false
  text=message.clone
  msgback=nil
  linecount=(Graphics.height>400) ? 3 : 2
  ### Text replacement
  text.gsub!(/\\sign\[([^\]]*)\]/i) {   # \sign[something] gets turned into
    next "\\op\\cl\\ts[]\\w["+$1+"]"    # \op\cl\ts[]\w[something]
  }
  text.gsub!(/\\\\/,"\5")
  text.gsub!(/\\1/,"\1")
  if $game_actors
    text.gsub!(/\\n\[([1-8])\]/i) {
      m = $1.to_i
      next $game_actors[m].name
    }
  end
  text.gsub!(/\\pn/i,$Trainer.name) if $Trainer
  text.gsub!(/\\pm/i,_INTL("${1}",$Trainer.money.to_s_formatted)) if $Trainer
  text.gsub!(/\\n/i,"\n")
  text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2="+$1+">" }
  text.gsub!(/\\pg/i,"\\b") if $Trainer && $Trainer.male?
  text.gsub!(/\\pg/i,"\\r") if $Trainer && $Trainer.female?
  text.gsub!(/\\pog/i,"\\r") if $Trainer && $Trainer.male?
  text.gsub!(/\\pog/i,"\\b") if $Trainer && $Trainer.female?
  text.gsub!(/\\pg/i,"")
  text.gsub!(/\\pog/i,"")
  text.gsub!(/\\b/i,"<c3=3050C8,D0D0C8>")
  text.gsub!(/\\r/i,"<c3=E00808,D0D0C8>")
  text.gsub!(/\\jle/i,"<c3=FF7F00,D0D0C8>")
  text.gsub!(/\\dns/i,"<c3=00BC61,D0D0C8>")
  text.gsub!(/\\atd/i,"<c3=C30FFF,D0D0C8>")
  text.gsub!(/\\aug/i,"<c3=B55E44,D0D0C8>")
  text.gsub!(/\\[Ww]\[([^\]]*)\]/) {
    w = $1.to_s
    if w==""
      msgwindow.windowskin = nil
    else
      msgwindow.setSkin("Graphics/Windowskins/#{w}",false)
    end
    next ""
  }
  isDarkSkin = isDarkWindowskin(msgwindow.windowskin)
  text.gsub!(/\\[Cc]\[([0-9]+)\]/) {
    m = $1.to_i
    next getSkinColor(msgwindow.windowskin,m,isDarkSkin)
  }
  loop do
    last_text = text.clone
    text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
    break if text == last_text
  end
  loop do
    last_text = text.clone
    text.gsub!(/\\l\[([0-9]+)\]/i) {
      linecount = [1,$1.to_i].max
      next ""
    }
    break if text == last_text
  end
  colortag = ""
  if $game_system && $game_system.respond_to?("message_frame") &&
     $game_system.message_frame != 0
    colortag = getSkinColor(msgwindow.windowskin,0,true)
  else
    colortag = getSkinColor(msgwindow.windowskin,0,isDarkSkin)
  end
  text = colortag+text
  ### Controls
  textchunks=[]
  controls=[]
  while text[/(?:\\([Xn][Nn]|[Dd][Xx][Nn]|[Xn][Nn][Aa]|[Xn][Nn][Bb]|[Xn][Nn][Cc]|f|ff|ts|cl|me|se|wt|wtnp|ch)\[([^\]]*)\]|\\(g|cn|pt|wd|wm|op|cl|wu|\.|\||\!|\^))/i]
    textchunks.push($~.pre_match)
    if $~[1]
      controls.push([$~[1].downcase,$~[2],-1])
    else
      controls.push([$~[3].downcase,"",-1])
    end
    text=$~.post_match
  end
  textchunks.push(text)
  for chunk in textchunks
    chunk.gsub!(/\005/,"\\")
  end
  textlen = 0
  for i in 0...controls.length
    control = controls[i][0]
    case control
    when "wt", "wtnp", ".", "|"
      textchunks[i] += "\2"
    when "!"
      textchunks[i] += "\1"
    end
    textlen += toUnformattedText(textchunks[i]).scan(/./m).length
    controls[i][2] = textlen
  end
  text = textchunks.join("")
  signWaitCount = 0
  signWaitTime = Graphics.frame_rate/2
  haveSpecialClose = false
  specialCloseSE = ""
  for i in 0...controls.length
    control = controls[i][0]
    param = controls[i][1]
    case control
    when "op"
      signWaitCount = signWaitTime+1
    when "cl"
      text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
      haveSpecialClose = true
      specialCloseSE = param
    when "f"
      facewindow.dispose if facewindow
      facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
    when "ff"
      facewindow.dispose if facewindow
      facewindow = FaceWindowVX.new(param)
    when "ch"
      cmds = param.clone
      cmdvariable = pbCsvPosInt!(cmds)
      cmdIfCancel = pbCsvField!(cmds).to_i
      commands = []
      while cmds.length>0
        commands.push(pbCsvField!(cmds))
      end
    when "wtnp", "^"
      text = text.sub(/\001\z/,"")   # fix: '$' can match end of line as well
    when "se"
      if controls[i][2]==0
        startSE = param
        controls[i] = nil
      end
    end
  end
  if startSE!=nil
    pbSEPlay(pbStringToAudioFile(startSE))
  elsif signWaitCount==0 && letterbyletter
    pbPlayDecisionSE()
  end
  ########## Position message window  ##############
  pbRepositionMessageWindow(msgwindow,linecount)
  if facewindow
    pbPositionNearMsgWindow(facewindow,msgwindow,:left)
    facewindow.viewport = msgwindow.viewport
    facewindow.z        = msgwindow.z
  end
  atTop = (msgwindow.y==0)
  ########## Show text #############################
  msgwindow.text = text
  Graphics.frame_reset if Graphics.frame_rate>60
  loop do
    if signWaitCount>0
      signWaitCount -= 1
      if atTop
        msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
      else
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
      end
    end
    for i in 0...controls.length
      next if !controls[i]
      next if controls[i][2]>msgwindow.position || msgwindow.waitcount!=0
      control = controls[i][0]
      param = controls[i][1]
      case control
              # NEW
        when "xn"
          # Show name box, displaying string
          string=controls[i][1]
          extra=string.split(",")
          # Feed them 0/nil to pass down and later ignore
          extra[1]="" if extra[1]=="" || !extra[1]
          extra[2]="" if extra[2]=="" || !extra[2]
          extra[3]="0" if extra[3]=="" || !extra[3]
          extra[4]="0" if extra[4]=="" || !extra[4]
          extra[5]="nil" if extra[5]=="" || !extra[5]
          extra[6]="0" if extra[6]=="" || !extra[6]
          extra[7]="0" if extra[7]=="" || !extra[7]
          extra[8]="0" if extra[8]=="" || !extra[8]
          colorBase=extra[1]
          colorShadow=extra[2]
          font=extra[3]
          fontSize=extra[4]
          alignment=extra[5]
          forcedX=extra[6]
          forcedY=extra[7]
          newSkin=extra[8]
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow([msgwindow,string,false,colorBase,colorShadow,font,fontSize,alignment,forcedX,forcedY,newSkin])
        when "dxn"
          # Show dark name box, displaying string
          string=controls[i][1]
          extra=string.split(",")
          # Feed them 0/nil to pass down and later ignore
          extra[1]="" if extra[1]=="" || !extra[1]
          extra[2]="" if extra[2]=="" || !extra[2]
          extra[3]="0" if extra[3]=="" || !extra[3]
          extra[4]="0" if extra[4]=="" || !extra[4]
          extra[5]="nil" if extra[5]=="" || !extra[5]
          extra[6]="0" if extra[6]=="" || !extra[6]
          extra[7]="0" if extra[7]=="" || !extra[7]
          extra[8]="0" if extra[8]=="" || !extra[8]
          colorBase=extra[1]
          colorShadow=extra[2]
          font=extra[3]
          fontSize=extra[4]
          alignment=extra[5]
          forcedX=extra[6]
          forcedY=extra[7]
          newSkin=extra[8]
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow([msgwindow,string,true,colorBase,colorShadow,font,fontSize,alignment,forcedX,forcedY,newSkin])
        # START SAMPLES / PRESETS
        # Three samples, use xna, xnb or xnc instead of xn or dxn in the text command
        # These do not take any additional parameters except for name
        # I created these samples so if, for example, you use a couple of commands
        # all the time (like to make the text blue/red for some NPCs) you don't
        # have to manually type them all the time, and can use these as shortcuts
        # instead!
        # Customize at your own peril but feel free to contact me on the 
        # resource's thread for some directions.
        # namewindow=pbDisplayNameWindow([msgwindow,string,true,colorBase,colorShadow,font,fontSize,alignment,forcedX,forcedY,newSkin])
        # Only keep msgwindow, string and the true/false, and set the others (as "0"/nil)
        when "xna"
          # Sample, sets a particular color (red)
          string=controls[i][1]
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow([msgwindow,string,false,"ef2110","ffadbd","0","0",nil,"0","0","0"])
        when "xnb"
          # Sample, sets a particular color (blue)
          string=controls[i][1]
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow([msgwindow,string,false,"0073ff","7bbdef","0","0",nil,"0","0","0"])
        when "xnc" 
          # Sample, window is placed at 96, 96, uses a different font and windowskin
          string=controls[i][1]
          namewindow.dispose if namewindow
          namewindow=pbDisplayNameWindow([msgwindow,string,false,"0","0","Power Clear","0",nil,"96","96","speech frlg"])
        # END SAMPLES / PRESETS
      when "f"
        facewindow.dispose if facewindow
        facewindow = PictureWindow.new("Graphics/Pictures/#{param}")
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
      when "ff"
        facewindow.dispose if facewindow
        facewindow = FaceWindowVX.new(param)
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        facewindow.viewport = msgwindow.viewport
        facewindow.z        = msgwindow.z
      when "g"      # Display gold window
        goldwindow.dispose if goldwindow
        goldwindow = pbDisplayGoldWindow(msgwindow)
      when "cn"     # Display coins window
        coinwindow.dispose if coinwindow
        coinwindow = pbDisplayCoinsWindow(msgwindow,goldwindow)
      when "pt"     # Display battle points window
        battlepointswindow.dispose if battlepointswindow
        battlepointswindow = pbDisplayBattlePointsWindow(msgwindow)
      when "wu"
        msgwindow.y = 0
        atTop = true
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        msgwindow.y = -msgwindow.height*signWaitCount/signWaitTime
      when "wm"
        atTop = false
        msgwindow.y = (Graphics.height-msgwindow.height)/2
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
      when "wd"
        atTop = false
        msgwindow.y = Graphics.height-msgwindow.height
        msgback.y = msgwindow.y if msgback
        pbPositionNearMsgWindow(facewindow,msgwindow,:left)
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-signWaitCount)/signWaitTime
      when "ts"     # Change text speed
        msgwindow.textspeed = (param=="") ? -999 : param.to_i
      when "."      # Wait 0.25 seconds
        msgwindow.waitcount += Graphics.frame_rate/4
      when "|"      # Wait 1 second
        msgwindow.waitcount += Graphics.frame_rate
      when "wt"     # Wait X/20 seconds
        param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
        msgwindow.waitcount += param.to_i*Graphics.frame_rate/20
      when "wtnp"   # Wait X/20 seconds, no pause
        param = param.sub(/\A\s+/,"").sub(/\s+\z/,"")
        msgwindow.waitcount = param.to_i*Graphics.frame_rate/20
        autoresume = true
      when "^"      # Wait, no pause
        autoresume = true
      when "se"     # Play SE
        pbSEPlay(pbStringToAudioFile(param))
      when "me"     # Play ME
        pbMEPlay(pbStringToAudioFile(param))
      end
      controls[i] = nil
    end
    break if !letterbyletter
    Graphics.update
    Input.update
    facewindow.update if facewindow
    if autoresume && msgwindow.waitcount==0
      msgwindow.resume if msgwindow.busy?
      break if !msgwindow.busy?
    end
    ########## Text Skipping #######################
    if $PokemonSystem.text_skip
        if Input.press?(TEXT_SKIP_BUTTON)
          msgwindow.textspeed=-999
          msgwindow.update
          if msgwindow.busy?
            pbPlayDecisionSE() if msgwindow.pausing?
            msgwindow.resume
          else
            break if signWaitCount==0
          end
        end
      end
    if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      if msgwindow.busy?
        pbPlayDecisionSE if msgwindow.pausing?
        msgwindow.resume
      else
        break if signWaitCount==0
      end
    end
    pbUpdateSceneMap
    msgwindow.update
    yield if block_given?
    break if (!letterbyletter || commandProc || commands) && !msgwindow.busy?
  end
  Input.update   # Must call Input.update again to avoid extra triggers
  msgwindow.letterbyletter=oldletterbyletter
  if commands
    $game_variables[cmdvariable]=pbShowCommands(msgwindow,commands,cmdIfCancel)
    $game_map.need_refresh = true if $game_map
  end
  if commandProc
    ret=commandProc.call(msgwindow)
  end
  msgback.dispose if msgback
  goldwindow.dispose if goldwindow
  coinwindow.dispose if coinwindow
  battlepointswindow.dispose if battlepointswindow
  facewindow.dispose if facewindow
  namewindow.dispose if namewindow
  if haveSpecialClose
    pbSEPlay(pbStringToAudioFile(specialCloseSE))
    atTop = (msgwindow.y==0)
    for i in 0..signWaitTime
      if atTop
        msgwindow.y = -msgwindow.height*i/signWaitTime
      else
        msgwindow.y = Graphics.height-msgwindow.height*(signWaitTime-i)/signWaitTime
      end
      Graphics.update
      Input.update
      pbUpdateSceneMap
      msgwindow.update
    end
  end
  return ret
end

#-------------------------------------------------------------------------------
# Attribute in PokemonSystem to save if text skip is enabled in save file
#-------------------------------------------------------------------------------
class PokemonSystem
	attr_writer :text_skip

	def text_skip
		@text_skip = ALLOW_TEXT_SKIP if !@text_skip
		return @text_skip
	end
end