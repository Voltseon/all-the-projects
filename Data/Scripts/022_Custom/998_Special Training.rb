SPECIAL_TRAINING_LEVEL_CAP = [
  20, # 0 badges
  30, # 1 badge
  35, # 2 badges
  40, # 3 badges
  45, # 4 badges
  50, # 5 badges
  55, # 6 badges
  65, # 7 badges
  100 # 8 badges
]

class Game_Temp
  attr_accessor :special_training
  attr_accessor :special_training_level

  def special_training_level
    @special_training_level = false if !@special_training_level
    return @special_training_level
  end

  def special_training
    @special_training = false if !@special_training
    return @special_training
  end
end

class Player < Trainer
  attr_accessor :special_training

  def special_training
    if !@special_training
      @special_training = {
        "Level" => [false] * 5,
        "HP" => [false] * 5,
        "Attack" => [false] * 5,
        "Sp. Attack" => [false] * 5,
        "Speed" => [false] * 5,
        "Defense" => [false] * 5,
        "Sp. Defense" => [false] * 5,
        "Extreme Level" => [false],
        "Extreme Attack" => [false],
        "Extreme Sp. Atk" => [false],
        "Extreme Speed" => [false]
      }
    end
    return @special_training
  end
end

BADGE_REQUIREMENTS = {
  1 => 0,
  2 => 2,
  3 => 4,
  4 => 7
}

def pbSpecialTraining
  #pbFadeOutIn {
    scene = SpecialTraining.new
    scene.pbStartScene
    scene.pbMain
    scene.pbEndScene
  #
end

def pbCheckSpecialTraining(type, difficulty)
  st = pbGet(32)
  unless st.is_a?(Hash)
    pbSet(32, {})
    return false
  end
  unless st[type].is_a?(Hash)
    st[type] = {
      1 => true,
      2 => false,
      3 => false,
      4 => false
    }
  end
  return st[type][difficulty] && $player.badge_count >= BADGE_REQUIREMENTS[difficulty]
end

def pbCheckExtremeTraining
  ret = true
  ["Level", "HP", "Attack", "Sp. Attack", "Speed", "Defense", "Sp. Defense"].each do |type|
    next if pbCheckSpecialTraining(type, 4)
    ret = false
    break
  end
  return ret
end

def pbSetSpecialTraining(type, difficulty, new_state)
  current_state = pbCheckSpecialTraining(type, difficulty)
  st = pbGet(32)
  st[type][difficulty] = new_state
end

class SpecialTraining_Icon < PokemonIconSprite
  attr_accessor :title
  attr_accessor :difficulty
  attr_accessor :rewards
  attr_accessor :condition

  def initialize(title, difficulty, pokemon, rewards, viewport)
    @title = title
    @difficulty = difficulty
    @rewards = rewards
    @condition = pbCheckSpecialTraining(@title, @difficulty)
    @doneSprite = nil
    @viewport = viewport
    @pokemon = pokemon
    super(@pokemon, @viewport)
  end

  def title;          return @title;      end
  def difficulty;     return @difficulty; end
  def rewards;        return @rewards;    end
  def pokemon;        return @pokemon;    end
  def condition;      return @condition;  end

  def update
    super
    @condition = pbCheckSpecialTraining(@title, @difficulty) || (@difficulty == 0 && pbCheckExtremeTraining)
    if @condition
      self.color = Color.new(0, 0, 0, 0)
      self.opacity = 255
    else
      self.color = Color.new(0, 0, 0, 255)
      self.opacity = 128
    end
    if $player.special_training[@title][@difficulty] && !@doneSprite
      @doneSprite = IconSprite.new(self.x+48, self.y+48, @viewport)
      @doneSprite.setBitmap(_INTL("Graphics/Pictures/trainingdone"))
    end
  end

  def dispose
    @doneSprite.dispose if @doneSprite
    super
  end

  def visible=(value)
    @doneSprite.visible = value if @doneSprite
    super(value)
  end
end

