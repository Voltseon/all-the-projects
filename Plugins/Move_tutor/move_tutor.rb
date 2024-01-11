class MoveRelearnerScreen
  def eggMoves(pkmn)
    babyspecies=pkmn.species
    babyspecies = GameData::Species.get(babyspecies).get_baby_species(false, nil, nil)
    eggmoves=GameData::Species.get_species_form(babyspecies, pkmn.form).egg_moves
    return eggmoves
  end
  
  def getMoveList
    return species_data.moves
  end
  
  def tutorMoves(pkmn)
    return pkmn.species_data.tutor_moves
  end
  
  def hackmoves
    moves=[]
	GameData::Move.each { |i| moves.push(i.id) }
	return moves
  end
  
  def compare_names(move,pkmn)
    pk= pkmn.name[0]
	m= move.real_name[0]
	return (pk==m)	
  end
  
  def pbGetRelearnableMoves(pkmn)
    return [] if !pkmn || pkmn.egg? || pkmn.shadowPokemon?
    moves = []
    pkmn.getMoveList.each do |m|
      next if m[0] > pkmn.level || pkmn.hasMove?(m[1])
      moves.push(m[1]) if !moves.include?(m[1])
    end
    tmoves = []
    if pkmn.first_moves
      for i in pkmn.first_moves
        tmoves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)
      end
    end
	#if $game_variables[MOVETUTOR]==0				#modify to == if you want to make distinct NPCs
    moves = tmoves + moves  
	#end
	
    # add tutor moves and eggmoves
    if $game_variables[MOVETUTOR]>=1				#modify to == if you want to make distinct NPCs
      eggmoves=eggMoves(pkmn)
	  for i in eggmoves
        moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)
      end
    end
    if $game_variables[MOVETUTOR]>=2				#modify to == if you want to make distinct NPCs
      tutormoves= tutorMoves(pkmn)
	  for i in tutormoves
        moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)
      end
    end
	if $game_variables[MOVETUTOR]==3	#hackmon
	  hmoves = hackmoves
	  for i in hmoves
        moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)
      end
	end
	if $game_variables[MOVETUTOR]==4    #Stabmon
	  smoves=[]
	  GameData::Move.each { |i| smoves.push(i.id) if (i.type==pkmn.types[0] || i.type==pkmn.types[1]) }	
	  for i in smoves
		  moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)  
	  end
	end
	if $game_variables[MOVETUTOR]==5    #Alphabetmon
	  smoves=[]
	  GameData::Move.each { |i| smoves.push(i.id) if compare_names(i,pkmn) }	
	  for i in smoves
		  moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)  
	  end
	end	
	if $game_variables[MOVETUTOR]>=6	#universal move tutor		
		for i in UCmoves
		  moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)  
		end
	end
	if $game_variables[MOVETUTOR]>=7	#custom move tutor	
		pmoves=[:JUDGMENT]
		if pkmn.name=='Psyduck'
			for i in pmoves
				moves.push(i) if !pkmn.hasMove?(i) && !moves.include?(i)  
			end
		end
	end	
	
    moves.sort! { |a, b| a.downcase <=> b.downcase } #sort moves alphabetically
    return moves | []   # remove duplicates
  end
  
end


 

