class Move
  attr_accessor :name, :internal, :width, :height, :animation_slowness, :animation_offset, :animation_type,
  :move_type, :speed, :is_projectile, :is_attached, :combo_move, :invulnerability_mult, :angles, :angle_step, :transform_radius, :sketch_radius, :can_crit, :crit_multiplier,
  :crit_condition, :cc_time, :cc_speed, :knockback, :duration, :pattern_automation, :power_multiplier, :on_hit, :actions, :hitboxes, :hitbox_activity

  def initialize(options)
    @name = options[:name]
    @internal = options[:internal]
    @width = options[:width]
    @height = options[:height]
    @animation_slowness = options[:animation_slowness]
    @animation_offset = options[:animation_offset]
    @animation_type = options[:animation_type]
    @move_type = options[:move_type]
    @speed = options[:speed]
    @is_projectile = options[:is_projectile]
    @is_attached = options[:is_attached]
    @combo_move = options[:combo_move]
    @invulnerability_mult = options[:invulnerability_mult]
    @angles = options[:angles]
    @angle_step = options[:angle_step]
    @transform_radius = options[:transform_radius]
    @sketch_radius = options[:sketch_radius]
    @can_crit = options[:can_crit]
    @crit_multiplier = options[:crit_multiplier]
    @crit_condition = options[:crit_condition]
    @cc_time = options[:cc_time]
    @cc_speed = options[:cc_speed]
    @knockback = options[:knockback]
    @duration = options[:duration]
    @pattern_automation = options[:pattern_automation]
    @power_multiplier = options[:power_multiplier]
    @on_hit = options[:on_hit]
    @actions = options[:actions]
    @hitboxes = options[:hitboxes]
    @hitbox_activity = options[:hitbox_activity]
end

  def filename
    return @name.gsub(" ", "")
  end

  def formatted
    return @name.gsub(" ", "_").downcase
  end
end