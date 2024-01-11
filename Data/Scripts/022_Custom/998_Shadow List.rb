def pbRematchShadow
  rematch_mon = nil
  gender = 0
  form = 0
  MenuHandlers.each(:shadow_list) do |option, hash, name|
    next if $player.shadow_pkmn[hash["name"]][1] || [:LUGIA,:NECROZMA].include?(hash["name"])
    rematch_mon = hash["name"]
    gender = hash["gender"].to_i
    form = hash["form"].to_i
    break
  end
  return false if !rematch_mon
  pkmn = Pokemon.new(rematch_mon, 70)
  pkmn.gender = gender
  pkmn.form = form
  pkmn.makeShadow
  pkmn.update_shadow_moves(true)
  pkmn.shiny = false
  return WildBattle.start(pkmn)
end

def shadowCheckSpecific(pkmn)
  return false if $player.shadow_pkmn[pkmn.species].nil?
  ret = false
  MenuHandlers.each(:shadow_list) do |option, hash, name|
    next unless pkmn.isSpecies?(hash["name"])
    break if pkmn.form != hash["form"].to_i || pkmn.gender != hash["gender"].to_i
    ret = true
    break
  end
  return ret
end

class Player < Trainer
  attr_accessor :shadow_pkmn # Hash containing [Seen, Caught, ]

  def shadow_pkmn
    initShadow
    return @shadow_pkmn
  end

  def shadow_pkmn_count
    initShadow
    return @shadow_pkmn.count
  end

  def shadow_pkmn_caught
    count = 0
    initShadow
    @shadow_pkmn.each do |key, value|
      count += 1 if value[1]
    end
    return count
  end

  def shadow_pkmn_seen
    count = 0
    initShadow
    @shadow_pkmn.each do |key, value|
      count += 1 if value[0]
    end
    return count
  end

  def initShadow
    if @shadow_pkmn.is_a?(Hash)
      MenuHandlers.each(:shadow_list) do |option, hash, name|
        next if @shadow_pkmn[hash["name"]].is_a?(Array)
        @shadow_pkmn[hash["name"]] = [false, false]
      end
    else
      @shadow_pkmn = {}
      MenuHandlers.each(:shadow_list) do |option, hash, name|
        @shadow_pkmn[hash["name"]] = [false, false]
      end
    end
  end
end

class Window_ShadowList < Window_PhoneList
  def drawCursor(index, rect)
    selarrow = AnimatedBitmap.new("Graphics/Pictures/shadowSel")
    if self.index == index
      pbCopyBitmap(self.contents, selarrow.bitmap, rect.x, rect.y)
    end
    return Rect.new(rect.x + 28, rect.y + 8, rect.width - 16, rect.height)
  end
end

def pbShadowList
  pbFadeOutIn {
    scene = ShadowList.new
    scene.pbStartScene
    scene.pbMain
    scene.pbEndScene
  }
end

