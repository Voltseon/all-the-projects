################################################################
#
# Zubat
#
################################################################
ListHandlers.add(:character, :zubat, {
  # =================================
  :name                   => "Zubat",
  :internal               => :ZUBAT,
  :melee                  => :WINGATTACK,
  :ranged                 => :POISONSTING,
  # =================================
  :speed                  => 6,
  :hp                     => 35,
  # =================================
  :melee_damage           => 5,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :movement_type          => :FLYING,
  :hitbox                 => [10,10,42,40],
  # =================================
  :evolution              => :GOLBAT,
  :evolution_exp          => 30,
  # =================================
  :description            => "Though very weak it has the ability to evolve into something stronger. Its Flight ability along with its agileness allows it to get out of sticky situations much faster. Its Double Team allows it to dodge attacks in a pinch."
  # =================================
})

################################################################
#
# Farfetch'd
#
################################################################
ListHandlers.add(:character, :farfetchd, {
  # =================================
  :name                   => "Farfetch'd",
  :internal               => :FARFETCHD,
  :melee                  => :LEAFBLADE,
  :ranged                 => :FLING,
  # =================================
  :speed                  => 8,
  :hp                     => 40,
  # =================================
  :melee_damage           => 6,
  :ranged_damage          => 5,
  :aim_range           => [7,6],       
  # =================================
  :guard_time             => 1.5,
  :hitbox                 => [-4,8,28,42],
  # =================================
  :description            => "A very well rounded fighter. It can use its Leek as an offensive ranged weapon by flinging it at its opponents. When in a tough spot it can Protect itself from damage. Its amazing focus results in frequent critical hits."
  # =================================
})

################################################################
#
# Ditto
#
################################################################
ListHandlers.add(:character, :ditto, {
  # =================================
  :name                   => "Ditto",
  :internal               => :DITTO,
  :melee                  => :TRANSFORM,
  :ranged                 => :IMPOSTER,
  # =================================
  :speed                  => 5,
  :hp                     => 50,
  # =================================
  :melee_damage           => 0,
  :ranged_damage          => 0,
  # =================================
  :guard_time             => 1,
  :hitbox                 => [8,-12,40,32],
  :unlock_proc            => proc { next $player.level >= 8 },
  # =================================
  :description            => "By itself it is no threat but using its transformation abilities it can turn into any opponent. It will copy all stats apart from their HP when transforming. While not transformed it can liquify to dodge attacks."
  # =================================
})

################################################################
#
# Spiritomb
#
################################################################
ListHandlers.add(:character, :spiritomb, {
  # =================================
  :name                   => "Spiritomb",
  :internal               => :SPIRITOMB,
  :melee                  => :FEINTATTACK,
  :ranged                 => :SNARL,
  # =================================
  :speed                  => 4,
  :hp                     => 65,
  # =================================
  :melee_damage           => 6,
  :ranged_damage          => 8,
  :aim_range              => [8,8],  
  # =================================
  :guard_time             => 4,
  :guard_cooldown         => 2.5,
  :movement_type          => :PHASE,
  :hitbox                 => [6,12,34,42],
  :unlock_proc            => proc { next $player.level >= 15 },
  # =================================
  :description            => "Very slow but strong in battle. Using its AOE attacks it can easily clear hoards of enemies. It can phase through small objects and when in danger return to its Keystone for a perfect shield."
  # =================================
})

################################################################
#
# Absol
#
################################################################
ListHandlers.add(:character, :absol, {
  # =================================
  :name                   => "Absol",
  :internal               => :ABSOL,
  :melee                  => :SUCKERPUNCH,
  :ranged                 => :SHADOWBALL,
  # =================================
  :speed                  => 9,
  :hp                     => 40,
  # =================================
  :melee_damage           => 7,
  :ranged_damage          => 5,
  # =================================
  :guard_time             => 0,
  :unguard_time           => 0.7,
  :dash_distance          => 3,
  :dash_speed             => 50,
  :hitbox                 => [-2,6,38,52],
  :unlock_proc            => proc { next $player.level >= 22 },
  # =================================
  :description            => "A high skilled offensive monster. Its Sucker Punch ensures great damage on close range closing the gap to its enemy. If it ever gets outsped by its opponent it can also dash or use its Shadow Ball for great ranged damage."
  # =================================
})

################################################################
#
# Heracross
#
################################################################
ListHandlers.add(:character, :heracross, {
  # =================================
  :name                   => "Heracross",
  :internal               => :HERACROSS,
  :melee                  => :FURYCUTTER,
  :ranged                 => :MEGAHORN,
  # =================================
  :speed                  => 5,
  :hp                     => 40,
  # =================================
  :melee_damage           => 2,
  :ranged_damage          => 6,
  :aim_range              => [5,5],
  :aim_type               => :EIGHTS,
  # =================================
  :hitbox                 => [10,10,42,40],
  :unlock_proc            => proc { next $player.level >= 27 },
  # =================================
  :description            => "It's a fierce fighter relying on the swift and precise Fury Cutter for combo damage, and the powerful Megahorn to close the gap and knock back its enemies."
  # =================================
})

