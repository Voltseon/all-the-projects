class Credits
  BGM                    = "Credits"
  SCROLL_SPEED           = 120   # Pixels per second
  TEXT_OUTLINE_COLOR     = Color.new(0, 0, 128, 255)
  TEXT_BASE_COLOR        = Color.new(254,255,255)
  TEXT_SHADOW_COLOR      = Color.new(64,64,64)
  # Start Editing
  CREDIT = <<_END_

"Pivot"

A game by:
Voltseon
ENLS
KennyCatches
Ranko
rainefall

Pokémon sprites by:
Pokémon Mystery Dungeon: Explorers of Sky
Spriters Resource

Pokémon portraits by:
Pokémon Mystery Dungeon: Explorers of Sky
PMD Sprite Repository
CHUNSOFT 
Pepper
fledermaus
Nooga
Emmuffin
baronessfaron

Ability VFX and SFX by:
Pokémon Mystery Dungeon: Explorers of Sky
Spriters Resource

Music by:
Pokémon Battle Revolution

Announcer voice by: 
Pokémon Battle Revolution 
Announcer Soundboard
Christopher Foo and contributors

Tilesets by:
Pokémon Shikari<s>Pokémon Quantum
Pokémon Machinery<s>
19Dante19<s>Alucus
AnonAlpaca<s>Asdsimone
BoOmxBiG<s>Boonzeet
ChaoticCherryCake<s>Chimcharsfireworkd
Claisprojects.com<s>Clara-WaH
Cuddlesthefatcat<s>DarkDragonn
Dewitty<s>EpicDay
Erma96<s>Flurmimon
FoxyTomcat<s>Gallanty
Gigatom<s>Hek-el-grande
Hydrargirium<s>Iametrine
Jesus Carrasco<s>Kalisar
Kauzz<s>KingTapir
KKKaito<s>Kyle-Dove
Kymotonian<s>Magiscarf
MewTheMega<s>Minorthreat0987
moca<s>Mucrush
Newtiteuf<s>NikNak93
NSora-96<s>Pablus94
PandaInDaGame<s>PeekyChew
Phyromatical<s>Poison-Master
PrincessPhoenix<s>rafa-cac
SailorVicious<s>Shawn Frost
Shutwig<s>SirMaIo
Spacemotion<s>Speedialga
Steinnaples<s>sylver1984
Takai-of-the-Fire<s>TeaAddiction
ThatsSoWitty<s>Thedeadheroalistair
The-Red-Ex<s>Thurpok
TyranitarDark<s>UltimoSpriter
WesleyFG<s>WilsonScarloxy
XDinky<s>Xxdevil
Zeo254<s>Zetavares852

{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE}
"Pokémon Essentials" was created by:
Flameguru
Poccil (Peter O.)
Maruno

With contributions from:
AvatarMonkeyKirby<s>Marin
Boushy<s>MiDas Mike
Brother1440<s>Near Fantastica
FL.<s>PinkMan
Genzai Kawakami<s>Popper
Golisopod User<s>Rataime
help-14<s>Savordez
IceGod64<s>SoundSpawn
Jacob O. Wobbrock<s>the__end
KitsuneKouta<s>Venom12
Lisa Anthony<s>Wachunga
Luka S.J.<s>
and everyone else who helped out

"mkxp-zr" by:
rainefall

"mkxp-z" by:
Roza
Based on "mkxp" by Ancurio et al.

"RPG Maker XP" by:
Enterbrain

Pokémon is owned by:
The Pokémon Company
Nintendo
Affiliated with Game Freak



This is a non-profit fan-made game.
No copyright infringements intended.
Please support the official games!

