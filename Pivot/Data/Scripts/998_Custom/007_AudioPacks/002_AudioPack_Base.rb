class AudioPack
  attr_accessor :name, :internal, :title, :main_menu, :lobby_menu,
  :character_selection, :tutorial, :arena_TRAININGROOM, :battle_start_simple,
  :battle_start_complex, :win_fanfare, :lose_fanfare, :menu_open,
  :menu_close, :gui_decision, :gui_cursor, :gui_cancel,
  :gui_buzzer, :notification, :teleport

  def initialize(name, internal, title, main_menu, lobby_menu, character_selection, tutorial, battle_start_simple,
                 battle_start_complex, win_fanfare, lose_fanfare, menu_open, menu_close, gui_decision, gui_cursor, gui_cancel,
                 gui_buzzer, notification, teleport, arenas = {})
    @name = name
    @internal = internal
    @title = title
    @main_menu = main_menu
    @lobby_menu = lobby_menu
    @character_selection = character_selection
    @tutorial = tutorial
    @battle_start_simple = battle_start_simple
    @battle_start_complex = battle_start_complex
    @win_fanfare = win_fanfare
    @lose_fanfare = lose_fanfare
    @menu_open = menu_open
    @menu_close = menu_close
    @gui_decision = gui_decision
    @gui_cursor = gui_cursor
    @gui_cancel = gui_cancel
    @gui_buzzer = gui_buzzer
    @notification = notification
    @teleport = teleport

    Arena.each do |arena|
      self.class.module_eval { attr_accessor "arena_#{arena.internal}".to_sym }
      arena_song = arenas[arena.internal] || ""
      self.instance_variable_set("@arena_#{arena.internal}", arena_song)
    end
  end

  def get_arena(arena)
    return self.send("arena_#{arena.internal}".to_sym) || ""
  end
end