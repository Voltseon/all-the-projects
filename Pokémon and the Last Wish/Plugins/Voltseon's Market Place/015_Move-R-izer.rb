def vMoverizer
  scene = Moverizer_Scene.new
  screen = Moverizer_Screen.new(scene)
  screen.pbStartScreen
end

class Trainer
  attr_accessor :custom_move

  # [ Name, Type-ID, Category-ID, Description ]
  def custom_move
		@custom_move = ["Custom Move",0,0,"A custom move that grows more powerful the more the user likes its Trainer."] if !@custom_move
		return @custom_move
  end
end

class Moverizer_Screen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbMoverizer
    @scene.pbEndScene
  end
end

class Moverizer_Scene
  TEXTBASECOLOR    = Color.new(248,248,248)
  TEXTSHADOWCOLOR  = Color.new(72,72,72)

  MOVERIZERPATH = "Graphics/Pictures/Move-R-izer/"

  # Initializes Scene
  def initialize
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @index_hor = 0
    @index_ver = 0
    @move_name = $Trainer.custom_move[0]
    @move_type = $Trainer.custom_move[1]
    @move_category = $Trainer.custom_move[2]
    @move_description = $Trainer.custom_move[3]
    @disposed = false
  end

  # draw scene elements
  def pbStartScene
    @sprites["background"] = IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(sprintf("%sbg",MOVERIZERPATH))
    @sprites["overlay"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @types = AnimatedBitmap.new(sprintf("%stype",MOVERIZERPATH))
    @categories = AnimatedBitmap.new(sprintf("%scategory",MOVERIZERPATH))
    @sprites["sel_name"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_name"].setBitmap(sprintf("%ssel_movename",MOVERIZERPATH))
    @sprites["sel_name"].x = 132
    @sprites["sel_name"].y = 40
    @sprites["sel_name"].visible = true
    @sprites["sel_type"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_type"].setBitmap(sprintf("%ssel_button",MOVERIZERPATH))
    @sprites["sel_type"].x = 128
    @sprites["sel_type"].y = 108
    @sprites["sel_type"].visible = false
    @sprites["sel_category"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_category"].setBitmap(sprintf("%ssel_button",MOVERIZERPATH))
    @sprites["sel_category"].x = 288
    @sprites["sel_category"].y = 108
    @sprites["sel_category"].visible = false
    @sprites["sel_description"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_description"].setBitmap(sprintf("%ssel_movedescription",MOVERIZERPATH))
    @sprites["sel_description"].x = 96
    @sprites["sel_description"].y = 172
    @sprites["sel_description"].visible = false
    @sprites["sel_teach"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_teach"].setBitmap(sprintf("%ssel_button",MOVERIZERPATH))
    @sprites["sel_teach"].x = 128
    @sprites["sel_teach"].y = 312
    @sprites["sel_teach"].visible = false
    @sprites["sel_close"] = IconSprite.new(0,0,@viewport)
    @sprites["sel_close"].setBitmap(sprintf("%ssel_button",MOVERIZERPATH))
    @sprites["sel_close"].x = 288
    @sprites["sel_close"].y = 312
    @sprites["sel_close"].visible = false
    @sprites["name_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["name_text"].bitmap)
    @sprites["name_text"].visible     = true
    @sprites["description_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["description_text"].bitmap)
    @sprites["description_text"].visible     = true
    @sprites["type_text"] = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    pbSetSystemFont(@sprites["type_text"].bitmap)
    @sprites["type_text"].visible     = true
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  # input controls
  def pbMoverizer
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if @disposed
        break
      else
        if Input.trigger?(Input::RIGHT) && @index_hor < 1 && @index_ver%2==1
          pbPlayCursorSE
          @index_hor += 1
          drawPresent
        elsif Input.trigger?(Input::LEFT) && @index_hor > 0 && @index_ver%2==1
          pbPlayCursorSE
          @index_hor -= 1
          drawPresent
        elsif Input.trigger?(Input::DOWN) && @index_ver < 3
          pbPlayCursorSE
          @index_ver += 1
          drawPresent
        elsif Input.trigger?(Input::UP) && @index_ver > 0
          pbPlayCursorSE
          @index_ver -= 1
          drawPresent
        elsif Input.trigger?(Input::USE)
          case @index_ver
          when 0
            pbPlayCursorSE
            changeName
          when 1
            pbPlayCursorSE
            (@index_hor==0) ? changeType : changeCategory
          when 2
            pbPlayCursorSE
            changeDescription
          when 3
            if @index_hor==0
              pbPlayCursorSE
              customMoveChoose(nil,true)
            else
              pbPlayCloseMenuSE
              break
            end
          end
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    end
  end

  # update UI based on current status
  # thanks to ThatWelshOne
  def drawPresent
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    @sprites["sel_name"].visible = false
    @sprites["sel_type"].visible = false
    @sprites["sel_category"].visible = false
    @sprites["sel_description"].visible = false
    @sprites["sel_teach"].visible = false
    @sprites["sel_close"].visible = false
    case @index_ver
    when 0
      @sprites["sel_name"].visible = true
    when 1
      (@index_hor==0) ? @sprites["sel_type"].visible = true : @sprites["sel_category"].visible = true
    when 2
      @sprites["sel_description"].visible = true
    when 3
      (@index_hor==0) ? @sprites["sel_teach"].visible = true : @sprites["sel_close"].visible = true
    end
    overlay.blt(128,108,@types.bitmap,
      Rect.new(0, @move_type * 48, 96, 48))
    overlay.blt(288,108,@categories.bitmap,
      Rect.new(0, @move_category * 48, 96, 48))
  end

  def changeName
    @move_name = pbMessageFreeText("Enter a new name for your custom move.",@move_name,false,16,260)
  end

  def changeType
    commands = []
    type_ids = []
    GameData::Type.each do |type|
      next if type.id == :QMARKS
      commands.push(type.name)
      type_ids.push(type.id_number)
    end
    commands.push("Cancel")
    type_ids.push(@move_type)
    @move_type = type_ids[pbShowCommands(nil,commands,commands.length-1)]
  end

  def changeCategory
    @move_category = pbShowCommands(nil,["Physical", "Special"],0)
  end

  def changeDescription
    @move_description = pbFreeTextBig(nil,@move_description,false,85,512,128)
  end

  def pbUpdate
    drawPresent if !@disposed
    updateMove  if !@disposed
    pbUpdateSpriteHash(@sprites)
  end

  def updateMove
    @sprites["name_text"].bitmap.clear
    @sprites["description_text"].bitmap.clear
    @sprites["type_text"].bitmap.clear
    pbDrawShadowText(@sprites["name_text"].bitmap,142,48,228,32,
      @move_name,TEXTBASECOLOR,TEXTSHADOWCOLOR,1)
    drawFormattedTextEx(@sprites["description_text"].bitmap,106,180,300,
      @move_description,TEXTBASECOLOR,TEXTSHADOWCOLOR)
    pbDrawShadowText(@sprites["type_text"].bitmap,138,116,76,32,
      GameData::Type.get(@move_type).name,TEXTBASECOLOR,@types.bitmap.get_pixel(14,@move_type*48),1)
    $Trainer.custom_move = [@move_name,@move_type,@move_category,@move_description]
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @categories.dispose
    @types.dispose
    @disposed = true
    @viewport.dispose
  end

  def customMoveAnnotations(movelist = nil)
    move = :CUSTOMMOVE
    ret = []
    $Trainer.party.each_with_index do |pkmn, i|
      if pkmn.egg?
        ret[i] = _INTL("NOT ABLE")
      elsif pkmn.hasMove?(move)
        ret[i] = _INTL("LEARNED")
      elsif pkmn.isSpecies?(:DITTO) || pkmn.isSpecies?(:UNOWN) || pkmn.isSpecies?(:MAGIKARP)
        ret[i] = _INTL("UNABLE")
      else
        species = pkmn.species
        ret[i] = _INTL("ABLE")
      end
    end
    return ret
  end
  
  def customMoveChoose(movelist=nil,bymachine=false,oneusemachine=false)
    ret = false
    move = :CUSTOMMOVE
    if movelist!=nil && movelist.is_a?(Array)
      for i in 0...movelist.length
        movelist[i] = GameData::Move.get(movelist[i]).id
      end
    end
    pbFadeOutIn {
      movename = GameData::Move.get(move).name
      annot = customMoveAnnotations(movelist)
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene,$Trainer.party)
      screen.pbStartScene(_INTL("Teach which Pokémon?"),false,annot)
      loop do
        chosen = screen.pbChoosePokemon
        break if chosen<0
        pokemon = $Trainer.party[chosen]
        if pokemon.egg?
          pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
        elsif pokemon.shadowPokemon?
          pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
        elsif movelist && !movelist.any? { |j| j==pokemon.species }
          pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
        elsif pokemon.isSpecies?(:DITTO) || pokemon.isSpecies?(:UNOWN) || pokemon.isSpecies?(:MAGIKARP)
          pbMessage(_INTL("{1} can't learn {2}.",pokemon.name,movename)) { screen.pbUpdate }
        else
          if pbLearnMove(pokemon,move,false,bymachine) { screen.pbUpdate }
            pokemon.add_first_move(move) if oneusemachine
            ret = true
            break
          end
        end
      end
      screen.pbEndScene
    }
    return ret   # Returns whether the move was learned by a Pokemon
  end
end