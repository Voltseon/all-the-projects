$lastPacket = {}

def warp(mapid, x=nil, y=nil)
  map = Game_Map.new
  map.setup(mapid)
  x = rand(map.width) if x.nil?
  y = rand(map.height) if y.nil?
  $game_temp.player_new_map_id    = mapid
  $game_temp.player_new_x         = x
  $game_temp.player_new_y         = y
  $game_temp.player_new_direction = 2
  $scene.transfer_player
end

def setArena(arena)
  arena = Arena.get(arena)
  pbSet(46, arena.internal)
  pbSet(48, arena.map_id)
  spawn_loc = arena.spawn_points[$Client_id]
  pbSet(49, spawn_loc[0])
  pbSet(50, spawn_loc[1])
  pbSet(47, spawn_loc[2])
end

def makePacket
  hash = {}
  hash["id"] = $Client_id
  hash["name"] = $player.name
  hash["version"] = Settings::GAME_VERSION
  hash["character"] = $player.character_id.to_s
  hash["map"] = $game_map.map_id
  hash["x"] = $game_player.x
  hash["y"] = $game_player.y
  hash["direction"] = $game_player.direction
  hash["hp"] = $player.current_hp
  hash["graphic"] = $game_player.character_name
  hash["pattern"] = $game_player.pattern
  hash["transformed"] = $player.transformed.to_s
  hash["setting_stocks"] = $game_temp.max_stocks
  hash["setting_time"] = $game_temp.match_time
  hash["sprite_color"] = $game_temp.sprite_color
  hash["dash_location"] = $game_temp.dash_location
  hash["dash_distance"] = $game_temp.dash_distance
  hash["real_x"] = $game_player.real_x
  hash["real_y"] = $game_player.real_y
  hash["is_dead"] = $player.dead
  hash["is_guarding"] = $player.guarding
  hash["hitbox"] = $player.character.hitbox
  hash["ready"] = $game_temp.ready
  hash["set"] = $game_temp.set
  hash["x_offset"] = $game_player.x_offset
  hash["y_offset"] = $game_player.y_offset
  hash["invulnerable"] = !$player.hitbox_active

  Move.each do |attack|
    next if $game_temp.attack_data[attack.internal].nil?
    next if $game_temp.attack_data[attack.internal][0] == [0,0,false,false,0,0,false,0,0,[0,0,0,0]]
    hash["#{attack.move_type.downcase}_#{attack.internal}"] = $game_temp.attack_data[attack.internal]
  end

  return HTTPLite::JSON.stringify(hash).gsub("\n", "").gsub("\r", "").gsub("\t", "").gsub("\"", "`").gsub("   ", "").gsub("  ", "")
=begin
  return nil if hash == $lastPacket
  newHash = {}
  hash.each do |key, value|
    next if $lastPacket[key] == value
    newHash[key] = value
  end
  $lastPacket = hash

  newPacket = HTTPLite::JSON.stringify(newHash).gsub("\n", "").gsub("\r", "").gsub("\t", "").gsub("\"", "`").gsub("   ", "").gsub("  ", "")
  
  return newPacket
=end
  #File.open("packet.json", "w") { |f| f.write(HTTPLite::JSON.stringify(hash)) }
end

module VersionNumber
  URL = "https://pastebin.com/raw/8kcqXAna"
  ThreadURL = "https://reliccastle.com/pivot/"
end

def checkVersion
  latest_version = pbDownloadToString(VersionNumber::URL)
  return if nil_or_empty?(latest_version)
  if Settings::GAME_VERSION != latest_version
    $game_temp.latest_version = latest_version
  end
end

class Game_Temp
  attr_accessor :latest_version
  
  def latest_version=(value)
    @latest_version = value
  end

  def latest_version
    @latest_version = Settings::GAME_VERSION if @latest_version.nil?
    return @latest_version
  end
end

def pbEmote(number)
  animation = Collectible.get($player.equipped_collectibles[:emote][number]).emote
  return if animation == -1
  $game_player.animation_id = animation
  $game_temp.animation_id = animation
  $game_player.animation_id = 0 if animation == 0
  $game_temp.animation_id = 0 if animation == 0
  check_for_challenge("Emotes", $game_map.map_id, $player.character_id)
end

def spin
  [1,4,7,8,9,6,3,2].each do |i|
    $game_player.turn_generic(i)
    pbWait(12)
  end
end  

def getBannerColors(banner)
  colors = {
    "default" => {
      "name_color" => Color.new(254,255,255),
      "name_shadow" => Color.new(64,64,64),
      "level_color" => Color.new(197,198,198),
      "level_shadow" => Color.new(64,64,64),
    },
    "test" => {
      "name_color" => Color.new(254,233,255),
      "name_shadow" => Color.new(116,0,211),
      "level_color" => Color.new(255,124,255),
      "level_shadow" => Color.new(116,0,211),
    },
  }
  return colors[banner] || colors["default"]
end

Discord.add_event_callback(:on_activity_join_request, proc {
  |user|
  Discord.send_request_reply(user.id, Discord::ActivityJoinRequestReply::YES)
})

Discord.add_event_callback(:on_activity_join, proc {
  |secret|
  id = Base64.decode64(secret).to_s
  echoln "Joining party #{id}"
  pbJoinLobby(id)
})