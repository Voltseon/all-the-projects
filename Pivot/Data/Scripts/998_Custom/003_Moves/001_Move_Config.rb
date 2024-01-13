=begin
################################################################
#
# Base Template
#
################################################################
ListHandlers.add(:move, :base_template, {
  # =================================
  :name                   => "Base Template",
  :internal               => :BASETEMPLATE,
  :width                  => 64,
  :height                 => 96,
  :animation_slowness     => 2,
  :animation_offset       => [0,0], # In tiles
  :animation_type         => :NORMAL, # :NORMAL, :REPEAT, :STICKY
  :move_type              => :MELEE, # :MELEE, :RANGED
  # =================================
  :speed                  => 2,
  :is_projectile          => true,
  :is_attached            => true,
  :invulnerability_mult   => 0.5,
  :angles                 => false,
  :angle_step             => 45,
  :transform_radius       => 0,
  :sketch_radius          => 0,
  # =================================
  :can_crit               => true,
  :crit_multiplier        => 2,
  :crit_condition         => proc { next $game_temp.crit_counter % 3 == 2 },
  # =================================
  :cc_time                => 1,
  :cc_speed               => 2,
  # =================================
  :duration               => 30,
  :hitboxes               => {
    10   => [10,10,10,10],
    5    => [10,10,10,10]
  },
  :power_multiplier       => proc { next 1 }, # a multiplier to the base power of the move
  :on_hit                 => proc { |obj| obj.playing = false }, # try 'next if obj.hits_detected.length > 0' to only be procced once
  :actions                => {
    10   => proc { |obj| obj.return_to_user },
  },
  :hitbox_activity        => [11,12,13] # [false] for no hitbox, [true] for active until death
  # =================================
})
=end

