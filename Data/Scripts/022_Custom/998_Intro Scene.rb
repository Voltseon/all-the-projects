def vCustomIntro
  return if $game_switches[82]
  pbFadeOutIn(99999) {
    scene=CustomIntroScene.new
    scene.pbStartScene
    scene.pbMain
    scene.pbEndScene
  }
end

class CustomIntroScene
  PATH = "Graphics/Pictures/IntroScene/"

  def pbStartScene
    Graphics.freeze
    @update_count = 0
    @sprites={} 
    @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
    @viewport.z=99999
    @sprites["background"]=IconSprite.new(0,0,@viewport)
    @sprites["background"].setBitmap(PATH+"bg")
    @sprites["lab"]=IconSprite.new(Graphics.width/2,Graphics.height/2,@viewport)
    @sprites["lab"].setBitmap(PATH+"lab")
    @sprites["lab"].ox = @sprites["lab"].width/2
    @sprites["lab"].oy = @sprites["lab"].height/2
    @sprites["lab"].opacity = 0
    @sprites["prof"]=IconSprite.new(Graphics.width/2,Graphics.height/2,@viewport)
    @sprites["prof"].setBitmap(PATH+"Prof")
    @sprites["prof"].ox = @sprites["prof"].width/2
    @sprites["prof"].oy = @sprites["prof"].height/2
    @sprites["mouth"]=ChangelingSprite.new(Graphics.width/2-8,Graphics.height/2+12,@viewport)
    @sprites["mouth"].ox = @sprites["mouth"].width/2
    @sprites["mouth"].oy = @sprites["mouth"].height/2
    @sprites["mouth"].addBitmap("0", PATH+"ProfMouth_0")
    @sprites["mouth"].addBitmap("1", PATH+"ProfMouth_1")
    @sprites["mouth"].addBitmap("2", PATH+"ProfMouth_2")
    @sprites["mouth"].addBitmap("3", PATH+"ProfMouth_3")
    @sprites["mouth"].addBitmap("4", PATH+"ProfMouth_4")
    @sprites["mouth"].changeBitmap("0")
    @sprites["overlay"]=IconSprite.new(0,0,@viewport)
    @sprites["overlay"].setBitmap(PATH+"overlay")
    pbSEPlay("PC Open")
    Graphics.transition(10, "Graphics/Transitions/computertr")
  end

  def pbMain
    pbChallenges
    pbWait(18)
    pbBGMPlay("RSE 104 Introductions")
    if (!$player.nostory)
      pbMessage("\\rHello! Thank you for contacting me.") { update }
      pbMessage("\\rAs you probably already know, my name is Professor Orchid.") { update }
      move_prof(130, 0, 3) { update }
      show_hide_lab(true) { update }
      $game_system.message_position = 0
      pbMessage("\\rI live in Bulkan Town in this cottage of a lab...") { update }
      pbMessage("\\rAnd I specialize in Pokémon Catching, a field I really enjoy.") { update }
      pbMessage("\\rAnyways, enough about me, I want to know more about you!") { update }
      show_hide_lab(false) { update }
      move_prof(-130, 0, 4) { update }
      $game_system.message_position = 2
      pbMessage("\\rTell me, what do you look like?") { update }
    end
    GenderPickSelection.show
    if (!$player.nostory)
      pbMessage("\\rOh wow! You look like someone who knows a thing or two about Pokémon Catching!") { update }
    end
    name_selection { update }
    if (!$player.nostory)
      pbMessage("\\r\\PN it is, that is such a nice name!") { update }
      pbMessage("\\rAlright then, \\PN. I am going to be sending you an e-mail, and I'd like you to check that out. It won't take that long!") { update }
      pbMessage("\\rIt's going to be a little quiz that will help me judge your personality.") { update }
      pbMessage("\\rDon't worry, there are no wrong answers. But it will help me judge which Pokémon to pick as your partner.") { update }
      pbMessage("\\rI will specifically pick three different Pokémon that match with your results, so you will still get a choice.") { update }
      pbMessage("\\rAnyways, I got to head out. Good luck on the quiz! Talk to you later!") { update }
      pbWait(18)
    end
    pbBGMFade(4)
  end

  def update
    pbUpdateSpriteHash(@sprites)
    @update_count += 1
    if @update_count > 2
      case $current_drawing_char
      when "b", "d", "m", "p" then @sprites["mouth"].changeBitmap("1")
      when "l", "r" then @sprites["mouth"].changeBitmap("2")
      when "a", "e", "h", "i", "o", "u", "y"  then @sprites["mouth"].changeBitmap("3")
      when "c", "f", "g", "j", "k", "n", "q", "s", "t", "v", "w", "x", "z" then @sprites["mouth"].changeBitmap("4")
      else @sprites["mouth"].changeBitmap("0")
      end
      @update_count = 0
    end
  end

  def name_selection
    pbMessage("\\rSo, what should I call you?") { update }
    pbTrainerName
    unless pbConfirmMessage("\\r\\PN, is that right? Like with a#{["a", "e", "f", "h", "l", "m", "n", "o", "r", "s", "x", "'", "!", "8", "@"].include?($player.name[0].downcase) ? "n" : ""} #{$player.name[0]}?") { update }
      name_selection { update }
    end
  end

  def show_hide_lab(show)
    if show
      25.times do |i|
        @sprites["lab"].opacity += 10
        pbWait(1)
      end
      @sprites["lab"].opacity = 255
    else
      25.times do |i|
        @sprites["lab"].opacity -= 10
        pbWait(1)
      end
      @sprites["lab"].opacity = 0
    end
  end

  def move_prof(x_dist, y_dist, speed)
    move_sprites_smooth([@sprites["prof"],@sprites["mouth"]], [x_dist, y_dist], speed)
  end

  def move_sprites_smooth(sprites, distance, speed, fds = {})
    final_destinations = fds
    if fds == {}
      sprites.each_with_index do |sprite, i|
        final_destinations["#{i}x"] = sprite.x+distance[0]
        final_destinations["#{i}y"] = sprite.y+distance[1]
      end
    end
    dist_abs = [distance[0].abs, distance[1].abs]
    counter = dist_abs.max/speed
    counter.times do
      sprites.each_with_index do |sprite, i|
        sprite.x += distance[0]/(counter) if sprite.x != final_destinations["#{i}x"]
        sprite.y += distance[1]/(counter) if sprite.y != final_destinations["#{i}y"]
      end
      pbWait(1)
    end
    new_distance = [final_destinations["0x"]-sprites[0].x, final_destinations["0y"]-sprites[0].y]
    if fds == {}
      move_sprites_smooth(sprites, new_distance, speed/2, final_destinations)
    else
      sprites.each_with_index do |sprite, i|
        sprite.x = final_destinations["#{i}x"]
        sprite.y = final_destinations["#{i}y"]
      end
    end
  end

  def pbEndScene
    Graphics.freeze
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbSEPlay("PC Close")
    Graphics.transition(10, "Graphics/Transitions/computertrclose")
  end
end