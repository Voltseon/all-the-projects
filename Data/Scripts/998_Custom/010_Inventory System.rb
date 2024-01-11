CARRY_CAPACITIES = [25, 50, 75, 100, 150, 200, 250, 500, 750, 999]
STORAGE_CAPACITIES = [150, 300, 500, 750, 1000, 1500, 2000, 3000, 5000, 7500, 9999]

def add_item(item, quantity=1, sound=true)
  if $player.items[item]
    $player.items[item] += quantity
  else
    $player.items[item] = quantity
  end
  too_many = 0
  if $player.items[item] >= $player.carry_capacity
    too_many = $player.items[item] - $player.carry_capacity
    $player.items[item] = $player.carry_capacity
  end
  quantity -= too_many
  if quantity > 0
    pbSEPlay("PLA 010 Level Up!") if sound
    pbNotify(_INTL("Item got!"), _INTL("{1} {2}", quantity, (quantity > 1 ? GameData::Item.try_get(item).name_plural : GameData::Item.try_get(item).name)), 1, [GameData::Item.icon_filename(item),256,20])
  end
  if too_many > 0
    pbMessage(_INTL("You can't carry any more {1}!", (too_many > 1 ? GameData::Item.try_get(item).name_plural : GameData::Item.try_get(item).name)))
    commands = ["Storage", "Toss"]
    outcome = pbMessage(_INTL("What would you like to do with the {1} remaining {2}?", too_many, (too_many > 1 ? GameData::Item.try_get(item).name_plural : GameData::Item.try_get(item).name)), commands)
    if outcome == 0
      add_to_storage(item, too_many, true)
    end
  end
end

def can_add_item(item, quantity)
  return true if $player.items[item].nil?
  return $player.items[item] + quantity <= $player.carry_capacity
end

def remove_item(item, quantity=1)
  if $player.items[item]
    $player.items[item] -= quantity
    if $player.items[item] <= 0
      $player.items[item] = 0
    end
  end
end

def has_item(item)
  return item_quantity(item) > 0 if item.is_a?(Symbol)
  if item.is_a?(Array)
    item.each do |i|
      return false if !has_item(i)
    end
    return true
  end
  if item.is_a?(Hash)
    item.each do |i, q|
      return false if item_quantity(i) < q
    end
    return true
  end
  return false
end

def item_quantity(item)
  return $player.items[item] || 0
end

def add_to_storage(item, quantity=1, toss=false)
  if $player.storage[item]
    $player.storage[item] += quantity
  else
    $player.storage[item] = quantity
  end
  too_many = 0
  total = storage_total
  if total >= $player.storage_capacity
    too_many = total - $player.storage_capacity
    $player.storage[item] -= too_many
  end
  quantity -= too_many
  if quantity > 0
    pbSEPlay("PLA 010 Level Up!")
    pbNotify(_INTL("Stored item!"), _INTL("{1} {2}", quantity, (quantity > 1 ? GameData::Item.try_get(item).name_plural : GameData::Item.try_get(item).name)), 1, [GameData::Item.icon_filename(item),256,20])
  end
  if too_many > 0
    pbMessage(_INTL("You can't store any more {1}!", (too_many > 1 ? GameData::Item.try_get(item).name_plural : GameData::Item.try_get(item).name)))
    if toss
      pbMessage(_INTL("{1} too many {2} were tossed!", too_many, (too_many > 1 ? GameData::Item.try_get(item).name_plural : GameData::Item.try_get(item).name)))
    else
      add_item(item, too_many, false)
    end
  end
end

def remove_from_storage(item, quantity)
  if $player.storage[item]
    $player.storage[item] -= quantity
    if $player.storage[item] <= 0
      $player.storage.delete(item)
    end
  end
end

def storage_quantity(item)
  return $player.storage[item] || 0
end

def storage_total
  total = 0
  $player.storage.each do |item, quantity|
    total += quantity
  end
  return total
end

def remove_from_storage(item, quantity=1)
  if $player.storage[item]
    $player.storage[item] -= quantity
    if $player.storage[item] <= 0
      $player.storage.delete(item)
    end
  end
end

def storage_quantity(item)
  return $player.storage[item] || 0
end

def has_storage_item(item)
  return storage_quantity(item) > 0
end