################################################################
#
# Munchlax
#
################################################################
ListHandlers.add(:character, :munchlax, {
  # =================================
  :name                   => "Munchlax",
  :internal               => :MUNCHLAX,
  :melee                  => :BITE,
  :ranged                 => :COVET,
  # =================================
  :speed                  => 5,
  :hp                     => 45,
  # =================================
  :melee_damage           => 3,
  :ranged_damage          => 4,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  :unlock_proc            => proc { next $player.level >= 30 },
  # =================================
  :evolution              => :SNORLAX,
  :evolution_exp          => 70,
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Bronzor
#
################################################################
ListHandlers.add(:character, :bronzor, {
  # =================================
  :name                   => "Bronzor",
  :internal               => :BRONZOR,
  :melee                  => :PSYSHIELDBASH,
  :ranged                 => :METALSOUND,
  # =================================
  :speed                  => 4,
  :hp                     => 40,
  # =================================
  :melee_damage           => 5,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  :unlock_proc            => proc { next $player.level >= 33 },
  # =================================
  :evolution              => :BRONZONG,
  :evolution_exp          => 50,
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Solosis
#
################################################################
ListHandlers.add(:character, :solosis, {
  # =================================
  :name                   => "Solosis",
  :internal               => :SOLOSIS,
  :melee                  => :ASTONISH,
  :ranged                 => :ENERGYBALL,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  :unlock_proc            => proc { next $player.level >= 36 },
  # =================================
  :evolution              => :DUOSION,
  :evolution_exp          => 30,
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Kabuto
#
################################################################
ListHandlers.add(:character, :kabuto, {
  # =================================
  :name                   => "Kabuto",
  :internal               => :KABUTO,
  :melee                  => :SCRATCH,
  :ranged                 => :ABSORB,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 3,
  :hitbox                 => [4,-12,36,32],
  :unlock_proc            => proc { next $player.level >= 38 },
  # =================================
  :evolution              => :KABUTOPS,
  :evolution_exp          => 50,
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Growlithe
#
################################################################
ListHandlers.add(:character, :growlithe, {
  # =================================
  :name                   => "Growlithe",
  :internal               => :GROWLITHE,
  :melee                  => :EMBER,
  :ranged                 => :FLAMECHARGE,
  # =================================
  :speed                  => 7,
  :hp                     => 40,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 6,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [30,16,60,56],
  :unlock_proc            => proc { next $player.level >= 42 },
  # =================================
  :evolution              => :ARCANINE,
  :evolution_exp          => 50,
  # =================================
  :playable               => true
  # =================================
})

################################################################
#
# Riolu
#
################################################################
ListHandlers.add(:character, :riolu, {
  # =================================
  :name                   => "Riolu",
  :internal               => :RIOLU,
  :melee                  => :QUICKATTACK,
  :ranged                 => :FORCEPALM,
  # =================================
  :speed                  => 7,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 5,
  :aim_range              => [3,4],     
  # =================================
  :guard_time             => 2,
  :hitbox                 => [12,4,42,48],
  :unlock_proc            => proc { next $player.level >= 45 },
  # =================================
  :evolution              => :LUCARIO,
  :evolution_exp          => 50,
  # =================================
  :playable               => true
  # =================================
})

################################################################
#
# Smeargle
#
################################################################
ListHandlers.add(:character, :smeargle, {
  # =================================
  :name                   => "Smeargle",
  :internal               => :SMEARGLE,
  :melee                  => :SKETCH,
  :ranged                 => :SKETCH_RANGED,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  :unlock_proc            => proc { next $player.level >= 48 },
  # =================================
  :playable               => true
  # =================================
})

################################################################
#
# Minior
#
################################################################
ListHandlers.add(:character, :minior, {
  # =================================
  :name                   => "Minior",
  :internal               => :MINIOR,
  :melee                  => :TAKEDOWN,
  :ranged                 => :POWERGEM,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  :unlock_proc            => proc { next $player.level >= 50 },
  # =================================
  :playable               => true
  # =================================
})

################################################################
#
# Larvitar
#
################################################################
ListHandlers.add(:character, :larvitar, {
  # =================================
  :name                   => "Larvitar",
  :internal               => :LARVITAR,
  :melee                  => :BITE,
  :ranged                 => :ROCKTHROW,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  :unlock_proc            => proc { next $player.level >= 52 },
  # =================================
  :evolution              => :PUPITAR,
  :evolution_exp          => 50,
  # =================================
  :playable               => true
  # =================================
})

################################################################
# EVOLUTIONS GO UNDER HERE
################################################################

################################################################
#
# Golbat
#
################################################################
ListHandlers.add(:character, :golbat, {
  # =================================
  :name                   => "Golbat",
  :internal               => :GOLBAT,
  :melee                  => :POISONFANG,
  :ranged                 => :AIRCUTTER,
  # =================================
  :speed                  => 8,
  :hp                     => 35,
  # =================================
  :melee_damage           => 7,
  :ranged_damage          => 5,
  # =================================
  :guard_time             => 2,
  :movement_type          => :FLYING,
  :hitbox                 => [0,12,30,42],
  # =================================
  :evolution              => :CROBAT,
  :evolution_exp          => 90
  # =================================
})

################################################################
#
# Crobat
#
################################################################
ListHandlers.add(:character, :crobat, {
  # =================================
  :name                   => "Crobat",
  :internal               => :CROBAT,
  :melee                  => :CROSSPOISON,
  :ranged                 => :AIRSLASH,
  # =================================
  :speed                  => 9,
  :hp                     => 35,
  # =================================
  :melee_damage           => 11,
  :ranged_damage          => 7,
  :aim_range              => [7,6],     
  # =================================
  :guard_time             => 2,
  :movement_type          => :FLYING,
  :hitbox                 => [0,12,30,42]
  # =================================
})

################################################################
#
# Snorlax
#
################################################################
ListHandlers.add(:character, :snorlax, {
  # =================================
  :name                   => "Snorlax",
  :internal               => :SNORLAX,
  :melee                  => :BELCH,
  :ranged                 => :HEAVYSLAM,
  # =================================
  :speed                  => 3,
  :hp                     => 70,
  # =================================
  :melee_damage           => 3,
  :ranged_damage          => 10,
  # =================================
  :guard_time             => 1.5,
  :hitbox                 => [0,0,64,64],
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Bronzong
#
################################################################
ListHandlers.add(:character, :bronzong, {
  # =================================
  :name                   => "Bronzong",
  :internal               => :BRONZONG,
  :melee                  => :IRONHEADSONG,
  :ranged                 => :HEALBELL,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 6,
  :ranged_damage          => 6,
  # =================================
  :guard_time             => 1.5,
  :hitbox                 => [0,0,64,64],
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Duosion
#
################################################################
ListHandlers.add(:character, :duosion, {
  # =================================
  :name                   => "Duosion",
  :internal               => :DUOSION,
  :melee                  => :ASTONISH,
  :ranged                 => :ENERGYBALL,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  # =================================
  :evolution              => :REUNICLUS,
  :evolution_exp          => 80,
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Reuniclus
#
################################################################
ListHandlers.add(:character, :reuniclus, {
  # =================================
  :name                   => "Reuniclus",
  :internal               => :REUNICLUS,
  :melee                  => :ASTONISH,
  :ranged                 => :ENERGYBALL,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Kabutops
#
################################################################
ListHandlers.add(:character, :kabutops, {
  # =================================
  :name                   => "Kabutops",
  :internal               => :KABUTOPS,
  :melee                  => :AQUAJET,
  :ranged                 => :BRINE,
  # =================================
  :speed                  => 7,
  :hp                     => 60,
  # =================================
  :melee_damage           => 3,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [18,12,52,52],
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Arcanine
#
################################################################
ListHandlers.add(:character, :arcanine, {
  # =================================
  :name                   => "Arcanine",
  :internal               => :ARCANINE,
  :melee                  => :FLAMECHARGE,
  :ranged                 => :EMBER,
  # =================================
  :speed                  => 7,
  :hp                     => 70,
  # =================================
  :melee_damage           => 6,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Pupitar
#
################################################################
ListHandlers.add(:character, :pupitar, {
  # =================================
  :name                   => "Pupitar",
  :internal               => :PUPITAR,
  :melee                  => :BITE,
  :ranged                 => :ROCKSLIDE,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  # =================================
  :evolution              => :TYRANITAR,
  :evolution_exp          => 80,
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Tyranitar
#
################################################################
ListHandlers.add(:character, :tyranitar, {
  # =================================
  :name                   => "Tyranitar",
  :internal               => :TYRANITAR,
  :melee                  => :BITE,
  :ranged                 => :ROCKSLIDE,
  # =================================
  :speed                  => 4,
  :hp                     => 50,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 3,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [0,0,48,48],
  # =================================
  :playable               => false
  # =================================
})

################################################################
#
# Wobbuffet
#
################################################################
ListHandlers.add(:character, :wobbuffet, {
  # =================================
  :name                   => "Wobbuffet",
  :internal               => :WOBBUFFET,
  :melee                  => :CROSSPOISON,
  :ranged                 => :AIRSLASH,
  # =================================
  :speed                  => 0,
  :hp                     => 1,
  # =================================
  :melee_damage           => 0,
  :ranged_damage          => 0,    
  # =================================
  :guard_time             => 0,
  :hitbox                 => [0,0,32,46],
  :playable               => false
  # =================================
})

################################################################
#
# Lucario
#
################################################################
ListHandlers.add(:character, :lucario, {
  # =================================
  :name                   => "Lucario",
  :internal               => :LUCARIO,
  :melee                  => :CLOSECOMBAT,
  :ranged                 => :AURASPHERE,
  # =================================
  :speed                  => 8,
  :hp                     => 60,
  # =================================
  :melee_damage           => 4,
  :ranged_damage          => 5,
  # =================================
  :guard_time             => 2,
  :hitbox                 => [16,24,50,60],
  :unlock_proc            => proc { next $player.level >= 45 }
  # =================================
})