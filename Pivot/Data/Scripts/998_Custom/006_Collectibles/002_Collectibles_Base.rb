class Collectible
  attr_accessor :name, :type, :internal, :description, :can_use,
                :use_proc, :can_equip, :consume_on_use, :audio_pack,
                :beam, :character, :skin, :price, :emote, :banner

  def initialize(name, type, internal, description, can_use, use_proc, can_equip, consume_on_use, audio_pack, beam, character, skin, price, emote, banner)
    @name = name
    @type = type
    @internal = internal
    @description = description
    @can_use = can_use
    @use_proc = use_proc
    @can_equip = can_equip
    @consume_on_use = consume_on_use
    @audio_pack = audio_pack
    @beam = beam
    @character = character
    @skin = skin
    @price = price
    @emote = emote
    @banner = banner
  end

  def equip
    return nil if !self.can_equip
    if self.type == :skin
      return false if $player.equipped_collectibles["#{self.type.to_s}_#{self.character.to_s}".to_sym] == self.internal
      $player.equipped_collectibles["#{self.type.to_s}_#{self.character.to_s}".to_sym] = self.internal
    elsif self.type == :audiopack
      return false if $player.equipped_collectibles[self.type] == self.internal
      $player.equipped_collectibles[self.type] = self.internal
      $PokemonGlobal.audio_pack = self.audio_pack
    else
      return false if $player.equipped_collectibles[self.type] == self.internal
      $player.equipped_collectibles[self.type] = self.internal
    end
    return true
  end
end