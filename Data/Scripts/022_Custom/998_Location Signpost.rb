################################################################################
# Location signpost - updated by:
# - LostSoulsDev / carmaniac
# - PurpleZaffre
# - Golisopod User
# Please give credits when using this.
################################################################################

class Game_Temp
  attr_accessor :location_window_showing

  def location_window_showing
    @location_window_showing = false if !@location_window_showing
    return @location_window_showing
  end
end

class LocationWindow
  def initialize(name)
    $game_temp.location_window_showing = true
    @sprites = {}
    @baseColor=Color.new(232,248,248)
    #@shadowColor=Color.new(64,64,120)
    @sprites["Image"] = Sprite.new
    mapname = name
    if pbResolveBitmap("Graphics/Maps/#{mapname}")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/#{mapname}")
    elsif $game_map.name.include?("Upil") && !$game_switches[71]
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/CityTakenOver")
    elsif $PokemonGlobal.diving
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Underwater")
    elsif $game_map.name.include?("313") || $game_map.name.include?("314")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Snow")
    elsif $game_map.name.include?("Bulgart") || $game_map.name.include?("Upil")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/CitySnow")
    elsif $game_map.name.include?("306")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Sea")
    elsif $game_map.name.include?("Route")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Route")
    elsif $game_map.name.include?("Town") || $game_map.name.include?("Village") || $game_map.name.include?("League")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Town")
    elsif $game_map.name.include?("Cave") || $game_map.name.include?("Mt.")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Cave")
    elsif $game_map.name.include?("City") || $game_map.name.include?("Battle")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/City")
    elsif $game_map.name.include?("Woods") || $game_map.name.include?("Forest")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Forest")
    elsif $game_map.name.include?("Bronze")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Bronze")
    elsif $game_map.name.include?("Silver")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Silver")
    elsif $game_map.name.include?("Gold")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Gold")
    else
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Blank")
    end
    @shadowColor=@sprites["Image"].bitmap.get_pixel(172,71)
    @sprites["Image"].x = 4
    @sprites["Image"].y = - @sprites["Image"].bitmap.height
    @sprites["Image"].z = 99990
    @sprites["Image"].opacity = 255
    @height = @sprites["Image"].bitmap.height
    pbSetSystemFont(@sprites["Image"].bitmap)
    pbDrawTextPositions(@sprites["Image"].bitmap,[[name,@sprites["Image"].bitmap.width/2-4,28,2,@baseColor,@shadowColor,true]])
    @currentmap = $game_map.map_id
    @frames = 0
  end

  def dispose
    @sprites["Image"].dispose
    $game_temp.location_window_showing = false
  end

  def disposed?
    return @sprites["Image"].disposed?
  end

  def update
    return if @sprites["Image"].disposed?
    if $game_temp.message_window_showing || @currentmap != $game_map.map_id
      @sprites["Image"].dispose
      return
    elsif @frames > 100
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height)/12)
      @sprites["Image"].dispose if @sprites["Image"].y + @height < 6
    elsif $game_temp.in_menu == true
      @sprites["Image"].y-= ((@sprites["Image"].bitmap.height)/6)
      @sprites["Image"].dispose if @sprites["Image"].y + @height < 6
    else
      @sprites["Image"].y+= ((@sprites["Image"].bitmap.height)/12) if @sprites["Image"].y < 6
    end
    @frames += 1
  end
end