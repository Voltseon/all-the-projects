def unlock_recipe(item)
  $player.crafting_recipes << item
  pbSEPlay("PLA 010 Level Up!")
  pbNotify(_INTL("New recipe!"), _INTL("{1}", GameData::Item.try_get(item).name), 1, [GameData::Item.icon_filename(item),256,20])
end

def research(again=false)
  items = []
  item_ids = []
  $player.items.each do |item, quantity|
    next unless quantity > 0
    next unless GameData::Item.get(item).pocket == 1
    next if $player.researched_items.include?(item)
    items.push(GameData::Item.get(item).name)
    item_ids.push(item)
  end
  items.push("Cancel")
  result = pbMessage(_INTL("\\drWhat {1}would you like me to research?", (again ? "else " : "")), items, items.length)
  if result < items.length - 1
    $player.researched_items << item_ids[result]
    pbSEPlay("Research")
    pbNotify(_INTL("Research complete!"), _INTL("{1}", GameData::Item.try_get(item_ids[result]).name), 1, [GameData::Item.icon_filename(item_ids[result]),256,20])
    pbMessage(_INTL("\\drNow let's see what we can make with it..."))
    unlocked = false
    MenuHandlers.each(:recipe) do |option, handler|
      next unless handler["research_item"] == item_ids[result]
      unlock_recipe(option)
      unlocked = true
    end
    if !unlocked
      pbMessage(_INTL("No new recipes were unlocked."))
      add_item(item_ids[result], 1)
    end
    research(true)
  else
    return
  end
end

MenuHandlers.add(:recipe, :TWINE, {
  "name"            => _INTL("Twine"),
  "items"           => { :SYLVENBRANCH => 2 },
  "yield"           => { :TWINE=>1 },
  "condition"       => proc { true },
  "research_item"   => :TWINE
})

MenuHandlers.add(:recipe, :HATCHET, {
  "name"            => _INTL("Hatchet"),
  "items"           => { :FERRICIODIDE => 1, :SYLVENSTONES => 2, :TWINE => 3, :SYLVENBRANCH => 5 },
  "yield"           => { :HATCHET=>1 },
  "condition"       => proc { !has_item(:HATCHET) },
  "research_item"   => :SYLVENBRANCH
})

MenuHandlers.add(:recipe, :BUCKET, {
  "name"            => _INTL("Bucket"),
  "items"           => { :FERRICIODIDE => 5, :TWINE => 2 },
  "yield"           => { :BUCKET=>1 },
  "condition"       => proc { !has_item(:BUCKET) },
  "research_item"   => :FERRICIODIDE
})

MenuHandlers.add(:recipe, :PICKAXE, {
  "name"            => _INTL("Pickaxe"),
  "items"           => { :SILICATESHARD => 5, :TWINE => 2, :SYLVENBRANCH => 3 },
  "yield"           => { :PICKAXE=>1 },
  "condition"       => proc { !has_item(:PICKAXE) },
  "research_item"   => :SILICATESHARD
})

MenuHandlers.add(:recipe, :COMMUNICATIONSMODULE, {
  "name"            => _INTL("Communications Module"),
  "items"           => { :SILICATECRYSTAL => 5, :SILICATESHARD => 10, :SANDSTONE => 15, :LUMINAR => 5 },
  "yield"           => { :COMMUNICATIONSMODULE=>1 },
  "condition"       => proc { !has_item(:COMMUNICATIONSMODULE) },
  "research_item"   => :SILICATECRYSTAL
})

MenuHandlers.add(:recipe, :ROCKETBOOTS, {
  "name"            => _INTL("Rocket Boots"),
  "items"           => { :GOLDHAIR => 10, :SILICATESHARD => 10, :COPPERNUGGET => 15, :LUMINAR => 10 },
  "yield"           => { :ROCKETBOOTS=>1 },
  "condition"       => proc { !has_item(:ROCKETBOOTS) },
  "research_item"   => :GOLDHAIR
})

MenuHandlers.add(:recipe, :TEXTFILE, {
  "name"            => _INTL("Tudee.txt"),
  "items"           => { :CHROME => 10, :DATASTRAND => 5, :RAWDATA => 2, :MUON => 1 },
  "yield"           => { :TEXTFILE=>1 },
  "condition"       => proc { !has_item(:TEXTFILE) },
  "research_item"   => :DATASTRAND
})

