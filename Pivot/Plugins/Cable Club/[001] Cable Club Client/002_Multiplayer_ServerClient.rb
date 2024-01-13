$Connection = nil
$Client_id = 1
$ClientPartners = {}

module ServerClient
	TICKS_PER_SECOND = 60

	def self.session(lobby_id, region_index = 2)
		host,port = get_server_info(region_index)
		Connection.open(host,port) do |connection|
			echoln "Connected to #{host}:#{port}"
			echoln "Sending lobby ID..."
			connection.send_msg(lobby_id)
			connection.recv_msg
			echoln "Waiting for server response..."
			frame = 0
			loop do
				Graphics.update
				Input.update
				$scene.update
				if frame*1000 >= 1000/TICKS_PER_SECOND
					connection.send_msg(makePacket)
					frame -= 1000.0/TICKS_PER_SECOND.to_f/1000.0
          pivot(connection.recv_msg)
          $ClientPartners.each_value do |client|
            next if client.nil?
            partner = client[0]
            r_event = client[1][:event]
            event = $game_map.events[r_event.id]
            #next if partner.name == $player.name
            event.real_x = partner.real_x unless partner.real_x.nil?
            event.real_y = partner.real_y unless partner.real_y.nil?
            event.direction = partner.direction unless partner.direction.nil?
            event.character_name = partner.graphic unless partner.graphic.nil?
            event.pattern = partner.pattern unless partner.pattern.nil?
          end
				end
				frame += Graphics.delta_s
			end
		end
	end

  def self.pivot(data)
    return if data.nil?
    data = data.gsub("null", "").split(/(?<=})/)
    data.each_with_index do |d, i|
      partner = Partner.new(i, "")
      partner.client_id = i
      partner.stocks = 0
      d = d.gsub(/[\{\}]/, "").gsub(/\"/, "").gsub("\\", "").split(/,/)
      d.each do |e|
        until e[0] != " "
          e = e[1..-1] if e[0] == " "
        end
        e = e.split(/: /)
        next if e[1].nil?
        case e[0]
        when "name"
          partner.name = e[1]
        when "character"
          partner.character_id = e[1].to_sym
        when "dash_distance"
          partner.dash_distance = e[1].to_i
        when "dash_location"
          partner.dash_location = e[1].split(" ")
          partner.dash_location.each_with_index { |d, i| partner.dash_location[i] = d.to_i }
        when "direction"
          partner.direction = e[1].to_i
        when "graphic"
          partner.graphic = e[1]
        when "hitbox"
          #partner.hitbox = e[1].split(" ")
          #partner.hitbox.each_with_index { |d, i| partner.hitbox[i] = d.to_i }
        when "hp"
          partner.current_hp = e[1].to_i
        when "id"
          partner.id = e[1].to_i
        when "is_dead"
          #partner.is_dead = e[1] == "true"
        when "is_guarding"
          #partner.is_guarding = e[1] == "true"
        when "map"
          #partner.map = e[1].to_i
        when "ready"
          #partner.ready = e[1] == "true"
        when "set"
          #partner.set = e[1] == "true"
        when "real_x"
          partner.real_x = e[1].to_f
        when "real_y"
          partner.real_y = e[1].to_f
        when "sprite_color"
          #partner.sprite_color = e[1].split(" ")
          #partner.sprite_color.each_with_index { |d, i| partner.sprite_color[i] = d.to_f }
        when "transformed"
          #partner.transformed = e[1].to_sym
        when "version"
          #partner.version = e[1]
        when "x"
          partner.x = e[1].to_i
        when "y"
          partner.y = e[1].to_i
        when "pattern"
          partner.pattern = e[1].to_i
        when "setting_stocks"
          #partner.setting_stocks = e[1].to_i
        when "setting_time"
          #partner.setting_time = e[1].to_i
        when "x_offset"
          #partner.x_offset = e[1].to_i
        when "y_offset"
          #partner.y_offset = e[1].to_i
        when "invulnerable"
          #partner.invulnerable = e[1] == "true"
        when "stocks"
          partner.stocks = e[1].to_i
        when "attacks"
          next if e[1].nil?
          partner.attack_data = e[1].split(" ")
          partner.attack_data.each_with_index { |d, i| partner.attack_data[i] = d.to_i }
        when "timer"
          #$game_temp.timer = e[1].to_i
        when "winner"
          #$game_temp.winner = e[1].to_i
        when "game_over"
          #$game_temp.game_over = e[1] == "true"
        end
      end
      if $ClientPartners[i].nil?
        rEvent = Rf.create_event do |event|
          event.x = 0
          event.y = 0
          event.pages[0].graphic.direction = 2
        end
      else
        rEvent = $ClientPartners[i][1]
      end
      $ClientPartners[i] = [partner, rEvent]
    end
  end

	def self.get_server_info(region) # region is an index - 0=EU, 1=NA
		ret = [HOSTS[region][:ip],HOSTS[region][:port]]
		if safeExists?("serverinfo.ini")
			File.foreach("serverinfo.ini") do |line|
				case line
				when /^\s*[Hh][Oo][Ss][Tt]\s*=\s*(.+)$/
					ret[0] = $1 if !nil_or_empty?($1)
				when /^\s*[Pp][Oo][Rr][Tt]\s*=\s*(\d{1,5})$/
					if !nil_or_empty?($1)
						port = $1.to_i
						ret[1] = port if port>0 && port<=65535
					end
				end
			end
		end
		return ret
	end
end