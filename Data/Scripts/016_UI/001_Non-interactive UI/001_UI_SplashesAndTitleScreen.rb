class IntroEventScene < EventScene
  # Splash screen images that appear for a few seconds and then disappear.
  SPLASH_IMAGES         = ["splash1", "splash2"]
  # The main title screen background image.
  TITLE_BG_IMAGE        = "title"
  TITLE_START_IMAGE     = "start"
  TITLE_START_IMAGE_X   = 0
  TITLE_START_IMAGE_Y   = 322
  SECONDS_PER_SPLASH    = 1
  TICKS_PER_ENTER_FLASH = 40   # 20 ticks per second
  FADE_TICKS            = 8    # 20 ticks per second

  def initialize(viewport = nil)
    super(viewport)
    @sirenpause = 0.0
    $game_system.bgm_play(RPG::AudioFile.new("synth humming", 100, 100), 2)
    @remove_me = addImage(0, 0, "Graphics/Titles/splash0")
    @remove_me.setOpacity(0, 0)
    @remove_me.moveOpacity(0, FADE_TICKS, 255)
    $game_system.message_position = 1
    $game_system.message_frame = nil
    pbMessage("\\ts[2]\\pop[digital]<ac>Press enter to continue...</ac>")
    #@remove_me.moveOpacity(0, FADE_TICKS, 0)
    @pic = addImage(0, 0, "")
    @pic.setOpacity(0, 0)        # set opacity to 0 after waiting 0 frames
    @pic2 = addImage(0, 0, "")   # flashing "Press Enter" picture
    @pic2.setOpacity(0, 0)       # set opacity to 0 after waiting 0 frames
    @index = 0
    if SPLASH_IMAGES.empty?
      close_title_screen(self, nil)
    else
      $game_system.bgm_play(RPG::AudioFile.new("C3 31 But An Alpha", 100, 100), 0)
      open_splash(self, nil)
    end
  end

  def open_splash(_scene, *args)
    onCTrigger.clear
    pbSEPlay("siren", 80)
    #@pic.name = "Graphics/Titles/" + SPLASH_IMAGES[@index]
    # fade to opacity 255 in FADE_TICKS ticks after waiting 0 frames
    #@pic.moveOpacity(0, FADE_TICKS, 255)
    @timer = 0.0                            # reset the timer
    pictureWait
    case @index
    when 0
      pbMessage("\\l[5]\\ts[2]\\pop[digital]<ac>Pokemon Essentials\\n\\n2011-2023 Maruno\\n2007-2010 Peter O.\\nBased on work by Flameguru\\wtnp[15]</ac>")
    when 1
      pbMessage("\\l[4]\\ts[2]\\pop[digital]<ac>mkxp-z\\n\\nRoza\\nBased on mkxp by Ancurio et al.\\wtnp[15]</ac>")
    when 2
      pbMessage("\\l[5]\\ts[3]\\pop[digital]<ac>Space Trainers\\n\\nby\\nENLS, Voltseon,\\nPurpleZaffre & Thundaga\\wtnp[12]</ac>")
    end
    onUpdate.set(method(:splash_update))    # called every frame
    onCTrigger.set(method(:close_splash))   # called when C key is pressed
  end

  def close_splash(scene, args)
    onUpdate.clear
    onCTrigger.clear
    @pic.moveOpacity(0, FADE_TICKS, 0)
    pictureWait
    @index += 1   # Move to the next picture
    if @index >= 3
      close_title_screen(scene, args)
    else
      open_splash(scene, args)
    end
  end

  def splash_update(scene, args)
    close_splash(scene, args)
  end

  def open_title_screen(_scene, *args)
    onUpdate.clear
    onCTrigger.clear
    @pic.name = "Graphics/Titles/" + TITLE_BG_IMAGE
    @pic.moveOpacity(0, FADE_TICKS, 255)
    @pic2.name = "Graphics/Titles/" + TITLE_START_IMAGE
    @pic2.setXY(0, TITLE_START_IMAGE_X, TITLE_START_IMAGE_Y)
    @pic2.setVisible(0, true)
    @pic2.moveOpacity(0, FADE_TICKS, 255)
    pictureWait
    #pbBGMPlay($data_system.title_bgm)
    onUpdate.set(method(:title_screen_update))    # called every frame
    onCTrigger.set(method(:close_title_screen))   # called when C key is pressed
  end

  def fade_out_title_screen(scene)
    onUpdate.clear
    onCTrigger.clear
    pbSEPlay("siren", 80)
    $game_system.message_position = 2
    $game_system.message_frame = 0
    # Play random cry
    #species_keys = GameData::Species.keys
    #species_data = GameData::Species.get(species_keys.sample)
    #Pokemon.play_cry(species_data.species, species_data.form)
    @pic.moveXY(0, 12, 0, 0)   # Adds 20 ticks (1 second) pause
    pictureWait
    # Fade out
    @remove_me.moveOpacity(0, 8, 0)
    @pic.moveOpacity(0, 8, 0)
    @pic2.clearProcesses
    @pic2.moveOpacity(0, 8, 0)
    pictureWait
    scene.dispose   # Close the scene
  end

  def close_title_screen(scene, *args)
    fade_out_title_screen(scene)
    if SaveData.exists?
      Game.load(load_save_file(SaveData::FILE_PATH))
    else
      Game.start_new
      #Game.load(load_save_file(SaveData::FILE_PATH))
    end
    #sscene = PokemonLoad_Scene.new
    #sscreen = PokemonLoadScreen.new(sscene)
    #sscreen.pbStartLoadScreen
  end

  def close_title_screen_delete(scene, *args)
    fade_out_title_screen(scene)
    sscene = PokemonLoad_Scene.new
    sscreen = PokemonLoadScreen.new(sscene)
    sscreen.pbStartDeleteScreen
  end

  def title_screen_update(scene, args)
    # Flashing of "Press Enter" picture
    if !@pic2.running?
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH * 2 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 0)
      @pic2.moveOpacity(TICKS_PER_ENTER_FLASH * 6 / 10, TICKS_PER_ENTER_FLASH * 4 / 10, 255)
    end
    if Input.press?(Input::DOWN) &&
       Input.press?(Input::BACK) &&
       Input.press?(Input::CTRL)
      close_title_screen_delete(scene, args)
    end
  end
end



class Scene_Intro
  def main
    Graphics.transition(0)
    if SaveData.exists?
      Game.load(load_save_file(SaveData::FILE_PATH))
    else
      @eventscene = IntroEventScene.new
      @eventscene.main
    end
    Graphics.freeze
  end
end