class SpecialTraining
  DEFAULTREWARDS = {
    0 => [[:RARECANDY,1]],
    1 => [[:EXPCANDYS,1],[:REDSHARD,1],[:BLUESHARD,1],[:GREENSHARD,1],[:YELLOWSHARD,1]],
    2 => [[:EXPCANDYM,1]],
    3 => [[:EXPCANDYL,1],[:FIRESTONE,1],[:WATERSTONE,1],[:LEAFSTONE,1],[:THUNDERSTONE,1]],
    4 => [[:EXPCANDYXL,1],[:RARECANDY,1],[:MOONSTONE,1],[:SUNSTONE,1],[:DUSKSTONE,1],[:DAWNSTONE,1],[:SHINYSTONE,1],[:ICESTONE,1]]
  }

  TEXT_BASE_COLOR = Color.new(255, 255, 255)
  TEXT_SHADOW_COLOR = Color.new(148, 198, 61)

  def pbStartScene
    @list = []
    @index = 0
    @page = 0
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    i = 0
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg_overlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Pokegear/bg#{($player.has_pdaplus ? "_plus" : "")}")
    @sprites["bg_overlay"].setBitmap("Graphics/Pictures/training#{($player.has_pdaplus ? "plus" : "")}bg")
    MenuHandlers.each(:special_training) do |option, hash, name|
      @list.push(hash)
      pbCheckSpecialTraining(hash["name"], hash["difficulty"])
      pokemon = hash["pokemon"]
      pkmn = Pokemon.new(pokemon[0],pokemon[1], nil, false)
      pkmn.form = pokemon[2]
      pkmn.nature = pokemon[3]
      pkmn.item = pokemon[4] if pokemon[4]
      pkmn.shiny = false
      pkmn.calc_stats
      pkmn.reset_moves
      @sprites["training#{i}"] = SpecialTraining_Icon.new(hash["name"], hash["difficulty"], pkmn, hash["rewards"], @viewport)
      @sprites["training#{i}"].x = 78 + (i%4*90)
      @sprites["training#{i}"].y = 72
      @sprites["training#{i}"].y += 132 if i%8 >= 4
      i += 1
    end
    @sprites["sel"] = IconSprite.new(0, 0, @viewport)
    @sprites["sel"].setBitmap("Graphics/Pictures/trainingsel")
    @sprites["text"] = IconSprite.new(0, 0, @viewport)
    @sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetNarrowFont(@sprites["text"].bitmap)
    pbUpdate
    refreshpage
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbStartSpecialTrainingBattle
      elsif Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        @index += ((@index % 8 >= 4 ? -4 : 4))
      elsif Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        if (@index == @page*8 || @index == @page*8+4) && @page > 0
          @page -= 1
          @index -= 5
          refreshpage
        elsif @index == 0 || @index == 4
          @page = @list.length/8-1
          @index = (@index == 0) ? @list.length-5 : @list.length-1
          refreshpage
        else
          @index -= 1
        end
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        if (@index == @page*8+3 || @index == (@page+1)*8-1) && (@page+1)*8+1 < @list.length-1
          @page += 1
          @index += 5
          refreshpage
        elsif @index == @list.length-1 || @index == @list.length-5
          @page = 0
          @index = (@index == @list.length-5) ? 0 : 4
          refreshpage
        else
          @index += 1
        end
      end
    end
  end

  def refreshpage
    @list.length.times do |i|
      @sprites["training#{i}"].visible = i<8*(@page+1) && i>=8*@page
    end
  end

  def pbStartSpecialTrainingBattle
    unless pbCheckSpecialTraining(@sprites["training#{@index}"].title, @sprites["training#{@index}"].difficulty) || (@sprites["training#{@index}"].difficulty == 0 && pbCheckExtremeTraining)
      pbPlayBuzzerSE
      if (@sprites["training#{@index}"].difficulty == 0)
        pbMessage("You have to unlock every Special Training Module to attempt Extreme Training!")
      elsif ($player.badge_count >= BADGE_REQUIREMENTS[@sprites["training#{@index}"].difficulty])
        pbMessage("You have to beat the previous difficulty to unlock this module!")
      else
        pbMessage("More Badges are required to attempt this module!")
      end
      return false
    end
    pbPlayDecisionSE
    $game_temp.special_training = true
    $game_temp.special_training_level = @sprites["training#{@index}"].title == "Level" || @sprites["training#{@index}"].title == "Extreme Level"
    setBattleRule("battleback", "training")
    setBattleRule("backdrop", "training")
    setBattleRule("base", "training")
    setBattleRule("environment", :None)
    setBattleRule("canLose")
    setBattleRule("single")
    setBattleRule("weather", :None)
    setBattleRule("disablepokeballs")
    setBattleRule("nopartner")
    setBattleRule("nomoney")
    $PokemonGlobal.nextBattleBGM = "CipherPeonBattle Parabeetle X"
    outcome = WildBattle.start_core(@sprites["training#{@index}"].pokemon.clone)
    if outcome == 1
      # won
      rewards = DEFAULTREWARDS[@sprites["training#{@index}"].difficulty]
      rewards += @sprites["training#{@index}"].rewards
      (rand(3)+1).times do
        it = rewards.sample
        pbReceiveItem(it[0], it[1])
      end
      unless @sprites["training#{@index}"].difficulty == 4
        pbSetSpecialTraining(@sprites["training#{@index}"].title, @sprites["training#{@index}"].difficulty + 1, true)
      end
      $player.special_training[@sprites["training#{@index}"].title][@sprites["training#{@index}"].difficulty] = true
    elsif outcome == 3
      # ran away
    else
      # lost
      $player.party.each do |pkmn|
        pkmn.hp = 0
      end
      $player.last_pokemon.hp = 1
    end
    $game_temp.special_training = false
    $game_temp.special_training_level = false
    return outcome
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @sprites["sel"].x = 68 + (@index%4*90)
    @sprites["sel"].y = 62
    @sprites["sel"].y += 132 if @index%8 >= 4
    @sprites["text"].bitmap.clear
    drawTextEx(@sprites["text"].bitmap, 76, 300, 512, 1, "Special Training: #{@list[@index]["name"]} Training#{(@list[@index]["difficulty"] != 0 ? " #{@list[@index]["difficulty"]}" : "")}", TEXT_BASE_COLOR, TEXT_SHADOW_COLOR)
    if @sprites["bg"].y > -1
      @sprites["bg"].y = -128
    else
      @sprites["bg"].y+=1
    end
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

MenuHandlers.add(:special_training, :level1, {
  "name"        => "Level",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:HAPPINY, 10, 1, :BOLD],
  "rewards"     => [[:EXPCANDYS,1],[:EXPCANDYS,2],[:EXPCANDYXS,2],[:EXPCANDYXS,3],[:EXPCANDYXS,4]],
  "condition"   => proc { next pbCheckSpecialTraining(:Level, 1) }
})

