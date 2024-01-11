MOUNTABLE_POKEMON = [
  :ARCANINE,
  :CYCLIZAR,
  :TAUROS,
  :ONIX, :STEELIX,
  :ABSOL,
  :ARIADOS,
  :AURORUS,
  :BASTIODON,
  :VENUSAUR, :CHARIZARD, :BLASTOISE,
  :MEGANIUM, :TYPHLOSION, :FERALIGATR,
  :SCEPTILE, :BLAZIKEN, :SWAMPERT,
  :TORTERRA, :INFERNAPE, :EMPOLEON,
  :SERPERIOR, :EMBOAR, :SAMUROTT,
  :CHESNAUGHT, :DELPHOX, :GRENINJA,
  :DECIDUEYE, :INCINEROAR, :PRIMARINA,
  :RILLABOOM, :CINDERACE, :INTELEON,
  :BEWEAR,
  :GIGALITH,
  :BOLTUND,
  :BOUFFALANT,
  :CAMERUPT,
  :CENTISKORCH,
  :CARKOL, :COALOSSAL,
  :COBALION, :TERRAKION, :VIRIZION, :KELDEO,
  :COPPERAJAH,
  :CRUSTLE,
  :DARMANITAN,
  :DODRIO,
  :DONPHAN,
  :DRAMPA,
  :DRAPION,
  :DUBWOOL,
  :ENTEI, :RAIKOU, :SUICUNE,
  :FLAREON, :JOLTEON, :VAPOREON,
  :ESPEON, :UMBREON,
  :GLACEON, :LEAFEON,
  :SYLVEON,
  :FURFROU,
  :GALVENTULA,
  :GIRAFARIG,
  :SPECTRIER, :GLASTRIER,
  :SKIDDO, :GOGOAT,
  :GROUDON, :KYOGRE, :RAYQUAZA,
  :HEATRAN,
  :HIPPOWDON,
  :HOUNDOOM,
  :KOMMOO,
  :KROOKODILE,
  :KYUREM, :RESHIRAM, :ZEKROM,
  :LIEPARD,
  :LUXRAY,
  :LYCANROC,
  :MAMOSWINE,
  :MANECTRIC,
  :MUDSDALE,
  :NINETALES,
  :PARASECT,
  :PERSIAN,
  :PONYTA, :RAPIDASH,
  :PROBOPASS,
  :PURUGLY,
  :PYROAR,
  :RHYHORN, :RHYDON, :RHYPERIOR,
  :SAWSBUCK,
  :SCOLIPEDE,
  :TYPENULL, :SILVALLY,
  :SNORLAX,
  :STATNLER,
  :STOUTLAND,
  :THIEVUL,
  :VILEPLUME,
  :XERNEAS, :YVELTAL, :ZYGARDE,
  :ZACIAN, :ZAMAZENTA,
  :REGIROCK, :REGICE, :REGISTEEL, :REGIDRAGO, :REGIELEKI, :REGIGIGAS,
  :NANYTE,
  :MEOWSCARADA, :SKELEDIRGE, :QUAQUAVAL,
  :OINKOLOGNE,
  :SPIDOPS,
  :PAWMOT,
  :DACHSBUN,
  :NACLSTACK, :GARGANACL,
  :ARMAROUGE, :CERULEDGE,
  :KILOWATTREL,
  :MABOSSTIFF,
  :TOEDSCRUEL,
  :KLAWF,
  :ESPATHRA,
  :BOMBIRDIER,
  :REVAVROOM,
  :ORTHWORM,
  :HOUNDSTONE,
  :CETITAN,
  :CLODSIRE,
  :FARIGIRAF,
  :DUDUNSPARCE,
  :GREATTUSK, :SLITHERWING,
  :IRONTREADS, :IRONJUGULIS, :IRONMOTH, :IRONTHORNS,
  :BAXCALIBUR,
  :GHOLDENGO,
  :WOCHIEN, :CHIENPAO, :TINGLU,
  :ROARINGMOON,
  :KORAIDON, :MIRAIDON,
  :WALKINGWAKE, :IRONLEAVES
]

MOUNT_BGM = "DPPt Bicycle Ride"

MenuHandlers.add(:party_menu, :mount, {
  "name"      => _INTL("Mount"),
  "order"     => 15,
  "condition" => proc { |screen, party, party_idx| next pbIsMountable(party_idx) },
  "effect"    => proc { |screen, party, party_idx|
    pbMountPkmn(party_idx)
  }
})

MenuHandlers.add(:party_menu, :dismount, {
  "name"      => _INTL("Dismount"),
  "order"     => 15,
  "condition" => proc { |screen, party, party_idx| next $PokemonGlobal.mounted_pkmn == party_idx },
  "effect"    => proc { |screen, party, party_idx|
    pbDismountPkmn(party_idx)
  }
})

def pbCanMount?
  return false unless pbCanUseBike?($game_map.map_id)
  return $game_switches[84]
end

class PokemonGlobalMetadata
  attr_accessor :mounted_pkmn
  def mounted_pkmn
    @mounted_pkmn = -1 if !@mounted_pkmn
    return @mounted_pkmn
  end
end

def pbIsMountable(party_idx)
  return false if $PokemonGlobal.mounted_pkmn == party_idx || !pbCanMount? 
  pkmn = $player.party[party_idx]
  return true if MOUNTABLE_POKEMON.include?(pkmn.species)
  return true if pkmn.isSpecies?(:LOTAD) && pkmn.item == :BLACKGLASSES
  return $DEBUG
end

def pbMountPkmn(party_idx, showMsg = true)
  pkmn = $player.party[party_idx]
  $PokemonGlobal.bicycle = true
  $PokemonGlobal.mounted_pkmn = party_idx
  $stats.cycle_count += 1
  $PokemonGlobal.mach_bike = pbGetMountedSpeed >= 32
  pbUpdateVehicle
  pbPokeRadarCancel
  FollowingPkmn.refresh(true)
  pbCueBGM(MOUNT_BGM, 0.5)
  pkmn.play_cry
  pbMessage("You are now mounting #{pkmn.name}.") if showMsg
  $game_player.move_speed = 3
  $game_player.move_speed = 7
end

def pbDismountPkmn(party_idx = $PokemonGlobal&.mounted_pkmn, showMsg = true)
  return if $PokemonGlobal.mounted_pkmn == -1
  $game_player.y_offset = 0
  $PokemonGlobal.bicycle = false
  $PokemonGlobal.mounted_pkmn = -1
  pbUpdateVehicle
  FollowingPkmn.refresh(true)
  $game_map.autoplayAsCue
  if party_idx > -1 && showMsg
    pkmn = $player.party[party_idx]
    pkmn.play_cry
    pbMessage("Dismounted from #{pkmn.name}.")
   end
end

def pbGetMountedSpeed
  return 3 if $PokemonGlobal.mounted_pkmn == -1
  pkmn = $player&.party[$PokemonGlobal&.mounted_pkmn]
  ret = pkmn.speed / 1000.000
  ret *= 100
  ret = (ret + 1).round
  ret *= 3
  ret *= 0.8
  return ret
end