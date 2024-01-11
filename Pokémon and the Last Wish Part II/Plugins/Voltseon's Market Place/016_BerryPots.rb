Events.onStepTaken += proc {
  for pot in $Trainer.berry_pots
    next if pot[0] == nil
    next if pot[1] < 1
    pot[1] -= 1
  end
}

def vBerryPots
  scene = BerryPots_Scene.new
  screen = BerryPots_Screen.new(scene)
  screen.pbStartScreen
end

class Trainer
  attr_accessor :berry_pots

  # [[ item_id, steps_left, total_steps, yield ] * 4]
  def berry_pots
		@berry_pots = [[nil,nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil],[nil,nil,nil,nil]] if !@berry_pots
		return @berry_pots
  end
end

class BerryPots_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbBerryPots
    @scene.pbEndScene
  end
end

class BerryPots_Scene
  TEXTBASECOLOR    = Color.new(248,248,248)
  TEXTSHADOWCOLOR  = Color.new(72,72,72)

  PATH = "Graphics/Pictures/BerryPots/"

  # Initializes Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @index = 0
    @berry_pots = $Trainer.berry_pots
    @disposed = false
  end

  # draw scene elements
  def pbStartScene
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("%sbg",PATH))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    for i in 0..3
      # Selection
      @sprites["sel_pot#{i}"] = IconSprite.new(0,0,@viewport)
      @sprites["sel_pot#{i}"].setBitmap(sprintf("%ssel",PATH))
      @sprites["sel_pot#{i}"].x = i*54 + 20
      @sprites["sel_pot#{i}"].y = 162
      @sprites["sel_pot#{i}"].visible = false
      # Contents
      next if @berry_pots[i][0] == nil
      if @berry_pots[i][1] < @berry_pots[i][2] * 0.75
        @sprites["berry#{i}"]        = AnimatedBerrySprite.new(_INTL("Graphics/Characters/berrytree{1}",@berry_pots[i][0]),4,32,64,2,@viewport)
      else
        @sprites["berry#{i}"]       = AnimatedSprite.new(_INTL("Graphics/Characters/berrytreeplanted"),4,32,64,2,@viewport)
      end
      @sprites["berry#{i}"].x       = i*54 + 38
      @sprites["berry#{i}"].y       = 142
      @sprites["berry#{i}"].visible = true
      @sprites["berry#{i}"].play
    end
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  # input controls
  def pbBerryPots
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @disposed
        break
      else
        if Input.trigger?(Input::RIGHT) && @index < 3
          pbPlayCursorSE
          @index += 1
          drawPresent
        elsif Input.trigger?(Input::LEFT) && @index > 0
          pbPlayCursorSE
          @index -= 1
          drawPresent
        elsif Input.trigger?(Input::USE)
          pbPlayCursorSE
          checkPot(@index)
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    end
  end

  def drawPresent
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    for i in 0..3
      @sprites["sel_pot#{i}"].visible = (i == @index)
      next if @berry_pots[i][0] == nil
      next if @berry_pots[i][1] >= @berry_pots[i][2] * 0.75
      if @berry_pots[i][1] < 1
        @sprites["berry#{i}"].frameaddition = 12
      elsif @berry_pots[i][1] < @berry_pots[i][2] * 0.25
        @sprites["berry#{i}"].frameaddition = 8
      elsif @berry_pots[i][1] < @berry_pots[i][2] * 0.5
        @sprites["berry#{i}"].frameaddition = 4
      else
        @sprites["berry#{i}"].frameaddition = 0
      end
    end
  end

  def checkPot(index)
    if @berry_pots[index][0] != nil
      berry_item = GameData::Item.get(@berry_pots[index][0])
      berry_name = berry_item.name
      commands = []
      commands.push((@berry_pots[index][1] < 1) ? "Harvest Crop" : "Destroy Crop")
      commands.push("Cancel")
      if pbMessage(_INTL("What would you like to do with the {1} crop?",berry_name),commands,1)==0
        if @berry_pots[index][1] < 1
          berry = @berry_pots[index][0]
          berrycount = @berry_pots[index][3]
          item = GameData::Item.get(berry)
          itemname = item.name
          pocket = item.pocket
          if !$PokemonBag.pbCanStore?(berry,berrycount)
            pbMessage(_INTL("Too bad...\nThe Bag is full..."))
            return
          end
          $PokemonBag.pbStoreItem(berry,berrycount)
          pbMessage(_INTL("\\me[Berry get]You picked the {1} \\c[1]{2}\\c[0].\\wtnp[30]",berrycount,itemname))
          pbMessage(_INTL("{1} put the \\c[1]{2}\\c[0] in the <icon=bagPocket{3}>\\c[1]{4}\\c[0] Pocket.\1",
            $Trainer.name,itemname,pocket,PokemonBag.pocketNames()[pocket]))
        else
          pbMessage(_INTL("\\se[Rock Smash]You destroyed the {1} crop",berry_name))
        end
        @berry_pots[index] = [nil,nil,nil,nil]
        @sprites["berry#{index}"].visible = false
      else
        pbPlayCloseMenuSE
      end
    else
      if pbMessage("What would you like to do?",["Plant Berry","Cancel"],1)==0
        pbFadeOutIn {
          scene = PokemonBag_Scene.new
          screen = PokemonBagScreen.new(scene,$PokemonBag)
          berry = screen.pbChooseItemScreen(Proc.new { |item|  GameData::Item.get(item).is_berry? })
        }
        if berry
          $PokemonBag.pbDeleteItem(berry,1)
          pbMessage(_INTL("The {1} was planted in the soft, earthy soil of the pot.", GameData::Item.get(berry).name))
          steps = rand(255..512)
          @berry_pots[index] = [berry,steps,steps,rand(2..5)]
          @sprites["berry#{index}"] = AnimatedSprite.new(_INTL("Graphics/Characters/berrytreeplanted"),4,32,64,2,@viewport)
          @sprites["berry#{index}"].x       = index*54 + 38
          @sprites["berry#{index}"].y       = 142
          @sprites["berry#{index}"].visible = true
        end
      else
        pbPlayCloseMenuSE
      end
    end
  end

  def pbUpdate
    drawPresent if !@disposed
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @disposed = true
    @viewport.dispose
    $Trainer.berry_pots = @berry_pots
  end
