def pbGetListMove
  movelist = []
  GameData::Move.each do |move|
    num = 0
    GameData::Species.each do |sp|
      if sp.egg_moves.include?(move.id) || sp.tutor_moves.include?(move.id) || checkTheMoves(sp.moves,move.id)
        num += 1
      end
    end
    movelist.push([move.name,move.type.name,move.base_damage,num])
    echoln _INTL("{1} - {2} Pokémon | {3} / 676",move.name,num,move.id_number)
  end
  File.open("movelist.txt","wb") { |f|
    movelist.each do |movenum|
      echoln _INTL("Write: {1}",movenum[0])
      f.write("#{movenum[0]}, #{movenum[1]}, #{movenum[2]}, #{movenum[3]}\r\n")
    end
  }
  echoln "Done!"
  Graphics.update
end

def checkTheMoves(a, b)
  ret = false
  a.each do |move|
    if move[1] == b
      ret = true
      break
    end
  end
  return ret
end

def pbShowListOfMoves(mon)
  echoln "Moves:"
  echoln ""
  echoln _INTL("{1}",GameData::Species.get(mon).moves)
  echoln ""
  echoln ""
  echoln ""
  echoln "Egg Moves:"
  echoln ""
  echoln _INTL("{1}",GameData::Species.get(mon).egg_moves)
  echoln ""
  echoln ""
  echoln ""
  echoln "Tutor Moves:"
  echoln ""
  echoln _INTL("{1}",GameData::Species.get(mon).tutor_moves)
end

