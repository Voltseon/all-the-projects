class Scene_DebugIntro
  def main
    Graphics.transition(0)
    if SaveData.exists?
      Game.load(load_save_file(SaveData::FILE_PATH))
    else
      Game.start_new
    end
    Graphics.freeze
  end
end

def pbCallTitle
  return Scene_DebugIntro.new if $DEBUG
  return Scene_Intro.new
end

def load_save_file(file_path)
  save_data = SaveData.read_from_file(file_path)
  unless SaveData.valid?(save_data)
    if File.file?(file_path + ".bak")
      pbMessage(_INTL("The save file is corrupt. A backup will be loaded."))
      save_data = load_save_file(file_path + ".bak")
    else
      self.prompt_save_deletion
      return {}
    end
  end
  return save_data
end

def mainFunction
  if $DEBUG
    pbCriticalCode { mainFunctionDebug }
  else
    mainFunctionDebug
  end
  return 1
end

def mainFunctionDebug
  begin
    MessageTypes.loadMessageFile("Data/messages.dat") if safeExists?("Data/messages.dat")
    PluginManager.runPlugins
    Compiler.main
    Game.initialize
    Game.set_up_system
    Graphics.update
    Graphics.freeze
    $scene = pbCallTitle
    $scene.main until $scene.nil?
    Graphics.transition
  rescue Hangup
    pbPrintException($!) if !$DEBUG
    pbEmergencySave
    raise
  end
end

loop do
  retval = mainFunction
  case retval
  when 0   # failed
    loop do
      Graphics.update
    end
  when 1   # ended successfully
    break
  end
end