end


class AnimatedBerrySprite < SpriteWrapper
  attr_reader :frame
  attr_reader :framewidth
  attr_reader :frameheight
  attr_reader :framecount
  attr_reader :animname
  attr_reader :frameaddition

  def initializeLong(animname,framecount,framewidth,frameheight,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    @frameskip *= Graphics.frame_rate/20
    raise _INTL("Frame width is 0") if framewidth==0
    raise _INTL("Frame height is 0") if frameheight==0
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
    rescue
      @animbitmap=Bitmap.new(framewidth,frameheight)
    end
    if @animbitmap.width%framewidth!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame width ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    if @animbitmap.height%frameheight!=0
      raise _INTL("Bitmap's height ({1}) is not a multiple of frame height ({2}) [Bitmap={3}]",
         @animbitmap.height,frameheight,animname)
    end
    @framecount=framecount
    @framewidth=framewidth
    @frameheight=frameheight
    @framesperrow=@animbitmap.width/@framewidth
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  # Shorter version of AnimationSprite.  All frames are placed on a single row
  # of the bitmap, so that the width and height need not be defined beforehand
  def initializeShort(animname,framecount,frameskip)
    @animname=pbBitmapName(animname)
    @realframes=0
    @frameskip=[1,frameskip].max
    @frameskip *= Graphics.frame_rate/20
    begin
      @animbitmap=AnimatedBitmap.new(animname).deanimate
    rescue
      @animbitmap=Bitmap.new(framecount*4,32)
    end
    if @animbitmap.width%framecount!=0
      raise _INTL("Bitmap's width ({1}) is not a multiple of frame count ({2}) [Bitmap={3}]",
         @animbitmap.width,framewidth,animname)
    end
    @framecount=framecount
    @framewidth=@animbitmap.width/@framecount
    @frameheight=@animbitmap.height
    @framesperrow=framecount
    @playing=false
    self.bitmap=@animbitmap
    self.src_rect.width=@framewidth
    self.src_rect.height=@frameheight
    self.frame=0
  end

  def initialize(*args)
    if args.length==1
      super(args[0][3])
      initializeShort(args[0][0],args[0][1],args[0][2])
    else
      super(args[5])
      initializeLong(args[0],args[1],args[2],args[3],args[4])
    end
  end

  def frameaddition
    @frameaddition = 0 if !@frameaddition
    return @frameaddition
  end

  def frameaddition=(value)
    @frameaddition = value
  end

  def self.create(animname,framecount,frameskip,viewport=nil)
    return self.new([animname,framecount,frameskip,viewport])
  end

  def dispose
    return if disposed?
    @animbitmap.dispose
    @animbitmap=nil
    super
  end

  def playing?
    return @playing
  end

  def frame=(value)
    @frame= (@frameaddition.nil?) ? value : value + @frameaddition
    @realframes=0
    self.src_rect.x=@frame%@framesperrow*@framewidth
    self.src_rect.y=@frame/@framesperrow*@frameheight
  end

  def start
    @playing=true
    @realframes=0
  end

  alias play start

  def stop
    @playing=false
  end

  def update
    super
    if @playing
      @realframes+=1
      if @realframes==@frameskip
        @realframes=0
        self.frame+=1
        self.frame%=self.framecount
      end
    end
  end
end