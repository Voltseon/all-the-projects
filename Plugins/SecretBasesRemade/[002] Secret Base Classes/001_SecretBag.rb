#===============================================================================
# The Bag object, which actually contains all the Decorations.
# Decorations are stored differently than regular items.
# A slot contains 2 things: [decor, placement index].
# This is in contrast to items which store [item, quantity]
# The placement index is the index in the Secret base array, or -1 if not placed.
#===============================================================================
class SecretBag

  def self.pocket_names
    return SecretBaseSettings.secret_bag_pocket_names
  end

  def self.pocket_count
    return self.pocket_names.length
  end

  def initialize
    @pockets              = []
    (0..SecretBag.pocket_count).each { |i| @pockets[i] = [] }
  end

  def clear
    @pockets.each { |pocket| pocket.clear }
  end

  def pockets
    return @pockets
  end

  #=============================================================================
  # You can use these ones if you need to.
  
  def has?(item)
    item_data = GameData::SecretBaseDecoration.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    return @pockets[pocket].any? {|i| i[0]==item}
  end
  
  def can_add?(item)
    item_data = GameData::SecretBaseDecoration.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    max_size = max_pocket_size(pocket)
    return true if max_size < 0   # Infinite size
    return @pockets[pocket][max_size - 1].nil?
  end

  
  def add(item)
    item_data = GameData::SecretBaseDecoration.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    max_size = max_pocket_size(pocket)
    max_size = @pockets[pocket].length + 1 if max_size < 0   # Infinite size
    return false if max_size >=0 && @pockets[pocket][max_size]
    @pockets[pocket][max_size - 1]=[item,-1]
    @pockets[pocket].compact!
    return true
  end
  
  def can_remove?(item)
    item_data = GameData::SecretBaseDecoration.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    return @pockets[pocket].any? {|i| i[0]==item && i[1]<0}
  end
  
  def remove(item)
    item_data = GameData::SecretBaseDecoration.try_get(item)
    return false if !item_data
    pocket = item_data.pocket
    ret = false
    @pockets[pocket].each_with_index do |i, idx|
      next if i[0]!=item || i[1]>=0
      @pockets[pocket][idx]=nil
      ret = true
      break
    end
    @pockets[pocket].compact!
    return ret
  end
 #=============================================================================
 # These are internal methods.
  def place_index(pocket, item_index, decor_index)
    @pockets[pocket][item_index][1] = decor_index
  end
  
  def is_placed?(pocket, item_index)
    return @pockets[pocket][item_index][1]>=0
  end
  
  def unplace_all
    @pockets.each do |pocket|
      pocket.each do |item|
        item[1] = -1
      end
    end
  end
  
  def remove_at_index(pocket, item_index)
    return false if is_placed?(pocket, item_index)
    ret = false
    if @pockets[pocket][item_index]
      @pockets[pocket][item_index] = nil
      ret = true
    end
    @pockets[pocket].compact!
    return ret
  end
  
  def unplace_at_decor_index(decor_index)
    @pockets.each do |pocket|
      pocket.each do |item|
        next if item[1] != decor_index
        item[1] = -1
      end
    end
  end
  #=============================================================================

  def max_pocket_size(pocket)
    return SecretBaseSettings::SECRET_BAG_MAX_POCKET_SIZE[pocket - 1] || -1
  end
  
  def current_pocket_size(pocket)
    @pockets[pocket].compact!
    return @pockets[pocket].length
  end
  #=============================================================================
  def sort_pocket(pocket)
    @pockets[pocket].sort! {|a,b| (a[0] == b[0]) ? b[1]<=>a[1] : a[0]<=>b[0] }
  end
  
  def sort_all_pockets
    (1..SecretBag.pocket_count).each do |i|
      sort_pocket(i)
    end
  end
end

def pbReceiveDecoration(item)
  item = GameData::SecretBaseDecoration.get(item)
  return false if !item
  itemname = item.name
  meName = "Item get"
  if itemname.starts_with_vowel?
    pbMessage(_INTL("\\me[{1}]You obtained an \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
  else
    pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", meName, itemname))
  end
  if $secret_bag.add(item)   # If item can be added
    pbMessage(_INTL("You put the {1} in\\nyour PC at home.", itemname))
    return true
  end
  return false   # Can't add the item
end

SaveData.register(:secret_bag) do
  ensure_class :SecretBag
  save_value { $secret_bag }
  load_value { |value| $secret_bag = value }
  new_game_value { SecretBag.new }
end