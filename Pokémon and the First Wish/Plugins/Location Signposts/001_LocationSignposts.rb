################################################################################
# Location signpost - updated by:
# - LostSoulsDev / carmaniac
# - PurpleZaffre
# - Golisopod User
# Please give credits when using this.
################################################################################

class LocationWindow
  def initialize(name)
    @sprites = {}
    @baseColor=Color.new(255,255,255)
    @shadowColor=MessageConfig::LIGHT_TEXT_SHADOW_COLOR
    @sprites["Image"] = Sprite.new
    mapname = name
    if pbResolveBitmap("Graphics/Maps/#{mapname}")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/#{mapname}")
    elsif $game_map.name.include?("Route") || $game_map.name.include?("Path") || $game_map.name.include?("Meadows") || $game_map.name.include?("Hills")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Route_1")
    elsif $game_map.name.include?("Town") || $game_map.name.include?("Village") || $game_map.name.include?("Settlement")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Town_1")
    elsif $game_map.name.include?("Lake")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Lake_1")
    elsif $game_map.name.include?("Cave")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Cave_1")
    elsif $game_map.name.include?("City")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/City_1")
    else
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Blank")
    end
    @sprites["Image"].x = 8
    @sprites["Image"].y = - @sprites["Image"].bitmap.height
    @sprites["Image"].z = 99990
    @sprites["Image"].opacity = 255
    @height = @sprites["Image"].bitmap.height
    pbSetSystemFont(@sprites["Image"].bitmap)
    pbDrawTextPositions(@sprites["Image"].bitmap,[[name,26,@sprites["Image"].bitmap.height-38,0,@baseColor,@shadowColor,true]])
    @currentmap = $game_map.map_id
    @frames = 0
  end

  def dispose
    @sprites["Image"].dispose
  end

  def disposed?
    return @sprites["Image"].disposed?
  end

  def update
    return if @sprites["Image"].disposed?
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      @sprites["Image"].dispose
      return
    elsif @frames > 140
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height)/18)
      @sprites["Image"].dispose if @sprites["Image"].y + @height < 6
    elsif $game_temp.in_menu == true
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height)/10)
      @sprites["Image"].dispose if @sprites["Image"].y + @height < 6
    else
      @sprites["Image"].y+= ((@sprites["Image"].bitmap.height)/18) if @sprites["Image"].y < 6
    end
    @frames += 1
  end
end