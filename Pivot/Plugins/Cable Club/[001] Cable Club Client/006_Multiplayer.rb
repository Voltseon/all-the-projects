$Partners = []
$Connections = []
$Client_id = 1

module CableClub
  def self.session(msgwindow, partner_trainer_id, regionindex)
    host,port = get_server_info(regionindex)
    timer = 0
    partner_trainer_id = partner_trainer_id.to_i if partner_trainer_id.is_a?(String)
    Connection.open(host,port) do |connection|
      state = :await_server
      last_state = nil
      client_id = 0
      partner_name = nil
      partner_trainer_type = nil
      frame = 0
      activity = nil
      seed = nil
      battle_type = nil
      chosen = nil
      partner_chosen = nil
      partner_confirm = false

      loop do
        if state != last_state
          last_state = state
          frame = 0
        else
          frame += 1
        end

        Graphics.update
        Input.update

        case state
        # Waiting to be connected to the server.
        # Note: does nothing without a non-blocking connection.
        when :await_server
          if connection.can_send?
            connection.send do |writer|
              writer.sym(:find)
              writer.str(Settings::GAME_VERSION)
              writer.int(partner_trainer_id.to_i)
              writer.str($player.name)
              writer.int($player.id)
              writer.sym($player.trainer_type)
            end
            state = :await_partner
          end

        # Waiting to be connected to the partner.
        when :await_partner
          connection.update do |record|
            case (type = record.sym)
            when :found
              client_id = record.int
              partner_name = record.str
              partner_trainer_type = record.sym
              state = :connect
            else
              raise "Unknown message: #{type}"
            end
          end
        when :connect
          $Partners.push(Partner.new(partner_trainer_id, partner_name))
          $Connections.push(connection)
          return true
        else
          raise "Unknown state: #{state}"
        end
        if timer > 300
          #connection.dispose
          #break
        end
        timer += 1
      end
    end
    return false
  end

  @@ractors = []

  def self.start_update
    $game_variables[27] = $Partners.length if $player
    return if $Connections.empty?
    return if $Partners.empty?
    $game_temp.partner_state = :cant if pbMapInterpreterRunning? || $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
    @@ractors.clear
    $Connections.each_with_index do |c, i|
      @@ractors << Ractor.new($Client_id, pbGet(46), c, $Partners[i], $player, $game_player, $game_map.map_id, $game_temp) { |clientid, map_name, connection, partner, player, game_player, map_id, game_temp|
        begin
          if connection.can_send?
            connection.send do |writer|
              # Send over your client id
              writer.int(clientid)
    
              # Send over trainer data
              writer.sym(player.character_id)
              writer.int(player.character_ID)
              writer.int(player.character.attack.to_i.round)
              writer.bool(player.being_hit)
              writer.int(player.stocks)
              writer.int(player.current_hp)
              writer.int(player.max_hp)
              writer.sym(player.transformed)
    
              # Send over attack data
              Move.each do |attack|
                attack = attack.internal
                writer.int(game_temp.attack_data[attack][0].round)
                writer.int(game_temp.attack_data[attack][1].round)
                writer.bool(game_temp.attack_data[attack][2])
                writer.bool(game_temp.attack_data[attack][3])
                writer.int(game_temp.attack_data[attack][4].round)
                writer.int(game_temp.attack_data[attack][5].round)
                writer.bool(game_temp.attack_data[attack][6])
                writer.int(game_temp.attack_data[attack][7])
                writer.int(game_temp.attack_data[attack][8])
              end
    
              # Send your current location
              writer.int(map_id)
              writer.int(game_player.x)
              writer.int(game_player.y)
              writer.int(game_player.direction)
    
              # Send your current sprite
              writer.str(game_player.character_name)
              writer.int(game_player.pattern)
              writer.int(game_player.bob_height)
              game_temp.sprite_color.each do |c|
                writer.int(c.round)
              end
    
              # Additional sprite settings
              writer.int(game_player.x_offset)
              writer.int(game_player.y_offset)
              writer.int((game_player.real_x * 10).to_i)
              writer.int((game_player.real_y * 10).to_i)
              writer.int(game_temp.dash_location[0])
              writer.int(game_temp.dash_location[1])
              writer.int(game_temp.dash_distance)
              writer.int((game_temp.guard_timer * 100).to_i)
    
              # Send over match data
              writer.bool(game_temp.ready)
              writer.int((game_temp.match_time * 10).to_i)
              writer.int((game_temp.match_time_current * 10).to_i)
              writer.int(game_temp.max_stocks)
              writer.bool(game_temp.in_a_match)
              writer.bool(game_temp.match_ended)
    
              # Send over miscellanious data
              writer.bool(false)#$PokemonGlobal.surfing)
              writer.int(0)#$PokemonGlobal.bridge)
              writer.sym(game_temp.partner_state)
              writer.int(game_temp.last_hit_by)
              writer.int(game_temp.last_hit_id)
              writer.sym(game_temp.latest_move_type_taken)
              writer.int(game_temp.latest_damage_taken)
              writer.sym(map_name)
              writer.int(Time.now)
              writer.str(Settings::GAME_VERSION)
            end
          end
  
          connection.update do |record|
            # Receive partner client id
            partner.client_id = record.int
  
            # Recieve partner trainer data
            partner.character_id = record.sym
            partner.character_ID = record.int
            partner.attack = record.int
            partner.invulnerable = record.bool
            partner.stocks = record.int
            partner.current_hp = record.int
            partner.max_hp = record.int
            partner.transformed = record.sym
  
            # Receive partner attack data
            partner.attack_data = {}
            Move.each do |attack|
              partner.attack_data[attack.internal] = [record.int, record.int, record.bool, record.bool, record.int, record.int, record.bool, record.int, record.int]
            end
  
            # Receive partner location
            partner.map_id = record.int
            partner.x = record.int
            partner.y = record.int
            partner.direction = record.int
  
            # Receive partner sprite
            partner.graphic = record.str
            partner.pattern = record.int
            partner.bob_height = record.int
            partner.sprite_color = [record.int,record.int,record.int,record.int,record.int]
  
            # Additional sprite settings
            partner.x_offset = record.int
            partner.y_offset = record.int
            partner.real_x = (record.int).to_f / 10.0
            partner.real_y = (record.int).to_f / 10.0
            partner.dash_location = [record.int,record.int]
            partner.dash_distance = record.int
            partner.guard_timer = (record.int).to_f / 100.0
  
            # Receive match data
            partner.ready = record.bool
            match_time = (record.int).to_f / 10.0
            match_time_current = (record.int).to_f / 10.0
            max_stocks = record.int
            in_a_match = record.bool
            match_ended = record.bool
            #if partner.client_id == 0
              #$game_temp.match_time = match_time
              #$game_temp.match_time_current = match_time_current
              #$game_temp.max_stocks = max_stocks
              #$game_temp.in_a_match = in_a_match
              #$game_temp.match_ended = match_ended
            #end
  
            # Receive partner data
            partner.surfing = record.bool
            partner.bridge = record.int
            partner.state = record.sym
            partner.last_hit_by = record.int
            partner.last_hit_id = record.int
            partner.latest_move_type_taken = record.sym
            partner.latest_damage_taken = record.int
            partner_arena = record.sym
            #setArena(partner_arena) if partner.client_id == 0
            received_ping = record.int
            if partner.client_id == 0
              game_temp.received_ping = received_ping
              game_temp.ping = (Time.now - game_temp.received_ping) * 1000
            end
            partner.version = record.str
            Ractor.make_shareable(partner)
            Ractor.yield partner
          end
        rescue Connection::Disconnected => e
          Ractor.yield :partner_disconnected
        rescue
          Ractor.yield :partner_disconnected
        end
      }
    end
  end

  def self.resolve_update
    return if $Connections.empty?
    return if $Partners.empty?
    # Update the partner event
    $Partners.length.times do |i|
      ractor_yield = @@ractors[i].take
      if ractor_yield == :partner_disconnected
        partner_disconnected($Connections[i], i, $Partners[i].client_id ? pbMapInterpreter.get_character_by_name("partner#{i+1}") : nil)
        next
      end
      $Partners[i] = ractor_yield
      if $Partners[i].client_id == 0
        $game_temp.match_time = match_time
        $game_temp.match_time_current = match_time_current
        $game_temp.max_stocks = max_stocks
        $game_temp.in_a_match = in_a_match
        $game_temp.match_ended = match_ended
      end
      if $Partners[i]
        if partner_event
          if $game_map.map_id == $Partners[i].map_id
            partner_event.character_name = $Partners[i].graphic
            partner_event.pattern = $Partners[i].pattern
            partner_event.bob_height = $Partners[i].bob_height
            partner_event.moveto($Partners[i].x, $Partners[i].y) unless $Partners[i].x == $game_player.x && $Partners[i].y == $game_player.y
            partner_event.direction = $Partners[i].direction
            partner_event.x_offset = $Partners[i].x_offset
            partner_event.y_offset = $Partners[i].y_offset
            partner_event.real_x = $Partners[i].real_x
            partner_event.real_y = $Partners[i].real_y
          else
            partner_event.character_name = ""
            partner_event.moveto(0,0)
          end
        end

        # Interact stuffs
        case $game_temp.partner_state
        when :decline
          $game_temp.partner_state = :possible
        when :possible
          if $Partners[i].state == "interact_#{$Client_id}".to_sym
            $game_temp.partner_state = "interacting_#{$Partners[i].client_id}".to_sym
          end
        when :cant

        when "interact_#{$Client_id}".to_sym
          if pbConfirmMessage("#{$Partners[i].name} would like to speak. Accept?")
            $game_temp.partner_state = :decline
          end
        when "interacting_#{$Partners[i].client_id}".to_sym

        when "interact_#{$Partners[i].client_id}".to_sym
          if $Partners[i].state == :decline
            pbMessage("#{$Partners[i].name} declined...")
          elsif $Partners[i].state == "interact_#{$Client_id}".to_sym
            $game_temp.partner_state = "interacting_#{$Partners[i].client_id}".to_sym
          elsif $Partners[i].state == "interacting_#{$Client_id}".to_sym
            $game_temp.partner_state = "interacting_#{$Partners[i].client_id}".to_sym
          end
        end
      else
        $Partners.delete_at(i)
        if partner_event
          partner_event.character_name = ""
          partner_event.moveto(0,0)
        end
        $game_variables[27] = $Partners.length
        $game_map.need_refresh = true
        connection.dispose
        $Connections.delete_at(i)
      end
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

