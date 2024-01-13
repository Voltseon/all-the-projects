class Arena
  attr_accessor :list
  def self.list
    if @list.nil?
      @list = []
      ListHandlers.each_available(:arena) do |option, hash, name|
        name = hash[:name]
        internal = hash[:internal]
        map_id = hash[:map_id] || 1
        spawn_points = hash[:spawn_points] || [[1,1,1],[1,1,1],[1,1,1],[1,1,1],[1,1,1]]
        unlock_proc = hash[:unlock_proc] || proc { next true }
        unlocked_level = hash[:unlocked_level] || 0
        @list.push(
          self.new(name, internal, map_id, spawn_points, unlock_proc, unlocked_level)
        )
      end
    end
    return @list
  end

  def self.each
    self.list if @list.nil?
    @list.each { |arena| yield arena }
  end

  def self.each_with_index
    self.list if @list.nil?
    @list.each_with_index { |arena, i| yield arena, i }
  end

  def self.get(arena)
    return arena if arena.is_a?(Arena)
    self.list if @list.nil?
    return @list[arena] if arena.is_a?(Numeric)
    ret = nil
    @list.each { |a| next if a.name != arena && a.internal != arena; ret = a; break }
    return @list[0] if ret.nil?
    return ret
  end

  def self.get_by_mapid(id)
    self.list if @list.nil?
    @list.each { |arena| return arena if arena.map_id == id }
    return nil
  end

  def self.count
    self.list if @list.nil?
    return @list.length
  end
end