class Arena
  attr_accessor :name, :internal, :map_id, :spawn_points, :unlock_proc, :unlocked_level

  def initialize(name, internal, map_id, spawn_points, unlock_proc, unlocked_level)
    @name = name
    @internal = internal
    @map_id = map_id
    @spawn_points = spawn_points
    @unlock_proc = unlock_proc
    @unlocked_level = unlocked_level
  end
end