# This surprisingly isn't a default method?
def pbTopRight(window)
  window.x = Graphics.width - window.width
  window.y = 0
end

def pbDecorationMenu
  player_base = $PokemonGlobal.secret_base_list[0]
  command = 0
  loop do
    command = pbShowCommandsWithHelp(nil,
         [_INTL("Decorate"),
          _INTL("Put Away"),
          _INTL("Toss"),
          _INTL("Cancel")],
         [_INTL("Put out the selected decoration item."),
          _INTL("Store the chosen decoration in the PC."),
          _INTL("Throw away unwanted decorations."),
          _INTL("Go back to the previous menu.")], -1, command)
    case command
    when 0 
      scene = SecretBag_Scene.new
      screen = SecretBagScreen.new(scene,$secret_bag)
      screen.pbDecorate(player_base)
    when 1
      scene = PlaceDecoration_Scene.new
      scene.pbStartScene($secret_bag,nil,player_base)
      scene.pbSelectTile
      scene.pbEndScene
    when 2
      scene = SecretBag_Scene.new
      screen = SecretBagScreen.new(scene,$secret_bag)
      screen.pbTossItems
    else
      break
    end
  end
end

class Window_BasePocketsList < Window_DrawableCommand
  attr_reader :bag

  def initialize(bag, x, y, width, height)
    @bag = bag
    super(x, y, width, height)
  end
  
  def itemCount
    return SecretBag.pocket_count + 1
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    textpos = []
    if index == SecretBag.pocket_count
      textpos.push([_INTL("CANCEL"), rect.x, rect.y, false, self.baseColor, self.shadowColor])
    else
      itemname = SecretBag.pocket_names[index]
      textpos.push([itemname, rect.x, rect.y, false, self.baseColor, self.shadowColor])
      if @bag.max_pocket_size(index + 1) > 0
        qty = _ISPRINTF("{1: 2d}/{2: 2d}", @bag.current_pocket_size(index + 1),@bag.max_pocket_size(index + 1))
      else
        qty = _ISPRINTF("{1: 2d}", @bag.current_pocket_size(index + 1))
      end
      sizeQty = self.contents.text_size(qty).width
      xQty = rect.x + rect.width - sizeQty - 2
      textpos.push([qty, xQty, rect.y, false, self.baseColor, self.shadowColor])
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

class Window_BaseDecorationsList < Window_DrawableCommand
  attr_reader :bag

  def initialize(bag, pocket, x, y, width, height)
    @bag = bag
    @pocket = pocket
    @itemUsing=AnimatedBitmap.new("Graphics/Pictures/SecretBases/secretBaseUsing")
    super(x, y, width, height)
  end
  
  def pocket=(value)
    @pocket = value
    @bag.sort_pocket(@pocket)
    self.index = 0
    self.refresh
  end
  
  def item
    return self.index==itemCount-1 ? nil : @bag.pockets[@pocket][self.index][0]
  end
  
  def itemCount
    return @bag.pockets[@pocket].length + 1
  end

  def drawItem(index, _count, rect)
    rect = drawCursor(index, rect)
    textpos = []
    if index == @bag.pockets[@pocket].length
      textpos.push([_INTL("CANCEL"), rect.x, rect.y, false, self.baseColor, self.shadowColor])
    else
      item = @bag.pockets[@pocket][index][0]
      itemname = GameData::SecretBaseDecoration.get(item).name
      textpos.push([itemname, rect.x, rect.y, false, self.baseColor, self.shadowColor])
      if @bag.is_placed?(@pocket, index)
        pbCopyBitmap(self.contents,@itemUsing.bitmap,rect.width-16,rect.y+6)
      end
    end
    pbDrawTextPositions(self.contents, textpos)
  end
end