MenuHandlers.add(:special_training, :level2, {
  "name"        => "Level",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:CHANSEY, 25, 1, :BOLD],
  "rewards"     => [[:EXPCANDYM,1],[:EXPCANDYM,2],[:EXPCANDYS,2],[:EXPCANDYS,3],[:EXPCANDYS,4]],
  "condition"   => proc { next pbCheckSpecialTraining(:Level, 2) }
})

MenuHandlers.add(:special_training, :level3, {
  "name"        => "Level",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:AUDINO, 45, 2, :BOLD],
  "rewards"     => [[:EXPCANDYL,1],[:EXPCANDYL,2],[:EXPCANDYM,2],[:EXPCANDYM,3],[:EXPCANDYM,4],[:LUCKYEGG,1],[:PPUP,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:Level, 3) }
})

MenuHandlers.add(:special_training, :level4, {
  "name"        => "Level",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:BLISSEY, 70, 1, :BOLD],
  "rewards"     => [[:EXPCANDYXL,1],[:EXPCANDYXL,2],[:EXPCANDYL,2],[:EXPCANDYL,3],[:EXPCANDYL,4],[:LUCKYEGG,1],[:MACHOBRACE,1],[:PPUP,1],[:PPMAX,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:Level, 4) }
})

MenuHandlers.add(:special_training, :hp1, {
  "name"        => "HP",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:NIDORANfE, 10, 1, :SERIOUS],
  "rewards"     => [[:HEALTHWING,1],[:ORANBERRY,2],[:ORANBERRY,3],[:SITRUSBERRY,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:HP, 1) }
})

MenuHandlers.add(:special_training, :hp2, {
  "name"        => "HP",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:NIDORINA, 25, 1, :SERIOUS],
  "rewards"     => [[:HEALTHWING,1],[:HEALTHWING,2],[:ORANBERRY,3],[:ORANBERRY,4],[:SITRUSBERRY,1],[:SITRUSBERRY,2],[:BERRYJUICE,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:HP, 2) }
})

MenuHandlers.add(:special_training, :hp3, {
  "name"        => "HP",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:KANGASKHAN, 45, 2, :SERIOUS],
  "rewards"     => [[:HEALTHWING,2],[:HEALTHWING,3],[:SITRUSBERRY,2],[:SITRUSBERRY,3],[:HPUP,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:HP, 3) }
})

MenuHandlers.add(:special_training, :hp4, {
  "name"        => "HP",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:NIDOQUEEN, 70, 1, :SERIOUS],
  "rewards"     => [[:HEALTHWING,3],[:HEALTHWING,4],[:SITRUSBERRY,3],[:SITRUSBERRY,4],[:HPUP,1],[:POWERWEIGHT,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:HP, 4) }
})