################################################################
#
# Wing Attack
#
################################################################
ListHandlers.add(:move, :wing_attack, {
  # =================================
  :name                   => "Wing Attack",
  :internal               => :WINGATTACK,
  :width                  => 96,
  :height                 => 80,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :duration               => 7,
  :hitboxes               => {
    0    => [16,16,32,64]
  },
  :actions                => {
    4    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [2,3,4,5,6]
  # =================================
})

################################################################
#
# Poison Sting
#
################################################################
ListHandlers.add(:move, :poison_sting, {
  # =================================
  :name                   => "Poison Sting",
  :internal               => :POISONSTING,
  :width                  => 64,
  :height                 => 16,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  :animation_type         => :STICKY,
  # =================================
  :speed                  => 4,
  :is_projectile          => true,
  :angles                 => true,
  :angle_step             => 5,
  # =================================
  :duration               => 12,
  :hitboxes               => {
    0    => [0,0,16,64]
  },
  :actions                => {
    2    => proc { |obj| obj.unlock(obj.move_type) },
    0    => proc { |obj| obj.unlock }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Leaf Blade
#
################################################################
ListHandlers.add(:move, :leaf_blade, {
  # =================================
  :name                   => "Leaf Blade",
  :internal               => :LEAFBLADE,
  :width                  => 48,
  :height                 => 32,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :can_crit               => true,
  :crit_multiplier        => 2,
  :crit_condition         => proc { next $game_temp.crit_counter % 3 == 2 },
  # =================================
  :duration               => 8,
  :hitboxes               => {
    0    => [0,0,48,32]
  },
  :hitbox_activity        => [1,2,3,4,5]
  # =================================
})

################################################################
#
# Fling
#
################################################################
ListHandlers.add(:move, :fling, {
  # =================================
  :name                   => "Fling",
  :internal               => :FLING,
  :width                  => 64,
  :height                 => 32,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  :animation_type         => :REPEAT,
  # =================================
  :speed                  => 1.8,
  :is_projectile          => true,
  :invulnerability_mult   => 0.15,
  # =================================
  :cc_speed               => 2,
  :cc_time				        => 1,
  # =================================
  :duration               => 120,
  :hitboxes               => {
    0    => [14,8,32,20]
  },
  :actions                => {
    12   => proc { |obj| obj.return_to_user; obj.unlock(obj.move_type) },
    5    => proc { |obj| obj.unlock }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Transform
#
################################################################
ListHandlers.add(:move, :transform, {
  # =================================
  :name                   => "Transform",
  :internal               => :TRANSFORM,
  :width                  => 112,
  :height                 => 96,
  :animation_slowness     => 3,
  :move_type              => :MELEE,
  # =================================
  :transform_radius       => 5,
  # =================================
  :duration               => 7,
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Imposter
#
################################################################
ListHandlers.add(:move, :imposter, {
  # =================================
  :name                   => "Imposter",
  :internal               => :IMPOSTER,
  :width                  => 48,
  :height                 => 64,
  :animation_slowness     => 3,
  :move_type              => :RANGED,
  # =================================
  :transform_radius       => 2,
  # =================================
  :duration               => 5,
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Feint Attack
#
################################################################
ListHandlers.add(:move, :feint_attack, {
  # =================================
  :name                   => "Feint Attack",
  :internal               => :FEINTATTACK,
  :width                  => 128,
  :height                 => 128,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :cc_time                => 0.5,
  # =================================
  :duration               => 13,
  :hitboxes               => {
    8    => [0,0,0,0],
    6    => [32,32,64,64],
    4    => [40,40,48,48],
    2    => [48,48,32,32],
    0    => [0,0,0,0]
  },
  :hitbox_activity        => [3,4,5,6,7,8]
  # =================================
})

################################################################
#
# Snarl
#
################################################################
ListHandlers.add(:move, :snarl, {
  # =================================
  :name                   => "Snarl",
  :internal               => :SNARL,
  :width                  => 160,
  :height                 => 144,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  # =================================
  :cc_time                => 0.5,
  :cc_speed               => 0,
  # =================================
  :duration               => 42,
  :hitboxes               => {
    24   => [0,0,0,0],
    20   => [10,10,140,124],
    18   => [32,38,86,82],
    13   => [38,42,82,72],
    4    => [58,62,42,36],
    0    => [0,0,0,0]
  },
  :actions                => {
    13   => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [4,5,6,7,8,16,17,18,19,20,21,22,23,24]
  # =================================
})

################################################################
#
# Sucker Punch
#
################################################################
ListHandlers.add(:move, :sucker_punch, {
  # =================================
  :name                   => "Sucker Punch",
  :internal               => :SUCKERPUNCH,
  :width                  => 48,
  :height                 => 64,
  :animation_slowness     => 2,
  :animation_offset       => [0.3,0.3],
  :move_type              => :MELEE,
  # =================================
  :cc_time                => 0.1,
  :cc_speed               => 2,
  # =================================
  :duration               => 8,
  :hitboxes               => {
    0    => [8,8,48,64]
  },
  :actions                => {
    5   => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [1,2,3,4]
  # =================================
})

################################################################
#
# Shadow Ball
#
################################################################
ListHandlers.add(:move, :shadow_ball, {
  # =================================
  :name                   => "Shadow Ball",
  :internal               => :SHADOWBALL,
  :width                  => 128,
  :height                 => 128,
  :animation_slowness     => 3,
  :move_type              => :RANGED,
  # =================================
  :speed                  => 0.625,
  :is_projectile          => true,
  :invulnerability_mult   => 0.25,
  # =================================
  :cc_time                => 2,
  :cc_speed               => 2,
  # =================================
  :duration               => 40,
  :hitboxes               => {
    32   => [0,0,0,0],
    28   => [32,32,64,64],
    4    => [24,24,80,80],
    0    => [32,32,64,64]
  },
  :actions                => {
    18   => proc { |obj| obj.unlock(obj.move_type) },
    32   => proc { |obj| obj.playing = false }
  },
  :hitbox_activity        => [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
  # =================================
})

################################################################
#
# Poison Fang
#
################################################################
ListHandlers.add(:move, :poison_fang, {
  # =================================
  :name                   => "Poison Fang",
  :internal               => :POISONFANG,
  :width                  => 128,
  :height                 => 128,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :duration               => 11,
  :hitboxes               => {
    0    => [48,48,32,32]
  },
  :actions                => {
    8    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [3,4,5,6,7,8]
  # =================================
})

################################################################
#
# Air Cutter
#
################################################################
ListHandlers.add(:move, :air_cutter, {
  # =================================
  :name                   => "Air Cutter",
  :internal               => :AIRCUTTER,
  :width                  => 96,
  :height                 => 48,
  :animation_slowness     => 1,
  :move_type              => :RANGED,
  :animation_type         => :REPEAT,
  # =================================
  :speed                  => 2,
  :is_projectile          => true,
  # =================================
  :cc_time                => 0,
  :cc_speed               => -1,
  # =================================
  :duration               => 24,
  :hitboxes               => {
    0    => [16,16,64,16]
  },
  :actions                => {
    8    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Cross Poison
#
################################################################
ListHandlers.add(:move, :cross_poison, {
  # =================================
  :name                   => "Cross Poison",
  :internal               => :CROSSPOISON,
  :width                  => 96,
  :height                 => 112,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :cc_time                => 0,
  # =================================
  :duration               => 11,
  :hitboxes               => {
    0    => [32,44,32,32]
  },
  :actions                => {
    6    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [2,3,4,5,6]
  # =================================
})

################################################################
#
# Air Slash
#
################################################################
ListHandlers.add(:move, :air_slash, {
  # =================================
  :name                   => "Air Slash",
  :internal               => :AIRSLASH,
  :width                  => 192,
  :height                 => 160,
  :animation_slowness     => 1,
  :move_type              => :RANGED,
  # =================================
  :cc_speed               => -1,
  # =================================
  :duration               => 22,
  :hitboxes               => {
    10   => [0,0,0,0],
    3    => [74,66,42,42],
    0    => [0,0,0,0]
  },
  :actions                => {
    10   => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [4,5,6,7,8,9,10]
  # =================================
})

################################################################
#
# Fury Cutter
#
################################################################
ListHandlers.add(:move, :fury_cutter, {
  # =================================
  :name                   => "Fury Cutter",
  :internal               => :FURYCUTTER,
  :width                  => 64,
  :height                 => 64,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :combo_move             => true,
  :invulnerability_mult   => 0.05,
  # =================================
  :cc_speed               => -1,
  # =================================
  :duration               => 32,
  :pattern_automation     => false,
  :hitboxes               => {
    0    => [16,16,32,32]
  },
  :actions                => {
    9   => proc { |obj| $game_player.pattern = 3 if obj.user == $Client_id },
    2    => proc { |obj| $game_player.pattern = 2 if obj.user == $Client_id },
    1    => proc { |obj| $game_player.pattern = 1 if obj.user == $Client_id },
    0    => proc { |obj| $game_player.pattern = 0 if obj.user == $Client_id }
  },
  :hitbox_activity        => [4,5,6,7,8]
  # =================================
})

################################################################
#
# Megahorn
#
################################################################
ListHandlers.add(:move, :megahorn, {
  # =================================
  :name                   => "Megahorn",
  :internal               => :MEGAHORN,
  :width                  => 28,
  :height                 => 88,
  :animation_slowness     => 2,
  :animation_offset       => [1,1],
  :move_type              => :RANGED,
  :animation_type         => :REPEAT,
  # =================================
  :speed                  => 4,
  :is_attached            => true,
  :angles                 => true,
  :angle_step             => 45,
  # =================================
  :knockback              => 2,
  # =================================
  :duration               => 12,
  :pattern_automation     => false,
  :hitboxes               => {
    0    => [0,0,28,88]
  },
  :actions                => {
    12   => proc { |obj| $game_player.pattern = 3 if obj.user == $Client_id },
    3    => proc { |obj| $game_player.pattern = 2 if obj.user == $Client_id },
    2    => proc { |obj| pbDash(5,40,false) if obj.user == $Client_id },
    1    => proc { |obj| $game_player.pattern = 1 if obj.user == $Client_id },
    0    => proc { |obj| $game_player.pattern = 0 if obj.user == $Client_id }
  },
  :hitbox_activity        => [1,2,3,4,5,6,7,8,9,10]
  # =================================
})

################################################################
#
# Bite
#
################################################################
ListHandlers.add(:move, :bite, {
  # =================================
  :name                   => "Bite",
  :internal               => :BITE,
  :width                  => 64,
  :height                 => 96,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :duration               => 8,
  :pattern_automation     => false,
  :hitboxes               => {
    5    => [0,32,64,32],
    3    => [0,48,64,16],
    0    => [0,0,0,0]
  },
  :actions                => {
    3    => proc { |obj| obj.unlock(obj.move_type); $game_player.pattern = 3 if obj.user == $Client_id },
    0    => proc { |obj| $game_player.pattern = 0 if obj.user == $Client_id }
  },
  :hitbox_activity        => [3,4,5,6]
  # =================================
})

################################################################
#
# Covet
#
################################################################
ListHandlers.add(:move, :covet, {
  # =================================
  :name                   => "Covet",
  :internal               => :COVET,
  :width                  => 48,
  :height                 => 48,
  :animation_slowness     => 2,
  :animation_offset       => [-1,-1],
  :move_type              => :RANGED,
  :animation_type         => :REPEAT,
  # =================================
  :is_attached            => true,
  # =================================
  :duration               => 20,
  :hitboxes               => {
    0    => [0,0,48,16]
  },
  :power_multiplier       => proc { next 0 },
  :on_hit                 => proc { |obj|
    next if obj.hits_detected.length > 0
    active_hud = $scene.active_hud
    attack = active_hud.sprites["COVETBURST#{obj.user}"]
    pos = [$game_player.x, $game_player.y]
    offset = $game_player.directional_offset
    pos[0] += offset[0]
    pos[1] += offset[1]
    attack.tile_x = pos[0]
    attack.tile_y = pos[1]
    active_hud.attack_positions($Client_id)
    attack.play
    obj.playing = false
  },
  :actions                => {
    3    => proc { },
    2    => proc { |obj| pbDash(10,32,false,obj) if obj.user == $Client_id }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Covet Burst
#
################################################################
ListHandlers.add(:move, :covet_burst, {
  # =================================
  :name                   => "Covet Burst",
  :internal               => :COVETBURST,
  :width                  => 112,
  :height                 => 128,
  :animation_slowness     => 1,
  :move_type              => :RANGED,
  # =================================
  :cc_speed               => -1,
  # =================================
  :duration               => 16,
  :hitboxes               => {
    10   => [0,0,0,0],
    3    => [74,66,42,42],
    0    => [0,0,0,0]
  },
  :actions                => {
    10   => proc { |obj| obj.unlock(obj.move_type) },
    1    => proc { },
    0    => proc { |obj| next if obj.user != $Client_id; offset = $game_player.directional_offset; $game_player.jump(-offset[0], -offset[1]); $game_player.turn_180 }
  },
  :hitbox_activity        => [4,5,6,7,8,9,10]
  # =================================
})

################################################################
#
# Belch
#
################################################################
ListHandlers.add(:move, :belch, {
  # =================================
  :name                   => "Belch",
  :internal               => :BELCH,
  :width                  => 128,
  :height                 => 128,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :speed                  => 0.2,
  :is_projectile          => true,
  :invulnerability_mult   => 0.5,
  # =================================
  :cc_time                => 1,
  :cc_speed               => 2,
  # =================================
  :duration               => 32,
  :pattern_automation     => false,
  :hitboxes               => {
    4    => [48,48,64,64],
    0    => [0,0,0,0]
  },
  :actions                => {
    12   => proc { |obj| obj.unlock(obj.move_type) },
    7    => proc { },
    6    => proc { |obj| $game_player.pattern = 3 if obj.user == $Client_id },
    4    => proc { |obj| $game_player.pattern = 2 if obj.user == $Client_id },
    2    => proc { |obj| $game_player.pattern = 1 if obj.user == $Client_id },
    0    => proc { |obj| $game_player.pattern = 0 if obj.user == $Client_id }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Heavy Slam
#
################################################################
ListHandlers.add(:move, :heavyslam, {
  # =================================
  :name                   => "HeavySlam",
  :internal               => :HEAVYSLAM,
  :width                  => 128,
  :height                 => 64,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  :animation_type         => :REPEAT,
  # =================================
  :is_attached            => true,
  # =================================
  :duration               => 50,
  :pattern_automation     => false,
  :hitboxes               => {
    0    => [0,0,0,0]
  },
  :actions                => { 
    51   => proc { },
    50   => proc { |obj|
      next unless obj.user == $Client_id
      obj.opacity += 5
      $game_player.pattern = 3
      active_hud = $scene.active_hud
      attack = active_hud.sprites["HEAVYSLAMEXPLODE#{obj.user}"]
      attack.tile_x = $game_player.x
      attack.tile_y = $game_player.y
      active_hud.attack_positions($Client_id)
      attack.play
    },
    26   => proc { |obj| next unless obj.user == $Client_id; obj.opacity += 5 },
    25   => proc { |obj| next unless obj.user == $Client_id; obj.opacity += 5; $game_player.pattern = 2 },
    6    => proc { |obj| next unless obj.user == $Client_id; obj.opacity += 5 },
    5    => proc { |obj| next unless obj.user == $Client_id; obj.opacity += 5; $game_player.pattern = 1; offset = $game_player.directional_offset; $game_player.jump(offset[0]*5, offset[1]*5) },
    0    => proc { |obj| next unless obj.user == $Client_id; obj.opacity = 0; $game_player.pattern = 0 }
  },
  :hitbox_activity        => [false]
  # =================================
})

################################################################
#
# Heavy Slam Explode
#
################################################################
ListHandlers.add(:move, :heavyslamexplode, {
  # =================================
  :name                   => "HeavySlamExplode",
  :internal               => :HEAVYSLAMEXPLODE,
  :width                  => 208,
  :height                 => 192,
  :animation_slowness     => 3,
  :move_type              => :RANGED,
  # =================================
  :cc_time                => 0.5,
  :cc_speed               => 0,
  # =================================
  :duration               => 16,
  :pattern_automation     => false,
  :hitboxes               => {
    15   => [0,0,0,0],
    10   => [32,38,86,82],
    8    => [10,10,140,124],
    6    => [32,38,86,82],
    4    => [38,42,82,72],
    2    => [58,62,42,36],
    0    => [0,0,0,0]
  },
  :actions                => {
    16   => proc { |obj| obj.unlock(obj.move_type) },
    0    => proc { |obj| next unless obj.user == $Client_id; obj.lock(obj.move_type); $game_player.pattern = 3 }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Psyshield Bash
#
################################################################
ListHandlers.add(:move, :psyshield_bash, {
  # =================================
  :name                   => "Psyshield Bash",
  :internal               => :PSYSHIELDBASH,
  :width                  => 176,
  :height                 => 176,
  :animation_slowness     => 1,
  :animation_offset       => [1,1],
  :move_type              => :MELEE,
  # =================================
  :knockback              => 1,
  # =================================
  :duration               => 12,
  :hitboxes               => {
    4    => [0,0,88,108],
    2    => [0,0,28,88],
    0    => [0,0,0,0]
  },
  :actions                => {
    1    => proc { },
    0    => proc { |obj| $game_player.move_forward if obj.user == $Client_id }
  },
  :hitbox_activity        => [2,3,4,5,6,7,8,9,10,11,12]
  # =================================
})

################################################################
#
# Metal Sound
#
################################################################
ListHandlers.add(:move, :metal_sound, {
  # =================================
  :name                   => "Metal Sound",
  :internal               => :METALSOUND,
  :width                  => 64,
  :height                 => 64,
  :animation_slowness     => 1,
  :move_type              => :RANGED,
  # =================================
  :speed                  => 1,
  :is_projectile          => true,
  # =================================
  :duration               => 39,
  :power_multiplier       => proc { |obj| next 1+obj.current_frame/20 },
  :hitboxes               => {
    0    => [0,0,64,64]
  },
  :actions                => {
    2    => proc { |obj| obj.unlock(obj.move_type) },
    0    => proc { |obj| obj.unlock }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Iron Head (Song)
#
################################################################
ListHandlers.add(:move, :iron_head_song, {
  # =================================
  :name                   => "Iron Head Song",
  :internal               => :IRONHEADSONG,
  :width                  => 176,
  :height                 => 128,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :knockback              => 3,
  # =================================
  :duration               => 20,
  :hitboxes               => {
    4    => [0,0,88,108],
    2    => [0,0,28,88],
    0    => [0,0,0,0]
  },
  :actions                => {
    1    => proc { },
    0    => proc { |obj| $game_player.move_forward if obj.user == $Client_id }
  },
  :hitbox_activity        => [0,1,2,3,4,5,6]
  # =================================
})

################################################################
#
# Heal Bell
#
################################################################
ListHandlers.add(:move, :heal_bell, {
  # =================================
  :name                   => "Heal Bell",
  :internal               => :HEALBELL,
  :width                  => 176,
  :height                 => 144,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  # =================================
  :is_attached            => true,
  # =================================
  :duration               => 22,
  :hitboxes               => {
    21   => [0,0,0,0],
    3    => [74,66,42,42],
    0    => [0,0,0,0]
  },
  :actions                => {
    10   => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Astonish
#
################################################################
ListHandlers.add(:move, :astonish, {
  # =================================
  :name                   => "Astonish",
  :internal               => :ASTONISH,
  :width                  => 64,
  :height                 => 64,
  :animation_slowness     => 1,
  :animation_offset       => [0,0],
  :move_type              => :MELEE,
  # =================================
  :cc_time                => 1,
  :cc_speed               => 0,
  # =================================
  :duration               => 8,
  :hitboxes               => {
    6    => [0,0,60,60],
    3    => [0,0,44,44],
    0    => [0,0,16,16]
  },
  :on_hit                 => proc { |obj|
    next if obj.hits_detected.length > 0
    active_hud = $scene.active_hud
    attack = active_hud.sprites["ASTONISHHIT#{obj.user}"]
    pos = [$game_player.x, $game_player.y]
    offset = $game_player.directional_offset
    pos[0] += offset[0]
    pos[1] += offset[1]
    attack.tile_x = pos[0]
    attack.tile_y = pos[1]
    active_hud.attack_positions($Client_id)
    attack.play
    obj.playing = false 
  }, # try 'next if obj.hits_detected.length > 0' to only be procced once
  :actions                => {
    6    => proc { |obj| obj.unlock }
    },
  :hitbox_activity        => [11,12,13] # [false] for no hitbox, [true] for active until death
  # =================================
})
################################################################
#
# Astonish
#
################################################################
ListHandlers.add(:move, :astonish_hit, {
  # =================================
  :name                   => "Astonish Hit",
  :internal               => :ASTONISHHIT,
  :width                  => 112,
  :height                 => 32,
  :animation_slowness     => 4,
  :animation_offset       => [0,0],
  :move_type              => :MELEE,
  # =================================
  :cc_time                => 1,
  :cc_speed               => 0,
  # =================================
  :duration               => 8,
  :hitboxes               => {},
  :on_hit                 => proc { |obj| },
  :actions                => {
    0    => proc { |obj| obj.unlock }
  },
  :hitbox_activity        => [false]
  # =================================
})

################################################################
#
# Energy Ball
#
################################################################
ListHandlers.add(:move, :energy_ball, {
  # =================================
  :name                   => "Energy Ball",
  :internal               => :ENERGYBALL,
  :width                  => 64,
  :height                 => 64,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  :animation_type         => :REPEAT,
  # =================================
  :speed                  => 2,
  :is_projectile          => true,
  # =================================
  :duration               => 12,
  :hitboxes               => {
    0    => [0,0,64,64]
  },
  :on_hit                 => proc { |obj|
    next if obj.hits_detected.length > 0
    echoln obj.hits_detected[0]
    active_hud = $scene.active_hud
    attack = active_hud.sprites["ENERGYBALLLAND#{obj.belonging_character.internal.to_s}#{obj.user}"]
    next if attack.nil?
    pos = [obj.tile_x, obj.tile_y]
    offset = $game_player.directional_offset
    pos[0] += offset[0]
    pos[1] += offset[1]
    attack.tile_x = pos[0]
    attack.tile_y = pos[1]
    active_hud.attack_positions($Client_id)
    attack.play
    obj.playing = false
  },
  :actions                => {
    0    => proc { }
  },
  :hitbox_activity        => [true]
  # =================================
})
################################################################
#
# Energy Ball Land (Solosis)
#
################################################################
ListHandlers.add(:move, :energy_ball_land1, {
  # =================================
  :name                   => "Energy Ball Land SOLOSIS",
  :internal               => :ENERGYBALLLANDSOLOSIS,
  :width                  => 96,
  :height                 => 96,
  :animation_slowness     => 2,
  :animation_offset       => [0,0],
  :move_type              => :RANGED,
  # =================================
  :cc_time                => 1,
  :cc_speed               => 0,
  # =================================
  :duration               => 12,
  :hitboxes               => {
    0    => [0,0,76,76]
  },
  :on_hit                 => proc { |obj| },
  :actions                => {
    2    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [false]
  # =================================
})
################################################################
#
# Energy Ball Land (Duosion)
#
################################################################
ListHandlers.add(:move, :energy_ball_land2, {
  # =================================
  :name                   => "Energy Ball Land DUOSION",
  :internal               => :ENERGYBALLLANDDUOSION,
  :width                  => 144,
  :height                 => 160,
  :animation_slowness     => 4,
  :animation_offset       => [0,0],
  :move_type              => :RANGED,
  # =================================
  :cc_time                => 1,
  :cc_speed               => 0,
  # =================================
  :duration               => 16,
  :hitboxes               => {
    0    => [0,0,76,76]
  },
  :on_hit                 => proc { |obj| },
  :actions                => {
    2    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [false]
  # =================================
})
################################################################
#
# Energy Ball Land (Reuniclus)
#
################################################################
ListHandlers.add(:move, :energy_ball_land3, {
  # =================================
  :name                   => "Energy Ball Land REUNICLUS",
  :internal               => :ENERGYBALLLANDREUNICLUS,
  :width                  => 128,
  :height                 => 128,
  :animation_slowness     => 4,
  :animation_offset       => [0,0],
  :move_type              => :RANGED,
  # =================================
  :cc_time                => 1,
  :cc_speed               => 0,
  # =================================
  :duration               => 28,
  :hitboxes               => {
    0    => [0,0,76,76]
  },
  :on_hit                 => proc { |obj| },
  :actions                => {
    2    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [false]
  # =================================
})

################################################################
#
# Ember
#
################################################################
ListHandlers.add(:move, :ember, {
  # =================================
  :name                   => "Ember",
  :internal               => :EMBER,
  :width                  => 32,
  :height                 => 48,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  :animation_type         => :REPEAT,
  # =================================
  :speed                  => 1.5,
  :is_projectile          => true,
  # =================================
  :duration               => 8,
  :hitboxes               => {
    0    => [0,0,36,48]
  },
  :actions                => {
    4    => proc { |obj| obj.unlock(obj.move_type) },
    0    => proc { |obj| obj.unlock }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Scratch
#
################################################################
ListHandlers.add(:move, :scratch, {
  # =================================
  :name                   => "Scratch",
  :internal               => :SCRATCH,
  :width                  => 96,
  :height                 => 80,
  :animation_slowness     => 2,
  :move_type              => :MELEE,
  # =================================
  :duration               => 16,
  :hitboxes               => {
    0    => [0,0,96,80]
  },
  :actions                => {
    4    => proc { |obj| obj.unlock(obj.move_type) }
  },
  :hitbox_activity        => [2,3,4,5,6,7,8]
  # =================================
})

################################################################
#
# Flame Charge
#
################################################################
ListHandlers.add(:move, :flame_charge, {
  # =================================
  :name                   => "Flame Charge",
  :internal               => :FLAMECHARGE,
  :width                  => 160,
  :height                 => 112,
  :animation_slowness     => 5,
  :move_type              => :RANGED,
  :animation_type         => :NORMAL,
  # =================================
  :speed                  => 0,
  :is_projectile          => true,
  :angles                 => true,
  :angle_step             => 5,
  # =================================
  :duration               => 20,
  :hitboxes               => {
    1    => [0,0,160,112],
    0    => [0,0,80,112]
  },
  :actions                => {
    6    => proc { |obj| obj.unlock(obj.move_type) },
    1    => proc { },
    0    => proc { |obj| pbDash(3,32,false,obj) if obj.user == $Client_id },
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Close Combat
#
################################################################
ListHandlers.add(:move, :close_combat, {
  # =================================
  :name                   => "Close Combat",
  :internal               => :CLOSECOMBAT,
  :width                  => 144,
  :height                 => 144,
  :animation_slowness     => 4,
  :move_type              => :MELEE,
  :animation_type         => :NORMAL,
  # =================================
  :speed                  => 1,
  :is_projectile          => true,
  :invulnerability_mult   => 0.3,
  # =================================
  :duration               => 20,
  :hitboxes               => {
    15   => [0,0,0,0],
    0    => [16,16,112,112]
  },
  :actions                => {
    16    => proc { |obj| obj.unlock(obj.move_type) },
    1    => proc { },
    0    => proc { |obj| pbDash(5,80,false,obj) if obj.user == $Client_id },
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Aura Sphere
#
################################################################
ListHandlers.add(:move, :aura_sphere, {
  # =================================
  :name                   => "Aura Sphere",
  :internal               => :AURASPHERE,
  :width                  => 80,
  :height                 => 54,
  :animation_slowness     => 8,
  :move_type              => :RANGED,
  # =================================
  :speed                  => 2.5,
  :is_projectile          => true,
  :angles                 => true,
  :angle_step             => 5,
  :invulnerability_mult   => 0.5,
  # =================================
  :duration               => 8,
  :hitboxes               => {
   3    => [0,0,0,0],
   0    => [16,16,48,22]
  },
  :actions                => {
   2   => proc { |obj| obj.unlock(obj.move_type) },
   3   => proc { |obj| obj.playing = false }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Quick Attack
#
################################################################
ListHandlers.add(:move, :quick_attack, {
  # =================================
  :name                   => "Quick Attack",
  :internal               => :QUICKATTACK,
  :width                  => 64,
  :height                 => 64,
  :animation_slowness     => 4,
  :move_type              => :MELEE,
  :animation_type         => :NORMAL,
  # =================================
  :speed                  => 0.75,
  :is_projectile          => true,
  :invulnerability_mult   => 0.3,
  # =================================
  :duration               => 12,
  :hitboxes               => {
    8    => [0,0,0,0],
    2    => [0,0,64,64],
    0    => [0,0,0,0]
  },
  :actions                => {
    8    => proc { |obj| obj.unlock(obj.move_type) },
    1    => proc { },
    0    => proc { |obj| pbDash(2,80,false,obj) if obj.user == $Client_id }
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Force Palm
#
################################################################
ListHandlers.add(:move, :force_palm, {
  # =================================
  :name                   => "Force Palm",
  :internal               => :FORCEPALM,
  :width                  => 112,
  :height                 => 128,
  :animation_slowness     => 2,
  :move_type              => :RANGED,
  # =================================
  :speed                  => 0.4,
  :is_projectile          => true,
  # =================================
  :duration               => 20,
  :hitboxes               => {
   11    => [0,0,0,0],
   5     => [24,32,64,64],
   0     => [0,0,0,0]
  },
  :actions                => {
   10   => proc { |obj| obj.unlock(obj.move_type) },
  },
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Sketch
#
################################################################
ListHandlers.add(:move, :sketch, {
  # =================================
  :name                   => "Sketch",
  :internal               => :SKETCH,
  :width                  => 48,
  :height                 => 64,
  :animation_slowness     => 3,
  :move_type              => :MELEE,
  # =================================
  :sketch_radius          => 3,
  # =================================
  :duration               => 5,
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Sketch (Ranged)
#
################################################################
ListHandlers.add(:move, :sketch_ranged, {
  # =================================
  :name                   => "Sketch",
  :internal               => :SKETCH_RANGED,
  :width                  => 48,
  :height                 => 64,
  :animation_slowness     => 3,
  :move_type              => :RANGED,
  # =================================
  :sketch_radius          => 2,
  # =================================
  :duration               => 5,
  :hitbox_activity        => [true]
  # =================================
})

################################################################
#
# Spawn Beams (Keep these one at the bottom)
#
################################################################
ListHandlers.add(:move, :spawn_purple, {
  # =================================
  :name                   => "SpawnPurple",
  :internal               => :SPAWNPURPLE,
  :width                  => 128,
  :height                 => 320,
  :animation_slowness     => 1,
  :animation_offset       => [0,0],
  :move_type              => :NONE,
  # =================================
  :duration               => 41
  # =================================
})

ListHandlers.add(:move, :spawn_pink, {
  # =================================
  :name                   => "SpawnPink",
  :internal               => :SPAWNPINK,
  :width                  => 128,
  :height                 => 320,
  :animation_slowness     => 1,
  :animation_offset       => [0,0],
  :move_type              => :NONE,
  # =================================
  :duration               => 41
  # =================================
})

ListHandlers.add(:move, :spawn_green, {
  # =================================
  :name                   => "SpawnGreen",
  :internal               => :SPAWNGREEN,
  :width                  => 128,
  :height                 => 320,
  :animation_slowness     => 1,
  :animation_offset       => [0,0],
  :move_type              => :NONE,
  # =================================
  :duration               => 41
  # =================================
})

ListHandlers.add(:move, :spawn_blue, {
  # =================================
  :name                   => "SpawnBlue",
  :internal               => :SPAWNBLUE,
  :width                  => 128,
  :height                 => 320,
  :animation_slowness     => 1,
  :animation_offset       => [0,0],
  :move_type              => :NONE,
  # =================================
  :duration               => 41
  # =================================
})

################################################################
#
# Evolution (Keep this one at the bottom)
#
################################################################
ListHandlers.add(:move, :evolution, {
  # =================================
  :name                   => "Evolve",
  :internal               => :EVOLUTION,
  :width                  => 80,
  :height                 => 96,
  :animation_slowness     => 1,
  :move_type              => :NONE,
  # =================================
  :duration               => 15
  # =================================
})