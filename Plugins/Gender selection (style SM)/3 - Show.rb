module GenderPickSelection
	class Show

		def show
      Graphics.freeze
			create_scene
      update_ingame
      update_scene
      set_input
      update_player
      pbSEPlay("GUI party switch")
      Graphics.transition(10, "Graphics/Transitions/021-Normal01")
			loop do
				break if @exit
				# Update
				update_ingame
				update_scene
				set_input
				update_player
			end
		end

		def create_scene
			# Background
			create_sprite("bg", "BackgroundSelect", @viewport)
			# Bitmap
			@realquant.times { |i|
				create_sprite("player #{i}", @player[i], @viewport)
				@sprites["player #{i}"].z = 1
			}
		end

		#-------#
		# Input #
		#-------#
		def set_input
			if @bg == 1
				if pbConfirmMessage("\\rAre you sure that's what you look like?")
					pbChangePlayer(@position + 1)
          case @position
          when 0, 3, 6 then pbSet(28,0)
          when 1, 4, 7 then pbSet(28,1)
          when 2, 5, 8 then pbSet(28,2)
          end
					@exit = true
				else
					@bg = 0
					@refresh = true
				end
				return
			end
			@bg = 1 if checkInput(Input::USE)
			if checkInput(Input::UP)
				if @position < 3
					@position += 6
				else
					@position -= 3
				end
				if @position < @startnum
					if (@startnum - 1) >= 0
						@startnum -= 1
						@position  = @startnum
					elsif (@startnum - 1) < 0
						@startnum = @player.size - @realquant
						@position = @startnum + @realquant - 1
					end
					@refresh = true
				end
			elsif checkInput(Input::DOWN)
				if @position > 5
					@position -= 6
				else
					@position += 3
				end
				limit = @startnum + @realquant - 1
				if @position > limit
					if (limit + 1 + 1) <= @player.size
						@startnum += 1
						@position  = @startnum + @realquant - 1
					elsif (limit + 1 + 1) > @player.size
						@startnum = 0
						@position = 0
					end
					@refresh = true
				end
			elsif checkInput(Input::LEFT)
				if [0,3,6].include?(@position)
					@position += 2
				else
					@position -= 1
				end
				if @position < @startnum
					if (@startnum - 2) >= -1
						@startnum -= 2
						if @startnum < 0
							@startnum = 0 
							@position = @startnum
						end
					elsif (@startnum - 2) < -1
						@startnum = @player.size - @realquant
						@position = @startnum + @realquant - 1
					end
					@refresh = true
				end
			elsif checkInput(Input::RIGHT)
				if [2,5,8].include?(@position)
					@position -= 2
				else
					@position += 1
				end
				limit = @startnum + @realquant - 1
				if @position > limit
					if (limit + 1 + 2) <= @player.size + 1
						@startnum += 2
						@startnum  = @player.size - @realquant if @startnum + @realquant > @player.size
						@position  = @startnum + @realquant - 1 if @position >= @player.size
					elsif (limit + 1 + 2) > @player.size + 1
						@startnum = 0
						@position = 0
					end
					@refresh = true
				end

			end
		end

		#--------#
		# Update #
		#--------#
		def update_scene
			return if @oldbg == @bg
			file = 
				case @bg
				when 0 then "BackgroundSelect"
				when 1 then "Background"
				end
			set_sprite("bg", file)
			@oldbg = @bg
		end

		def update_player
			male = [0,1,2]
			female = [3,4,5] #118
			other = [6,7,8] #236
			case @bg
			when 0
				@realquant.times { |i|
					set_visible_sprite("player #{i}", true)
					if @refresh
						player = update_bitmap
						set_sprite("player #{i}", player[i])
					end
					y = 24
					case i
					when 0
						x = 82
					when 1
						x = 206
					when 2
						x = 330
					when 3
						x = 82
						y += 118
					when 4
						x = 206
						y += 118
					when 5
						x = 330
						y += 118
					when 6
						x = 82
						y += 236
					when 7
						x = 206
						y += 236
					when 8
						x = 330
						y += 236
					end

					set_xy_sprite("player #{i}", x, y)
					@sprites["player #{i}"].opacity = (@startnum + i) == @position ? 255 : 150
				}
				@refresh = false if @refresh
			when 1
				@realquant.times { |i|
					if (@startnum + i) == @position
						set_xy_sprite("player #{i}", 206, 104)
						next
					end
					set_visible_sprite("player #{i}")
				}
			end
		end

		def update_bitmap
			player = []
			n = @startnum + @realquant
			(@startnum...n).each { |i| player << @player[i] }
			return player
		end

	end
end