class Player < Trainer
  attr_accessor :frontier_medals

  def frontier_medals
    @frontier_medals = [0] * 5 if !@frontier_medals
    return @frontier_medals
  end

  def set_medal(type, rank)
    @frontier_medals[type] = rank
  end
end

class MedalIcon < IconSprite
  def initialize(rank=0,*args)
    super(*args)
    @shine = AnimatedSprite.new("Graphics/Pictures/FrontierPass/medal_shine#{rank}", 16, 32, 32, 1, self.viewport)
    @shine.x = self.x
    @shine.y = self.y
    @shine.z = self.z + 1
    @shine.visible = rank > 0
    @shine.start
    @shine.color = self.color
  end

  def update
    @shine&.update if @shine&.visible
    @shine&.color = self.color
    super
  end

  def dispose
    @shine&.dispose
    super
  end
end

def pbFrontierPass
  pbFadeOutIn {
    scene = FrontierPass.new
    scene.pbStartScene
    scene.pbMain
    scene.pbEndScene
  }
end

class FrontierPass
  TEXT_BASE_COLOR = Color.new(248, 248, 248)
  TEXT_SHADOW_COLOR = Color.new(99, 99, 115)
  TEXT_DARK_SHADOW  = Color.new(186, 186, 186)
  PATH = "Graphics/Pictures/FrontierPass/"

  def pbStartScene
    # Initialize values
    @sprites = {}
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(PATH + "bg_" + ($player.character_ID-1 < 3 ? "m" : $player.character_ID-1 < 6 ? "f" : "o"))
    # Player Data
    @sprites["player_picture"] = IconSprite.new(8, 36, @viewport)
    @sprites["player_picture"].setBitmap("Graphics/Pictures/GenderSelection/#{$player.trainer_type}")
    # Sel
    @sprites["sel"] = IconSprite.new(218, 52, @viewport)
    @sprites["sel"].setBitmap(PATH + "sel")
    # Party Pokémon
    if $player.party.is_a?(Array) && $player.party.length > 0
      $player.party.each_with_index do |pkmn, i|
        @sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @viewport)
        @sprites["party#{i}"].x = (i%2==0 ? 36 : 124)
        @sprites["party#{i}"].y = 184 + 8*(i%2) + 44*(i/2).floor
      end
    end
    # Medals
    $player.frontier_medals.each_with_index do |medal, i|
      @sprites["medal#{i}"] = MedalIcon.new(medal, 40 + i*28, 124 + 30*(i%2), @viewport)
      @sprites["medal#{i}"].setBitmap(PATH + "medals")
      if medal < 1
        @sprites["medal#{i}"].visible = false
      else
        @sprites["medal#{i}"].src_rect.set(32*(medal-1), 32*i, 32, 32)
      end
    end
    # Text graphic
    @sprites["text"] = IconSprite.new(0, 0, @viewport)
    @sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetNarrowFont(@sprites["text"].bitmap)
    # Finally show the screen
    pbSEPlay("GUI trainer card open")
    pbUpdate
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    loop do
      # Generic update loop
      Graphics.update
      Input.update
      pbUpdate
      # Check player input
      if Input.trigger?(Input::UP) && @index > 0
        pbPlayCursorSE
        @index -= 1
      elsif Input.trigger?(Input::DOWN) && @index < 3
        pbPlayCursorSE
        @index += 1
      elsif Input.trigger?(Input::USE)
        case @index
        when 0
          # Frontier brains
          pbPlayDecisionSE
          pbFadeOutIn {
            scene = FrontierBrainList.new
            scene.pbStartScene
            scene.pbMain
            scene.pbEndScene
          }
        when 1
          # Match History
          pbPlayDecisionSE
          pbCommonEvent(9)
        when 2
          # Check Rules
          pbPlayDecisionSE
          pbFrontierRules
        when 3
          # Online stuff
          pbMessage("Coming soon!")
        end
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @sprites["text"].bitmap.clear
    textpos = []
    # Show BP
    textpos.push(["#{$player.battle_points.to_s_formatted}", 168, 94, 1, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
    # Show player name
    textpos.push(["#{$player.name}", 148, 58, 2, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR])
    # Options
    textpos.push(["Frontier Brains", 362, 72, 2, TEXT_SHADOW_COLOR, TEXT_DARK_SHADOW])
    textpos.push(["Match History", 362, 136, 2, TEXT_SHADOW_COLOR, TEXT_DARK_SHADOW])
    textpos.push(["Check Rules", 362, 200, 2, TEXT_SHADOW_COLOR, TEXT_DARK_SHADOW])
    textpos.push(["???", 362, 264, 2, TEXT_SHADOW_COLOR, TEXT_DARK_SHADOW])
    # Draw text
    pbDrawTextPositions(@sprites["text"].bitmap, textpos)
    # Sel position
    @sprites["sel"].y = 52 + @index*64
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

class FrontierBrainList
  PATH = "Graphics/Pictures/FrontierPass/"
  TEXT_BASE_COLOR = Color.new(99, 99, 115)
  TEXT_SHADOW_COLOR = Color.new(186, 186, 186)

  BRAINS = [
    # Name, Class, Description, Party (Species, Gender, Form, Shiny?)
    ["Radsel", :FRONTIERBRAIN_Radsel, "Compitent Lawyer, Dark-type master.", [[:ABSOL, 1, 1, true], [:GRENINJA, 1, 0, false], [:HONCHKROW, 0, 0, false], [:THIEVUL, 1, 0, false], [:MALAMAR, 1, 0, false], [:MUK, 1, 1, false]]],
    ["Optus", :FRONTIERBRAIN_Optus, "Ex-hired sniper, Water-type master.", [[:BLASTOISE, 0, 1, false], [:INTELEON, 1, 0, false], [:BARBARACLE, 0, 0, true], [:KINGDRA, 1, 0, false], [:OCTILLERY, 0, 0, false], [:SWANNA, 1, 0, false]]],
    ["Tyler", :FRONTIERBRAIN_Tyler, "Professional barber, Steel-type master.", [[:SCIZOR, 0, 1, false], [:PERRSERKER, 1, 0, false], [:AEGISLASH, 0, 0, true], [:EXCADRILL, 1, 0, false], [:SKARMORY, 0, 0, false], [:MAWILE, 1, 0, false]]],
    ["Annie", :FRONTIERBRAIN_Annie, "Ethical hacker, Bug-type master.", [[:BEEDRILL, 1, 1, false], [:ACCELGOR, 1, 0, false], [:YANMEGA, 1, 0, false], [:SHEDINJA, 1, 0, false], [:ARAQUANID, 1, 0, true], [:NANYTE, 0, 0, false]]],
    ["Hashil", :FRONTIERBRAIN_Hashil, "Detached from reality, Rock-type master.", [[:ARCHEOPS, 0, 0, false], [:MINIOR, 0, 3, false], [:DREDNAW, 0, 0, false], [:TYRANITAR, 0, 1, false], [:GOLEM, 0, 1, false], [:GIGALITH, 0, 0, true]]]
  ]

  def pbStartScene
    # Initialize values
    @sprites = {}
    @index = 0
    @current_brain = BRAINS[@index]
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    # Background
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(PATH + "brain_bg")
    # Arrow left
    @sprites["arrow_left"] = IconSprite.new(8, 174, @viewport)
    @sprites["arrow_left"].setBitmap(PATH + "brain_arrows")
    @sprites["arrow_left"].src_rect.set(0, 0, 20, 34)
    # Arrow right
    @sprites["arrow_right"] = IconSprite.new(484, 174, @viewport)
    @sprites["arrow_right"].setBitmap(PATH + "brain_arrows")
    @sprites["arrow_right"].src_rect.set(20, 0, 20, 34)
    # Trainer sprite
    @sprites["trainer"] = IconSprite.new(188, 182, @viewport)
    @sprites["trainer"].z = @sprites["bg"].z + 10
    # Trainer team
    locations = [[214, 246], [298, 246], [174, 238], [338, 238], [142, 232], [370, 232]]
    @current_brain[3].each_with_index do |pkmn, i|
      @sprites["pokemon#{i}"] = PokemonSprite.new(@viewport)
      @sprites["pokemon#{i}"].z = @sprites["trainer"].z - (i + 1)
      @sprites["pokemon#{i}"].setOffset(PictureOrigin::BOTTOM)
      @sprites["pokemon#{i}"].x = locations[i][0]
      @sprites["pokemon#{i}"].y = locations[i][1]+92
    end
    # Text graphic
    @sprites["text"] = IconSprite.new(0, 0, @viewport)
    @sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetNarrowFont(@sprites["text"].bitmap)
    # Finally show the screen
    pbSEPlay("GUI trainer card open")
    pbUpdate
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    loop do
      # Generic update loop
      Graphics.update
      Input.update
      pbUpdate
      # Check player input
      if Input.trigger?(Input::LEFT) && @index > 0
        pbPlayCursorSE
        @index -= 1
      elsif Input.trigger?(Input::RIGHT) && @index < 4
        pbPlayCursorSE
        @index += 1
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      end
    end
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @current_brain = BRAINS[@index]
    @sprites["text"].bitmap.clear
    @sprites["arrow_left"].visible = @index > 0
    @sprites["arrow_right"].visible = @index < 4
    drawTextEx(@sprites["text"].bitmap, 88, 64, 352, 1, "Frontier Brain #{@current_brain[0]}", TEXT_BASE_COLOR, TEXT_SHADOW_COLOR)
    drawTextEx(@sprites["text"].bitmap, 88, 96, 352, 1, @current_brain[2], TEXT_BASE_COLOR, TEXT_SHADOW_COLOR)
    # Trainer sprite
    @sprites["trainer"].setBitmap("Graphics/Trainers/" + @current_brain[1].to_s)
    @current_brain[3].each_with_index do |pkmn, i|
      @sprites["pokemon#{i}"].setSpeciesBitmap(pkmn[0], pkmn[1], pkmn[2], pkmn[3])
      @sprites["pokemon#{i}"].visible = !pkmn[0].nil?
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

def pbFrontierRules
  choice = pbMessage("For which facility would you like to see the rules?", ["Battle Palace", "Battle Arena", "Battle Factory", "Battle Tower"])
  case choice
  when 0
    # Battle Palace
    pbCommonEvent(6)
  when 1
    # Battle Arena
    pbCommonEvent(7)
  when 2
    # Battle Factory
    pbCommonEvent(8)
  when 3
    # Battle Tower
    pbCommonEvent(11)
  end
end