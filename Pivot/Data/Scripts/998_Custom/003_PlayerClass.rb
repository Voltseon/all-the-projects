class Player < Trainer
  class Pokedex
  end
  attr_accessor :current_hp, :using_melee, :using_ranged, :guarding, :exp, :stocks,
                :transformed, :transformed_time, :character_id, :character, 
                :unlocked_arenas, :unlocked_characters, :melee_combo, :collectibles,
                :equipped_collectibles, :logged_in, :online_username, :friends, :friend_requests,
                :challenges, :last_challenge_day, :pp_level

  DEFAULT_COLLECTIBLES = [:audiopack_PIVOT, :beam_PURPLE, :banner_DEFAULT, :loadingscreen_PIVOT, :emote_EXCLAIM, :emote_HEART]
  DEFAULT_EQUIPPED_COLLECTIBLES = {
    :audiopack => :audiopack_PIVOT,
    :beam => :beam_PURPLE,
    :banner => :banner_DEFAULT,
    :loadingscreen => :loadingscreen_PIVOT,
    :emote => {1 => :emote_EXCLAIM, 2 => :emote_HEART, 3 => :emote_NONE}
    # Default skins are added automatically
  }
                
  def current_hp; @current_hp = max_hp if !@current_hp; return @current_hp; end
  def current_hp=(value); @current_hp = value; end
  def max_hp; return character.hp; end
  def using_melee; @using_melee = false if !@using_melee; return @using_melee; end
  def using_melee=(value); @using_melee = value; end
  def using_ranged; @using_ranged = false if !@using_ranged; return @using_ranged; end
  def using_ranged=(value); @using_ranged = value; end
  def guarding; @guarding = false if !@guarding; return @guarding; end
  def guarding=(value); @guarding = value; end
  def melee_combo; @melee_combo = 0 if !@melee_combo; return @melee_combo; end
  def dead; return current_hp <= 0; end
  def character_id;
    return @transformed if @transformed && @transformed != :NONE
    @character_id = :ZUBAT if !@character_id;
    return @character_id;
  end
  def character; return Character.get(character_id); end
  def reset_state
    @guarding = false
    @using_melee = false
    @using_ranged = false
  end
  def has_state
    return @guarding || @using_melee || @using_ranged
  end
  def exp; @exp = 0.0 if !@exp; return @exp; end
  def exp=(value); @exp = value; end
  def level
    return (Math.sqrt(exp * 5.0).floor / 2).round + 1
  end
  def exp_to_current_level
    return ((((level.to_f-1.0)* 2.0)**2.0 / 5.0).ceil).round
  end
  def exp_to_next_level
    return (total_exp_to_next_level - exp).round
  end
  def total_exp_to_next_level
    return ((((level.to_f)* 2.0)**2.0 / 5.0).ceil).round
  end
  def stocks
    @stocks = 0 if !@stocks
    return @stocks
  end
  def stocks=(value)
    @stocks = value
  end
  def transformed
    @transformed = :NONE if !@transformed
    return @transformed
  end
  def transformed=(value)
    @transformed = value
  end
  def transformed_time
    @transformed_time = 0 if !@transformed_time
    return @transformed_time
  end
  def transformed_time=(value)
    @transformed_time = value
  end
  def unlocked_arenas
    if !@unlocked_arenas
      @unlocked_arenas = []
      Arena.each { |arena| @unlocked_arenas.push(arena.internal) if arena.unlock_proc.call }
    end
    return @unlocked_arenas
  end
  def unlocked_characters
    @unlocked_characters = [:ZUBAT, :GOLBAT, :CROBAT, :FARFETCHD] if !@unlocked_characters
    return @unlocked_characters
  end

  def collectibles
    if !@collectibles
      @collectibles = DEFAULT_COLLECTIBLES
    end
    # Sort collectibles by type and then alphabetically
    @collectibles.sort! { |a, b|
      a_collectible = Collectible.get(a)
      b_collectible = Collectible.get(b)
      if a_collectible.type == b_collectible.type
        a_collectible.name <=> b_collectible.name
      else
        a_collectible.type <=> b_collectible.type
      end
    }
    return @collectibles
  end

  def equipped_collectibles
    if !@equipped_collectibles
      @equipped_collectibles = DEFAULT_EQUIPPED_COLLECTIBLES
      Character.each { |character| @equipped_collectibles["skin_#{character.internal}".to_sym] = "skin_#{character.internal}_default".to_sym }
    end
    return @equipped_collectibles
  end

  def refresh_equipped
    @equipped_collectibles.each do |key, value|
      Collectible.get(value).equip
    end
  end

  def add_collectible(collectible, amount = 1)
    collectible = Collectible.get(collectible)
    id = $player.id if !id
    return false if !collectible
    return false if @collectibles.include?(collectible.internal) && !collectible.consume_on_use
    amount.times { @collectibles.push(collectible.internal) }
    # Sort collectibles by type and then alphabetically
    @collectibles.sort! { |a, b|
      a_collectible = Collectible.get(a)
      b_collectible = Collectible.get(b)
      if a_collectible.type == b_collectible.type
        a_collectible.name <=> b_collectible.name
      else
        a_collectible.type <=> b_collectible.type
      end
    }
    return true
  end
  
  def remove_collectible(collectible, amount = 1)
    collectible = Collectible.get(collectible)
    return false if !collectible
    return false if !@collectibles.include?(collectible.internal)
    amount.times { @collectibles.delete_at(@collectibles.index(collectible.internal)) }
    return true
  end

  def friends
    @friends = [] if !@friends
    return @friends
  end

  def friends=(value)
    @friends = value
  end

  def friend_ids
    return @friends.map { |friend| friend.id }
  end

  def add_friend(friend)
    @friends = [] if !@friends
    return false if !friend.is_a?(Friend)
    return false if friend.id == @id
    return false if @friends.include?(friend)
    @friends.push(friend)
    refresh_friends
    return true
  end

  def remove_friend(friend)
    return false if !friend_id.is_a?(Friend)
    return false if !@friends.include?(friend)
    @friends.delete_at(@friends.index(friend))
    refresh_friends
    return true
  end

  def refresh_friends
    @friends.sort_by! { |friend| friend.name }
    pbUpdateFriends($player.id)
  end

  def friend_requests(check = false)
    if !@friend_requests || check
      @friend_requests = [] 
      account = pbGetAccount($player.id)
      if account[0] == "success"
        return @friend_requests if !account[6]
        friend_requests = account[6].split(",")
        friend_requests.each do |friend_request|
          next if @friend_requests.any? { |friend| friend.id == friend_request }
          friend_request_data = pbGetAccount(friend_request)
          friend = Friend.new(friend_request_data[2])
          @friend_requests.push(friend)
        end
      end
    end
    return @friend_requests
  end

  def remove_friend_request(friend)
    return false if !friend.is_a?(Friend)
    return false if !@friend_requests.include?(friend)
    @friend_requests.delete_at(@friend_requests.index(friend))
    return true
  end

  def challenges
    @challenges = pbCreateDailyChallenges if !@challenges
    return @challenges
  end

  def challenges=(value)
    @challenges = value
  end

  def reset_challenges
    @challenges = pbCreateDailyChallenges
  end

  def pp_level
    @pp_level = 1 if !@pp_level
    return @pp_level
  end

  def pp_level=(value)
    @pp_level = value
  end

  def speed
    return (@slowed ? @slow_speed : character.speed)
  end
  def heal(heal_amount)
    pbSEPlay("XD 88 Fanfare - Level Up")
    @current_hp = [@current_hp + heal_amount, max_hp].min
  end

  def __test
    i = level
    echoln [level, exp, exp_to_next_level]
    while level < 100
      echoln [level, exp, exp_to_next_level] if level != i
      i = level
      @exp += 1
    end
    echoln [level, exp, exp_to_next_level]
  end

  def __test2
    while @pp_level < 100
      @pp_level += 1
      Graphics.update
      Input.update
      pbUpdateSceneMap
    end
  end

  def checkExp
    oldlevel = self.level
    return "" if $game_temp.gained_exp <= 0
    gained_exp = $game_temp.gained_exp
    player_exp = @exp
    if $game_temp.gained_exp > 0
      @exp += 1
      $game_temp.gained_exp -= 0.5
    else
      $game_temp.gained_exp = 0
      @exp = player_exp+gained_exp
    end
    if oldlevel != self.level
      checkUnlocked
      Game.save
    end
  end

  def checkUnlocked
=begin
    Arena.each do |arena|
      next if unlocked_arenas.include?(arena.internal)
      next unless arena.unlock_proc.call
      unlocked_arenas.push(arena.internal)
      unlocked = 1
      notification("Unlocked Arena", "#{arena.name}")
    end
    Character.each do |character|
      next unless character.playable
      next if unlocked_characters.include?(character.internal)
      next unless character.unlock_proc.call
      unlocked_characters.push(character.internal)
      notification("Unlocked Character", "#{character.name}","Graphics/Characters/#{character.internal}/icon")
    end
=end
  end

  def equipped_skin(character)
    return Collectible.get(equipped_collectibles["skin_#{character.internal}".to_sym]).skin.capitalize
  end

  def equipped_emotes
    ret = []
    equipped_collectibles[:emote].each do |key, value|
      ret.push(Collectible.get(value).name.gsub("Emote - ", "")) if value && value != :emote_NONE
    end
    return "None" if ret.length == 0
    return ret.join(", ")
  end
end