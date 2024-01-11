module GameData
  class SecretBaseDecoration
    attr_reader :id
    attr_reader :real_name
    attr_reader :pocket
    attr_reader :price
    attr_reader :sell_price
    attr_reader :real_description
    attr_reader :tile_offset
    attr_reader :tile_size
    attr_reader :permission
    attr_reader :event_id

    DATA = {}
    DATA_FILENAME = "secret_decorations.dat"

    extend ClassMethodsSymbols
    include InstanceMethods

    SCHEMA = {
      "Name"         => [:name,        "s"],
      "Pocket"       => [:pocket,      "v"],
      "Price"        => [:price,       "u"],
      "SellPrice"    => [:sell_price,  "u"],
      "Description"  => [:description, "q"],
      "TileOffset"   => [:tile_offset, "u"],
      "TileSize"     => [:tile_size,  "vv"],
      "PlacingPerms" => [:permission, "e", {"Floor" => :floor,"floor" => :floor,
                                            "Wall" => :wall,"wall" => :wall,
                                            "Decor" => :decor,"decor" => :decor,
                                            "Board" => :board,"board" => :board}],
      "EventID"      => [:event_id, "u"]
    }

    def initialize(hash)
      @id               = hash[:id]
      @real_name        = hash[:name]        || "Unnamed"
      @pocket           = hash[:pocket]      || 1
      @price            = hash[:price]       || 0
      @sell_price       = hash[:sell_price]  || (@price / 2)
      @real_description = hash[:description] || "???"
      @tile_offset      = hash[:tile_offset]
      @tile_size        = hash[:tile_size]   || [1,1]
      @permission       = hash[:permission]  || :floor
      @event_id         = hash[:event_id]
    end
    
    # @return [String] the translated name of this item
    def name
      return pbGetMessageFromHash(MessageTypes::SecretBaseDecorations, @real_name)
    end
    
    # @return [String] the translated description of this item
    def description
      return pbGetMessageFromHash(MessageTypes::SecretBaseDecorationDescriptions, @real_description)
    end
    
    def is_floor?;              return @permission == :floor; end
    def is_wall?;               return @permission == :wall;  end
    def is_decor?;              return @permission == :decor; end
    def is_board?;              return @permission == :board; end
    
    def get_layer
      return 2 if is_decor? || is_board?
      return 1
    end
    
    def self.icon_filename(item)
      return "Graphics/Items/back" if item.nil?
      item_data = self.try_get(item)
      return "Graphics/Items/000" if item_data.nil?
      # Check for files
      ret = sprintf("Graphics/Pictures/SecretBases/Icons/%s", item_data.id)
      return ret if pbResolveBitmap(ret)
      return "Graphics/Items/000"
    end
  end
end