MenuHandlers.add(:recipe, :SANDSTONE, {
  "name"            => _INTL("Sandstone"),
  "items"           => { :COARSESAND => 5 },
  "yield"           => { :SANDSTONE=>1 },
  "condition"       => proc { true },
  "research_item"   => :SANDSTONE
})

MenuHandlers.add(:recipe, :SILICATESHARD, {
  "name"            => _INTL("Silicate Shard"),
  "items"           => { :SILICATECRYSTAL => 2 },
  "yield"           => { :SILICATESHARD=>5 },
  "condition"       => proc { true },
  "research_item"   => :SANDSTONE
})

MenuHandlers.add(:recipe, :PIECEOFIRON, {
  "name"            => _INTL("Piece of Iron"),
  "items"           => { :FERRICIODIDE => 5, :MOLTENMETAL => 5 },
  "yield"           => { :PIECEOFIRON => 5 },
  "condition"       => proc { true },
  "research_item"   => :PIECEOFIRON
})

MenuHandlers.add(:recipe, :NEBULASPORES, {
  "name"            => _INTL("Nebula Spores"),
  "items"           => { :MUSHROOMCAP => 10, :LUMINAR => 5 },
  "yield"           => { :NEBULASPORES => 5 },
  "condition"       => proc { true },
  "research_item"   => :NEBULASPORES
})

MenuHandlers.add(:recipe, :METEORITE, {
  "name"            => _INTL("Meteorite"),
  "items"           => { :MOLTENMETAL => 25, :WATER => 25 },
  "yield"           => { :METEORITE => 5 },
  "condition"       => proc { true },
  "research_item"   => :METEORITE
})

# Carry Capacity Upgrades

MenuHandlers.add(:recipe, :CAPACITY1, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :LUMINAR => 20, :FERRICIODIDE => 10, :TWINE => 25, :SYLVENSTONES => 20 },
  "yield"           => { :CAPACITY1=>1 },
  "condition"       => proc { !has_item(:CAPACITY1) && (!has_item(:STORAGE1)) },
  "research_item"   => :LUMINAR
})

MenuHandlers.add(:recipe, :CAPACITY2, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :SILICATESHARD => 20, :SILICATECRYSTAL => 10, :COARSESAND => 25, :SANDSTONE => 15 },
  "yield"           => { :CAPACITY2=>1 },
  "condition"       => proc { !has_item(:CAPACITY2) && (!has_item(:STORAGE2)) },
  "research_item"   => :SANDSTONE
})

MenuHandlers.add(:recipe, :CAPACITY3, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :COPPERNUGGET => 20, :PIECEOFIRON => 10, :MOLTENMETAL => 15, :GOLDHAIR => 10 },
  "yield"           => { :CAPACITY3=>1 },
  "condition"       => proc { !has_item(:CAPACITY3) && (!has_item(:STORAGE3)) },
  "research_item"   => :MOLTENMETAL
})

MenuHandlers.add(:recipe, :CAPACITY4, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :MUSHROOMCAP => 25, :WATER => 20, :METEORITE => 15, :NEBULASPORES => 10 },
  "yield"           => { :CAPACITY4=>1 },
  "condition"       => proc { !has_item(:CAPACITY4) && (!has_item(:STORAGE4)) },
  "research_item"   => :WATER
})

MenuHandlers.add(:recipe, :CAPACITY5, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :CHROME => 25, :MUON => 20, :RAWDATA => 10, :DATASTRAND => 15 },
  "yield"           => { :CAPACITY5=>1 },
  "condition"       => proc { !has_item(:CAPACITY5) && (!has_item(:STORAGE5)) },
  "research_item"   => :MUON
})

MenuHandlers.add(:recipe, :CAPACITY6, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :PLATINUMINGOT => 35, :NEBULASPORES => 10, :FERRICIODIDE => 15, :MOONSTONE => 20 },
  "yield"           => { :CAPACITY6=>1 },
  "condition"       => proc { !has_item(:CAPACITY6) && (!has_item(:STORAGE6)) },
  "research_item"   => :PLATINUMINGOT
})

MenuHandlers.add(:recipe, :CAPACITY7, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :MOONSTONE => 150 },
  "yield"           => { :CAPACITY7=>1 },
  "condition"       => proc { !has_item(:CAPACITY7) && (!has_item(:STORAGE7)) },
  "research_item"   => :MOONSTONE
})

