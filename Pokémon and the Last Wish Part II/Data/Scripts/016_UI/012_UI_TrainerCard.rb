#===============================================================================
#
#===============================================================================
class PokemonTrainerCard_Scene
  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    pbCustomCardTypes
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["trainer"] = IconSprite.new(336,112,@viewport)
    @sprites["trainer"].setBitmap(GameData::TrainerType.player_front_sprite_filename($Trainer.trainer_type))
    @sprites["trainer"].x -= (@sprites["trainer"].bitmap.width-128)/2
    @sprites["trainer"].y -= (@sprites["trainer"].bitmap.height-140)
    @sprites["trainer"].z = 2
    pbDrawTrainerCardFront
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbCustomCardTypes
    addBackgroundPlane(@sprites,"bg","loadbg",@viewport)
    if false # Beaten Arapawa
      @sprites["card"] = IconSprite.new(0,0,@viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_04")
    elsif $Trainer.pendants.count{ |pendant| pendant == true } == 8 # All Pendants
      @sprites["card"] = IconSprite.new(0,0,@viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_03")
    elsif $game_switches[99] # Game Beaten
      @sprites["card"] = IconSprite.new(0,0,@viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_01")
    elsif $game_switches[74] # Movie Done
      @sprites["card"] = IconSprite.new(0,0,@viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_02")
    elsif $Trainer.female?
      @sprites["card"] = IconSprite.new(0,0,@viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card_f")
    else
      @sprites["card"] = IconSprite.new(0,0,@viewport)
      @sprites["card"].setBitmap("Graphics/Pictures/Trainer Card/card")
    end
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    baseColor   = Color.new(248,248,248)
    shadowColor = Color.new(72,72,72)
    totalsec = Graphics.frame_count / Graphics.frame_rate
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour>0) ? _INTL("{1}h {2}m",hour,min) : _INTL("{1}m",min)
    $PokemonGlobal.startTime = pbGetTimeNow if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
       pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
       $PokemonGlobal.startTime.day,
       $PokemonGlobal.startTime.year)
    textPositions = [
       [_INTL("Name"),34,58,0,baseColor,shadowColor],
       [$Trainer.name,302,58,1,baseColor,shadowColor],
       [_INTL("ID No."),332,58,0,baseColor,shadowColor],
       [sprintf("%05d",$Trainer.public_ID),468,58,1,baseColor,shadowColor],
       [_INTL("Money"),34,106,0,baseColor,shadowColor],
       [_INTL("${1}",$Trainer.money.to_s_formatted),302,106,1,baseColor,shadowColor],
       [_INTL("Pokédex"),34,154,0,baseColor,shadowColor],
       [sprintf("%d/%d",$Trainer.pokedex.owned_count,$Trainer.pokedex.seen_count),302,154,1,baseColor,shadowColor],
       [_INTL("Time"),34,202,0,baseColor,shadowColor],
       [time,302,202,1,baseColor,shadowColor],
       [_INTL("Started"),34,250,0,baseColor,shadowColor],
       [starttime,302,250,1,baseColor,shadowColor]
    ]
    pbDrawTextPositions(overlay,textPositions)
    x = 340
    region = pbGetCurrentRegion(0) # Get the current region
    imagePositions = []
    for i in 0...8
      if $Trainer.badges[i+region*8]
        imagePositions.push(["Graphics/Pictures/Trainer Card/icon_badges",x,260,i*32,region*32,32,32])
      end
      x += 48
    end
    pen_x = 56
    for i in 0...8
      if $Trainer.pendants[i]
        imagePositions.push(["Graphics/Pictures/Trainer Card/icon_pendants",pen_x,300,i*32,0,32,64])
      end
      pen_x += 48
    end
    pbDrawImagePositions(overlay,imagePositions)
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end
