=begin
################################################################
#
# Base Template
#
################################################################
ListHandlers.add(:audio_pack, :base_template, {
  # =================================
  :name                   => "Base Template",
  :internal               => :BASETEMPLATE,
  # =================================
  :title                  => "TitleSongName,
  :main_menu              => "MenuSongName",
  :lobby_menu             => { 1 => "LobbySong10Percent", 9 => "LobbySong90Percent" },
  :character_selection    => "",
  :tutorial               => "",
  # =================================
  :arena_TRAININGROOM     => "",
  :arena_CRYSTAL          => "",
  # =================================
  :battle_start_simple    => "",
  :battle_start_complex   => "",
  :win_fanfare            => "",
  :lose_fanfare           => "",
  # =================================
  :menu_open              => "",
  :menu_close             => "",
  :gui_decision           => "",
  :gui_cursor             => "",
  :gui_cancel             => "",
  :gui_buzzer             => "",
  :notification           => "",
  :teleport               => ""
  # =================================
})
=end

################################################################
#
# Pivot
#
################################################################
ListHandlers.add(:audio_pack, :pivot, {
  # =================================
  :name                   => "Pivot",
  :internal               => :PIVOT,
  # =================================
  :title                  => "BR 01 Title Screen",
  :main_menu              => "BR 31 Reception Desk",
  :lobby_menu             => "BR 30 Nintendo WFC Menu",
  :character_selection    => "BR 33 Select your Pokemon",
  :tutorial               => "BR 35 Battle Tutorial Menu",
  # =================================
  :arena_TRAININGROOM     => "BR 32 Beta Track",
  :arena_CRYSTAL          => "BR 08 Magma Colosseum",
  :arena_WOODS            => "BR 13 Gateway Colosseum",
  :arena_OASIS            => "BR 09 Courtyard Colosseum",
  :arena_LIGHTS           => "BR 15 Main Street Colosseum",
  :arena_QUANTUM          => "BR 12 Stargazer Colosseum",
  :arena_FACTORY          => "BR 28 Lagoon Colosseum",
  :arena_THERING          => "BR 16 Crystal Colosseum",
  :arena_AISHO            => "CON-KonohaGate",
  :arena_SAFFRON          => "CON-KonohaGate",
  :arena_FAIRYLAND        => "PFA Yoshiko",
  # =================================
  :battle_start_simple    => "BR 18 Player Fanfare 1",
  :battle_start_complex   => "BR 20 Player Fanfare 3",
  :win_fanfare            => "BR 26 Player Wins Fanfare",
  :lose_fanfare           => "BR 25 Player Lost Fanfare",
  # =================================
  :menu_open              => "GUI menu open",
  :menu_close             => "GUI menu close",
  :gui_decision           => "GUI sel decision",
  :gui_cursor             => "nothing",
  :gui_cancel             => "GUI sel cancel",
  :gui_buzzer             => "GUI sel buzzer",
  :notification           => "GUI notification",
  :teleport               => "Teleport"
  # =================================
})
################################################################
#
# Test
#
################################################################
ListHandlers.add(:audio_pack, :melee, {
  # =================================
  :name                   => "Melee",
  :internal               => :MELEE,
  # =================================
  :title                  => "SSBM 105 Menu 2",
  :main_menu              => "SSBM 103 Menu 1",
  :lobby_menu             => "SSBM 103 Menu 1",
  :character_selection    => "SSBM 105 Menu 2",
  :tutorial               => "BR 35 Battle Tutorial Menu",
  # =================================
  :arena_TRAININGROOM     => "SSBM 108 Kongo Jungle",
  :arena_CRYSTAL          => "SSBM 113 Brinstar Depths",
  :arena_WOODS            => "SSBM 109 Jungle Japes",
  :arena_OASIS            => "BR 09 Courtyard Colosseum",
  :arena_LIGHTS           => "BR 15 Main Street Colosseum",
  :arena_QUANTUM          => "BR 12 Stargazer Colosseum",
  :arena_FACTORY          => "BR 28 Lagoon Colosseum",
  :arena_THERING          => "BR 16 Crystal Colosseum",
  :arena_AISHO            => "CON-KonohaGate",
  :arena_SAFFRON          => "CON-KonohaGate",
  # =================================
  :battle_start_simple    => "BR 18 Player Fanfare 1",
  :battle_start_complex   => "BR 20 Player Fanfare 3",
  :win_fanfare            => "BR 26 Player Wins Fanfare",
  :lose_fanfare           => "BR 25 Player Lost Fanfare",
  # =================================
  :menu_open              => "melee decision",
  :menu_close             => "melee back",
  :gui_decision           => "melee decision",
  :gui_cursor             => "melee cursor",
  :gui_cancel             => "melee back",
  :gui_buzzer             => "GUI sel buzzer",
  :notification           => "GUI notification",
  :teleport               => "Teleport"
  # =================================
})