MenuHandlers.add(:recipe, :CAPACITY8, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :DATASTRAND => 50, :RAWDATA => 20, :WATER => 40 },
  "yield"           => { :CAPACITY8=>1 },
  "condition"       => proc { !has_item(:CAPACITY8) && (!has_item(:STORAGE8)) },
  "research_item"   => :RAWDATA
})

MenuHandlers.add(:recipe, :CAPACITY9, {
  "name"            => _INTL("Capacity Module"),
  "items"           => { :SYLVENSTONES => 100, :SANDSTONE => 100, :PIECEOFIRON => 100 },
  "yield"           => { :CAPACITY9=>1 },
  "condition"       => proc { !has_item(:CAPACITY9) && (!has_item(:STORAGE9)) },
  "research_item"   => :PIECEOFIRON
})

# Storage Capacity Upgrades

MenuHandlers.add(:recipe, :STORAGE1, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY1 => 1, :LUMINAR => 20, :FERRICIODIDE => 10, :SYLVENSTONES => 20 },
  "yield"           => { :STORAGE1=>1 },
  "condition"       => proc { !has_item(:STORAGE1) },
  "research_item"   => :LUMINAR
})

MenuHandlers.add(:recipe, :STORAGE2, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY2 => 1, :SILICATESHARD => 20, :SILICATECRYSTAL => 10, :SANDSTONE => 15 },
  "yield"           => { :STORAGE2=>1 },
  "condition"       => proc { !has_item(:STORAGE2) },
  "research_item"   => :SANDSTONE
})

MenuHandlers.add(:recipe, :STORAGE3, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY3 => 1, :COPPERNUGGET => 20, :MOLTENMETAL => 15, :GOLDHAIR => 10 },
  "yield"           => { :STORAGE3=>1 },
  "condition"       => proc { !has_item(:STORAGE3) },
  "research_item"   => :MOLTENMETAL
})

MenuHandlers.add(:recipe, :STORAGE4, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY4 => 1, :MUSHROOMCAP => 25, :WATER => 20, :NEBULASPORES => 10 },
  "yield"           => { :STORAGE4=>1 },
  "condition"       => proc { !has_item(:STORAGE4) },
  "research_item"   => :WATER
})

MenuHandlers.add(:recipe, :STORAGE5, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY5 => 1, :CHROME => 25, :MUON => 20, :DATASTRAND => 15 },
  "yield"           => { :STORAGE5=>1 },
  "condition"       => proc { !has_item(:STORAGE5) },
  "research_item"   => :MUON
})

MenuHandlers.add(:recipe, :STORAGE6, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY6 => 1, :PLATINUMINGOT => 20, :NEBULASPORES => 5 },
  "yield"           => { :STORAGE6=>1 },
  "condition"       => proc { !has_item(:STORAGE6) },
  "research_item"   => :PLATINUMINGOT
})

MenuHandlers.add(:recipe, :STORAGE7, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY7 => 1, :FERRICIODIDE => 100 },
  "yield"           => { :STORAGE7=>1 },
  "condition"       => proc { !has_item(:STORAGE7) },
  "research_item"   => :MOONSTONE
})

MenuHandlers.add(:recipe, :STORAGE8, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY8 => 1, :DATASTRAND => 20, :RAWDATA => 10, :WATER => 200 },
  "yield"           => { :STORAGE8=>1 },
  "condition"       => proc { !has_item(:STORAGE8) },
  "research_item"   => :RAWDATA
})

MenuHandlers.add(:recipe, :STORAGE9, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :CAPACITY9 => 1, :COARSESAND => 500, :MUSHROOMCAP => 100, :CHROME => 100 },
  "yield"           => { :STORAGE9=>1 },
  "condition"       => proc { !has_item(:STORAGE9) },
  "research_item"   => :PIECEOFIRON
})

MenuHandlers.add(:recipe, :STORAGE10, {
  "name"            => _INTL("Storage Module"),
  "items"           => { :TWINE => 999 },
  "yield"           => { :STORAGE10=>1 },
  "condition"       => proc { !has_item(:STORAGE10) },
  "research_item"   => :MOLTENMETAL
})