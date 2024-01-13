GENERIC = "Voice Generic "
BATTLE = "Voice Battle "
COMMENT = "Voice Comment "
MISC = "Voice Misc "
PERSONAL = "Voice Personal "
FOOLS = "/April Fools/"

def pbAnnounce(event, battler = nil)
  battler = $player&.character_ID if !battler
  battler = Character.get(battler).internal
  battler = battler.to_s
  case event
  # Personal
  when :character
    pbVoicePlay(PERSONAL+"1_"+battler)
  when :tired
    pbVoicePlay(PERSONAL+"2_"+battler)
  when :evades
    pbVoicePlay(PERSONAL+"3_"+battler)
  when :transform
    pbVoicePlay(PERSONAL+"4_"+battler)
  when :restore
    pbVoicePlay(PERSONAL+"5_"+battler)
  when :won
    pbVoicePlay(PERSONAL+"6_"+battler)
  when :low_health
    pbVoicePlay(PERSONAL+"7_"+battler)
  # Generic
  when :generic_1
    pbVoicePlay(GENERIC+"1")
  when :generic_2
    pbVoicePlay(GENERIC+"2")
  when :end
    pbVoicePlay(GENERIC+"3")
  when :results
    pbVoicePlay(GENERIC+"4")
  when :start
    pbVoicePlay(GENERIC+"5")
  when :draw
    pbVoicePlay(GENERIC+"6")
  # In-Battle
  when :massive_damage
    pbVoicePlay(BATTLE+"1")
  when :brilliant_hit
    pbVoicePlay(BATTLE+"2")
  when :well_aimed
    pbVoicePlay(BATTLE+"3")
  when :that_hurt
    pbVoicePlay(BATTLE+"4")
  when :solid_hit
    pbVoicePlay(BATTLE+"5")
  when :light_hit
    pbVoicePlay(BATTLE+"6")
  when :perfect_shot
    pbVoicePlay(BATTLE+"7")
  when :what
    pbVoicePlay(BATTLE+"8")
  when :down_and_out
    pbVoicePlay(BATTLE+"9")
  when :bam
    pbVoicePlay(BATTLE+"10")
  when :went_down
    pbVoicePlay(BATTLE+"11")
  when :taken_down
    pbVoicePlay(BATTLE+"12")
  when :slammed
    pbVoicePlay(BATTLE+"13")
  when :aah
    pbVoicePlay(BATTLE+"14")
  # Comment
  when :defeat_1
    pbVoicePlay(COMMENT+"1")
  when :defeat_2
    pbVoicePlay(COMMENT+"2")
  when :defeat_3
    pbVoicePlay(COMMENT+"3")
  when :defeat_4
    pbVoicePlay(COMMENT+"4")
  # Misc
  when :arena_1
    pbVoicePlay(MISC+"1")
  when :arena_2
    pbVoicePlay(MISC+"2")
  when :arena_3 # doesn't exist yet
    pbVoicePlay(MISC+"3")
  # April Fools
  when :fools_splash_1
    pbVoicePlay(FOOLS+"Fools 1")
  when :fools_splash_2
    pbVoicePlay(FOOLS+"Fools 2")
  when :fools_main_menu
    pbVoicePlay(FOOLS+"Fools 3")
  when :fools_play
    pbVoicePlay(FOOLS+"Fools 4")
  when :fools_options
    pbVoicePlay(FOOLS+"Fools 5")
  when :fools_patch_notes
    pbVoicePlay(FOOLS+"Fools 6")
  when :fools_rename
    pbVoicePlay(FOOLS+"Fools 7")
  when :fools_discord
    pbVoicePlay(FOOLS+"Fools 8")
  when :fools_training
    pbVoicePlay(FOOLS+"Fools 9")
  when :fools_music_volume
    pbVoicePlay(FOOLS+"Fools 10")
  when :fools_se_volume
    pbVoicePlay(FOOLS+"Fools 11")
  when :fools_announcer_volume
    pbVoicePlay(FOOLS+"Fools 12")
  when :fools_screen_size
    pbVoicePlay(FOOLS+"Fools 13")
  when :fools_configure_controls
    pbVoicePlay(FOOLS+"Fools 14")
  when :fools_close
    pbVoicePlay(FOOLS+"Fools 15")
  when :fools_play_credits
    pbVoicePlay(FOOLS+"Fools 16")
  when :fools_replay_tutorial
    pbVoicePlay(FOOLS+"Fools 17")
  when :fools_pivot_version
    pbVoicePlay(FOOLS+"Fools 18")
  when :fools_are_you_sure_tutorial
    pbVoicePlay(FOOLS+"Fools 19")
  when :fools_yes
    pbVoicePlay(FOOLS+"Fools 20")
  when :fools_no
    pbVoicePlay(FOOLS+"Fools 21")
  when :fools_multiplayer
    pbVoicePlay(FOOLS+"Fools 22")
  when :fools_enter_code
    pbVoicePlay(FOOLS+"Fools 23")
  when :fools_create_lobby
    pbVoicePlay(FOOLS+"Fools 24")
  when :fools_refresh
    pbVoicePlay(FOOLS+"Fools 25")
  when :fools_back
    pbVoicePlay(FOOLS+"Fools 26")
  when :fools_enter_id
    pbVoicePlay(FOOLS+"Fools 27")
  when :fools_select_character
    pbVoicePlay(FOOLS+"Fools 28")
  when :fools_spectating
    pbVoicePlay(FOOLS+"Fools 29")
  when :fools_confirm
    pbVoicePlay(FOOLS+"Fools 30")
  when :fools_ready
    pbVoicePlay(FOOLS+"Fools 31")
  when :fools_unready
    pbVoicePlay(FOOLS+"Fools 32")
  when :fools_select_arena
    pbVoicePlay(FOOLS+"Fools 33")
  when :fools_region_NA
    pbVoicePlay(FOOLS+"Fools 34")
  when :fools_region_EU
    pbVoicePlay(FOOLS+"Fools 35")
  when :fools_region_OC
    # TODO: Add OC voice
  when :fools_region_DEV
    # 
  when :fools_visibility_0
    pbVoicePlay(FOOLS+"Fools 36")
  when :fools_visibility_1
    pbVoicePlay(FOOLS+"Fools 37")
  when :fools_crystal
    pbVoicePlay(FOOLS+"Fools 38")
  when :fools_woods
    pbVoicePlay(FOOLS+"Fools 39")
  when :fools_oasis
    pbVoicePlay(FOOLS+"Fools 40")
  when :fools_lights
    pbVoicePlay(FOOLS+"Fools 41")
  when :fools_quantum
    pbVoicePlay(FOOLS+"Fools 42")
  when :fools_factory
    pbVoicePlay(FOOLS+"Fools 43")
  when :fools_the_ring
    pbVoicePlay(FOOLS+"Fools 44")
  when :fools_unlocked_4
    pbVoicePlay(FOOLS+"Fools 45")
  when :fools_unlocked_11
    pbVoicePlay(FOOLS+"Fools 46")
  when :fools_unlocked_18
    pbVoicePlay(FOOLS+"Fools 47")
  when :fools_unlocked_25
    pbVoicePlay(FOOLS+"Fools 48")
  when :fools_unlocked_29
    pbVoicePlay(FOOLS+"Fools 49")
  when :fools_unlocked_33
    pbVoicePlay(FOOLS+"Fools 50")
  when :fools_lobby_id
    pbVoicePlay(FOOLS+"Fools 51")
  when :fools_number_1
    pbVoicePlay(FOOLS+"Fools 52")
  when :fools_number_2
    pbVoicePlay(FOOLS+"Fools 53")
  when :fools_number_3
    pbVoicePlay(FOOLS+"Fools 54")
  when :fools_number_4
    pbVoicePlay(FOOLS+"Fools 55")
  when :fools_number_5
    pbVoicePlay(FOOLS+"Fools 56")
  when :fools_number_6
    pbVoicePlay(FOOLS+"Fools 57")
  when :fools_number_7
    pbVoicePlay(FOOLS+"Fools 58")
  when :fools_number_8
    pbVoicePlay(FOOLS+"Fools 59")
  when :fools_number_9
    pbVoicePlay(FOOLS+"Fools 60")
  when :fools_number_10
    pbVoicePlay(FOOLS+"Fools 61")
  when :fools_number_0
    pbVoicePlay(FOOLS+"Fools 62")
  when :fools_stocks_1
    pbVoicePlay(FOOLS+"Fools 63")
  when :fools_stocks_3
    pbVoicePlay(FOOLS+"Fools 64")
  when :fools_stocks_5
    pbVoicePlay(FOOLS+"Fools 65")
  when :fools_stocks_7
    pbVoicePlay(FOOLS+"Fools 66")
  when :fools_stocks_10
    pbVoicePlay(FOOLS+"Fools 67")
  when :fools_time_180
    pbVoicePlay(FOOLS+"Fools 68")
  when :fools_time_300
    pbVoicePlay(FOOLS+"Fools 69")
  when :fools_time_480
    pbVoicePlay(FOOLS+"Fools 70")
  when :fools_time_900
    pbVoicePlay(FOOLS+"Fools 71")
  when :fools_leave
    pbVoicePlay(FOOLS+"Fools 72")
  when :fools_start
    pbVoicePlay(FOOLS+"Fools 73")
  when :fools_kick
    pbVoicePlay(FOOLS+"Fools 74")
  when :fools_are_you_sure_leave
    pbVoicePlay(FOOLS+"Fools 75")
  when :fools_are_you_sure_kick
    pbVoicePlay(FOOLS+"Fools 76")
  when :fools_story
    pbBGMPlay("Fools 77")
  when :fools_at_least_2
    pbVoicePlay(FOOLS+"Fools 78")
  when :fools_lobby_not_available
    pbVoicePlay(FOOLS+"Fools 79")
  when :fools_kicked_from_lobby
    pbVoicePlay(FOOLS+"Fools 80")
  when :fools_controls_up
    pbVoicePlay(FOOLS+"Fools 81")
  when :fools_controls_left
    pbVoicePlay(FOOLS+"Fools 82")
  when :fools_controls_down
    pbVoicePlay(FOOLS+"Fools 83")
  when :fools_controls_right
    pbVoicePlay(FOOLS+"Fools 84")
  when :fools_controls_action
    pbVoicePlay(FOOLS+"Fools 85")
  when :fools_controls_caencel
    pbVoicePlay(FOOLS+"Fools 86")
  when :fools_controls_menu
    pbVoicePlay(FOOLS+"Fools 87")
  when :fools_controls_guard
    pbVoicePlay(FOOLS+"Fools 88")
  when :fools_controls_reset
    pbVoicePlay(FOOLS+"Fools 89")
  when :fools_controls_close
    pbVoicePlay(FOOLS+"Fools 90")
  end
end


def pbVoicePlay(param, volume = 75)
  return if !param
  param = pbResolveAudioFile(param, volume)
  if param.name && param.name != ""
    if $game_system
      $game_system.voice_play(param)
      return
    end
  end
end

class Game_System
  def voice_play(se)
    se = RPG::AudioFile.new(se) if se.is_a?(String)
    if se && se.name != "" && FileTest.audio_exist?("Audio/SE/Announcer/" + se.name)
      vol = se.volume
      vol *= $PokemonSystem.voicevolume / 100.0
      vol = vol.to_i
      Audio.se_play("Audio/SE/Announcer/" + se.name, vol, se.pitch)
    end
  end
end