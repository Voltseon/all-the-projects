class PokemonGlobalMetadata
  attr_writer :secret_base_rank
  attr_writer :secret_base_registry
  
  def secret_base_rank
    return @secret_base_rank || 0
  end
  
  def secret_base_registry
    return @secret_base_registry || false
  end
  
  def secret_base_list
    if !@secret_base_list
      @secret_base_list = []
      @secret_base_list[0] = SecretBase.new(nil,$player)
    end
    return @secret_base_list
  end
end

class PokemonMapMetadata
  attr_accessor :current_base_id
  
  alias _secretbase_clear clear
  def clear
    _secretbase_clear
    # fixes save/load bug
    if $game_map && $game_map.map_id != SecretBaseSettings::SECRET_BASE_MAP
      @current_base_id = nil
    end
  end
end

class GameStats
  attr_writer :moved_secret_base_count
  
  def moved_secret_base_count
    return @moved_secret_base_count || 0
  end
end