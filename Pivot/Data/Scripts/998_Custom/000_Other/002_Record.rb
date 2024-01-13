class Recording
  @@records = []
  @@recording = false
  @@framerate = 2
  @@frames = 48
  @@spinning = false
  @@name = "recording"
  @@split = false

  def self.snapshot
    return unless @@recording
    bitmap = Graphics.snap_to_bitmap
    if @@split
      bitmap.to_file("./Graphics/Pictures/Animated Backgrounds/#{@@name}_#{@@records.length}.png")
    end
    @@records << bitmap
    if @@records.length >= @@frames
      self.finalize
    elsif @@spinning && $player.character.evolution_line
      if @@records.length % 48 == 0
        $player.character_id = $player.character.evolution
        spin
      end
    end
  end

  def self.finalize
    echoln "Finalizing recording..."
    width = Graphics.width
    height = Graphics.height
    if @@spinning
      width = 248
      height = 248
      @@records.each do |record|
        record.blt(0,0,record,Rect.new(388,146,width,height))
      end
    end
    final_bitmap = Bitmap.new(width*4, height/4*@@records.length)
    @@records.each_with_index do |record,i|
      final_bitmap.blt(width*(i%4),height*(i/4),record,record.rect)
    end
    final_bitmap.to_file("./#{@@name}.png")
    @@records = []
    @@recording = false
  end

  def self.start(frames = 48, split = false, name = "recording")
    @@frames = frames
    @@split = split
    @@name = name
    echoln "Starting"
    @@recording = true
  end

  def self.start_spin
    @@frames = 48
    @@name = $player.character_id.to_s
    if $player.character.evolution_line
      @@frames = 48*$player.character.evolution_stages
    end
    echoln "Starting"
    @@spinning = true
    @@recording = true
    spin
  end

  def self.is_recording?
    return @@recording
  end

  def self.framerate
    return @@framerate
  end
end

module Graphics
  class << self
    @@frame = 0

    alias old_update update

    def update
      old_update
      Recording.snapshot if Recording.is_recording? && @@frame == 0
      @@frame = (@@frame+1)%Recording.framerate
    end
  end
end