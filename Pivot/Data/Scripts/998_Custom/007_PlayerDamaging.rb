class Rect < Object
  def over?(other)
    return (self.x.between?(other.x, other.x + other.width) && other.y.between?(self.y, self.y + self.height)) || (other.x.between?(self.x, self.x + self.width) && self.y.between?(other.y, other.y + other.height) || self.x.between?(other.x, other.x + other.width) && self.y.between?(other.y, other.y + other.height)) || (other.x.between?(self.x, self.x + self.width) && other.y.between?(self.y, self.y + self.height))
  end

  def to_array
    return [self.x, self.y, self.width, self.height]
  end
end

def distance_between_radians(lat1,lat2,lon1,lon2)
  # Convert to radians
  lat1 = lat1 * Math::PI / 180
  lon1 = lon1 * Math::PI / 180
  lat2 = lat2 * Math::PI / 180
  lon2 = lon2 * Math::PI / 180
  # Haversine formula
  dlon = lon2 - lon1
  dlat = lat2 - lat1
  a = (Math.sin(dlat/2))**2 + Math.cos(lat1) * Math.cos(lat2) * (Math.sin(dlon/2))**2
  # Distance
  c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
  return c
end

class Player < Trainer
  attr_accessor :hurt_frame
  attr_accessor :hitbox_active
  attr_accessor :region
  attr_accessor :slowed
  attr_accessor :invulnerable_frames
  attr_accessor :slow_duration
  attr_accessor :slow_frame
  attr_accessor :slow_speed

  BASE_INVULNERABLE_FRAMES = 16 # The amount of frames the player will be invulnerable for, no matter the attack.
  FLASH_FRAMES = 32

  def hurt_frame; @hurt_frame = 0 if !@hurt_frame; return @hurt_frame; end
  def hitbox_active; @hitbox_active = true if @hitbox_active.nil?; return @hitbox_active; end

  def hurt_frame=(value); @hurt_frame = value; return @hurt_frame; end
  def hitbox_active=(value); @hitbox_active = value; return @hitbox_active; end

  def being_hit; @being_hit = false if @being_hit.nil?; return @being_hit; end
  def being_hit=(value); @being_hit = value; end

  def slowed; @slowed = false if @slowed.nil?; return @slowed; end
  def slowed=(value); @slowed = value; end

  def invulnerable_frames; @invulnerable_frames = 16 if !@invulnerable_frames; return @invulnerable_frames; end
  def invulnerable_frames=(value); @invulnerable_frames = value; end

  def slow_duration; @slow_duration = 0 if !@slow_duration; return @slow_duration; end
  def slow_duration=(value); @slow_duration = value; end

  def slow_frame; @slow_frame = 0 if !@slow_frame; return @slow_frame; end
  def slow_frame=(value); @slow_frame = value; end

  def slow_speed; @slow_speed = 1 if !@slow_speed; return @slow_speed; end
  def slow_speed=(value); @slow_speed = value; end
  

  def region
    if @region.nil?
      place = pbDownloadToString("http://ip-api.com/line/?fields=status,lat,lon")
      place = place.split("\n")
      latitude = place[1].to_f
      longtitude = place[2].to_f
      distanceNA = distance_between_radians(latitude,38.631317,longtitude,-90.192154)
      distanceEU = distance_between_radians(latitude,48.137428,longtitude,11.57549)
      distanceOC = distance_between_radians(latitude,-33.86752,longtitude,151.20732)
      case [distanceNA,distanceEU,distanceOC].min
      when distanceNA
        @region = 1
      when distanceEU
        @region = 0
      when distanceOC
        @region = 2
      end
    end
    return @region
  end
  def region=(value); @region = value; end

  def hit
    return if @being_hit
    @being_hit = true
    $player.hitbox_active = false
    if @current_hp < 1
      # Death logic
      $game_temp.match_exp = [0, $game_temp.match_exp/2].max
      $player.character.sketched_melee = nil
      $player.character.sketched_ranged = nil
      $player.character.sketched_melee_damage = nil
      $player.character.sketched_ranged_damage = nil
      @stocks -= 1
      $stats.total_faints += 1
      if @stocks==0 && $game_temp.in_a_match
        case rand(1..3)
        when 1
          pbAnnounce(:defeat_1)
        when 2
          pbAnnounce(:defeat_3)
        when 3
          pbAnnounce(:defeat_4)
        end
      else
        case rand(1..2)
        when 1
          pbAnnounce(:went_down)
        when 2
          pbAnnounce(:taken_down)
        end
      end
    else
      case rand(1..5)
      when 1
        pbAnnounce(:that_hurt)
      when 2
        pbAnnounce(:aah)
      end
    end
  end

  def slow(duration, speed)
    @slowed = true
    @slow_duration = duration*60
    @slow_frame = 0
    case speed
    when -1
      @slow_speed = $player.character.speed
    when 0
      @slow_speed = 0
      $game_temp.character_lock = true
    else
      @slow_speed = speed
    end
  end

  def unhit
    @being_hit = false
    @hurt_frame = 0
    @hitbox_active = true
  end

  def unslow
    @slowed = false
    @slow_duration = 0
    @slow_frame = 0
    $game_temp.character_lock = false if $game_temp.character_lock
    @slow_speed = 1
  end
end