def pbSpecialTutor
  moves = [
    :PLAYROUGH, :BODYSLAM, :COUNTER, :MIRRORCOAT, :DOUBLEEDGE, :HYPNOSIS, :NIGHTMARE, :DREAMEATER, :SELFDESTRUCT, :EXPLOSION, :MEGAPUNCH, :MEGAKICK, :SEISMICTOSS, :SOFTBOILED,
    :FIREPUNCH, :THUNDERPUNCH, :ICEPUNCH, :SHADOWPUNCH, :MIMIC, :FURYCUTTER, :PSYCHUP, :SNORE, :SWIFT, :SKYATTACK, :FAKEOUT, :ZAPCANNON, :DRACOMETEOR, :SYNTHESIS,
    :OMINOUSWIND, :TRICK, :VACUUMWAVE, :ZENHEADBUTT, :MAGNETRISE, :LASTRESORT, :AQUATAIL, :GUNKSHOT, :GASTROACID, :HEATWAVE, :IRONDEFENSE, :SUPERPOWER, :SIGNALBEAM,
    :EARTHPOWER, :TAILWIND, :WORRYSEED, :BLOCK, :GRAVITY, :ROLEPLAY, :BUGBITE, :DRILLRUN, :DUALCHOP, :DRAINPUNCH, :KNOCKOFF, :RECYCLE, :ENDEAVOR, :STEALTHROCK, :TRICKROOM,
    :ROOST, :NATURALGIFT, :TAILSLAP, :ICICLESPEAR, :MAGNETBOMB, :ELECTROWEB, :AFTERYOU, :PAINSPLIT, :TERRAINPULSE, :BURNINGJEALOUSY, :FLIPTURN, :GRASSYGLIDE, :RISINGVOLTAGE,
    :COACHING, :SCORCHINGSANDS, :DUALWINGBEAT, :METEORBEAM, :SKITTERSMACK, :TRIPLEAXEL, :CORROSIVEGAS, :EXPANDINGFORCE, :POLTERGEIST, :SCALESHOT, :LASHOUT, :STEELROLLER, :MISTYEXPLOSION
  ]
  move_names = []
  moves.each { |move| move_names.push(GameData::Move.get(move).name) }
  move_names.push("Cancel")
  move = pbMessage(_INTL("Choose a move to teach."), move_names, -1)
  return if move < 0 || move == move_names.length - 1
  pbChoosePokemon(1, 3, proc { |poke| poke && !poke.shadowPokemon? && poke.able? && !poke.hasMove?(moves[move]) && poke.compatible_with_move?(moves[move]) })
  return if $game_variables[1] < 0
  pbLearnMove($game_variables[1], moves[move])
  pbCallBub
  choice = pbMessage("Would you like to teach another move?" , ["Yes", "No"], 1)
  if choice == 0
    pbSpecialTutor
  end
end