class SecretBase
  # @return [Integer] the ID of the base
  attr_accessor :id
  # @return [Owner] this Secret Base's owner
  attr_reader :owner
  # @return [Array<Array<Symbol,Integer,Integer>>] the placed decorations in this secret base,
  #   where every element is [decoration ID, X position, Y position]
  # The X and Y positions are relative to the bottom right corner.
  attr_reader :decorations
  # @return [Integer] the number of bases received in record mixing
  attr_accessor :bases_received_count
  # @return [Integer] the registry status of a base, for record mixing
  attr_accessor :registry_status
  
  UNREGISTERED = 0
  REGISTERED = 1
  NEW = 2
  
  def initialize(id, owner)
    @id = id
    @owner = Owner.new_from_trainer(owner)
    @decorations = Array.new(SecretBaseSettings::SECRET_BASE_MAX_DECORATIONS)
    @bases_received_count = 0
    @registry_status = UNREGISTERED
  end
  
  def get_free_decoration_slot
    return @decorations.find_index(nil)
  end
  
  def can_add_decoration?
    return !(get_free_decoration_slot.nil?)
  end
  
  # validation for room should have already been done before hand.
  def add_decoration(decor, x, y)
    slot = get_free_decoration_slot
    return -1 unless slot
    @decorations[slot]=[decor,x,y]
    return slot
  end
  
  # returns [Array<Integer>] all decorations indices at this spot.
  # returns an empty array if nothing is in this spot.
  def find_decorations_at(x, y)
    ret = -1
    rets = []
    is_mat = false
    terrain_tags = $data_tilesets[SecretBaseSettings::SECRET_BASE_TILESET].terrain_tags
    2.times do |check|
      break if ret>=0
      @decorations.each_with_index do |d, idx|
        next unless d
        item_data = GameData::SecretBaseDecoration.get(d[0])
        # We prioritize :decor type decorations on the first loop
        # This is so we remove them first before grabbing mats or desks
        # that may be below them.
        next if check==0 && item_data.permission != :decor
        # find decorations that overlaps this spot.
        width,height = item_data.tile_size
        tile_offset = item_data.tile_offset
        tmp_mat=false
        (0...height).reverse_each do |h|
          (0...width).reverse_each do |w|
            if tile_offset
              terrain = GameData::TerrainTag.try_get(terrain_tags[tile_offset+w+(h*8)+384])
              tmp_mat|=(terrain.id==SecretBaseSettings::SECRET_BASE_DECOR_FLOOR_TAG)
            end
            if d[1]+w-width+1 == x && d[2]+h-height+1 == y
              ret = idx
              break unless tile_offset
            end
            # intentionally keep looping if this is a tileset decor, in case this is a stacked decor with only a few valid spaces
          end
          break unless tile_offset
        end
        if ret>=0
          rets.push(ret)
          is_mat = tmp_mat
          break
        end
      end
    end
    if is_mat
      item, decor_x,decor_y = @decorations[ret]
      item_data = GameData::SecretBaseDecoration.get(item)
      width,height = item_data.tile_size
      # Temporarily hide this decoration so we don't re-find it.
      @decorations[ret] = nil
      (0...height).reverse_each do |h|
        (0...width).reverse_each do |w|
          rets.push(find_decorations_at(decor_x+w-width+1,decor_y+h-height+1))
        end
      end
      # Re-add decoration to the array
      @decorations[ret] = [item,decor_x,decor_y]
    end
    rets.flatten!
    return rets
  end
  
  # @param id [Array<Integer>] an array of decoration indices
  # Does not impact the SecretBag
  def remove_decorations(arr)
    arr.each do |i|
      @decorations[i] = nil
    end
  end
end


class SecretBase
  class Owner
    # @return [Integer] the ID of the owner
    attr_reader :id
    # @return [String] the name of the owner
    attr_reader :name
    # @return [Symbol] the trainer type of the owner
    attr_reader :trainer_type
    # @return [Integer] the language of the owner (see pbGetLanguage for language IDs)
    attr_reader :language

    # @param id [Integer] the ID of the owner
    # @param name [String] the name of the owner
    # @param trainer_type [Symbol] the trainer type of the owner
    # @param language [Integer] the language of the owner (see pbGetLanguage for language IDs)
    def initialize(id, name, trainer_type, language)
      validate id => Integer, name => String, trainer_type => Symbol, language => Integer
      @id = id
      @name = name
      @trainer_type = trainer_type
      @language = language
    end

    # Returns a new Owner object populated with values taken from +trainer+.
    # @param trainer [Player, NPCTrainer] trainer object to read data from
    # @return [Owner] new Owner object
    def self.new_from_trainer(trainer)
      validate trainer => [Player, NPCTrainer]
      return new(trainer.id, trainer.name, trainer.trainer_type, trainer.language)
    end
    
    # @return [Integer] the public portion of the owner's ID
    def public_id
      return @id & 0xFFFF
    end
  end
end