module CheckStatsInBattle

	class Show

		def initialize(team, quantity, activestore)
			player, opponent = team
			activef, actives, activep = activestore
			# Start
			@sprites = {}
			# Viewport
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
			# Array
			@name = []
			@pkmn = []
			player[:name].each_with_index { |name, i| @name[2*i] = name }
			player[:pkmn].each_with_index { |pkmn, i| @pkmn[2*i] = pkmn }
			opponent[:name].each_with_index { |name, i| @name[2*i+1] = name } if opponent[:name].size != 0
			opponent[:pkmn].each_with_index { |pkmn, i| @pkmn[2*i+1] = pkmn }
			@quant = {}
			@quant[:player]   = quantity[0]
			@quant[:opponent] = quantity[1]
			# Value
			@bg = 1
			@chose = false
			@position = 0
			@exit = false
			# Frame
			@frames = 0
			@iconw  = 0
			# Field, side, postion
			@active  = 0
			@activef = activef
			@activep = activep
			@actives = actives
			@framesactive = 0
			@originactive = 0
		end

		def set_active_size
			# Reset
			@showactive = []
			# Set
			@showactive << @activef if @activef.size > 0
			@showactive << @actives if @actives[@position%2].size > 0
			@showactive << @activep if @activep[@position].size > 0
		end

	end

	def self.show(team, quantity, activestore)
		s = Show.new(team, quantity, activestore)
		s.show
		s.endScene
	end

end