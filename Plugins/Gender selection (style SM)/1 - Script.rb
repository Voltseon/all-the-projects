#-----------------------------------------------------------#
#-----------------------------------------------------------#
#            Gender Selection (S/M)
#    Credit: bo4p5687, Richard PT (graphics)
#-----------------------------------------------------------#
#-----------------------------------------------------------#
# Script runs normally with 8+ characters and 2+ characters
#-----------------------------------------------------------#
module GenderPickSelection
	class Show

		# When SET_NAME is true, script will use name of bitmap in NAME_OF_BITMAP. (Quantity of names has to equal quantity of characters)
		# When SET_NAME is false, it will use name in file metadata.txt, first line.
		# Example: TrainerType = POKEMONTRAINER_Red -> Name of bitmap need to set POKEMONTRAINER_Red
		SET_NAME = false
		NAME_OF_BITMAP = [
			# Example
			"AvatarA", # Name of first Avatar
			"AvatarB", # Name of second Avatar
			"AvatarC", # Name of third Avatar
			"AvatarD", # Name of fourth Avatar
			"AvatarE", # Name of fifth Avatar
			"AvatarF", # Name of sixth Avatar
			"AvatarG", # Name of seventh Avatar
			"AvatarH"  # Name of eighth Avatar
		]

		def initialize
			@sprites = {}
			# Viewport
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
			# Value
			quantity = GenderPickSelection.quant_registered_player
			@realquant = quantity > 9 ? 9 : quantity
			@player = []
			quantity.times { |i| @player << (SET_NAME ? NAME_OF_BITMAP[i] : GameData::PlayerMetadata.get(i+1).trainer_type) }
			@bg = 0
			@oldbg = 0
			@startnum = 0
			@position = 0
			@exit = false
		end
	end

	def self.quant_registered_player
		first = GameData::PlayerMetadata.get(1)
		i = 2
		loop do
			meta = GameData::PlayerMetadata.get(i)
			meta != first ? i += 1 : (break)
		end
		return i - 1
	end

	def self.show
		s = Show.new
		s.show
		s.endScene
	end
end