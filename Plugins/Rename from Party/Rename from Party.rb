MenuHandlers.add(:party_menu, :rename, {
  "name"      => _INTL("Rename"),
  "order"     => 55,
  "condition" => proc { |screen, party, party_idx| next !party[party_idx].egg? && !party[party_idx].shadowPokemon? },
  "effect"    => proc { |screen, party, party_idx|
    pkmn = party[party_idx]
    name = pbMessageFreeText("#{pkmn.speciesName}'s nickname?",_INTL(""),false,Pokemon::MAX_NAME_SIZE) { screen.pbUpdate }
    name=pkmn.speciesName if name ==""
    pkmn.name=name
    screen.pbDisplay(_INTL("{1} was renamed to {2}.",pkmn.speciesName,pkmn.name))
  }
})