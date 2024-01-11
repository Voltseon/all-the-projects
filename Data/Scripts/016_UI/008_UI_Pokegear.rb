#===============================================================================
#
#===============================================================================
class PokegearButton < Sprite
  attr_reader :index
  attr_reader :name
  attr_reader :selected

  TEXT_BASE_COLOR = Color.new(255, 255, 255)
  TEXT_SHADOW_COLOR = Color.new(148, 198, 61)

  def initialize(command, x, y, viewport = nil)
    super(viewport)
    @image = command[0]
    @name  = command[1]
    @selected = false
    @button = AnimatedBitmap.new("Graphics/Pictures/Pokegear/icon_button")
    @contents = BitmapWrapper.new(@button.width*2, @button.height)
    self.bitmap = @contents
    self.x = x
    self.y = y
    pbSetSystemFont(self.bitmap)
    refresh
  end

  def dispose
    @button.dispose
    @contents.dispose
    super
  end

  def selected=(val)
    oldsel = @selected
    @selected = val
    refresh if oldsel != val
  end

  def refresh
    self.bitmap.clear
    rect = Rect.new(0, 0, @button.width, @button.height / 2)
    rect.y = @button.height / 2 if @selected
    self.bitmap.blt(0, 0, @button.bitmap, rect)
    textpos = [
      [@name, rect.width / 2 - 16, (rect.height / 2) - 10, 0, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, true]
    ]
    pbDrawTextPositions(self.bitmap, textpos)
    imagepos = [
      [sprintf("Graphics/Pictures/Pokegear/icon_" + @image), 18, 4]
    ]
    pbDrawImagePositions(self.bitmap, imagepos)
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegear_Scene
  def pbUpdate
    return if @disposed
    counter = ($player.has_pdaplus) ? "Shadow: #{$player.shadow_pkmn_caught}" : "Seen: #{$player.pokedex.seen_count}"
    counter2 = ($player.has_pdaplus) ? "Purified: #{$stats.shadow_pokemon_purified}" : "Owned: #{$player.pokedex.owned_count}"
    @sprites["holotext"].bitmap.clear
    @commands.length.times do |i|
      @sprites["button#{i}"].selected = (i == @index)
    end
    pbUpdateSpriteHash(@sprites)
    drawTextEx(@sprites["holotext"].bitmap, 410, 142, 278, 2, "Badges: #{$player.badge_count}", Color.new(248, 248, 248), Color.new(148, 198, 61))
    drawTextEx(@sprites["holotext"].bitmap, 410, 174, 278, 2, counter, Color.new(248, 248, 248), Color.new(148, 198, 61))
    drawTextEx(@sprites["holotext"].bitmap, 410, 206, 278, 2, counter2, Color.new(248, 248, 248), Color.new(148, 198, 61))
  end

  def pbStartScene(commands)
    @commands = commands
    @disposed = false
    @index = 0
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, -128, @viewport)
    @sprites["background_overlay"] = IconSprite.new(0, 0, @viewport)
    @sprites["holotext"] = IconSprite.new(-24, 0, @viewport)
    @sprites["overlay"] = Sprite.new(@viewport)
    @sprites["overlay"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    @sprites["holotext"].bitmap = Bitmap.new(Graphics.width+24, Graphics.height)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    pbSetNarrowFont(@sprites["holotext"].bitmap)
    if $player.has_pdaplus
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg_plus")
      @sprites["background_overlay"].setBitmap("Graphics/Pictures/Pokegear/overlay")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/Pokegear/bg")
      @sprites["background_overlay"].setBitmap("Graphics/Pictures/Pokegear/overlay_rust")
    end
    offset = ($player.has_pdaplus) ? 16 : 0
    @commands.length.times do |i|
      @sprites["button#{i}"] = PokegearButton.new(@commands[i], 32, 0, @viewport)
      button_height = @sprites["button#{i}"].bitmap.height / 2
      @sprites["button#{i}"].y = ((Graphics.height - (@commands.length * button_height)) / 2) + (i * button_height) + offset
    end
    @sprites["player_picture"] = IconSprite.new(279, 130, @viewport)
    @sprites["player_picture"].setBitmap("Graphics/Pictures/GenderSelection/#{$player.trainer_type}")
    device_name = ($player.has_pdaplus) ? "P★DA+" : "P★DA"
    drawTextEx(@sprites["overlay"].bitmap, Graphics.width / 2, 12, 278, 2, device_name, Color.new(248, 248, 248), Color.new(85, 90, 112))
    drawTextEx(@sprites["overlay"].bitmap, 320, 102, 278, 2, $player.name, Color.new(248, 248, 248), Color.new(85, 90, 112))
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    ret = -1
    loop do
      break if @disposed
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = @index
        break
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE if @commands.length > 1
        @index -= 1
        @index = @commands.length - 1 if @index < 0
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE if @commands.length > 1
        @index += 1
        @index = 0 if @index >= @commands.length
      elsif Input.trigger?(Input::SPECIAL)
        pbPlayCursorSE
        pda_item = @commands[@index][2]
        $bag.registered?(pda_item) ? $bag.unregister(pda_item) : $bag.register(pda_item)
      end
      if @sprites["background"].y > -1
        @sprites["background"].y = -128
      else
        @sprites["background"].y+=1
      end
    end
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    dispose
  end

  def dispose
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonPokegearScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    # Get all commands
    command_list = []
    commands = []
    MenuHandlers.each_available(:pokegear_menu) do |option, hash, name|
      command_list.push([hash["icon_name"] || "", name, hash["pdaitem"]])
      commands.push(hash)
    end
    @scene.pbStartScene(command_list)
    # Main loop
    end_scene = false
    loop do
      choice = @scene.pbScene
      if choice < 0
        end_scene = true
        break
      end
      break if commands[choice]["effect"].call(@scene)
    end
    @scene.pbEndScene if end_scene
  end
end

#===============================================================================
#
#===============================================================================
MenuHandlers.add(:pokegear_menu, :map, {
  "name"      => _INTL("Map"),
  "icon_name" => "map",
  "pdaitem"   => :PDAMAP,
  "order"     => 10,
  "effect"    => proc { |menu|
    pbFadeOutIn {
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      if ret
        $game_temp.fly_destination = ret
        menu.dispose
        next 99999
      end
    }
    pbFlyToNewLocation if $game_temp.fly_destination
    next $game_temp.fly_destination
  }
})

MenuHandlers.add(:pokegear_menu, :phone, {
  "name"      => _INTL("Phone"),
  "icon_name" => "phone",
  "pdaitem"   => :PDAPHONE,
  "order"     => 20,
  "condition" => proc { next $PokemonGlobal.phoneNumbers && $PokemonGlobal.phoneNumbers.length > 0 },
  "effect"    => proc { |menu|
    pbFadeOutIn { PokemonPhoneScene.new.start }
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :pokesearch, {
  "name"      => _INTL("PokéSearch"),
  "icon_name" => "pokesearch",
  "pdaitem"   => :PDAPOKESEARCH,
  "order"     => 21,
  "condition"  => proc { next $player.has_pdaplus },
  "effect"    => proc { |menu|
    menu.pbEndScene
    vPokeSearch
    next true
  }
})

MenuHandlers.add(:pokegear_menu, :purification, {
  "name"      => _INTL("Purification"),
  "icon_name" => "purification",
  "pdaitem"   => :PDAPURIFICATION,
  "order"     => 22,
  "condition"  => proc { next $player.has_pdaplus && !$player.rocketmode },
  "effect"    => proc { |menu|
    pbFadeOutIn { pbPurifyChamber }
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :shadow_dex, {
  "name"      => _INTL("Shadow Dex"),
  "icon_name" => "shadow",
  "pdaitem"   => :PDASHADOWDEX,
  "order"     => 24,
  "condition"  => proc { next $player.has_pdaplus },
  "effect"    => proc { |menu|
    pbShadowList
    next false
  }
})

MenuHandlers.add(:pokegear_menu, :specialtraining, {
  "name"      => _INTL("Sp. Training"),
  "icon_name" => "specialtraining",
  "pdaitem"   => :PDASPTRAINING,
  "order"     => 26,
  "condition"  => proc { next !$game_switches[79] && $game_switches[75] },
  "effect"    => proc { |menu|
    menu.pbEndScene
    pbSpecialTraining
    next true
  }
})

MenuHandlers.add(:pokegear_menu, :pokeradar, {
  "name"      => _INTL("PokéRadar"),
  "icon_name" => "pokeradar",
  "pdaitem"   => :PDAPOKERADAR,
  "order"     => 30,
  "condition"  => proc { next $player.has_pokeradar },
  "effect"    => proc { |menu|
    menu.dispose
    pbUsePokeRadar
    next true
  }
})