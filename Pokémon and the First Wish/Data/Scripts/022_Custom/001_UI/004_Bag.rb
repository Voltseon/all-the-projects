class BagUI
	BASE_COLOR = Color.new(91,51,44)
  SHADOW_COLOR = Color.new(204,174,106)
  BASE_COLOR_ALT = Color.new(45,33,32)
  SHADOW_COLOR_ALT = SHADOW_COLOR
	PATH = "Graphics/Pictures/Bag/"

	def initialize
		$game_temp.in_menu = true
		@sprites = {}
		@viewport = nil
		@disposed = false
		@bag = $bag
		@pocket = @bag.last_viewed_pocket
		pbStartScene
	end

	def pbStartScene
		# Initialize scene objects
		@viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
		@viewport.z = 99999
		@overlay = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@overlay.z = 99999
		@overlay2 = BitmapSprite.new(Graphics.width,Graphics.height,@viewport)
		@overlay2.z = 99999
		pbSetSystemFont(@overlay.bitmap)
		pbSetSmallFont(@overlay2.bitmap)
		# Setup background
		@sprites["background"] = IconSprite.new(0,0,@viewport)
		@sprites["background"].setBitmap(PATH+"bg")
		@sprites["background"].x = (Graphics.width - @sprites["background"].width)/2
    	@sprites["background"].y = (Graphics.height - @sprites["background"].height)/2
		# Buttons
		@sprites["close_button"] = ButtonSprite.new(self,"Close",PATH+"closebutton",PATH+"closebutton_sel",proc{close_bag},619,482,@viewport)
    	@sprites["close_button"].setTextOffset(0,12)
    	@sprites["close_button"].setTextColor(BASE_COLOR,SHADOW_COLOR)
		# Party UI
		$player.party.each_with_index{|pkmn, i|
		# TODO: Replace this with custom party buttonsprite objects
		@sprites["pkmn#{i}"] = PokemonIconSprite.new(pkmn,@viewport)
		@sprites["pkmn#{i}"].x = 611
		@sprites["pkmn#{i}"].y = 60 + 68*i
		@sprites["pkmn#{i}"].z = 99999
		@sprites["pkmn#{i}"].selected = false
		}
		pbTransparentAndShow(@sprites) { pbUpdate }
		pbMain
	end

	def close_bag
		pbSEPlay("page turn")
		pbEndScene
	end

	def pbMain
		loop do
			break if @disposed
			if Input.trigger?(Input::BACK)
        pbSEPlay("page turn")
        break
      end
			@overlay.bitmap.clear
			@overlay2.bitmap.clear
			textpos = []
			textpos2 = []
			pbDrawTextPositions(@overlay.bitmap, textpos)
			pbUpdate
		end
		pbEndScene
	end

	def pbUpdate
		Graphics.update
		Input.update
		$scene.update
		@overlay&.bitmap.clear
		@overlay2&.bitmap.clear
		pbUpdateSpriteHash(@sprites) if @sprites
	end
		

	def pbEndScene
		@disposed = true
		pbDisposeSpriteHash(@sprites)
		@overlay.dispose
		@overlay2.dispose
		@viewport.dispose
		$game_temp.in_menu = false
	end
end
