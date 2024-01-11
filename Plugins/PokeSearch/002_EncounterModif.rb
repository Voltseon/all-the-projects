# All of the berry effects modifying the encounter
Events.onWildPokemonCreate+=proc {|sender,e|
  if $PokemonSystem.pokesearch_encounter
    pkmn = e[0]
    if $PokemonSystem.current_berry != nil
      case $PokemonSystem.current_berry
      when :LUMBERRY
        if (rand(25)==1)
          pkmn.ability_index=2
        end
      when :CHESTOBERRY, :CHERIBERRY, :PECHABERRY, :RAWSTBERRY, :PERSIMBERRY, :EMONBERRY, :ASPEARBERRY
        if (rand(50)==1)
          pkmn.givePokerus
        end
      when :ORANBERRY
        GameData::Stat.each_main do |s|
          pkmn.iv[s.id] = [pkmn.iv[s.id]+5, Pokemon::IV_STAT_LIMIT].min
        end
      when :SITRUSBERRY
        GameData::Stat.each_main do |s|
          pkmn.iv[s.id] = [pkmn.iv[s.id]+10, Pokemon::IV_STAT_LIMIT].min
        end
      when :GOLDBERRY
        if (rand(5)==1)
          pkmn.shiny = true
        end
      end
    end
    pkmn.reset_moves
    pkmn.calc_stats
  end
}