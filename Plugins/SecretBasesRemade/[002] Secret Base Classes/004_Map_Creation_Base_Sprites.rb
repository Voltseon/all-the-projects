class SecretBaseSprite
  def initialize(event, map, viewport = nil)
    @event          = event
    @map            = map
    @sprite         = IconSprite.new(0, 0, viewport)
    @disposed       = false
    @sprite.ox      = 16
    @sprite.oy      = 32
    @event.name[/SecretBase\((\w+)\)/]
    @base_id  = $~[1].to_sym
    @base_template  = GameData::SecretBase.get(@base_id).map_template
    @active_base    = SecretBaseMethods.is_active_secret_base?(@base_id) || $PokemonMap.current_base_id == @base_id
    update_graphic
  end

  def dispose
    @sprite.dispose
    @map      = nil
    @event    = nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def update_graphic
    char_name=GameData::SecretBaseTemplate.get(@base_template).type
    if @active_base
      @sprite.setBitmap("Graphics/Pictures/SecretBases/tile_#{char_name}")
      @sprite.visible=true
    else
      filename="Graphics/Pictures/SecretBases/closed_#{char_name}"
      if pbResolveBitmap(filename)
        @sprite.setBitmap(filename)
        @sprite.visible=true
      else
        @sprite.setBitmap("")
        @sprite.visible=false
      end
    end
  end

  def update
    return if !@sprite || !@event
    new_active = SecretBaseMethods.is_active_secret_base?(@base_id) || $PokemonMap.current_base_id == @base_id
    if new_active != @active_base
      @active_base = new_active
      update_graphic
    end
    @sprite.update
    @sprite.x      = ScreenPosHelper.pbScreenX(@event)
    @sprite.y      = ScreenPosHelper.pbScreenY(@event)
    @sprite.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    @sprite.zoom_y = @sprite.zoom_x
    pbDayNightTint(@sprite)
  end
end

class SecretBasePCSprite
  def initialize(event, map, viewport = nil)
    @event          = event
    @map            = map
    @disposed       = false
    @base_id        = $PokemonMap.current_base_id
    @active_base    = SecretBaseMethods.is_active_secret_base?(@base_id)
    update_graphic
  end

  def dispose
    @map      = nil
    @event    = nil
    @disposed = true
  end

  def disposed?
    return @disposed
  end

  def update_graphic
    if @active_base
      filename = SecretBaseSettings::SECRET_BASE_PC_FILENAME
      if pbResolveBitmap("Graphics/Characters/" + filename)
        @event.character_name = filename
      else
        @event.character_name = "Object ball"
      end
    else
      @event.character_name = ""
    end
  end

  def update
    return if !@sprite || !@event
    @base_id = $PokemonMap.current_base_id unless @base_id
    new_active = SecretBaseMethods.is_active_secret_base?(@base_id)
    if new_active != @active_base
      @active_base = new_active
      update_graphic
    end
    pbDayNightTint(@sprite)
  end
end

