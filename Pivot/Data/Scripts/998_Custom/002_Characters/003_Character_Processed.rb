class Character
  attr_accessor :list
  def self.list
    if @list.nil?
      @list = []
      ListHandlers.each_available(:character) do |option, hash, name|
        name = hash[:name]
        internal = hash[:internal]
        melee = hash[:melee]
        ranged = hash[:ranged]
        speed = hash[:speed]
        hp = hash[:hp]
        melee_damage = hash[:melee_damage]
        ranged_damage = hash[:ranged_damage]
        aim_range = hash[:aim_range] || [16,9]
        aim_type = hash[:aim_type] || :DEFAULT
        movement_type = hash[:movement_type] || :DEFAULT
        hitbox = hash[:hitbox] || [0,0,80,80]
        guard_time = hash[:guard_time] || 1
        guard_cooldown = hash[:guard_cooldown] || 1
        guard_cooldown *= -1
        unguard_time = hash[:unguard_time] || 1
        unguard_time -= 1
        dash_distance = hash[:dash_distance] || 0
        dash_speed = hash[:dash_speed] || 100
        unlock_proc = hash[:unlock_proc] || proc { next true }
        playable = (hash[:playable].nil? ? true : hash[:playable])
        evolution = hash[:evolution] || nil
        evolution_exp = hash[:evolution_exp] || 0
        description = hash[:description] || ""
        @list.push(
          self.new(name, internal, melee, ranged, speed, hp, melee_damage, ranged_damage,
            aim_range, aim_type, movement_type, hitbox, guard_time, guard_cooldown, unguard_time,
            dash_distance, dash_speed, unlock_proc, playable, evolution, evolution_exp, description)
        )
      end
    end
    return @list
  end

  def self.sample_playable
    self.list if @list.nil?
    playable_characters = []
    @list.each { |char| next unless char.playable; next if char.is_evolution; playable_characters.push(char) }
    return playable_characters.sample
  end

  def self.sample_playable_unlocked
    self.list if @list.nil?
    playable_characters = []
    @list.each { |char| next unless char.playable; next if char.is_evolution; next unless $player.unlocked_characters.include?(char.internal); playable_characters.push(char) }
    return playable_characters.sample
  end

  def self.each
    self.list if @list.nil?
    @list.each { |char| yield char }
  end

  def self.each_with_index
    self.list if @list.nil?
    @list.each_with_index { |char, i| yield char, i }
  end

  def self.get(character)
    return character if character.is_a?(Character)
    self.list if @list.nil?
    return @list[character] if character.is_a?(Numeric)
    ret = nil
    @list.each { |char| next if char.name != character && char.internal != character; ret = char; break }
    return @list[0] if ret.nil?
    return ret
  end

  def self.get_from_move(move)
    return self.get_from_move_with_type(move)[0]
  end

  def self.get_from_move_with_type(move)
    self.list if @list.nil?
    return @list[move] if move.is_a?(Numeric)
    ret = [nil, nil]
    @list.each { |char| next if char.melee != move; ret = [char,:MELEE]; break }
    @list.each { |char| next if char.ranged != move; ret = [char,:RANGED]; break } if ret[0].nil? || ret[1].nil?
    return ret
  end

  def self.count
    self.list if @list.nil?
    return @list.length
  end
end

Character.each do |character|
  Player::DEFAULT_EQUIPPED_COLLECTIBLES["skin_#{character.internal}".to_sym] = "skin_#{character.internal}_default".to_sym
  Player::DEFAULT_COLLECTIBLES << "skin_#{character.internal}_default".to_sym
end