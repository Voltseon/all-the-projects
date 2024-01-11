MOUNTABLE_POKEMON = [
  :SERPERIOR, :INFERNAPE, :SWAMPERT,
  :BIBAREL, :FLOATZEL, :NOCTOWL,
  :YANMEGA, :AMOONGUSS,
  :DARMANISLAM, :SAWSBUCK,
  :ZOROARK, :CLEFABLE,
  :SANDSLASH, :GLISCOR,
  :DUNSPARCE, :CAMERUPT,
  :BOLDORE, :GIGALITH,
  :CRUSTLE, :EXCADRILL,
  :EELEKTROSS, :TOGEKISS,
  :HOUNDOOM, :RAPIDASH,
  :NIDOQUEEN, :NIDOKING,
  :GARBODOR,
  :STANTLER, :WYRDEER,
  :HERACROSS, :PINSIR, :VESPIQUEN,
  :TAUROS, :MILTANK,
  :SEVIPER,
  :GRANBULL, :CRYOGONAL,
  :PILOSWINE, :MAMOSWINE,
  :KANGASKHAN, :PROBOPASS,
  :RAMPARDOS, :BASTIODON,
  :DUSKNOIR, :GOLURK,
  :DURANT, :HEATMOR,
  :ZWEILOUS, :HYDREIGON,
  :GARCHOMP,
  :TORNADUS, :THUNDURUS, :ENAMORUS, :LANDORUS,
  :HEATRAN, :LOTAD
]

MOUNT_BGM = "BW 161 Bicycle"

MenuHandlers.add(:party_menu, :mount, {
  "name"      => _INTL("Mount"),
  "order"     => 17,
  "condition" => proc { |screen, party, party_idx| next pbIsMountable(party_idx) },
  "effect"    => proc { |screen, party, party_idx|
    pbMountPkmn(party_idx)
  }
})

MenuHandlers.add(:party_menu, :dismount, {
  "name"      => _INTL("Dismount"),
  "order"     => 17,
  "condition" => proc { |screen, party, party_idx| next $PokemonGlobal.mounted_pkmn == party_idx },
  "effect"    => proc { |screen, party, party_idx|
    pbDismountPkmn(party_idx)
  }
})

def pbCanMount?
  return !$PokemonGlobal.surfing
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
  return $DEBUG
end

def pbMountPkmn(party_idx, showMsg = true)
  pkmn = $player.party[party_idx]
  $PokemonGlobal.bicycle = true
  $PokemonGlobal.mounted_pkmn = party_idx
  $stats.cycle_count += 1
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
  FollowingPkmn.refresh(false)
  $game_map.autoplayAsCue
  if party_idx > -1 && showMsg
    pkmn = $player.party[party_idx]
    pkmn.play_cry
    pbMessage("Dismounted from #{pkmn.name}.")
   end
end

def pbGetMountedSpeed
  return 12.8 if $PokemonGlobal.mounted_pkmn == -1
  pkmn = $player&.party[$PokemonGlobal&.mounted_pkmn]
  ret = pkmn.speed / 1000.000
  ret *= 100
  ret = (ret + 1).round
  ret *= 3
  ret *= 0.8
  return ret
end