class SecretBag_Scene
  def pbUpdate; pbUpdateSpriteHash(@sprites); end
  
  def pbStartScene(bag)
    @bag = bag
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["pocketlistwindow"] = Window_BasePocketsList.new(bag,0,0,Graphics.width/2,Graphics.height)
    @sprites["pocketlistwindow"].visible = false
    @sprites["pocketlistwindow"].viewport = @viewport
    @sprites["pocketlistwindow"].refresh
    @sprites["decorlistwindow"] = Window_BaseDecorationsList.new(bag,0,0,0,Graphics.width/2,Graphics.height)
    @sprites["decorlistwindow"].visible = false
    @sprites["decorlistwindow"].viewport = @viewport
    @sprites["decorlistwindow"].refresh
    @sprites["pocketwindow"] = Window_AdvancedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["pocketwindow"].visible = false
    @sprites["descwindow"] = Window_AdvancedTextPokemon.newWithSize("", 0, 0, 32, 32, @viewport)
    @sprites["descwindow"].visible = false
    @pocketstate = false
    @descstate = false
    pbSEPlay("GUI menu open")
  end

  def pbDisplay
    old_pocket_visible = @sprites["pocketlistwindow"].visible
    @sprites["pocketlistwindow"].visible = false
    old_decor_visible = @sprites["decorlistwindow"].visible
    @sprites["decorlistwindow"].visible = false
    @sprites["pocketwindow"].visible = false
    @sprites["descwindow"].visible = false
    pbUpdate
    begin
      yield if block_given?
    ensure
      @sprites["pocketlistwindow"].visible = old_pocket_visible
      @sprites["decorlistwindow"].visible = old_decor_visible
      @sprites["pocketwindow"].visible = @pocketstate
      @sprites["descwindow"].visible = @descstate
      pbUpdate
    end
  end

  def pbShowPocket(text)
    @sprites["pocketwindow"].resizeToFit(text, (Graphics.width/2)-8)
    @sprites["pocketwindow"].text    = text
    @sprites["pocketwindow"].visible = true
    @sprites["pocketwindow"].width = (Graphics.width/2)-8 if @sprites["pocketwindow"].width < (Graphics.width/2)-8
    pbTopRight(@sprites["pocketwindow"])
    @pocketstate = true
  end
  
  def pbHidePocket
    @sprites["pocketwindow"].visible = false
    @pocketstate = false
  end

  def pbShowDescription(text)
    @sprites["descwindow"].resizeToFit(text, (Graphics.width/2)-8)
    @sprites["descwindow"].text    = text
    @sprites["descwindow"].visible = true
    @sprites["descwindow"].width = (Graphics.width/2)-8 if @sprites["descwindow"].width < (Graphics.width/2)-8
    pbBottomRight(@sprites["descwindow"])
    @descstate = true
  end
  
  def pbHideDescription
    @sprites["descwindow"].visible = false
    @descstate = false
  end

  def pbChooseItem(continue_selection=false)
    pocketwindow = @sprites["pocketlistwindow"]
    decorwindow = @sprites["decorlistwindow"]
    unless continue_selection
      pocketwindow = @sprites["pocketlistwindow"]
      pocketwindow.visible = true
      decorwindow = @sprites["decorlistwindow"]
      decorwindow.visible = false
      pbHidePocket
      pbHideDescription
      sel_pocket = -1
    else
      sel_pocket = pocketwindow.index
    end
    loop do
      if sel_pocket<0
        pbActivateWindow(@sprites, "pocketlistwindow") {
          loop do
            Graphics.update
            Input.update
            pbUpdate
            if Input.trigger?(Input::BACK)   # Cancel the item screen
              pbPlayCursorSE
              sel_pocket = -1
              break
            elsif Input.trigger?(Input::USE)   # Choose selected item
              pbPlayCursorSE
              if pocketwindow.index == SecretBag.pocket_count
                sel_pocket = -1
                break
              elsif @bag.current_pocket_size(pocketwindow.index + 1)>0
                sel_pocket = pocketwindow.index
                break
              else
                pbDisplay { pbMessage(_INTL("There are no decorations.")) }
              end
            end
          end
        }
      end
      return [-1,-1] if sel_pocket < 0 || sel_pocket == SecretBag.pocket_count
      # Necessary for pocket shenanigans
      sel_pocket = sel_pocket + 1
      sel_item = (continue_selection) ? decorwindow.index : -1
      decorwindow.pocket = sel_pocket
      decorwindow.index = sel_item if sel_item>=0 && sel_item <= @bag.current_pocket_size(sel_pocket)
      pocketwindow.visible = false
      decorwindow.visible = true
      
      if @bag.max_pocket_size(sel_pocket) > 0
        pbShowPocket(_INTL("{1}<r>{2}/{3}",SecretBag.pocket_names[sel_pocket - 1],@bag.current_pocket_size(sel_pocket),@bag.max_pocket_size(sel_pocket)))
      else
        pbShowPocket(_INTL("{1}<r>{2}",SecretBag.pocket_names[sel_pocket - 1],@bag.current_pocket_size(sel_pocket)))
      end
      if decorwindow.item
        pbShowDescription(GameData::SecretBaseDecoration.get(decorwindow.item).description)
      else
        pbShowDescription(_INTL("Go back to the previous menu."))
      end
      pbActivateWindow(@sprites, "decorlistwindow") {
        loop do
          oldindex = decorwindow.index
          Graphics.update
          Input.update
          pbUpdate
          if oldindex != decorwindow.index
            if decorwindow.item
              pbShowDescription(GameData::SecretBaseDecoration.get(decorwindow.item).description)
            else
              pbShowDescription(_INTL("Go back to the previous menu."))
            end
          end
          if Input.trigger?(Input::BACK)   # Cancel the item screen
            pbPlayCursorSE
            sel_pocket = -1
            sel_item = -1
            break
          elsif Input.trigger?(Input::USE)   # Choose selected item
            pbPlayCursorSE
            sel_item = (decorwindow.item.nil?) ? -1 : decorwindow.index
            break
          end
        end
      }
      return [sel_pocket,sel_item] if sel_item>=0
      decorwindow.visible = false
      pbHidePocket
      pbHideDescription
      pocketwindow.visible = true
      pocketwindow.refresh
      sel_pocket = -1
    end
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @bag.sort_all_pockets
  end

  def pbRefresh; end
