FISHING_ITEMS_COMMON = [:POKEBALL]
FISHING_ITEMS_UNCOMMON = [:GREATBALL]
FISHING_ITEMS_RARE = [:ULTRABALL]
FISHING_ITEM_CHANCE = 5 # out of 10

def pbFishingItem
  chance = rand(1..10)
  item = nil
  quantity = 1
  if chance < 7
    item = FISHING_ITEMS_COMMON.sample
    quantity = rand(1..3)
  elsif chance < 9
    item = FISHING_ITEMS_UNCOMMON.sample
    quantity = rand(1..2)
  elsif chance == 10
    item = FISHING_ITEMS_RARE.sample
  end
  return false if item.nil? || quantity < 1
  pbItemBall(item, quantity)
  return true
end

ItemHandlers::UseInField.add(:OLDROD, proc { |item|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  encounter = $PokemonEncounters.has_encounter_type?(:OldRod)
  if pbFishing(encounter, 1)
    if rand(1..10) > FISHING_ITEM_CHANCE
      next true if pbFishingItem
    end
    $stats.fishing_battles += 1
    pbEncounter(:OldRod)
  end
  next true
})

ItemHandlers::UseInField.add(:GOODROD, proc { |item|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  encounter = $PokemonEncounters.has_encounter_type?(:GoodRod)
  if pbFishing(encounter, 2)
    if rand(1..10) > FISHING_ITEM_CHANCE
      next true if pbFishingItem
    end
    $stats.fishing_battles += 1
    pbEncounter(:GoodRod)
  end
  next true
})

ItemHandlers::UseInField.add(:SUPERROD, proc { |item|
  notCliff = $game_map.passable?($game_player.x, $game_player.y, $game_player.direction, $game_player)
  if !$game_player.pbFacingTerrainTag.can_fish || (!$PokemonGlobal.surfing && !notCliff)
    pbMessage(_INTL("Can't use that here."))
    next false
  end
  encounter = $PokemonEncounters.has_encounter_type?(:SuperRod)
  if pbFishing(encounter, 3)
    if rand(1..10) > FISHING_ITEM_CHANCE
      next true if pbFishingItem
    end
    $stats.fishing_battles += 1
    pbEncounter(:SuperRod)
  end
  next true
})