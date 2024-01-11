#===============================================================================
# * Wall Clock - by FL (Credits will be apreciated)
#===============================================================================
#
# This script is for Pokémon Essentials. It's the Wall Clock from
# Ruby/Sapphire/Emerald.
#
#===============================================================================
#
# To this script works, put it above main and put the pictures at 
# Graphics/Pictures (may works with other sizes):
# -  56x24  clockam
# - 256x256 clockfemale
# - 256x256 clockmale
# -  56x24  clockpm
# -  24x100 clockpointerhour
# -  24x100 clockpointerminute
#
# Command for call this script: 
# 'pbWallClock(true)' for boy clock
# 'pbWallClock(false)' for girl clock
# 'pbWallClock($Trainer.gender==0)' for clock of the player gender
# 'pbWallClock($Trainer.gender!=0)' for clock of the opposite of player gender
#
#===============================================================================

class WallClockScene
    def update
      pbUpdateSpriteHash(@sprites)
    end
    
    IMAGEPATH="Graphics/Pictures/Wall Clock/"
    
    def pbStartScene()
      @sprites={} 
      @viewport=Viewport.new(0,0,Graphics.width,Graphics.height)
      @viewport.z=99999
      @sprites["background"]=IconSprite.new(0,0,@viewport)
      @sprites["background"].bitmap=Bitmap.new(Graphics.width,Graphics.height)
      @sprites["background"].bitmap.fill_rect(0,0,
          @sprites["background"].bitmap.width, 
          @sprites["background"].bitmap.height, Color.new(74,178,189))
      @sprites["clock"]=IconSprite.new(0,0,@viewport)
      @sprites["clock"].setBitmap(IMAGEPATH+"clock_#{$player.gender}")
      @sprites["clock"].x=(Graphics.width-@sprites["clock"].bitmap.width)/2
      @sprites["clock"].y=(Graphics.height-@sprites["clock"].bitmap.height)/2
      @sprites["pointerminute"]=IconSprite.new(0,0,@viewport)
      @sprites["pointerminute"].setBitmap(IMAGEPATH+"clockpointerminute")
      @sprites["pointerminute"].x=@sprites["clock"].x+128
      @sprites["pointerminute"].y=@sprites["clock"].y+128
      @sprites["pointerminute"].ox=12
      @sprites["pointerminute"].oy=88
      @sprites["pointerhour"]=IconSprite.new(0,0,@viewport)
      @sprites["pointerhour"].setBitmap(IMAGEPATH+"clockpointerhour")
      @sprites["pointerhour"].x=@sprites["clock"].x+128
      @sprites["pointerhour"].y=@sprites["clock"].y+128
      @sprites["pointerhour"].ox=12
      @sprites["pointerhour"].oy=88
      pbUpdateClock
      pbFadeInAndShow(@sprites) { update }
    end
    
    def pbUpdateClock
      time = pbGetTimeNow
      @sprites["pointerminute"].angle=(-time.min)*6
      @sprites["pointerhour"].angle=(-time.hour%12)*30+(-time.min)/2
      @sprites["pmam"].dispose if @sprites["pmam"]
      @sprites["pmam"]=IconSprite.new(0,0,@viewport)
      @sprites["pmam"].setBitmap(IMAGEPATH+(
          time.hour>=12 ? "clockpm" : "clockam"))
      @sprites["pmam"].x=@sprites["clock"].x+(
          @sprites["clock"].bitmap.width-@sprites["pmam"].bitmap.width)/2
      @sprites["pmam"].y=@sprites["clock"].y+176
    end  
  
    def pbMain
      secondsForUpdate=5
      loop do
        Graphics.update
        Input.update
        pbUpdateClock if Graphics.frame_count%(
            secondsForUpdate*Graphics.frame_rate)==0
        self.update
        if Input.trigger?(Input::C) || Input.trigger?(Input::B)
          pbSEPlay($data_system.decision_se) 
          break
        end   
      end 
    end
  
    def pbEndScene
      pbFadeOutAndHide(@sprites) { update }
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
    end
  end
  
  class WallClockScreen
    def initialize(scene)
      @scene=scene
    end
  
    def pbStartScreen
      @scene.pbStartScene
      @scene.pbMain
      @scene.pbEndScene
    end
  end
  
  def pbWallClock
    pbFadeOutIn(99999) {
      scene=WallClockScene.new
      screen=WallClockScreen.new(scene)
      screen.pbStartScreen()
    }
  end