def randomid
  $player.id = rand(2**16) | (rand(2**16) << 16)
  $player.name = "ENLS"
end

def update_multiplayer
  $game_variables[27] = $Partners.length if $player
  #return if $Connections.empty?
  return if $Partners.empty?
  $game_temp.partner_state = :cant if pbMapInterpreterRunning? || $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
  $Connections.each_with_index do |connection, i|
    next if connection.nil?
    begin
      partner_event = $Partners[i].client_id ? pbMapInterpreter.get_character_by_name("partner#{i+1}") : nil
    
      if connection.can_send?
        connection.send do |writer|
          # Send over your client id
          writer.int($Client_id)

          # Send over trainer data
          writer.sym($player.character_id)
          writer.int($player.character_ID)
          writer.int($player.character.attack.to_i.round)
          writer.bool($player.being_hit)
          writer.int($player.stocks)
          writer.int($player.current_hp)
          writer.int($player.max_hp)
          writer.sym($player.transformed)

          # Send over attack data
          Move.each do |attack|
            attack_data = $game_temp.attack_data[attack.internal]
            writer.int(attack_data[0].round)
            writer.int(attack_data[1].round)
            writer.bool(attack_data[2])
            writer.bool(attack_data[3])
            writer.int(attack_data[4].round)
            writer.int(attack_data[5].round)
            writer.bool(attack_data[6])
            writer.int(attack_data[7])
            writer.int(attack_data[8])
          end

          # Send your current location
          writer.int($game_map.map_id)
          writer.int($game_player.x)
          writer.int($game_player.y)
          writer.int($game_player.direction)

          # Send your current sprite
          writer.str($game_player.character_name)
          writer.int($game_temp.animation_id)
          $game_temp.animation_id = 0
          writer.int($game_player.pattern)
          writer.int($game_player.bob_height)
          $game_temp.sprite_color.each do |c|
            writer.int(c.round)
          end

          # Additional sprite settings
          writer.int($game_player.x_offset)
          writer.int($game_player.y_offset)
          writer.int(($game_player.real_x * 10).to_i)
          writer.int(($game_player.real_y * 10).to_i)
          writer.int($game_temp.dash_location[0])
          writer.int($game_temp.dash_location[1])
          writer.int($game_temp.dash_distance)
          writer.int(($game_temp.guard_timer * 100).to_i)

          # Send over match data
          writer.bool($game_temp.ready)
          writer.int(($game_temp.match_time * 10).to_i)
          writer.int(($game_temp.match_time_current * 10).to_i)
          writer.int($game_temp.max_stocks)
          #writer.bool($game_temp.in_a_match)
          writer.bool($game_temp.match_ended)

          # Send over miscellanious data
          writer.bool($PokemonGlobal.surfing)
          writer.int($PokemonGlobal.bridge)
          writer.sym($game_temp.partner_state)
          writer.int($game_temp.last_hit_by)
          writer.int($game_temp.last_hit_id)
          writer.sym($game_temp.latest_move_type_taken)
          writer.int($game_temp.latest_damage_taken)
          writer.sym(pbGet(46))
          writer.bool($game_temp.start_match_calling)
          writer.str(Settings::GAME_VERSION)
        end
      end

      connection.update do |record|
        # Receive partner client id
        $Partners[i].client_id = record.int

        # Recieve partner trainer data
        $Partners[i].character_id = record.sym
        $Partners[i].character_ID = record.int
        $Partners[i].attack = record.int
        $Partners[i].invulnerable = record.bool
        $Partners[i].stocks = record.int
        $Partners[i].current_hp = record.int
        $Partners[i].max_hp = record.int
        $Partners[i].transformed = record.sym

        # Receive partner attack data
        $Partners[i].attack_data = {} if !$Partners[i].attack_data
        Move.each do |attack|
          $Partners[i].attack_data[attack.internal] = [record.int, record.int, record.bool, record.bool, record.int, record.int, record.bool, record.int, record.int]
        end

        # Receive partner location
        $Partners[i].map_id = record.int
        $Partners[i].x = record.int
        $Partners[i].y = record.int
        $Partners[i].direction = record.int

        # Receive partner sprite
        $Partners[i].graphic = record.str
        $Partners[i].animation_id = record.int
        $Partners[i].pattern = record.int
        $Partners[i].bob_height = record.int
        $Partners[i].sprite_color = [record.int,record.int,record.int,record.int,record.int]

        # Additional sprite settings
        $Partners[i].x_offset = record.int
        $Partners[i].y_offset = record.int
        $Partners[i].real_x = (record.int).to_f / 10.0
        $Partners[i].real_y = (record.int).to_f / 10.0
        $Partners[i].dash_location = [record.int,record.int]
        $Partners[i].dash_distance = record.int
        $Partners[i].guard_timer = (record.int).to_f / 100.0

        # Receive match data
        $Partners[i].ready = record.bool
        match_time = (record.int).to_f / 10.0
        match_time_current = (record.int).to_f / 10.0
        max_stocks = record.int
        #in_a_match = record.bool
        match_ended = record.bool
        if $Partners[i].client_id == 0
          $game_temp.match_time = match_time
          $game_temp.match_time_current = match_time_current
          $game_temp.max_stocks = max_stocks
          #$game_temp.in_a_match = in_a_match
          $game_temp.match_ended = match_ended
        end

        # Receive partner data
        $Partners[i].surfing = record.bool
        $Partners[i].bridge = record.int
        $Partners[i].state = record.sym
        $Partners[i].last_hit_by = record.int
        $Partners[i].last_hit_id = record.int
        $Partners[i].latest_move_type_taken = record.sym
        $Partners[i].latest_damage_taken = record.int
        partner_arena = record.sym
        start_match = record.bool
        if $Partners[i].client_id == 0
          setArena(partner_arena)
          $game_temp.start_match_calling = start_match
        end
        $Partners[i].version = record.str
      end

      # Update the partner event
      if $Partners[i]
        if partner_event
          if $game_map.map_id == $Partners[i].map_id
            partner_event.character_name = $Partners[i].graphic
            partner_event.animation_id = $Partners[i].animation_id
            partner_event.pattern = $Partners[i].pattern
            partner_event.bob_height = $Partners[i].bob_height
            partner_event.moveto($Partners[i].x, $Partners[i].y) unless $Partners[i].x == $game_player.x && $Partners[i].y == $game_player.y
            partner_event.direction = $Partners[i].direction
            partner_event.x_offset = $Partners[i].x_offset
            partner_event.y_offset = $Partners[i].y_offset
            partner_event.real_x = $Partners[i].real_x
            partner_event.real_y = $Partners[i].real_y
          else
            partner_event.character_name = ""
            partner_event.moveto(0,0)
          end
        end

        # Interact stuffs
        case $game_temp.partner_state
        when :decline
          $game_temp.partner_state = :possible
        when :possible
          if $Partners[i].state == "interact_#{$Client_id}".to_sym
            $game_temp.partner_state = "interacting_#{$Partners[i].client_id}".to_sym
          end
        when :cant

        when "interact_#{$Client_id}".to_sym
          if pbConfirmMessage("#{$Partners[i].name} would like to speak. Accept?")
            $game_temp.partner_state = :decline
          end
        when "interacting_#{$Partners[i].client_id}".to_sym

        when "interact_#{$Partners[i].client_id}".to_sym
          if $Partners[i].state == :decline
            pbMessage("#{$Partners[i].name} declined...")
          elsif $Partners[i].state == "interact_#{$Client_id}".to_sym
            $game_temp.partner_state = "interacting_#{$Partners[i].client_id}".to_sym
          elsif $Partners[i].state == "interacting_#{$Client_id}".to_sym
            $game_temp.partner_state = "interacting_#{$Partners[i].client_id}".to_sym
          end
        end
      else
        $Partners.delete_at(i)
        if partner_event
          partner_event.character_name = ""
          partner_event.moveto(0,0)
        end
        $game_variables[27] = $Partners.length
        $game_map.need_refresh = true
        connection.dispose
        $Connections.delete_at(i)
      end
    rescue Connection::Disconnected => e
      partner_disconnected(connection, i, partner_event, e)
    rescue
      partner_disconnected(connection, i, partner_event)
    end
  end
