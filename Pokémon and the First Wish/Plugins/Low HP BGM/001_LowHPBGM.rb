module Settings
  LOW_HP_BGM = "BW 160 A Tight Spot During Battle"
end

class Game_Temp
  attr_accessor :battle_theme
  attr_accessor :battle_theme_position
end

class Battle::Scene::PokemonDataBox < Sprite

  def visible=(value)
    super
    @sprites.each do |i|
      i[1].visible = value if !i[1].disposed?
    end
    @expBar.visible = (value && @showExp)
    if value == true && ((@battler.index%2)==0)
      if @battler.hp<=@battler.totalhp/4
        if $game_system.playing_bgm.name!=Settings::LOW_HP_BGM
          $game_temp.battle_theme_position = (Audio.bgm_pos rescue 0)
          $game_temp.battle_theme = $game_system.getPlayingBGM
          pbBGMPlay(Settings::LOW_HP_BGM)
        end
      else
        low = 0
        @battler.battle.battlers.each_with_index do |b,i|
          next if !b || (b.index%2)==1
          low +=1 if b.hp<b.totalhp/4
        end
        if low == 0 && $game_system.playing_bgm.name==Settings::LOW_HP_BGM && $game_temp.battle_theme   
          $game_system.bgm_play_internal2("Audio/BGM/" + $game_temp.battle_theme.name, 80, 100, $game_temp.battle_theme_position)
          $game_temp.battle_theme = nil
          $game_temp.battle_theme_position = 0
        end
      end
    end
  end
  

  alias oldupdateHPAnimation updateHPAnimation
  def updateHPAnimation
    oldupdateHPAnimation
    return if !@animatingHP
    if ((@battler.index%2)==0)
      if @battler.hp<=@battler.totalhp/4 && @battler.hp>0
        if $game_system.playing_bgm.name!=Settings::LOW_HP_BGM
          $game_temp.battle_theme_position = (Audio.bgm_pos rescue 0)
          $game_temp.battle_theme = $game_system.getPlayingBGM
          pbBGMPlay(Settings::LOW_HP_BGM)
        end
      elsif $game_system.playing_bgm.name==Settings::LOW_HP_BGM
        low = 0
        @battler.battle.battlers.each_with_index do |b,i|
          next if !b || (b.index%2)==1
          low +=1 if b.hp<b.totalhp/4
        end
        if low == 0 && $game_system.playing_bgm.name==Settings::LOW_HP_BGM && $game_temp.battle_theme     
          $game_system.bgm_play_internal2("Audio/BGM/" + $game_temp.battle_theme.name, 80, 100, $game_temp.battle_theme_position)
          $game_temp.battle_theme = nil
          $game_temp.battle_theme_position = 0
        end
      end
    end
  end
  
end

class Battle::Battler

  alias old_pbFaint pbFaint
  def pbFaint(showMessage = true)
    old_pbFaint
    low = 0
    @battle.battlers.each_with_index do |b,i|
      next if !b || (b.index%2)==1
      low +=1 if b.hp<b.totalhp/4 && b.hp > 0
    end
    if low == 0 && $game_system.playing_bgm.name==Settings::LOW_HP_BGM && $game_temp.battle_theme
      $game_system.bgm_play_internal2("Audio/BGM/" + $game_temp.battle_theme.name, 80, 100, $game_temp.battle_theme_position)
      $game_temp.battle_theme = nil
      $game_temp.battle_theme_position = 0
    end
  end
  
end