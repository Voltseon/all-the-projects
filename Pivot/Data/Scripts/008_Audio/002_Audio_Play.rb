def pbStringToAudioFile(str)
  if str[/^(.*)\:\s*(\d+)\s*\:\s*(\d+)\s*$/]   # Of the format "XXX: ###: ###"
    file   = $1
    volume = $2.to_i
    pitch  = $3.to_i
    return RPG::AudioFile.new(file, volume, pitch)
  elsif str[/^(.*)\:\s*(\d+)\s*$/]             # Of the format "XXX: ###"
    file   = $1
    volume = $2.to_i
    return RPG::AudioFile.new(file, volume, 100)
  else
    return RPG::AudioFile.new(str, 100, 100)
  end
end

# Converts an object to an audio file.
# str -- Either a string showing the filename or an RPG::AudioFile object.
# Possible formats for _str_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbResolveAudioFile(str, volume = nil, pitch = nil)
  if str.is_a?(String)
    str = pbStringToAudioFile(str)
    str.volume = volume || 100
    str.pitch  = pitch || 100
  end
  if str.is_a?(RPG::AudioFile)
    if volume || pitch
      return RPG::AudioFile.new(str.name, volume || str.volume || 100,
                                pitch || str.pitch || 100)
    else
      return str
    end
  end
  return str
end

################################################################################

# Plays a BGM file.
# param -- Either a string showing the filename
# (relative to Audio/BGM/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGMPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.bgm_play(param)
      return
    elsif (RPG.const_defined?(:BGM) rescue false)
      b = RPG::BGM.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.bgm_play(canonicalize("Audio/BGM/" + param.name), param.volume, param.pitch)
  end
end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMFade(x = 0.0); pbBGMStop(x); end

# Fades out or stops BGM playback. 'x' is the time in seconds to fade out.
def pbBGMStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0
    $game_system.bgm_fade(timeInSeconds)
    return
  elsif $game_system
    $game_system.bgm_stop
    return
  elsif (RPG.const_defined?(:BGM) rescue false)
    begin
      (timeInSeconds > 0.0) ? RPG::BGM.fade((timeInSeconds * 1000).floor) : RPG::BGM.stop
      return
    rescue
    end
  end
  (timeInSeconds > 0.0) ? Audio.bgm_fade((timeInSeconds * 1000).floor) : Audio.bgm_stop
end

################################################################################

# Plays an ME file.
# param -- Either a string showing the filename
# (relative to Audio/ME/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbMEPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.me_play(param)
      return
    elsif (RPG.const_defined?(:ME) rescue false)
      b = RPG::ME.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.me_play(canonicalize("Audio/ME/" + param.name), param.volume, param.pitch)
  end
end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEFade(x = 0.0); pbMEStop(x); end

# Fades out or stops ME playback. 'x' is the time in seconds to fade out.
def pbMEStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0 && $game_system.respond_to?("me_fade")
    $game_system.me_fade(timeInSeconds)
    return
  elsif $game_system.respond_to?("me_stop")
    $game_system.me_stop(nil)
    return
  elsif (RPG.const_defined?(:ME) rescue false)
    begin
      (timeInSeconds > 0.0) ? RPG::ME.fade((timeInSeconds * 1000).floor) : RPG::ME.stop
      return
    rescue
    end
  end
  (timeInSeconds > 0.0) ? Audio.me_fade((timeInSeconds * 1000).floor) : Audio.me_stop
end

################################################################################

# Plays a BGS file.
# param -- Either a string showing the filename
# (relative to Audio/BGS/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                        volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbBGSPlay(param, volume = nil, pitch = nil)
  return if !param
  param = pbResolveAudioFile(param, volume, pitch)
  if param.name && param.name != ""
    if $game_system
      $game_system.bgs_play(param)
      return
    elsif (RPG.const_defined?(:BGS) rescue false)
      b = RPG::BGS.new(param.name, param.volume, param.pitch)
      if b.respond_to?("play")
        b.play
        return
      end
    end
    Audio.bgs_play(canonicalize("Audio/BGS/" + param.name), param.volume, param.pitch)
  end
end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSFade(x = 0.0); pbBGSStop(x); end

# Fades out or stops BGS playback. 'x' is the time in seconds to fade out.
def pbBGSStop(timeInSeconds = 0.0)
  if $game_system && timeInSeconds > 0.0
    $game_system.bgs_fade(timeInSeconds)
    return
  elsif $game_system
    $game_system.bgs_play(nil)
    return
  elsif (RPG.const_defined?(:BGS) rescue false)
    begin
      (timeInSeconds > 0.0) ? RPG::BGS.fade((timeInSeconds * 1000).floor) : RPG::BGS.stop
      return
    rescue
    end
  end
  (timeInSeconds > 0.0) ? Audio.bgs_fade((timeInSeconds * 1000).floor) : Audio.bgs_stop