end

class SecretBagScreen
  def initialize(scene, bag)
    @bag   = bag
    @scene = scene
  end
  
  def pbChooseItem
    @scene.pbStartScene(@bag)
    item = @scene.pbChooseItem
    @scene.pbEndScene
    return item
  end
  
  def pbDecorate(base)
    @scene.pbStartScene(@bag)
    item = [-1,-1]
    firstloop = true
    loop do
      item = @scene.pbChooseItem(!firstloop)
      break if item[0]<0
      if @bag.is_placed?(item[0],item[1])
        @scene.pbDisplay { 
          pbMessage(_INTL("This is in use already."))
        }
      elsif !base.can_add_decoration?
        @scene.pbDisplay { 
            pbMessage(_INTL("No more decorations can be placed.\nThe most that can be placed is {1}.", SecretBaseSettings::SECRET_BASE_MAX_DECORATIONS))
          }
      else
        decor = @bag.pockets[item[0]][item[1]]
        @scene.pbDisplay {
          scene = PlaceDecoration_Scene.new
          scene.pbStartScene(@bag,decor,base)
          scene.pbSelectTile
          scene.pbEndScene
        }
      end
      firstloop = false
    end
    @scene.pbEndScene
  end
  
  def pbTossItems
    @scene.pbStartScene(@bag)
    item = [-1,-1]
    firstloop = true
    loop do
      item = @scene.pbChooseItem(!firstloop)
      break if item[0]<0
      if @bag.is_placed?(item[0],item[1])
        @scene.pbDisplay { 
          pbMessage(_INTL("This decoration is in use.\nIt can't be thrown away."))
        }
      else
        decor = @bag.pockets[item[0]][item[1]]
        decorname = GameData::SecretBaseDecoration.get(decor[0]).name
        @scene.pbDisplay { 
          if pbConfirmMessage(_INTL("This {1} will be discarded.\nIs this okay?",decorname))
            @bag.remove_at_index(item[0],item[1])
            pbMessage(_INTL("The decoration item was thrown away."))
          end
        }
      end
      firstloop = false
    end
    @scene.pbEndScene
  end
end

