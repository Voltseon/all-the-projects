#-----------------------------------------------------#
#-----------------------------------------------------#
# Credit: KleinStudio (original), bo4p5687 (update)
#-----------------------------------------------------#
#-----------------------------------------------------#

module ItemHandlers
	AnimationForm = ItemHandlerHash.new

	# Shows "Use" option in Bag
	def self.hasOutHandler(item)
    return !UseFromBag[item].nil? || !UseInField[item].nil? || !UseOnPokemon[item].nil? || !AnimationForm[item].nil?
  end

	def self.hasUseOnPokemon(item)
    return !UseOnPokemon[item].nil? || !AnimationForm[item].nil?
  end

	def self.triggerAnimationForm(item, pkmn, scene, choice)
    return false if !AnimationForm[item]
    return AnimationForm.trigger(item, pkmn, scene, choice)
	end
end

module ChangeFormAnimation
	DIR = "Graphics/Pokemon/Animation Change Form"

	def self.normal(pkmnname, pkmnsprite, form = 0)
		vp = Viewport.new(0,0,Graphics.width,Graphics.height)
    vp.z = 999999
		# Pokemon
		sprite = Sprite.new(vp)
		file  = "#{DIR}/#{pkmnname}"
		file += "_#{form}" if form != 0
		sprite.bitmap = Bitmap.new(file)
		sprite.src_rect.width = sprite.bitmap.height
		sprite.ox = sprite.bitmap.height / 2
		sprite.oy = sprite.bitmap.height / 2
		sprite.x  = pkmnsprite.x + 20
		sprite.y  = pkmnsprite.y + 30
		# Animation
		div  = sprite.bitmap.width / sprite.bitmap.height
		half = div / 2
		div.times { |i|
			Graphics.update
			sprite.update
			sprite.src_rect.x += sprite.bitmap.height
			if i == half
				yield if block_given?
			end
		}
		sprite.dispose
		vp.dispose
	end

	def self.fusion(pkmnname1, pkmnsprite1, form1, pkmnname2, pkmnsprite2, form2)
		vp = Viewport.new(0,0,Graphics.width,Graphics.height)
    vp.z = 999999
		# Pokemon 1
		sprite1 = Sprite.new(vp)
		file  = "#{DIR}/#{pkmnname1}"
		file += "_#{form1}" if form1 != 0
		sprite1.bitmap = Bitmap.new(file)
		sprite1.src_rect.width = sprite1.bitmap.height
		sprite1.ox = sprite1.bitmap.height / 2
		sprite1.oy = sprite1.bitmap.height / 2
		sprite1.x = pkmnsprite1.x + 60
		sprite1.y = pkmnsprite1.y + 30
		div1 = sprite1.bitmap.width / sprite1.bitmap.height
		half = div1 / 2
		# Pokemon 2
		sprite2 = Sprite.new(vp)
		file  = "#{DIR}/#{pkmnname2}"
		file += "_#{form2}" if form2 != 0
		sprite2.bitmap = Bitmap.new(file)
		sprite2.src_rect.width = sprite2.bitmap.height
		sprite2.ox = sprite2.bitmap.height / 2
		sprite2.oy = sprite2.bitmap.height / 2
		sprite2.x = pkmnsprite2.x + 60
		sprite2.y = pkmnsprite2.y + 30
		div2 = sprite2.bitmap.width / sprite2.bitmap.height
		# Animation
		diff = div1 - div2
		div1.times { |i|
			Graphics.update
			sprite1.update
			sprite2.update
			sprite1.src_rect.x += sprite1.bitmap.height
			sprite2.src_rect.x += sprite2.bitmap.height if sprite2.src_rect.x + sprite2.bitmap.height < sprite2.bitmap.width
			if i == half
				yield if block_given?
			end
		}
		if diff < 0
			diff.abs.times { |i|
				Graphics.update
				sprite2.update
				sprite2.src_rect.x += sprite2.bitmap.height
			} 
		end
		sprite1.dispose
		sprite2.dispose
		vp.dispose
	end

end

class PokemonParty_Scene
	def change_form_animation(name, partynum, form) = ChangeFormAnimation.normal(name, @sprites["pokemon#{partynum}"], form) { yield if block_given? }
	def change_form_animation_fusion(name1, partynum1, form1, name2, partynum2, form2) = ChangeFormAnimation.fusion(name1, @sprites["pokemon#{partynum1}"], form1, name2, @sprites["pokemon#{partynum2}"], form2) { yield if block_given? }
end

class PokemonPartyScreen
	def change_form_animation(name, partynum, form) = @scene.change_form_animation(name, partynum, form) { yield if block_given? }
	def change_form_animation_fusion(name1, partynum1, form1, name2, partynum2, form2) = @scene.change_form_animation_fusion(name1, partynum1, form1, name2, partynum2, form2) { yield if block_given? }
end