end

################################################################################

# Plays an SE file.
# param -- Either a string showing the filename
# (relative to Audio/SE/) or an RPG::AudioFile object.
# Possible formats for _param_:
# filename                  volume and pitch 100
# filename:volume           pitch 100
# filename:volume:pitch
# volume -- Volume of the file, up to 100
# pitch -- Pitch of the file, normally 100
def pbSEPlay(name, volume = nil, pitch = nil, pan = 0)
  return if !name
  param = pbResolveAudioFile(name, volume, pitch)
  param_l = pbResolveAudioFile(name+"_L", volume, pitch) if name.is_a?(String)
  param_r = pbResolveAudioFile(name+"_R", volume, pitch) if name.is_a?(String)
  if param.name && param.name != ""
    if param_l&.name && param_l&.name != "" && param_r&.name && param_r&.name != ""
      if pan < 0
        param_l.volume = (param.volume * pan.abs / 100.0).round
        param.volume -= param_l.volume
        param_r.volume = 0
      elsif pan > 0
        param_r.volume = (param.volume * pan / 100.0).round
        param.volume -= param_r.volume
        param_l.volume = 0
      else
        param_l.volume = 0
        param_r.volume = 0
      end
      if $game_system
        $game_system.se_play(param) if param.volume > 0
        $game_system.se_play(param_l) if param_l.volume > 0
        $game_system.se_play(param_r) if param_r.volume > 0
        return
      end
      Audio.se_play(canonicalize("Audio/SE/" + param.name), param.volume, param.pitch) if param.volume > 0
      Audio.se_play(canonicalize("Audio/SE/" + param_l.name), param_l.volume, param_l.pitch) if param_l.volume > 0
      Audio.se_play(canonicalize("Audio/SE/" + param_r.name), param_r.volume, param_r.pitch) if param_r.volume > 0
    else
      if $game_system
        $game_system.se_play(param)
        return
      end
      if (RPG.const_defined?(:SE) rescue false)
        b = RPG::SE.new(param.name, param.volume, param.pitch)
        if b.respond_to?("play")
          b.play
          return
        end
      end
      Audio.se_play(canonicalize("Audio/SE/" + param.name), param.volume, param.pitch) if param.volume > 0
    end
  end
end

# Stops SE playback.
def pbSEFade(x = 0.0); pbSEStop(x); end

# Stops SE playback.
def pbSEStop(_timeInSeconds = 0.0)
  if $game_system
    $game_system.se_stop
  elsif (RPG.const_defined?(:SE) rescue false)
    RPG::SE.stop rescue nil
  else
    Audio.se_stop
  end
end

################################################################################

# Plays a sound effect that plays when the player moves the cursor.
def pbPlayCursorSE
  sound = AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).gui_cursor, AudioPack.get($PokemonGlobal.audio_pack))
  if FileTest.audio_exist?("Audio/SE/#{sound}")
    pbSEPlay("#{sound}", 80)
  end
end

# Plays a sound effect that plays when a decision is confirmed or a choice is made.
def pbPlayDecisionSE
  sound = AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).gui_decision, AudioPack.get($PokemonGlobal.audio_pack))
  if FileTest.audio_exist?("Audio/SE/#{sound}")
    pbSEPlay("#{sound}", 80)
  end
end

# Plays a sound effect that plays when a choice is canceled.
def pbPlayCancelSE
  sound = AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).gui_cancel, AudioPack.get($PokemonGlobal.audio_pack))
  if FileTest.audio_exist?("Audio/SE/#{sound}")
    pbSEPlay("#{sound}", 80)
  end
end

# Plays a buzzer sound effect.
def pbPlayBuzzerSE
  sound = AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).gui_buzzer, AudioPack.get($PokemonGlobal.audio_pack))
  if FileTest.audio_exist?("Audio/SE/#{sound}")
    pbSEPlay("#{sound}", 80)
  end
end

# Plays a sound effect that plays when the player closes a menu.
def pbPlayCloseMenuSE
  sound = AudioPack.parse(AudioPack.get($PokemonGlobal.audio_pack).menu_close, AudioPack.get($PokemonGlobal.audio_pack))
  if FileTest.audio_exist?("Audio/SE/#{sound}")
    pbSEPlay("#{sound}", 80)
  end
end
