################################################################################
# Location signpost - updated by:
# - LostSoulsDev / carmaniac
# - PurpleZaffre
# - Golisopod User
# Please give credits when using this.
################################################################################

if defined?(PluginManager)
  PluginManager.register({
    :name => "Location Signposts with Background Image",
    :version => "1.1",
    :credits => ["LostSoulsDev / carmaniac","PurpleZaffre","Golisopod User"],
    :link => "https://reliccastle.com/resources/385/"
  })
end

class LocationWindow
  def initialize(name)
    @sprites = {}
    @baseColor=Color.new(255,255,255)
    @shadowColor=MessageConfig::LIGHT_TEXT_SHADOW_COLOR
    @sprites["Image"] = Sprite.new
    mapname = name
    hgss = false
    if pbResolveBitmap("Graphics/Maps/#{mapname}")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/#{mapname}")
    elsif $game_map.name.include?("Mavora")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Desert")
    elsif $game_map.name.include?("Resort")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Resort")
    elsif $game_map.name.include?("Route")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Route_1")
    elsif $game_map.name.include?("???")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Qmarks")
    elsif $game_map.name.include?("Rosewood Generator") || $game_map.name.include?("Caramel Cave") || $game_map.name.include?("Anakiwa Cave") || $game_map.name.include?("Prim Cave")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/HGSS_6")
      hgss = true
    elsif $game_map.name.include?("Safari Zone")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/HGSS_8")
    elsif $game_map.name.include?("Town")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Town_1")
    elsif $game_map.name.include?("Village")
        @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Town_1")
    elsif $game_map.name.include?("Lake")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Lake_1")
    elsif $game_map.name.include?("Cave")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Cave_1")
    elsif $game_map.name.include?("City")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/City_1")
    elsif $game_map.name.include?("Woods") || $game_map.name.include?("Zana Village")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Forest_1")
    elsif $game_map.name.include?("Undersea Temple")
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/HGSS_5")
    else
      @sprites["Image"].bitmap = Bitmap.new("Graphics/Maps/Blank")
    end
    @sprites["Image"].x = 8
    @sprites["Image"].y = - @sprites["Image"].bitmap.height
    @sprites["Image"].z = 99990
    @sprites["Image"].opacity = 255
    @height = @sprites["Image"].bitmap.height
    pbSetSystemFont(@sprites["Image"].bitmap)
    if hgss
    	pbDrawTextPositions(@sprites["Image"].bitmap,[[name,22,@sprites["Image"].bitmap.height-48,0,@baseColor,@shadowColor,true]])
    else
    	pbDrawTextPositions(@sprites["Image"].bitmap,[[name,22,@sprites["Image"].bitmap.height-44,0,@baseColor,@shadowColor,true]])
    end
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