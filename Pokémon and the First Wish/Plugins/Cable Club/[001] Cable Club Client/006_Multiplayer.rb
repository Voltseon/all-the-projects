MULTIPLAYER_MAPS = [33]

$Partners = []
$Connections = []
$Client_id = 0

def pbInteractPartner(partnerId)
  return unless $Partners[partnerId] && $Partners[partnerId].is_a?(Partner)
  if $Partners[partnerId].partner_state == :possible
    $game_temp.partner_state = "interact_#{$Partners[partnerId].client_id}".to_sym
  else
    pbDisplayMessageBrief("#{$Partners[partnerId].name} is busy...", )
  end
end

def pbInteractPartnerFollower(partnerId)
  return unless $Partners[partnerId] && $Partners[partnerId].is_a?(Partner) && $Partners[partnerId].follower_toggled && $Partners[partnerId].follower_pokemon
  EventHandlers.trigger_2(:following_pkmn_talk, $Partners[partnerId].follower_pokemon, rand(6))
end

def pbCreateRoom(roomId)
  if roomId < 10000 || roomId.nil?
    pbMessage("Room id: #{roomId} is not valid!")
    return
  end
  check_valid = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Check"})
  if !check_valid.include?("Empty room")
    pbMessage("Room id: #{roomId} is not valid!")
    return
  end
  ret = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Create"})
  echoln ret
  if ret == "made"
    $Client_id = 0
    pbJoinRoom(roomId)
  else
    pbMessage("Something went wrong with creating room #{roomId}")
  end
end

def pbJoinRoom(roomId=nil)
  if roomId < 10000 || roomId.nil?
    pbMessage("Room #{roomId} is not available!")
    return
  end
  check_valid = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Check"})
  if check_valid.include?("#{$player.public_ID($player.id)}")
    pbMessage("Room #{roomId} is not available!")
    return
  end
  ret = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Join"})
  echoln ret
  if ret == "joined"
    frame = 0
    my_partners = []
    until ret == "Empty room"
      echoln ret
      Graphics.update
      Input.update
      $scene.update
      if ret.include?('&^#')
        partners = ret.split('&^*#@')
        partners.each do |prt|
          next if prt.nil?
          partner = prt.split('&^#')
          next if my_partners.any? { |a| a.include?(partner[1].to_i) }
          if partner[1].to_i == $player.public_ID($player.id)
            $Client_id = partner[0].to_i-1
            next
          end
          my_partners.push([partner[1].rjust(5, '0').to_i, partner[2].to_s])
        end
      end
      if Input.pressex?(:O)
        pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Leave"})
        pbMessage("Left the room...")
        return
      elsif Input.pressex?(:P) && $Client_id == 0
        pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Delete"})
        break
      end
      if frame%60==0
        ret = pbWebRequest({:ROOM_ID => roomId, :ROOM_METHOD => "Check"})
      end
      frame += 1
    end
    $Connections = []
    if my_partners.empty?
      echoln "Something went wrong"
      pbMessage("Something went wrong")
      return
    end
    my_partners.each do |prtnr|
      CableClub::session(nil, prtnr[0])
    end
  else
    pbMessage("Something went wrong with joining room #{roomId}")
  end
end

def pbWebRequest(request)
  request[:GAME_ID] = "FirstWish"
  request[:PLAYER_ID] = $player.public_ID($player.id)
  request[:PLAYER_NAME] = $player.name
  request[:PLAYER_LVL] = $player.badge_count
  return pbPostDataPHP("", request).gsub(/\n/,'')
end

def pbSession
  msgwindow = pbCreateMessageWindow()
  begin
    pbMessageDisplay(msgwindow, _ISPRINTF("What's the ID of the trainer you're searching for? (Your ID: {1:05d})\\^",$player.public_ID($player.id)))
    partner_trainer_id = ""
    loop do
      partner_trainer_id = pbFreeText(msgwindow, partner_trainer_id, false, 5)
      return if partner_trainer_id.empty?
      break if partner_trainer_id =~ /^[0-9]{5}$/
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, {1} is not a trainer ID.", partner_trainer_id))
    end
    CableClub::session(msgwindow, partner_trainer_id)
  rescue Connection::Disconnected => e
    case e.message
    when "disconnected"
      pbMessageDisplay(msgwindow, _INTL("Thank you for using the Cable Club. We hope to see you again soon."))
      return true
    when "invalid version"
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, your game version is out of date compared to the Cable Club."))
      return false
    when "invalid party"
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, your party contains Pokémon not allowed in the Cable Club."))
      return false
    when "peer disconnected"
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, the other trainer has disconnected."))
      return true
    else
      pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server has malfunctioned!"))
      return false
    end
  rescue Errno::ECONNREFUSED
    pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club server is down at the moment."))
    return false
  rescue
    pbPrintException($!)
    pbMessageDisplay(msgwindow, _INTL("I'm sorry, the Cable Club has malfunctioned!"))
    return false
  ensure
    pbDisposeMessageWindow(msgwindow)
  end
