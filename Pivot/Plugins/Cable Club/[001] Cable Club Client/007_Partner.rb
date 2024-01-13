def pbInteractPartner(partnerId)
  return unless $Partners[partnerId] && $Partners[partnerId].is_a?(Partner)
  if $Partners[partnerId].partner_state == :possible
    $game_temp.partner_state = "interact_#{$Partners[partnerId].client_id}".to_sym
  else
    pbDisplayMessageBrief("#{$Partners[partnerId].name} is busy...", )
  end
end

class Partner
  attr_accessor :id, :client_id, :event, :character_id, :character_ID, :attack, :attack_data, :sprite_color, :name, :map_id, 
                :x, :y, :x_offset, :y_offset, :real_x, :real_y, :direction, :graphic, :animation_id, :pattern, :bob_height, :surfing, :bridge, :state, 
                :last_hit_by, :last_hit_id, :latest_damage_taken, :latest_move_type_taken, :checked_for_downed, :checked_for_damage, :invulnerable, :stocks, :ready, 
                :current_hp, :max_hp, :transformed, :dash_location, :dash_distance, :guard_timer, :version
  
  def initialize(id, name)
    @id = id
    @name = name
  end

  def version; @version = "" if !@version; @version; end

  def character
    return Character.get(@character_id)
  end

  def transparent=(value)
    #pbMapInterpreter.get_character_by_name("partner#{@client_id+1}").transparent = value
  end
end