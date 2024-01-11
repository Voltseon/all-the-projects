module GameData
  class SecretBaseTemplate
    attr_reader :id
    attr_reader :map_id
    attr_reader :type
    attr_reader :door_location
    attr_reader :pc_location
    attr_reader :owner_location
    attr_reader :preview_steps
    attr_reader :map_borders

    DATA = {}

    extend ClassMethodsSymbols
    include InstanceMethods

    def self.load; end
    def self.save; end

    def initialize(hash)
      @id              = hash[:id]
      @map_id          = hash[:map_id]
      @type            = hash[:type]
      @door_location   = hash[:door_location]
      @pc_location     = hash[:pc_location]
      @owner_location  = hash[:owner_location]
      @preview_steps   = hash[:preview_steps] || 2
      @map_borders     = hash[:map_borders]
    end
  end
end

GameData::SecretBaseTemplate.register({
  :id            => :CaveRed1,
  :map_id        => 32,
  :type          => :cave,
  :door_location => [13,14],
  :pc_location   => [9,8],
  :map_borders   => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveRed2,
  :map_id        => 42,
  :type          => :cave,
  :door_location => [11,21],
  :pc_location   => [13,14],
  :map_borders   => [8,6,14,21]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveRed3,
  :map_id        => 43,
  :type          => :cave,
  :door_location => [11,13],
  :pc_location   => [9,8],
  :map_borders   => [8,6,22,13]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveRed4,
  :map_id        => 48,
  :type          => :cave,
  :door_location => [10,19],
  :pc_location   => [10,8],
  :map_borders   => [8,6,16,20]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBrown1,
  :map_id        => 76,
  :type          => :cave,
  :door_location => [13,14],
  :pc_location   => [15,18],
  :map_borders   => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBrown2,
  :map_id        => 77,
  :type          => :cave,
  :door_location => [9,14],
  :pc_location   => [17,7],
  :map_borders   => [8,6,21,14]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBrown3,
  :map_id        => 78,
  :type          => :cave,
  :door_location => [19,16],
  :pc_location   => [21,9],
  :map_borders   => [8,6,22,16]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBrown4,
  :map_id        => 79,
  :type          => :cave,
  :door_location => [10,15],
  :pc_location   => [9,7],
  :map_borders   => [8,6,21,17]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBlue1,
  :map_id        => 80,
  :type          => :cave,
  :door_location => [13,14],
  :pc_location   => [9,8],
  :map_borders   => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBlue2,
  :map_id        => 81,
  :type          => :cave,
  :door_location => [15,12],
  :pc_location   => [9,7],
  :map_borders   => [8,6,22,12]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBlue3,
  :map_id        => 82,
  :type          => :cave,
  :door_location => [12,22],
  :pc_location   => [11,20],
  :map_borders   => [8,6,17,22]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveBlue4,
  :map_id        => 83,
  :type          => :cave,
  :door_location => [12,22],
  :pc_location   => [11,19],
  :map_borders   => [8,6,16,22]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveYellow1,
  :map_id        => 84,
  :type          => :cave,
  :door_location => [13,14],
  :pc_location   => [17,8],
  :map_borders   => [8,6,18,14]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveYellow2,
  :map_id        => 85,
  :type          => :cave,
  :door_location => [20,14],
  :pc_location   => [16,12],
  :map_borders   => [8,6,21,14]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveYellow3,
  :map_id        => 86,
  :type          => :cave,
  :door_location => [13,16],
  :pc_location   => [11,11],
  :map_borders   => [8,6,19,16]
})

GameData::SecretBaseTemplate.register({
  :id            => :CaveYellow4,
  :map_id        => 87,
  :type          => :cave,
  :door_location => [14,19],
  :pc_location   => [13,14],
  :map_borders   => [8,6,20,19]
})

GameData::SecretBaseTemplate.register({
  :id            => :Tree1,
  :map_id        => 88,
  :type          => :vines,
  :door_location => [5,8],
  :pc_location   => [2,2],
  :map_borders   => [0,0,10,8]
})

GameData::SecretBaseTemplate.register({
  :id            => :Tree2,
  :map_id        => 89,
  :type          => :vines,
  :door_location => [3,15],
  :pc_location   => [5,5],
  :map_borders   => [0,0,6,15]
})

GameData::SecretBaseTemplate.register({
  :id            => :Tree3,
  :map_id        => 90,
  :type          => :vines,
  :door_location => [8,7],
  :pc_location   => [15,2],
  :map_borders   => [0,0,16,7]
})

GameData::SecretBaseTemplate.register({
  :id            => :Tree4,
  :map_id        => 91,
  :type          => :vines,
  :door_location => [7,13],
  :pc_location   => [4,9],
  :map_borders   => [0,0,13,13]
})

GameData::SecretBaseTemplate.register({
  :id            => :Shrub1,
  :map_id        => 92,
  :type          => :shrub,
  :door_location => [3,8],
  :pc_location   => [3,2],
  :map_borders   => [0,0,10,8]
})

GameData::SecretBaseTemplate.register({
  :id            => :Shrub2,
  :map_id        => 93,
  :type          => :shrub,
  :door_location => [7,6],
  :pc_location   => [1,1],
  :map_borders   => [0,0,14,6]
})

GameData::SecretBaseTemplate.register({
  :id            => :Shrub3,
  :map_id        => 94,
  :type          => :shrub,
  :door_location => [6,10],
  :pc_location   => [7,7],
  :map_borders   => [0,0,12,10]
})

GameData::SecretBaseTemplate.register({
  :id            => :Shrub4,
  :map_id        => 95,
  :type          => :shrub,
  :door_location => [11,9],
  :pc_location   => [9,5],
  :map_borders   => [0,0,13,10]
})