MenuHandlers.add(:special_training, :attack1, {
  "name"        => "Attack",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:NIDORANmA, 10, 1, :ADAMANT],
  "rewards"     => [[:MUSCLEWING,1],[:LIECHIBERRY,2],[:LIECHIBERRY,3],[:SITRUSBERRY,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:ATTACK, 1) }
})

MenuHandlers.add(:special_training, :attack2, {
  "name"        => "Attack",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:NIDORINO, 25, 1, :ADAMANT],
  "rewards"     => [[:MUSCLEWING,1],[:MUSCLEWING,2],[:LIECHIBERRY,3],[:LIECHIBERRY,4],[:SITRUSBERRY,2]],
  "condition"   => proc { next pbCheckSpecialTraining(:ATTACK, 2) }
})

MenuHandlers.add(:special_training, :attack3, {
  "name"        => "Attack",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:PINSIR, 45, 2, :ADAMANT],
  "rewards"     => [[:MUSCLEWING,2],[:MUSCLEWING,3],[:PROTEIN,1],[:XATTACK,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:ATTACK, 3) }
})

MenuHandlers.add(:special_training, :attack4, {
  "name"        => "Attack",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:NIDOKING, 70, 1, :ADAMANT, :FLAMEORB],
  "rewards"     => [[:MUSCLEWING,3],[:MUSCLEWING,4],[:PROTEIN,1],[:POWERBRACER,1],[:XATTACK,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:ATTACK, 4) }
})

MenuHandlers.add(:special_training, :defense1, {
  "name"        => "Defense",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:ARON, 10, 1, :IMPISH],
  "rewards"     => [[:RESISTWING,1],[:GANLONBERRY,2],[:GANLONBERRY,3],[:SITRUSBERRY,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:DEFENSE, 1) }
})

MenuHandlers.add(:special_training, :defense2, {
  "name"        => "Defense",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:LAIRON, 25, 1, :IMPISH],
  "rewards"     => [[:RESISTWING,1],[:RESISTWING,2],[:GANLONBERRY,3],[:GANLONBERRY,4],[:SITRUSBERRY,2]],
  "condition"   => proc { next pbCheckSpecialTraining(:DEFENSE, 2) }
})

MenuHandlers.add(:special_training, :defense3, {
  "name"        => "Defense",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:DURANT, 45, 1, :IMPISH],
  "rewards"     => [[:RESISTWING,2],[:RESISTWING,3],[:IRON,1],[:XDEFENSE,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:DEFENSE, 3) }
})

MenuHandlers.add(:special_training, :defense4, {
  "name"        => "Defense",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:AGGRON, 70, 2, :IMPISH],
  "rewards"     => [[:RESISTWING,3],[:RESISTWING,4],[:IRON,1],[:POWERBELT,1],[:XDEFENSE,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:DEFENSE, 4) }
})

MenuHandlers.add(:special_training, :special_attack1, {
  "name"        => "Sp. Attack",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:PORYGON, 10, 1, :MODEST],
  "rewards"     => [[:GENIUSWING,1],[:PETAYABERRY,2],[:PETAYABERRY,3],[:SITRUSBERRY,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_ATTACK, 1) }
})

MenuHandlers.add(:special_training, :special_attack2, {
  "name"        => "Sp. Attack",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:PORYGON2, 25, 1, :MODEST],
  "rewards"     => [[:GENIUSWING,1],[:GENIUSWING,2],[:PETAYABERRY,3],[:PETAYABERRY,4],[:SITRUSBERRY,2]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_ATTACK, 2) }
})

MenuHandlers.add(:special_training, :special_attack3, {
  "name"        => "Sp. Attack",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:SIGILYPH, 45, 1, :MODEST, :FLAMEORB],
  "rewards"     => [[:GENIUSWING,2],[:GENIUSWING,3],[:CALCIUM,1],[:XSPATK,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_ATTACK, 3) }
})

MenuHandlers.add(:special_training, :special_attack4, {
  "name"        => "Sp. Attack",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:PORYGONZ, 70, 1, :MODEST, :FLAMEORB],
  "rewards"     => [[:GENIUSWING,3],[:GENIUSWING,4],[:CALCIUM,1],[:POWERLENS,1],[:XSPATK,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_ATTACK, 4) }
})