class PlaceDecoration_Scene
  def pbUpdate
    @frames+=1
    if @frames>=(Graphics.frame_rate*(3.0/8.0)) && @blink
      @frames = 0
      @sprites["cursor"].visible ^= true
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene(bag,item,base)
    $game_player.transparent = true
    pbUpdateSceneMap
    @bag = bag
    @item = item
    @base = base
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["cursor"] = Sprite.new(@viewport)
    if @item
      bitmap = get_decoration_bitmap
      @sprites["cursor"].bitmap = bitmap
      @sprites["cursor"].ox = bitmap.width-(Game_Map::TILE_WIDTH/2)
      @sprites["cursor"].oy = bitmap.height
    else
      @sprites["cursor"].bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/SecretBases/", "secretBaseDeleter")
      @sprites["cursor"].ox = @sprites["cursor"].bitmap.width/2
      @sprites["cursor"].oy = @sprites["cursor"].bitmap.height
      @width, @height = 1,1
    end
    @sprites["cursor"].x = $game_player.screen_x
    @sprites["cursor"].y = $game_player.screen_y
    @sprites["arrow"] = IconSprite.new(0,0,@viewport)
    @sprites["arrow"].setBitmap(sprintf("Graphics/Pictures/SecretBases/secretBaseArrow%d",$player.character_ID))
    @sprites["arrow"].x = @sprites["cursor"].x + Game_Map::TILE_WIDTH
    @sprites["arrow"].y = @sprites["cursor"].y - Game_Map::TILE_HEIGHT
    @cursor_x = $game_player.x
    @cursor_y = $game_player.y
    base_data = GameData::SecretBase.get(@base.id)
    @template_data = GameData::SecretBaseTemplate.get(base_data.map_template)
    @frames = 0
    @blink = true
  end
  
  def get_decoration_bitmap
    event_map = load_data(sprintf("Data/Map%03d.rxdata", SecretBaseSettings::SECRET_BASE_DECOR_MAP))
    tileset_name = $data_tilesets[event_map.tileset_id].tileset_name
    item_data = GameData::SecretBaseDecoration.get(@item[0])
    if item_data.event_id
      event = event_map.events[item_data.event_id]
      page_graphic = event.pages[0].graphic
      tile_id = page_graphic.tile_id
      character_name = event.pages[0].graphic.character_name
      character_hue = page_graphic.character_hue
      if tile_id>=384
        if event.name[/size\((\d+),(\d+)\)/i]
          @width = $~[1].to_i
          @height = $~[2].to_i
        else
          @width = 1
          @height = 1
        end
        return pbGetTileBitmap(tileset_name, tile_id,
                        character_hue, @width, @height)
      elsif character_name != ""
        charbitmap = AnimatedBitmap.new(
          "Graphics/Characters/" + character_name, character_hue
        )
        cw = charbitmap.width / 4
        ch = charbitmap.height / 4
        sx = page_graphic.pattern * cw
        sy = ((page_graphic.direction - 2) / 2) * ch
        ret = Bitmap.new(cw,ch)
        ret.blt(0, 0, charbitmap.bitmap, Rect.new(sx, sy, cw, ch))
        @width = cw/Game_Map::TILE_WIDTH
        @height = ch/Game_Map::TILE_HEIGHT
        return ret
      end
    end
    if item_data.tile_offset
      @width, @height = item_data.tile_size
      tile_offset = item_data.tile_offset + ((@height - 1)*8) + 384
      return pbGetTileBitmap(tileset_name, tile_offset, 0, @width, @height)
    end
    return RPG::Cache.load_bitmap("","")
  end
  
  def pbSelectTile
    map_left,map_top,map_right,map_bottom = @template_data.map_borders
    refresh_map = false
    loop do
      Graphics.update
      Input.update
      pbUpdate
      ox,oy = 0,0
      dir = Input.dir4
      case dir
      when 2
        oy = 1 if @cursor_y < map_bottom
      when 8
        oy = -1 if @cursor_y-@height+1 > map_top
      when 4
        ox = -1 if @cursor_x-@width+1 > map_left
      when 6
        ox = 1 if @cursor_x < map_right
      end
      if ox != 0 || oy != 0
        pbScrollMap(dir, 1, 5)
        @cursor_x += ox
        @cursor_y += oy
      end
      if Input.trigger?(Input::BACK)
        msg = (@item) ? _INTL("Cancel decorating?") : _INTL("Stop putting away decorations?")
        if pbConfirmMessage(msg) { pbUpdate }
          $game_player.center($game_player.x, $game_player.y)
          break
        end
      elsif Input.trigger?(Input::USE)
        ret = check_location
        break if ret
      end
    end
  end
  
  def check_location
    @blink = false
    @sprites["cursor"].visible = !@item.nil?
    if @item
      item_data = GameData::SecretBaseDecoration.get(@item[0])
      cant_place = false
      width,height = item_data.tile_size
      (0...height).reverse_each do |h|
        (0...width).reverse_each do |w|
          cant_place|=!can_place_here?(item_data,@cursor_x+w-width+1,@cursor_y+h-height+1)
        end
      end
      if cant_place
        pbMessage("It can't be placed here.") { pbUpdate }
      else
        if pbConfirmMessage(_INTL("Place it here?")) { pbUpdate }
          ret = true
          pbFadeOutIn(99999){
            player_x = $game_player.x
            player_y = $game_player.y
            player_dir = $game_player.direction
            @item[1] = @base.add_decoration(@item[0],@cursor_x,@cursor_y)
            $map_factory.setup($game_map.map_id)
            $game_player.center($game_player.x, $game_player.y)
            pbMapInterpreter.get_self&.turn_left
            $scene.disposeSpritesets
            RPG::Cache.clear
            $scene.createSpritesets
          }
        end
      end
    else
      decors = @base.find_decorations_at(@cursor_x,@cursor_y)
      if decors.length == 0
        pbMessage("There is no decoration item here.") { pbUpdate }
      else
        if pbConfirmMessage(_INTL("Return this decoration to the PC?")) { pbUpdate }
          pbFadeOutIn(99999){
            oldx = $game_map.display_x
            oldy = $game_map.display_y
            @base.remove_decorations(decors)
            decors.each {|d| @bag.unplace_at_decor_index(d) }
            $map_factory.setup($game_map.map_id)
            $game_player.center($game_player.x, $game_player.y)
            pbMapInterpreter.get_self&.turn_left
            $game_map.display_x = oldx
            $game_map.display_y = oldy
            $scene.disposeSpritesets
            RPG::Cache.clear
            $scene.createSpritesets
          }
        end
      end
    end
    @blink = true
    return ret
  end
  
  def can_place_here?(item_data,x,y)
    # No placing on the PC
    return false if @template_data.pc_location[0] == x && @template_data.pc_location[1] == y
    # No placing where the player is currently standing
    return false if $game_player.x == x && $game_player.y == y
    # No placing in front of the door
    return false if @template_data.door_location[0] == x && (@template_data.door_location[1]-1) == y
    terrain_tag = $game_map.terrain_tag(x, y).id
    # No placing on top of Layer 0 decorations
    return false if terrain_tag == SecretBaseSettings::SECRET_BASE_GROUND_DECOR_TAG
    # No placing on a wall if it doesn't have the wall tag
    return false if item_data.is_wall? && terrain_tag != SecretBaseSettings::SECRET_BASE_WALL_TAG
    passable = $game_map.passableStrict?(x, y, 0)
    is_hole = false
    SecretBaseSettings::SECRET_BASE_HOLES.each do |hole_data|
      tile_offset = hole_data[0]+384
      width=hole_data[1]
      height=hole_data[2]
      (0...height).each do |h|
        (0...width).each do |w|
          tile_id = tile_offset + w + (h*8)
          is_hole|=($game_map.data[x,y,1]==tile_id)
        end
      end
    end
    # Can only place boards on a hole
    return false if is_hole && !item_data.is_board?
    # Needs to be passable if it's a floor type decoration
    return false if item_data.is_floor? && !passable
    # Needs to be passable if it's a board type decoration and this is not a hole
    return false if item_data.is_board? && !is_hole && !passable
    is_mat = terrain_tag == SecretBaseSettings::SECRET_BASE_DECOR_FLOOR_TAG
    if item_data.is_decor?
      # Needs to be passable if it's a decor type decoration
      return false if SecretBaseSettings::SECRET_BASE_DECOR_ANYWHERE && !passable
      # Needs to be on a decor floor tag if it's a decor.
      return false if !is_mat
    end
    # Can't place if there's something already here, and it's not a hole (for boards) or a mat (for decor)
    if (item_data.is_decor? && !is_mat) && !is_hole
      return false if $game_map.data[x,y,1]>0
    end
    # Can't place if there's something already here
    return false if $game_map.data[x,y,2]>0
    return true
  end
  
  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    $game_player.transparent = false
    pbUpdateSceneMap
  end
end