module SecretBaseMethods
  def self.load_baseline_map(base_location, template_data,map)
    template_map = load_data(sprintf("Data/Map%03d.rxdata", template_data.map_id))
    map.width = template_map.width
    map.height = template_map.height
    map.data = template_map.data
    map.events = {}
    # create Door
    event=RPG::Event.new(template_data.door_location[0],template_data.door_location[1])
    key_id = (map.events.keys.max || 0) + 1
    event.name = "Door"
    event.id = key_id 
    event.pages[0].trigger = 1 # Player Touch
    list = event.pages[0].list
    # We have to create a warp event with only code now.
    # not too bad, just a warp
    Compiler::push_event(list, 250, [RPG::AudioFile.new("Door exit",80,100)])   # Play SE
    Compiler::push_event(list, 223, [Tone.new(-255,-255,-255,0),6])   # Change Screen Tone
    Compiler::push_event(list, 106, [8])   # Wait
    Compiler::push_event(list, 201, [0,base_location[0],base_location[1],base_location[2],2,1])   # Transfer Player
    Compiler::push_event(list, 223, [Tone.new(0,0,0,0),6])   # Change Screen Tone
    Compiler::push_end(list)
    map.events[key_id] = event
    # Finished making Door
    # Create PC
    event=RPG::Event.new(template_data.pc_location[0],template_data.pc_location[1])
    key_id = (map.events.keys.max || 0) + 1
    event.name = "SecretPC"
    event.id = key_id
    Compiler::push_script(event.pages[0].list,"pbSecretBasePC")
    Compiler::push_end(event.pages[0].list)
    map.events[key_id] = event
    # Finished making PC
    # Create Owner would go here.
  end
  
  def self.place_decorations(base, map)
    event_map = load_data(sprintf("Data/Map%03d.rxdata", SecretBaseSettings::SECRET_BASE_DECOR_MAP))
    base.decorations.each do |decor|
      next unless decor
      item_data = GameData::SecretBaseDecoration.get(decor[0])
      event_id = item_data.event_id
      x = decor[1]
      y = decor[2]
      if event_id
        event = RPG::Event.new(x, y)
        key_id = (map.events.keys.max || 0) + 1
        event.id = key_id
        to_copy = event_map.events[event_id]
        event.name = to_copy.name
        to_copy.pages.each_with_index do |page,idx|
          event.pages[idx] = Marshal.load(Marshal.dump(page))
        end
        map.events[key_id] = event
      end
      tile_offset = item_data.tile_offset
      if tile_offset
        width,height = item_data.tile_size
        layer = item_data.get_layer
        (0...height).reverse_each do |h|
          (0...width).reverse_each do |w|
            tile_id = tile_offset + w + (h*8) + 384
            map.data[x+w-width+1,y+h-height+1,layer] = tile_id
          end
        end
      end
    end
  end
  
  def self.create_exterior_event(key_id, x, y, base_id)
    event = RPG::Event.new(x,y)
    # name the event after the base id to make it easier to pick the right secret base entrance
    event.name = sprintf("SecretBase(%s)",base_id)
    event.id = key_id 
    event.pages[0].trigger = 1 # Player Touch
    # First page is the warp caller.
    Compiler::push_script(event.pages[0].list,sprintf("pbSecretBase(:%s)",base_id))
    Compiler::push_end(event.pages[0].list)
    # second page is the exit from base, where it does the steppy off.
    # create new page
    event.pages[1] = RPG::Event::Page.new
    event.pages[1].trigger = 3 # Autorun
    event.pages[1].condition.switch1_valid = true
    event.pages[1].condition.switch1_id = 22 # should be 's:tsOff?("A")'
    list = event.pages[1].list
    # Semi-copied from the Compiler
    Compiler::push_branch(list, "get_self.onEvent?")   # Conditional Branch
    Compiler::push_script(list, "Followers.hide_followers", 1)
    Compiler::push_move_route_and_wait(list, -1, [PBMoveRoute::ThroughOn,
                                                  PBMoveRoute::Down,
                                                  PBMoveRoute::ThroughOff], 1)   # Move Route for player exiting warp
    Compiler::push_event(list, 210, [], 1)   # Wait for Move's Completion
    Compiler::push_script(list, "Followers.put_followers_on_player", 1)
    Compiler::push_branch_end(list, 1)
    Compiler::push_script(list, "setTempSwitchOn(\"A\")")
    Compiler::push_end(list)
    return event
  end
end


EventHandlers.add(:on_game_map_setup, :secret_base,
  proc { |map_id, map, _tileset_data|
    next if !$player # player needs to exists to set up the secret base list.
    if map_id==SecretBaseSettings::SECRET_BASE_MAP
      base_id = $PokemonMap.current_base_id
      base_data = GameData::SecretBase.get($PokemonMap.current_base_id)
      template_data = GameData::SecretBaseTemplate.get(base_data.map_template)
      # on the secret base map, load from template, then find the secret base to load the decor.
      SecretBaseMethods.load_baseline_map(base_data.location, template_data, map)
      base = SecretBaseMethods.get_base_from_id(base_id)
      if base
        SecretBaseMethods.place_decorations(base, map)
      end
    else
      # we need to load the environment and create events for bases.
      GameData::SecretBase.each do |base|
        # this base isn't defined for this map
        next if base.location[0]!=map_id
        key_id = (map.events.keys.max || 0) + 1
        event=SecretBaseMethods.create_exterior_event(key_id,base.location[1],base.location[2], base.id)
        map.events[key_id] = event
      end
    end
  }
)

EventHandlers.add(:on_new_spriteset_map, :add_secret_base_exit_graphics,
  proc { |spriteset, viewport|
    map = spriteset.map
    map.events.each do |event|
      next if !event[1].name[/SecretBase\(\w+\)/i]
      spriteset.addUserSprite(SecretBaseSprite.new(event[1], map, viewport))
    end
  }
)

EventHandlers.add(:on_new_spriteset_map, :add_secret_base_pc_graphics,
  proc { |spriteset, viewport|
    map = spriteset.map
    next unless map.map_id == SecretBaseSettings::SECRET_BASE_MAP
    map.events.each do |event|
      next if !event[1].name[/SecretPC/i]
      spriteset.addUserSprite(SecretBasePCSprite.new(event[1], map, viewport))
    end
  }
)
