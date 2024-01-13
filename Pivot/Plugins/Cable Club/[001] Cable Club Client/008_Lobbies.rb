def pbCreateLobby(lobby_id, region = 0, arenaId = 0, visibility = 0)
  if lobby_id < 100 || lobby_id.nil?
    pbMessage("Room id: #{lobby_id} is not valid!")
    return
  end
  table_name = "#{lobby_id.to_s}#{visibility.to_s}#{region.to_s}#{sprintf("%02d", arenaId)}"
  check_valid = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Check"})
  if !check_valid.include?("Empty room")
    pbMessage("Lobby ID: #{table_name} is not valid!")
    return
  end
  ret = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Create"})
  if ret == "made"
    $Client_id = 0
    pbJoinLobby(table_name)
  else
    pbMessage("Something went wrong with creating the lobby.")
  end
end

def pbJoinLobby(table_name=nil)
  table_name = table_name.to_s
  visibility = table_name[table_name.length-4].to_i
  region = table_name[table_name.length-3].to_i
  arenaId = table_name[table_name.length-2..table_name.length-2].to_i
  lobby_id = table_name.chop.chop.chop.to_i
  if lobby_id < 100 || lobby_id.nil?
    pbAnnounce(:fools_lobby_not_available) if $april_fools
    pbMessage("Lobby is not available!")
    return
  end
  check_valid = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Check"})
  if check_valid.include?("#{$player.id}")
    pbAnnounce(:fools_lobby_not_available) if $april_fools
    pbMessage("Lobby #{table_name} is not available!")
    return
  end
  if check_valid.scan(/(?=#{"&^*#@"})/).count >= 4
    pbMessage("The lobby is full!")
    return
  end
  ret = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Join"})
  if ret == "joined"
    scene = LobbyMenu.new(lobby_id, table_name)
    scene.pbStartScene
    frame = 0
    my_partners = []
    my_self = [$Client_id,$player.id,$player.name,$player.level, Collectible.get($player.equipped_collectibles[:banner]).banner]
    ret = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Check"})
    until ret == "Empty room"
      my_partners = []
      scene.pbUpdate
      bg = MainMenu::ANIMATED_BGS[MainMenu::BG_GRAPHIC]
      scene.sprites["bg"].changeBitmap(frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]) if scene.sprites["bg"].currentKey != frame % (bg["frames"]*bg["frame_time"])/bg["frame_time"]
      if ret.include?('&^#')
        if !ret.include?("#{$player.id}") && scene.ret_method == 0
          pbAnnounce(:fools_kicked_from_lobby) if $april_fools
          pbMessage("You were kicked from the lobby!\\wtnp[30]")
          scene.leaveRoom
          break
        end
        partners = ret.split('&^*#@')
        partners.each do |prt|
          next if prt.nil?
          partner = prt.split('&^#')
          next if my_partners.any? { |a| a.include?(partner[1].to_i) }
          #echoln "Partner: #{partner[1]}"
          #echoln "Player: #{$player.id}"
          if partner[1] == $player.id || partner[1].to_i == $player.id.to_i
            my_self[0] = partner[0].to_i
            next
          end
          my_partners.push([partner[0].to_i, partner[1].to_i, partner[2].to_s, partner[3].to_i, partner[4].to_s])
        end
      end
      #echoln "My partners: #{my_partners}"
      #echoln "My self: #{my_self}"
      scene.set_lobby_members(my_partners+[my_self])
      case scene.ret_method
      when 1 then return
      when 2 then break
      end
      if frame>=60
        ret = pbWebRequest({:ROOM_ID => table_name, :ROOM_METHOD => "Check"})
        frame = 0
      end
      frame += 1
    end
    $Connections = []
    if my_partners.empty?
      $game_temp.main_menu_calling = true
      scene.pbEndScene
      return
    end
    $game_temp.character_select_calling = true
    my_partners.each do |prtnr|
      begin
        CableClub::session(nil, prtnr[1], region)
      rescue Connection::Disconnected => e
        echoln e.message
        case e.message
        when "disconnected"
          $game_temp.main_menu_calling = true
        when "invalid version"
          pbMessage("You are on an outdated version of Pivot. Please update to the latest version in order to access online features.\\wtnp[40]")
          $game_temp.main_menu_calling = true
        when "peer disconnected"
          $game_temp.main_menu_calling = true
        else
          pbMessage("An unknown error has occurred. Error Code: 1\\wtnp[40]")
          $game_temp.main_menu_calling = true
        end
      rescue Errno::ECONNREFUSED
        pbMessage("The #{CableClub::HOSTS[region][:short_name]} server seems to be down at the moment. Error Code: 20#{region}\\wtnp[40]")
        pbPostWebhook("The #{CableClub::HOSTS[region][:short_name]} server seems to be down at the moment. <@162985952074006528> <@298015015661731841>") if $Client_id == 0
        $game_temp.main_menu_calling = true
      rescue
        pbMessage("There was an error whilst trying to connect to the server. Error Code: 0\\wtnp[40]")
        $game_temp.main_menu_calling = true
      ensure
        $game_temp.main_menu_calling = true
      end
    end
    scene.pbEndScene
  else
    pbMessage("Something went wrong with joining room #{lobby_id}\\wtnp[40]")
  end
end


def pbWebRequest(request)
  request[:GAME_ID] = "PivotRoom"
  request[:PLAYER_ID] = $player.id if !request[:PLAYER_ID]
  request[:PLAYER_NAME] = $player.name
  request[:PLAYER_LVL] = $player.level
  request[:PLAYER_BANNER] = Collectible.get($player.equipped_collectibles[:banner]).banner
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'')
end