_END_
# Stop Editing

  def initialize
    $game_temp.credits_calling = false
    pbGlobalFadeOut(1)
    @viewport = nil
    @sprites = {}
    @overlay = nil
    @disposed = false
    @total_height = 0
    @credit_sprites = []
    @counter = 0.0   # Counts time elapsed since the background image changed
    @bitmap_height = Graphics.height   # For a single credits text bitmap
    @trim = 0
    # Number of game frames per background frame
    @realOY = -(Graphics.height - @trim)
    pbStartScene
  end

  def pbStartScene
    Discord.update_activity({
      :large_image => "icon_big",
      :large_image_text => "Pivot",
      :details => "Watching the Credits"
    })
    @viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z = 99999
    @overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
    @overlay.z = 99999
    x_position = 12
    y_position = 158
    graphic = MainMenu::PATH+"bg"
    if $player.equipped_collectibles[:loadingscreen]
      graphic = "Graphics/Pictures/Loading Screens/#{Collectible.get($player.equipped_collectibles[:loadingscreen]).internal.to_s}"
    end
    @background_sprite = IconSprite.new(0,0,@viewport)
    @background_sprite.setBitmap(graphic)
    pbSetSystemFont(@overlay.bitmap)
    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << (pcred[0] + "\n")
        i = 1
        until i >= pcred.size
          plugin_credits << (pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n")
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << (name + "\n") }
      end
      plugin_credits << "\n"
    end
    CREDIT.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
    credit_lines = CREDIT.split(/\n/)
    @total_height = credit_lines.size * 32
    pbMain
  end

  def pbMain
    pbUpdate
    #-------------------------------
    # Animated Background Setup
    #-------------------------------
    #-------------------------------
    # Credits text Setup
    #-------------------------------
    plugin_credits = ""
    PluginManager.plugins.each do |plugin|
      pcred = PluginManager.credits(plugin)
      plugin_credits << "\"#{plugin}\" v.#{PluginManager.version(plugin)} by:\n"
      if pcred.size >= 5
        plugin_credits << (pcred[0] + "\n")
        i = 1
        until i >= pcred.size
          plugin_credits << (pcred[i] + "<s>" + (pcred[i + 1] || "") + "\n")
          i += 2
        end
      else
        pcred.each { |name| plugin_credits << (name + "\n") }
      end
      plugin_credits << "\n"
    end
    CREDIT.gsub!(/\{INSERTS_PLUGIN_CREDITS_DO_NOT_REMOVE\}/, plugin_credits)
    credit_lines = CREDIT.split(/\n/)
    #-------------------------------
    # Make background and text sprites
    #-------------------------------
    viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    viewport.z = 99999
    text_viewport = Viewport.new(0, @trim, Graphics.width, Graphics.height - (@trim * 2))
    text_viewport.z = 99999
    @credit_sprites = []
    @total_height = credit_lines.size * 32
    lines_per_bitmap = @bitmap_height / 32
    num_bitmaps = (credit_lines.size.to_f / lines_per_bitmap).ceil
    num_bitmaps.times do |i|
      credit_bitmap = Bitmap.new(Graphics.width, @bitmap_height + 16)
      pbSetSystemFont(credit_bitmap)
      lines_per_bitmap.times do |j|
        line = credit_lines[(i * lines_per_bitmap) + j]
        next if !line
        line = line.split("<s>")
        xpos = 0
        align = 1   # Centre align
        linewidth = Graphics.width
        line.length.times do |k|
          if line.length > 1
            xpos = (k == 0) ? 0 : 20 + (Graphics.width / 2)
            align = (k == 0) ? 2 : 0   # Right align : left align
            linewidth = (Graphics.width / 2) - 20
          end
          credit_bitmap.font.color = TEXT_SHADOW_COLOR
          credit_bitmap.draw_text(xpos, (j * 32) + 2, linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos+2, (j * 32), linewidth, 32, line[k], align)
          credit_bitmap.draw_text(xpos+2, (j * 32) + 2, linewidth, 32, line[k], align)
          credit_bitmap.font.color = TEXT_BASE_COLOR
          credit_bitmap.draw_text(xpos, (j * 32), linewidth, 32, line[k], align)
        end
      end
      credit_sprite = Sprite.new(text_viewport)
      credit_sprite.bitmap = credit_bitmap
      credit_sprite.z      = 9998
      credit_sprite.oy     = @realOY - (@bitmap_height * i)
      @credit_sprites[i] = credit_sprite
    end
    #-------------------------------
    # Setup
    #-------------------------------
    Graphics.transition
    loop do
      break if @disposed
      Graphics.update
      Input.update
      pbUpdate
      break if Input.press?(Input::BACK)
      pbGlobalFadeIn if $overlay.faded_out? && !@disposed
    end
    $game_temp.background_bitmap = Graphics.snap_to_bitmap
    $game_temp.background_bitmap.dispose
    @background_sprite.dispose
    @credit_sprites.each { |s| s&.dispose }
    text_viewport.dispose
    viewport.dispose
    pbEndScene
  end

  def pbUpdate
    return if @disposed
    delta = Graphics.delta_s
    @counter += delta
    @realOY += SCROLL_SPEED * delta
    pbEndScene if @realOY >= 4950
    @credit_sprites.each_with_index { |s, i| s.oy = @realOY - (@bitmap_height * i) }
  end

  def goBack
    pbPlayCloseMenuSE
    pbGlobalFadeOut(24, true)
    $game_temp.main_menu_calling = true
    @disposed = true
  end

  def pbEndScene
    $game_temp.main_menu_calling = true
    @disposed = true
    pbDisposeSpriteHash(@sprites)
    @overlay.dispose
    @viewport.dispose
  end
end