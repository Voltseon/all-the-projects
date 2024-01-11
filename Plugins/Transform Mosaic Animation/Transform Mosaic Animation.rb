#===============================================================================
# ■ Transform Mosaic script by KleinStudio
# http://pokemonfangames.com
# bo4p5687 for update
#===============================================================================
class PokemonSpriteTransform < PokemonSprite
  attr_reader :mosaic
  def initialize(*args)
    super(*args)
    @mosaic=0
    @inrefresh=false
    @mosaicbitmap=nil
    @mosaicbitmap2=nil
    @oldbitmap=self.bitmap
  end
  def mosaic=(value)
    @mosaic=value
    @mosaic=0 if @mosaic<0
    mosaicRefresh(@oldbitmap)
  end
  def dispose
    super
    @mosaicbitmap.dispose if @mosaicbitmap
    @mosaicbitmap=nil
    @mosaicbitmap2.dispose if @mosaicbitmap2
    @mosaicbitmap2=nil
  end
  def bitmap=(value)
    super
    mosaicRefresh(value)
  end
  def mosaicRefresh(bitmap)
    return if @inrefresh
    @inrefresh=true
    @oldbitmap=bitmap
    if @mosaic<=0 || !@oldbitmap
      @mosaicbitmap.dispose if @mosaicbitmap
      @mosaicbitmap=nil
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap2=nil
      self.bitmap=@oldbitmap
    else
      newWidth=[(@oldbitmap.width/@mosaic),1].max
      newHeight=[(@oldbitmap.height/@mosaic),1].max
      @mosaicbitmap2.dispose if @mosaicbitmap2
      @mosaicbitmap=pbDoEnsureBitmap(@mosaicbitmap,newWidth,newHeight)
      @mosaicbitmap.clear
      @mosaicbitmap2=pbDoEnsureBitmap(@mosaicbitmap2,
         @oldbitmap.width,@oldbitmap.height)
      @mosaicbitmap2.clear
      @mosaicbitmap.stretch_blt(Rect.new(0,0,newWidth,newHeight),
         @oldbitmap,@oldbitmap.rect)
      @mosaicbitmap2.stretch_blt(
         Rect.new(-@mosaic/2+1,-@mosaic/2+1,
         @mosaicbitmap2.width,@mosaicbitmap2.height),
         @mosaicbitmap,Rect.new(0,0,newWidth,newHeight))
      self.bitmap=@mosaicbitmap2
    end
    @inrefresh=false
  end
end
class Battle::Scene
  def pbChangePokemonTransform(idxBattler,pkmn)
    idxBattler = idxBattler.index if idxBattler.respond_to?("index")
    pkmnSprite   = @sprites["pokemon_#{idxBattler}"]
    shadowSprite = @sprites["shadow_#{idxBattler}"]
    back = !@battle.opposes?(idxBattler)
    sideSize = @battle.pbSideSize(idxBattler)
    if pkmnSprite.pkmn
      pkmnSprite.visible=false
      pkmnSprite2=PokemonSpriteTransform.new(@viewport)
      pkmnSprite2.setPokemonBitmap(pkmnSprite.pkmn,back)
      pkmnSprite2.x=pkmnSprite.x
      pkmnSprite2.y=pkmnSprite.y
      pkmnSprite2.z=pkmnSprite.z
      pkmnSprite2.ox=pkmnSprite.ox
      pkmnSprite2.oy=pkmnSprite.oy
      pkmnSprite2.visible=true
    end
    pkmnSprite.setPokemonBitmap(pkmn,back)
    shadowSprite.setPokemonBitmap(pkmn)
    # Set visibility of battler's shadow
    shadowSprite.visible = pkmn.species_data.shows_shadow? if shadowSprite && !back
    if pkmnSprite.pkmn
      10.times {Graphics.update; pkmnSprite2.mosaic=pkmnSprite2.mosaic+2}
      10.times {Graphics.update; pkmnSprite2.mosaic=pkmnSprite2.mosaic-2}
    end
    pkmnSprite2.dispose
    pkmnSprite.visible=true
  end
end
class Battle::Move::TransformUserIntoTarget < Battle::Move
  def pbShowAnimation(id,user,targets,hitNum=0,showAnimation=true)
    super
    @battle.scene.pbChangePokemonTransform(user,targets[0].pokemon)
  end
end