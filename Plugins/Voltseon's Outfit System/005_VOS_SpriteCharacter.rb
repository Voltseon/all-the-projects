# This script handles all the visual stuff
class Sprite_Character < RPG::Sprite
  alias sc__initialize__vos initialize
  def initialize(viewport, character = nil)
    sc__initialize__vos(viewport, character)
    @outfit_bitmaps = {}
    if @character.is_a?(Game_Player)
      @vos_outfit = $player&.vos_outfit
      # Failsave
      if !@vos_outfit
        @vos_outfit = Vosoutfit.new
        $player.vos_outfit = @vos_outfit
      end
      @vos_outfit.retall.each do |outfit|
        key = outfit[0]
        cloth = outfit[1]
        fileloc = "Graphics/Characters/VOS/#{key}/#{cloth.id.to_s}"
        fileloc += Vosoutfit.get_suffix(fileloc)
        @outfit_bitmaps[key] = IconSprite.new(0, 0, @viewport)
        @outfit_bitmaps[key].setBitmap(fileloc)
      end
    end
  end

  alias sc__dispose__vos dispose
  def dispose
    # Disposal
    @outfit_bitmaps&.each_value { |bmp| bmp&.dispose }
    @outfit_bitmaps = nil
    sc__dispose__vos
  end

  # Called when changing outfit
  def refresh_clothes
    @outfit_bitmaps&.each do |key, bmp|
      fileloc = "Graphics/Characters/VOS/#{key}/#{@vos_outfit.get(key).id.to_s}"
      fileloc += Vosoutfit.get_suffix(fileloc)
      bmp&.setBitmap(fileloc)
    end
  end

  alias sc__update__vos update
  def update
    sc__update__vos
    # Update and keep track of outfit changes
    @outfit_bitmaps&.each do |key, bmp|
      cloth = @vos_outfit.get(key)
      bmp&.x = self.x
      bmp&.y = self.y
      bmp&.ox = self.ox
      bmp&.oy = self.oy
      bmp&.opacity = self.opacity
      bmp&.blend_type = self.blend_type
      bmp&.visible = self.visible
      bmp&.tone = self.tone
      bmp&.color = self.color
      bmp&.src_rect.set(self.src_rect)
      bmp&.z = self.z + (VOS_LAYER_ORDER.length - VOS_LAYER_ORDER.find_index(key))
      bmp&.bitmap.hue_change(cloth.hue)
      bmp&.update
    end
  end
end