class ShadowList
  TEXT_BASE_COLOR = Color.new(255, 255, 255)
  TEXT_SHADOW_COLOR = Color.new(148, 198, 61)

  def pbStartScene
    @list = []
    MenuHandlers.each_available(:shadow_list) do |option, hash, name|
      @list.push([hash["name"],hash])
    end
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg_overlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap("Graphics/Pictures/Pokegear/bg_plus")
    @sprites["bg_overlay"].setBitmap("Graphics/Pictures/shadow_list")
    @sprites["list"] = Window_ShadowList.newEmpty(-18, 38, Graphics.width - 142, Graphics.height - 80, @viewport)
    @sprites["list"].windowskin = nil
    @sprites["list"].baseColor = TEXT_BASE_COLOR
    @sprites["list"].shadowColor = TEXT_SHADOW_COLOR
    @sprites["text"] = IconSprite.new(0, 0, @viewport)
    @sprites["text"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetNarrowFont(@sprites["text"].bitmap)
    @sprites["pokemon"] = PokemonSprite.new(@viewport)
    @sprites["pokemon"].x = 412
    @sprites["pokemon"].y = 152
    @pokemon = []
    commands = []
    @list.each_with_index do |entry, index|
      s = GameData::Species.try_get(entry[0])
      numstring = ""
      num = index+1
      numstring += "0" if num < 100
      numstring += "0" if num < 10
      numstring += num.to_s
      if $player.shadow_pkmn[entry[0]][0] # Seen
        @pokemon.push(s)
        commands.push("##{numstring} " + s.name)
      else
        @pokemon.push(nil)
        commands.push("##{numstring} ----------")
      end
    end
    @sprites["list"].commands = commands
    pbUpdate
    pbFadeInAndShow(@sprites)
  end

  def pbMain
    pbActivateWindow(@sprites, "list") {
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          break
        end
      end
    }
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
    @sprites["text"].bitmap.clear
    if @sprites["bg"].y > -1
      @sprites["bg"].y = -128
    else
      @sprites["bg"].y+=1
    end
    hash = @list[@sprites["list"].index][1]
    sp = @pokemon[@sprites["list"].index]
    sp = sp.nil? ? nil : sp.id
    @sprites["pokemon"].setSpeciesBitmap(sp, hash["form"], hash["form"], false, true)
    stat = (sp.nil?) ? "Unknown" : ($player.shadow_pkmn[sp][1]) ? "Caught" : "Seen"
    trainer = hash["trainer"]
    if trainer[1].nil?
      trainer_name = ""
    else
      trainer_name = "#{GameData::TrainerType.get(trainer[1]).name} #{trainer[2]}"
    end
    location = pbGetMapNameFromId(trainer[0])
    if sp.nil?
      trainer_name = "???"
      location = "???"
    end
    drawTextEx(@sprites["text"].bitmap, 24, 344, 278, 2, "Status: #{stat}", Color.new(248, 248, 248), Color.new(148, 198, 61))
    drawTextEx(@sprites["text"].bitmap, 336, 296, 278, 2, "#{trainer_name}", Color.new(248, 248, 248), Color.new(148, 198, 61))
    drawTextEx(@sprites["text"].bitmap, 336, 328, 278, 2, "#{location}", Color.new(248, 248, 248), Color.new(148, 198, 61))
    drawTextEx(@sprites["text"].bitmap, 24, 12, 278, 2, "Shadow List", Color.new(248, 248, 248), Color.new(85, 90, 112))
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

MenuHandlers.add(:shadow_list, :venonat, {
  "name"        => :VENONAT,
  "order"       => 0,
  "trainer"     => [148, :BUGCATCHER, "Rey"],  # MapID, Trainer Class, Trainer Name
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :shuckle, {
  "name"        => :SHUCKLE,
  "order"       => 1,
  "trainer"     => [148, :BUGCATCHER, "Brendan"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :bagon, {
  "name"        => :BAGON,
  "order"       => 2,
  "trainer"     => [148, :TAMER, "Eliott"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :raichu, {
  "name"        => :RAICHU,
  "order"       => 3,
  "trainer"     => [134, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 1,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :ninjask, {
  "name"        => :NINJASK,
  "order"       => 4,
  "trainer"     => [148, :BEAUTY, "Norine"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :gogoat, {
  "name"        => :GOGOAT,
  "order"       => 5,
  "trainer"     => [148, :HEXMANIAC, "Susan"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :heatmor, {
  "name"        => :HEATMOR,
  "order"       => 6,
  "trainer"     => [148, :KINDLER, "Abe"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :floette, {
  "name"        => :FLOETTE,
  "order"       => 7,
  "trainer"     => [148, :AROMALADY, "Val"],
  "gender"      => 0,
  "form"        => 3,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :muk, {
  "name"        => :MUK,
  "order"       => 8,
  "trainer"     => [148, :PSYCHIC_M, "Alexi"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :plusle, {
  "name"        => :PLUSLE,
  "order"       => 9,
  "trainer"     => [148, :YOUNGCOUPLE, "Arla"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :minun, {
  "name"        => :MINUN,
  "order"       => 10,
  "trainer"     => [148, :YOUNGCOUPLE, "Jordan"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})

MenuHandlers.add(:shadow_list, :grapploct, {
  "name"        => :GRAPPLOCT,
  "order"       => 11,
  "trainer"     => [157, :TEAMROCKET_F, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 5 }
})

MenuHandlers.add(:shadow_list, :lycanroc, {
  "name"        => :LYCANROC,
  "order"       => 12,
  "trainer"     => [172, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :luxray, {
  "name"        => :LUXRAY,
  "order"       => 13,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :seaking, {
  "name"        => :SEAKING,
  "order"       => 14,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 1,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :copperajah, {
  "name"        => :COPPERAJAH,
  "order"       => 15,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :sudowoodo, {
  "name"        => :SUDOWOODO,
  "order"       => 16,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :talonflame, {
  "name"        => :TALONFLAME,
  "order"       => 17,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :stunfisk, {
  "name"        => :STUNFISK,
  "order"       => 18,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 1,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :lucario, {
  "name"        => :LUCARIO,
  "order"       => 19,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :rapidash, {
  "name"        => :RAPIDASH,
  "order"       => 20,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 0,
  "form"        => 1,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :tyranitar, {
  "name"        => :TYRANITAR,
  "order"       => 21,
  "trainer"     => [173, :TEAMROCKET_M, "Grunt"],
  "gender"      => 1,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :necrozma, {
  "name"        => :NECROZMA,
  "order"       => 22,
  "trainer"     => [207, :ROCKETBOSS, "Silver"],
  "gender"      => 0,
  "form"        => 3,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :alakazam, {
  "name"        => :ALAKAZAM,
  "order"       => 23,
  "trainer"     => [207, :ROCKETBOSS, "Silver"],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next $player.badge_count > 6 }
})

MenuHandlers.add(:shadow_list, :lugia, {
  "name"        => :LUGIA,
  "order"       => 24,
  "trainer"     => [207, nil, nil],
  "gender"      => 0,
  "form"        => 0,
  "condition"   => proc { next true }
})