end

module CableClub
  def self.session(msgwindow, partner_trainer_id)
    host,port = get_server_info
    timer = 0
    Connection.open(host,port) do |connection|
      state = :await_server
      last_state = nil
      client_id = 0
      partner_name = nil
      partner_trainer_type = nil
      partner_party = nil
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
              writer.int(partner_trainer_id)
              writer.str($player.name)
              writer.int($player.id)
              writer.sym($player.online_trainer_type)
              write_party(writer)
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
              partner_party = parse_party(record)
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
end

# Create partner events
EventHandlers.add(:on_enter_map, :create_partner_events,
  proc { |old_map_id|
    next unless $scene.is_a?(Scene_Map)
    3.times do |i|
      event = Rf.create_event do |e|
        e.name = "partner#{i+1}"
        e.x = 0
        e.y = 0
        e.pages[0].condition.variable_id = 27
        e.pages[0].condition.variable_value = i+1
        e.pages[0].trigger = 0
        e.pages[0].list.clear
        Compiler.push_script(e.pages[0].list, "pbInteractPartner(#{i+1})")
        Compiler.push_end(e.pages[0].list)
      end
      follower_event = Rf.create_event do |e|
        e.name = "partner_follower#{i+1}"
        e.x = 0
        e.y = 0
        e.pages[0].condition.variable_id = 27
        e.pages[0].condition.variable_value = i+1
        e.pages[0].trigger = 0
        e.pages[0].list.clear
        Compiler.push_script(e.pages[0].list, "pbInteractPartnerFollower(#{i+1})")
        Compiler.push_end(e.pages[0].list)
      end
    end
  }
)

