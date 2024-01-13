class Collectible
  attr_accessor :list
  def self.list
    if @list.nil?
      @list = []
      Character.each do |character|
        name = "Character Skin - #{character.name} (Default)"
        type = :skin
        internal = "skin_#{character.internal}_default".to_sym
        description = "The default skin for #{character.name}."
        can_use = true
        use_proc = proc { next }
        can_equip = true
        consume_on_use = false
        audio_pack = nil
        beam = nil
        character = character.internal
        skin = "default"
        price = 0
        emote = nil
        banner = nil
        @list.push(
          self.new(name, type, internal, description, can_use, use_proc, can_equip, consume_on_use, audio_pack, beam, character, skin, price, emote, banner)
        )
      end
      ListHandlers.each_available(:collectible) do |option, hash, name|
        name = hash[:name]
        type = hash[:type] || :generic
        internal = hash[:internal]
        description = hash[:description] || ""
        can_use = hash[:can_use] || (type != :generic)
        use_proc = hash[:use_proc] || proc { next }
        can_equip = hash[:can_equip] || (type != :generic)
        consume_on_use = hash[:consume_on_use] || false
        audio_pack = hash[:audio_pack] || nil
        beam = hash[:beam] || nil
        character = hash[:character] || nil
        skin = hash[:skin] || nil
        price = hash[:price] || 0
        emote = hash[:emote] || nil
        banner = hash[:banner] || nil
        @list.push(
          self.new(name, type, internal, description, can_use, use_proc, can_equip, consume_on_use, audio_pack, beam, character, skin, price, emote, banner)
        )
      end
    end
    return @list
  end

  def self.each
    self.list if @list.nil?
    @list.each { |collectible| yield collectible }
  end

  def self.each_with_index
    self.list if @list.nil?
    @list.each_with_index { |collectible, i| yield collectible, i }
  end

  def self.each_by_type(type)
    self.list if @list.nil?
    @list.each { |collectible| yield collectible if collectible.type == type }
  end

  def self.get(collectible)
    return collectible if collectible.is_a?(Collectible)
    self.list if @list.nil?
    return @list[collectible] if collectible.is_a?(Numeric)
    ret = nil
    @list.each { |c| next if c.name != collectible && c.internal != collectible; ret = c; break }
    return @list[0] if ret.nil?
    return ret
  end

  def self.count
    self.list if @list.nil?
    return @list.length
  end
end