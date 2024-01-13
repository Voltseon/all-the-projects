class Friend
  attr_reader :name, :id, :exp, :last_online, :equipped_collectibles, :accepted, :account, :last_sync_time

  def initialize(id)
    @id = id
    sync_account
    @name = @account[1]
    @exp = @account[3].to_i
    @last_online = Time.at(@account[5].to_i)
    @accepted = false
    if @account[9]
      received_hash = HTTPLite::JSON.parse(@account[9]).map { |k,v| [k.to_sym,(k == "emote") ? HTTPLite::JSON.parse(v) : v.to_sym] }.to_h
      received_hash[:emote] = received_hash[:emote].map { |k,v| [k.to_i,(v == "") ? nil : v.to_sym] }.to_h
      @equipped_collectibles = received_hash
    end
  end

  def name
    return @name
  end

  def level
    return (Math.sqrt(self.exp * 5.0).floor / 2).round + 1
  end

  def id
    return @id
  end

  def exp
    sync_account
    if @account[0] == "success"
      @exp = @account[3].to_i
    end
    return @exp
  end

  def equipped_collectibles
    sync_account
    if @account[0] == "success"
      received_hash = HTTPLite::JSON.parse(@account[9]).map { |k,v| [k.to_sym,(k == "emote") ? HTTPLite::JSON.parse(v) : v.to_sym] }.to_h
      received_hash[:emote] = received_hash[:emote].map { |k,v| [k.to_i,(v == "") ? nil : v.to_sym] }.to_h
      @equipped_collectibles = received_hash
    end
    return @equipped_collectibles
  end

  def accepted?
    if @accepted
      return true
    else
      sync_account
      if @account[0] == "success"
        friends = @account[4].split(",")
        if friends.include?($player.id.to_s)
          @accepted = true
          return true
        end
      end
    end
    return false
  end

  def sync_account
    return if @last_sync_time && @last_sync_time > Time.now - 60 * 5
    @account = pbGetAccount(@id)
    @last_sync_time = Time.now
    return @account
  end

  def online?
    return false if !self.accepted?
    return self.last_online > Time.now - 60 * 5
  end
  
  def last_online
    return Time.new(1970, 1, 1, 0, 0, 0, 0) if !self.accepted?
    sync_account
    if @account[0] == "success"
      timestamp = @account[5].to_i
      @last_online = Time.at(timestamp)
      return Time.at(timestamp)
    end
    return @last_online
  end
end

def pbSendFriendRequest(id = nil)
  if id
    friend_data = pbGetAccount(id)
  else
    username = pbEnterText(_INTL("Enter the username of the friend you want to add."), 0, 16, "", nil, true)
    friend_data = pbGetAccount(pbGetID(username))
  end
  if friend_data[0] == "success"
    friend = Friend.new(friend_data[2])
    friend.name = friend_data[1]
    $player.add_friend(friend)
    pbAddToFriendRequests(friend.id, $player.id)
    pbMessage(_INTL("Sent a friend request to {1}.", friend.name))
  else
    pbMessage(_INTL("No account found with that username."))
  end
end

def pbAcceptFriendRequest
  friend_requests = $player.friend_requests
  if friend_requests.length == 0
    pbMessage(_INTL("You have no friend requests."))
    return
  end
  friend_request_names = []
  friend_requests.each do |friend_request|
    friend_request_names.push("#{friend_request.name} Lv. #{friend_request.level}")
  end
  friend_request_names.push(_INTL("Cancel"))
  choice = pbMessage(_INTL("Which friend request would you like to accept?"), friend_request_names)
  if choice == friend_request_names.length - 1
    return
  end
  friend = friend_requests[choice]
  $player.add_friend(friend)
  pbRemoveFromFriendRequests(friend.id, $player.id)
  $player.remove_friend_request(friend)
  pbMessage(_INTL("You are now friends with {1}.", friend.name))
end

def pbReallyLogout
  SaveData.delete_file
  pbMessage(_INTL("Successfully logged out. Closing the game..."))
  $scene = nil
  exit!
end