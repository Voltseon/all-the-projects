class OverworldPokemon
  attr_accessor :pokemon
  attr_accessor :r_event
  attr_accessor :mud_hits
  attr_accessor :bait_hits
  attr_accessor :aggression
  attr_accessor :terrain

  def initialize(pokemon, r_event, terrain=:Land)
    @pokemon = pokemon
    @r_event = r_event
    @mud_hits = 0
    @bait_hits = 0
    @terrain = terrain
    # For every 50 average base attack stats increase aggression by one
    @aggression = ((@pokemon.species_data.base_stats[:ATTACK].to_f + @pokemon.species_data.base_stats[:SPECIAL_ATTACK].to_f) / 100.0).round
  end

  def catchRateModifier
    return [[(@mud_hits.to_f-@bait_hits.to_f/2.0)*1.1,1].max,2].min
  end

  def baitHit
    @bait_hits += 1
    @aggression = [@aggression-1,0].max
  end

  def mudHit
    @mud_hits += 1
    @aggression += 1
  end

  def pokemon; @pokemon; end
  def mud_hits; @mud_hits; end
  def bait_hits; @bait_hits; end
  def aggression; @aggression; end
  
  def pokemon=(value)
    @pokemon = value
  end

  def mud_hits=(value)
    @mud_hits = value
  end

  def bait_hits=(value)
    @bait_hits = value
  end

  def aggression=(value)
    @aggression = value
  end
end