EventHandlers.add(:on_leave_map, :cleanup_minimap,
  proc {
    $game_temp.minimap.pbEndScene if $game_temp.minimap
    $game_temp.minimap = nil
  }
)

EventHandlers.add(:on_enter_map, :create_minimap,
  proc {
    $game_temp.minimap.pbEndScene if $game_temp.minimap
    next unless pbResolveBitmap(Minimap::PATH + $game_map.map_id.to_s)
    $game_temp.minimap = Minimap.new
    $game_temp.minimap.pbStartScene
  }
)

EventHandlers.add(:on_leave_tile, :hide_minimap,
  proc { |event, map, oldX, oldY|
    next if !$game_temp.minimap
    #$game_temp.minimap.visible = false
  }
)

class Minimap
  attr_reader :visible
  
  PATH = "Graphics/Pictures/Minimap/"

  def initialize
    @visible = true
    @timer = 0
    @sprites = {}
    @item_events = []
    @viewport = Viewport.new(572, 8, 220, 220)
    @viewport.z = 99999
    @viewport2 = Viewport.new(592, 28, 180, 180)
    @viewport2.z = 99998
  end

  def pbStartScene
    return if !$game_map || !$game_player
    return unless pbResolveBitmap(PATH + $game_map.map_id.to_s)
    @sprites["frame"] = Sprite.new(@viewport)
    @sprites["frame"].bitmap = Bitmap.new(PATH + "frame")
    @sprites["player"] = ChangelingSprite.new(108, 108, @viewport)
    4.times do |i|
      dir = (i+1)*2
      @sprites["player"].addBitmap(dir, PATH + "player_#{dir}")
    end
    @sprites["player"].changeBitmap($game_player.direction)
    @sprites["background"] = Sprite.new(@viewport2)
    @sprites["background"].bitmap = Bitmap.new(PATH + "background")
    @sprites["map"] = Sprite.new(@viewport2)
    @sprites["map"].bitmap = Bitmap.new(PATH + $game_map.map_id.to_s)
    @max_x = $game_map.width.to_f * Game_Map::REAL_RES_X.to_f
    @max_y = $game_map.height.to_f * Game_Map::REAL_RES_Y.to_f
    @scale_x = $game_map.width.to_f / @sprites["map"].bitmap.width.to_f
    @scale_y = $game_map.height.to_f / @sprites["map"].bitmap.height.to_f
    $game_map.events.each_value do |event|
      next unless event.name[/RandomItem/i]
      next if event.erased || event.character_name == ""
      @sprites["item_#{event.id}"] = Sprite.new(@viewport2)
      @sprites["item_#{event.id}"].bitmap = Bitmap.new(PATH + "item")
      @item_events.push(event)
    end
    @sprites["foreground"] = Sprite.new(@viewport2)
    @sprites["foreground"].bitmap = Bitmap.new(PATH + "foreground")
  end

  def pbUpdate
    return if !$game_map || !$game_player
    return unless @sprites["player"]
    if @visible
      @sprites["player"].changeBitmap($game_player.direction)
      @sprites["map"].x = -$game_player.real_x/@max_x * @sprites["map"].bitmap.width + 90
      @sprites["map"].y = -$game_player.real_y/@max_y * @sprites["map"].bitmap.height + 90
      @item_events.each do |event|
        @sprites["item_#{event.id}"].x = event.x/@scale_x + @sprites["map"].x - 2
        @sprites["item_#{event.id}"].y = event.y/@scale_y + @sprites["map"].y - 2
        next unless event.erased || event.character_name == ""
        @sprites["item_#{event.id}"].dispose
        @sprites.delete("item_#{event.id}")
        @item_events.delete(event)
      end
      pbUpdateSpriteHash(@sprites)
    else
      @timer += 1
      if @timer >= 20 && !$game_player.moving? && !$game_player.jumping? && !pbMapInterpreterRunning? && !$game_temp.message_window_showing && !$game_temp.in_menu
        @timer = 0
        self.visible = true
      end
    end
  end

  def visible=(value)
    @visible = value
    @sprites.each_value { |sprite| sprite.visible = value }
    if !value
      @timer = 0
    end
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    @viewport2.dispose
  end
end