MenuHandlers.add(:special_training, :special_defense1, {
  "name"        => "Sp. Defense",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:BLIPBUG, 10, 1, :CALM],
  "rewards"     => [[:CLEVERWING,1],[:APICOTBERRY,2],[:APICOTBERRY,3],[:SITRUSBERRY,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_DEFENSE, 1) }
})

MenuHandlers.add(:special_training, :special_defense2, {
  "name"        => "Sp. Defense",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:DOTTLER, 25, 1, :CALM],
  "rewards"     => [[:CLEVERWING,1],[:CLEVERWING,2],[:APICOTBERRY,3],[:APICOTBERRY,4],[:SITRUSBERRY,2]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_DEFENSE, 2) }
})

MenuHandlers.add(:special_training, :special_defense3, {
  "name"        => "Sp. Defense",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:COMFEY, 45, 1, :CALM],
  "rewards"     => [[:CLEVERWING,2],[:CLEVERWING,3],[:ZINC,1],[:XSPDEF,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_DEFENSE, 3) }
})

MenuHandlers.add(:special_training, :special_defense4, {
  "name"        => "Sp. Defense",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:ORBEETLE, 70, 1, :CALM],
  "rewards"     => [[:CLEVERWING,3],[:CLEVERWING,4],[:ZINC,1],[:POWERBAND,1],[:XSPDEF,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPECIAL_DEFENSE, 4) }
})

MenuHandlers.add(:special_training, :speed1, {
  "name"        => "Speed",
  "order"       => 0,
  "difficulty"  => 1,
  "pokemon"     => [:LUVDISC, 10, 1, :JOLLY],
  "rewards"     => [[:SWIFTWING,1],[:SALACBERRY,2],[:SALACBERRY,3],[:SITRUSBERRY,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPEED, 1) }
})

MenuHandlers.add(:special_training, :speed2, {
  "name"        => "Speed",
  "order"       => 10,
  "difficulty"  => 2,
  "pokemon"     => [:FLETCHLING, 25, 1, :JOLLY],
  "rewards"     => [[:SWIFTWING,1],[:SWIFTWING,2],[:SALACBERRY,3],[:SALACBERRY,4],[:SITRUSBERRY,2]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPEED, 2) }
})

MenuHandlers.add(:special_training, :speed3, {
  "name"        => "Speed",
  "order"       => 20,
  "difficulty"  => 3,
  "pokemon"     => [:FLETCHINDER, 45, 1, :JOLLY],
  "rewards"     => [[:SWIFTWING,2],[:SWIFTWING,3],[:CARBOS,1],[:XSPEED,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPEED, 3) }
})

MenuHandlers.add(:special_training, :speed4, {
  "name"        => "Speed",
  "order"       => 30,
  "difficulty"  => 4,
  "pokemon"     => [:TALONFLAME, 70, 1, :JOLLY],
  "rewards"     => [[:SWIFTWING,3],[:SWIFTWING,4],[:CARBOS,1],[:POWERANKLET,1],[:XSPEED,1]],
  "condition"   => proc { next pbCheckSpecialTraining(:SPEED, 4) }
})

MenuHandlers.add(:special_training, :level5, {
  "name"        => "Extreme Level",
  "order"       => 50,
  "difficulty"  => 0,
  "pokemon"     => [:ETERNATUS, 100, 1, :SERIOUS],
  "rewards"     => [[:RARECANDY,2],[:RARECANDY,3]],
  "condition"   => proc { next pbCheckExtremeTraining }
})

MenuHandlers.add(:special_training, :attack5, {
  "name"        => "Extreme Attack",
  "order"       => 50,
  "difficulty"  => 0,
  "pokemon"     => [:ETERNATUS, 100, 2, :ADAMANT],
  "rewards"     => [[:RARECANDY,2],[:RARECANDY,3]],
  "condition"   => proc { next pbCheckExtremeTraining }
})

MenuHandlers.add(:special_training, :special_attack5, {
  "name"        => "Extreme Sp. Atk",
  "order"       => 50,
  "difficulty"  => 0,
  "pokemon"     => [:ETERNATUS, 100, 3, :MODEST],
  "rewards"     => [[:RARECANDY,2],[:RARECANDY,3]],
  "condition"   => proc { next pbCheckExtremeTraining }
})

MenuHandlers.add(:special_training, :speed5, {
  "name"        => "Extreme Speed",
  "order"       => 50,
  "difficulty"  => 0,
  "pokemon"     => [:ETERNATUS, 100, 4, :JOLLY],
  "rewards"     => [[:RARECANDY,2],[:RARECANDY,3]],
  "condition"   => proc { next pbCheckExtremeTraining }
})