end

def partner_disconnected(connection, i, partner_event, reason="unknown error")
  return unless $game_temp.in_a_match
  partner_name = $Partners[i].name
  partner_character = $Partners[i].character_id
  partner_id = $Partners[i].client_id
  spectator = $Partners[i].client_id > 3
  $Partners.delete_at(i)
  if partner_event
    partner_event.character_name = ""
    partner_event.moveto(0,0)
  end
  $game_variables[27] = $Partners.length
  $game_map.need_refresh = true
  connection.dispose
  $Connections.delete_at(i)
  spectator ? notification("Spectator left",partner_name) : notification("Disconnected",partner_name,"Graphics/Characters/#{partner_character}/icon")
  $Client_id -= 1 if partner_id == 0
end

def get_partner_by_id(id)
  $Partners.each do |partner|
    return partner if partner.client_id == id
  end
  return nil
end

module Graphics
  unless defined?(g_update)
    class << Graphics
      alias g_update update
    end
  end

  def self.update
    g_update
    update_multiplayer
  end
end

class Game_Temp
  attr_accessor :partner_state, :animation_id
  def partner_state; @partner_state = :possible if !@partner_state; return @partner_state; end
  def partner_state=(value); @partner_state = value; end

  def animation_id; @animation_id = 0 if !@animation_id; return @animation_id; end
  def animation_id=(value); @animation_id = value; end
end