def update_multiplayer
  $game_variables[27] = $Partners.length if $player
  return if $Connections.empty?
  return if $Partners.empty?
  $game_temp.partner_state = :cant if pbMapInterpreterRunning? || $game_temp.in_menu || $game_temp.in_battle || $game_temp.message_window_showing
  #return unless MULTIPLAYER_MAPS.include?($game_map.map_id)
  $Connections.each_with_index do |connection, i|
    next if connection.nil?
    begin
      partner_event = $Partners[i].client_id ? pbMapInterpreter.get_character_by_name("partner#{i+1}") : nil
      partner_follower_event = $Partners[i].client_id ? pbMapInterpreter.get_character_by_name("partner_follower#{i+1}") : nil
    
      if connection.can_send?
        connection.send do |writer|
          # Send over your client id
          writer.int($Client_id)

          # Send your current location
          writer.int($game_map.map_id)
          writer.int($game_player.x)
          writer.int($game_player.y)
          writer.int($game_player.direction)

          # Send your current sprite
          writer.str($game_player.character_name)
          writer.int($game_player.pattern)
          writer.int($game_player.bob_height)

          # Additional sprite settings
          writer.int($game_player.x_offset)
          writer.int($game_player.y_offset)
          writer.int(($game_player.real_x * 10).to_i)
          writer.int(($game_player.real_y * 10).to_i)
          writer.int($player.outfit_hues[0])
          writer.int($player.outfit_hues[1])
          writer.int($player.outfit_hues[2])

          # Send over thrown ball data
          writer.sym($game_temp.thrown_ball[0])
          writer.int($game_temp.thrown_ball[1])
          writer.int($game_temp.thrown_ball[2])
          writer.bool($game_temp.thrown_ball[3])

          # Send over Following Pokemon data
          writer.bool(($PokemonGlobal.follower_toggled.nil? ? false : $PokemonGlobal.follower_toggled))
          follower = FollowingPkmn.get_event
          writer.str((follower ? follower.character_name : ""))
          writer.int((follower ? follower.pattern : 0))
          writer.int((follower ? follower.bob_height : 0))
          writer.int((follower ? follower.direction : 0))
          writer.int((follower ? follower.x : 0))
          writer.int((follower ? follower.y : 0))
          writer.int((follower ? follower.x_offset : 0))
          writer.int((follower ? follower.y_offset : 0))
          writer.int((follower ? (follower.real_x * 10).to_i : 0))
          writer.int((follower ? (follower.real_y * 10).to_i : 0))
          CableClub::write_pkmn(writer, FollowingPkmn.get_pokemon)

          # Send over miscellanious data
          writer.bool($PokemonGlobal.surfing)
          writer.bool($PokemonGlobal.bicycle)
          writer.int($PokemonGlobal.mounted_pkmn)
          writer.int($PokemonGlobal.bridge)
          writer.sym($game_temp.partner_state)

          # Send over party
          CableClub::write_party(writer)
        end
      end

      connection.update do |record|
        # Receive partner client id
        $Partners[i].client_id = record.int

        # Receive partner location
        $Partners[i].map_id = record.int
        $Partners[i].x = record.int
        $Partners[i].y = record.int
        $Partners[i].direction = record.int

        # Receive partner sprite
        $Partners[i].graphic = record.str
        $Partners[i].pattern = record.int
        $Partners[i].bob_height = record.int

        # Additional sprite settings
        $Partners[i].x_offset = record.int
        $Partners[i].y_offset = record.int
        $Partners[i].real_x = (record.int).to_f / 10
        $Partners[i].real_y = (record.int).to_f / 10
        $Partners[i].outfit_hues = [record.int,record.int,record.int]

        # Receive thrown ball data
        $Partners[i].thrown_ball = [
          record.sym, record.int,
          record.int, record.bool
        ]

        # Receive Following Pokemon data
        $Partners[i].follower_toggled = record.bool
        $Partners[i].follower_graphic = record.str
        $Partners[i].follower_pattern = record.int
        $Partners[i].follower_bob_height = record.int
        $Partners[i].follower_direction = record.int
        $Partners[i].follower_x = record.int
        $Partners[i].follower_y = record.int
        $Partners[i].follower_x_offset = record.int
        $Partners[i].follower_y_offset = record.int
        $Partners[i].follower_real_x = (record.int).to_f / 10
        $Partners[i].follower_real_y = (record.int).to_f / 10
        $Partners[i].follower_pokemon = CableClub::parse_pkmn(record)

        # Receive partner data
        $Partners[i].surfing = record.bool
        $Partners[i].mounting = record.bool
        $Partners[i].mounted_pkmn = record.int
        $Partners[i].bridge = record.int
        $Partners[i].state = record.sym

        # Receive partner party
        $Partners[i].party = CableClub::parse_party(record)
      end

      # Update the partner event
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
        if partner_follower_event
          if $game_map.map_id == $Partners[i].map_id && !$Partners[i].mounting
            partner_follower_event.character_name = $Partners[i].follower_graphic
            partner_follower_event.pattern = $Partners[i].follower_pattern
            partner_follower_event.bob_height = $Partners[i].follower_bob_height
            partner_follower_event.moveto($Partners[i].follower_x, $Partners[i].follower_y) unless $Partners[i].follower_x == $game_player.x && $Partners[i].follower_y == $game_player.y
            partner_follower_event.direction = $Partners[i].follower_direction
            partner_follower_event.x_offset = $Partners[i].follower_x_offset
            partner_follower_event.y_offset = $Partners[i].follower_y_offset
            partner_follower_event.real_x = $Partners[i].follower_real_x
            partner_follower_event.real_y = $Partners[i].follower_real_y
          else
            partner_follower_event.character_name = ""
            partner_follower_event.moveto(0,0)
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
        if partner_follower_event
          partner_follower_event.character_name = ""
          partner_follower_event.moveto(0,0)
        end
        $game_variables[27] = $Partners.length
        $game_map.need_refresh = true
        connection.dispose
        $Connections.delete_at(i)
      end
    rescue
      $Partners.delete_at(i)
      if partner_event
        partner_event.character_name = ""
        partner_event.moveto(0,0)
      end
      if partner_follower_event
        partner_follower_event.character_name = ""
        partner_follower_event.moveto(0,0)
      end
      $game_variables[27] = $Partners.length
      $game_map.need_refresh = true
      connection.dispose
      $Connections.delete_at(i)
    end
  end
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
  attr_accessor :partner_state
  def partner_state; @partner_state = :possible if !@partner_state; return @partner_state; end
  def partner_state=(value); @partner_state = value; end
end