class Move
  attr_accessor :list

  def self.list
    return @list unless @list.nil?
    @list = []
    ListHandlers.each_available(:move) do |option, hash, name|
      default_values = {
        animation_slowness: 2,
        animation_offset: [0, 0],
        animation_type: :NORMAL,
        move_type: :MELEE,
        speed: 1,
        is_projectile: false,
        is_attached: false,
        combo_move: false,
        invulnerability_mult: 1,
        angles: false,
        angle_step: 0.1,
        transform_radius: 0,
        sketch_radius: 0,
        can_crit: false,
        crit_multiplier: 2,
        crit_condition: proc { next false },
        cc_time: 0.2,
        cc_speed: 1,
        knockback: 0,
        duration: 0,
        pattern_automation: true,
        power_multiplier: proc { next 1 },
        on_hit: proc { },
        actions: {},
        hitboxes: { 0 => [0, 0, 0, 0] },
        hitbox_activity: hash[:duration] || 0
      }
      options = default_values.merge(hash)
      options[:name] = hash[:name]
      @list.push(self.new(**options))
    end
    @list
  end

  def self.each(&block)
    list.each(&block)
  end

  def self.each_with_index(&block)
    list.each_with_index(&block)
  end

  def self.get(move)
    return move if move.is_a?(Move)
    return list[move] if move.is_a?(Numeric)

    list.find { |m| m.name == move || m.internal == move } || list[0]
  end

  def self.count
    list.length
  end
end