def pbRegisterTemp(name, secret)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "RegisterTemp"
  request[:username] = name
  request[:player_id] = $player.id
  request[:secret] = secret
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbTempExists(name, secret)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "GetTemp"
  request[:username] = name
  request[:player_id] = $player.id
  request[:secret] = secret
  ret = pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
  return (ret == "exists")
end

def pbGetRegisterURL(name, secret)
  url = "https://localhost/register?account="
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "GetEncodedAccount"
  request[:username] = name
  request[:player_id] = $player.id
  request[:secret] = secret
  account = pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
  return url+account
end

def pbLoginRequest(username, password)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "Login"
  request[:username] = username
  request[:password] = password
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbRegisterRequest(username, password, player_id, exp)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "Register"
  request[:username] = username
  request[:password] = password
  request[:player_id] = player_id
  request[:exp] = exp
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbCheckUsernameAvailability(username)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "CheckUsername"
  request[:username] = username
  ret = pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
  return (ret == "available")
end

def pbCheckIDAvailability(id)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "CheckID"
  request[:player_id] = id
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbGetID(username)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "GetID"
  request[:username] = username
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbGetAccount(id)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "GetAccount"
  request[:player_id] = id
  ret = pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
  return ret.split('&^#')
end

def pbUpdateLastOnline(id)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "UpdateLastOnline"
  request[:player_id] = id
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbUpdateFriends(id)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "UpdateFriends"
  request[:player_id] = id
  request[:friends] = $player.friend_ids.join(',')
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbUpdateAccount(id = nil)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "UpdateAccount"
  request[:player_id] = id || $player.id
  request[:exp] = $player.exp
  request[:pp_level] = $player.pp_level
  request[:collection] = $player.collectibles.join(',')
  formatted_hash = $player.equipped_collectibles.clone
  formatted_hash[:emote] = HTTPLite::JSON.stringify(formatted_hash[:emote].map { |k,v| [k.to_s, v.to_s] }.to_h)
  request[:equipped_collectibles] = HTTPLite::JSON.stringify(formatted_hash.map { |k,v| [k.to_s, v.to_s] }.to_h)
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbAddToFriendRequests(player_id, friend_id)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "AddFriendRequest"
  request[:player_id] = player_id
  request[:friend_id] = friend_id
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbRemoveFromFriendRequests(friend_id, player_id)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "RemoveFriendRequest"
  request[:player_id] = player_id
  request[:friend_id] = friend_id
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end

