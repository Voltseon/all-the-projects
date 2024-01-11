def pbPokeReroll
  pbChooseTradablePokemon(1, 3, proc { |pkmn|
    next pkmn.fused.nil?
  })
  idx = pbGet(1)
  return false if idx < 0
  $player.party[idx] = pbRerollMon($player.party[idx])
  return true
end

def pbRerollMon(pok, message = true)
  pbDismountPkmn($PokemonGlobal.mounted_pkmn,false)
  ball = pok.poke_ball
  item = pok.item
  exp = pok.exp
  exp = 0 if $player.levelone
  form = pok.form
  shiny = pok.shiny?
  sshiny = pok.super_shiny?
  pkmn = Pokemon.new(pok.species, Settings::EGG_LEVEL)
  pkmn.form = form
  pkmn.name           = _INTL("Egg")
  pkmn.steps_to_hatch = 1
  pkmn.hatched_map    = 0
  pkmn.obtain_method  = 1
  pkmn.poke_ball = ball
  pkmn.calc_stats
  pkmn.shiny = false if $player.murphyslaw
  pkmn.hp = 1 if $player.onehp && pkmn.hp > 0
  pkmn.shiny = shiny if shiny
  pkmn.super_shiny = sshiny if sshiny
  xscandies = (exp/800).floor
  scandies = (xscandies/4).floor
  mcandies = (scandies/3).floor
  lcandies = (mcandies/3).floor
  xlcandies = (lcandies/3).floor
  xscandies -= scandies*4
  scandies -= mcandies*3
  mcandies -= lcandies*3
  lcandies -= xlcandies*3
  if !$player.murphyslaw
    if pkmn.shiny?
      pkmn.super_shiny = rand(4)==1
    elsif rand(512) == 1
      pkmn.shiny = true
    end
  end
  pok = pkmn
  FollowingPkmn.refresh
  pbMessage("Your #{pbGet(3)} has successfully been PokéRerolled!") if message
  if item
    pbMessage("Your #{pbGet(3)} was holding a #{GameData::Item.get(item).name}.") if message
    pbReceiveItem(item)
  end
  pbReceiveItem(:EXPCANDYXS, xscandies) if xscandies > 0
  pbReceiveItem(:EXPCANDYS, scandies) if scandies > 0
  pbReceiveItem(:EXPCANDYM, mcandies) if mcandies > 0
  pbReceiveItem(:EXPCANDYL, lcandies) if lcandies > 0
  pbReceiveItem(:EXPCANDYXL, xlcandies) if xlcandies > 0
  return pok
end

def rerollUntilSpecial
  pbChooseTradablePokemon(1, 3, proc { |pkmn|
    next pkmn.fused.nil?
  })
  idx = pbGet(1)
  return false if idx < 0
  $bag.quantity(:REVIVE).times do |i|
    $bag.remove(:REVIVE)
    echoln "** Rerolling #{i} **"
    $player.party[idx] = pbRerollMon($player.party[idx], false)
    break if $player.party[idx].shiny? || $player.party[idx].super_shiny?
    echoln "** Rerolled #{i} **"
  end
end