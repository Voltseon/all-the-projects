class AudioPack
  attr_accessor :list
  def self.list
    if @list.nil?
      @list = []
      ListHandlers.each_available(:audio_pack) do |option, hash, name|
        name = hash[:name]
        internal = hash[:internal]
        title = hash[:title]
        main_menu = hash[:main_menu]
        lobby_menu = hash[:lobby_menu]
        character_selection = hash[:character_selection]
        tutorial = hash[:tutorial]
        battle_start_simple = hash[:battle_start_simple]
        battle_start_complex = hash[:battle_start_complex]
        win_fanfare = hash[:win_fanfare]
        lose_fanfare = hash[:lose_fanfare]
        menu_open = hash[:menu_open]
        menu_close = hash[:menu_close]
        gui_decision = hash[:gui_decision]
        gui_cursor = hash[:gui_cursor]
        gui_cancel = hash[:gui_cancel]
        gui_buzzer = hash[:gui_buzzer]
        notification = hash[:notification]
        teleport = hash[:teleport]

        arenas = {}
        Arena.each do |arena|
          arena_song = hash["arena_#{arena.internal}".to_sym] || ""
          arenas[arena.internal] = arena_song
        end

        @list.push(
          self.new(name, internal, title, main_menu, lobby_menu, character_selection, tutorial, battle_start_simple,
            battle_start_complex, win_fanfare, lose_fanfare, menu_open, menu_close, gui_decision, gui_cursor, gui_cancel,
            gui_buzzer, notification, teleport, arenas)
        )
      end
    end
    return @list
  end

  def self.each
    self.list if @list.nil?
    @list.each { |audio_pack| yield audio_pack }
  end

  def self.each_with_index
    self.list if @list.nil?
    @list.each_with_index { |audio_pack, i| yield audio_pack, i }
  end

  def self.get(audio_pack)
    return audio_pack if audio_pack.is_a?(AudioPack)
    self.list if @list.nil?
    return @list[audio_pack] if audio_pack.is_a?(Numeric)
    ret = nil
    @list.each { |a| next if a.name != audio_pack && a.internal != audio_pack; ret = a; break }
    return @list[0] if ret.nil?
    return ret
  end

  def self.count
    self.list if @list.nil?
    return @list.length
  end

  def self.parse(sound, pack)
    if sound.is_a?(Hash)
      total = 0
      sound.each { |key, value| total += key }
      random = rand(total)
      sound.each { |key, value| return "#{pack.name}/#{value}" if random < key }
      return "#{pack.name}/" + sound.values.last
    else
      return "#{pack.name}/" + sound
    end
  end
end