def pbUpdatePlayerName(player_id, new_name)
  request = {}
  request[:GAME_ID] = "PivotLogin"
  request[:ACCOUNT_METHOD] = "UpdatePlayerName"
  request[:player_id] = player_id
  request[:new_name] = new_name
  return pbPostDataPHP("https://localhost/requests", request).gsub(/\n/,'').gsub(/\r/,'')
end


def pbLogin(username = nil)
  username = pbMessageFreeText("Enter your username:", "", false, Settings::MAX_PLAYER_NAME_SIZE) if username.nil?
  if pbCheckUsernameAvailability(username)
    pbMessage("No account found!\\wtnp[30]")
    pbLogin
  end
  password = pbMessageFreeText("Enter your password:", "", true, 24)
  ret = pbLoginRequest(username,password)
  case ret
  when "success"
    pbMessage("Logged in successfully!\\wtnp[30]")
    $player.logged_in = true
    $player.online_username = username
    $player.id = pbGetID(username)
    account = pbGetAccount($player.id)
    if account[0] == "success"
      $player.name = account[1]
      $player.exp = account[3].to_i
      $player.friends = account[4].split(",").map { |friend| Friend.new(friend) }
      $player.pp_level = account[7].to_i
      if account[8]
        $player.collectibles = account[8].split(",").map { |collectible| collectible.to_sym }
      else
        $player.collectibles = Player::DEFAULT_COLLECTIBLES
      end
      if account[9]
        received_hash = HTTPLite::JSON.parse(account[9]).map { |k,v| [k.to_sym,(k == "emote") ? HTTPLite::JSON.parse(v) : v.to_sym] }.to_h
        received_hash[:emote] = received_hash[:emote].map { |k,v| [k.to_i,(v == "") ? nil : v.to_sym] }.to_h
        $player.equipped_collectibles = received_hash
      else
        $player.equipped_collectibles = Player::DEFAULT_EQUIPPED_COLLECTIBLES
      end
    end
    return true
  when "wrong password"
    pbMessage("Wrong password!\\wtnp[30]")
    pbLogin(username)
  when "user not found"
    pbMessage("No account found!\\wtnp[30]")
    pbLogin
  end
end

def pbRegister
=begin
  if pbConfirmMessage("Would you like to register on the website instead of in game?\\wtnp[30]")
    System.launch("https://localhost/accounts")
    return
  end
=end
  username = pbMessageFreeText("Enter your username:", "", false, Settings::MAX_PLAYER_NAME_SIZE)
  if pbCheckUsernameAvailability(username)
    pbMessage("Username already taken!\\wtnp[30]")
    pbRegister
  else
    password = pbEnterPassword
    ret = pbRegisterRequest(username,password,$player.id,$player.exp)
    case ret
    when "success"
      pbMessage("Account created successfully!\\wtnp[30]")
      pbLoginRequest(username,password)
    when "user already exists"
      pbMessage("Username already taken!\\wtnp[30]")
      pbRegister
    end
  end
end

def pbEnterPassword
  password = pbMessageFreeText("Enter your password:", "", true, 24)
  if password_strength(password) < 3
    pbMessage("Password is too weak!\\wtnp[30]")
    pbEnterPassword
  else
    return password
  end
end

def password_strength(password)
  score = 0
  score += 1 if password.length > 6
  score += 1 if password.length > 10
  score += 1 if password =~ /[A-Z]/
  score += 1 if password =~ /[a-z]/
  score += 1 if password =~ /\d/
  score += 1 if password =~ /\W/
  score
end