#===============================================================================
#
#===============================================================================
class BugContestState
  attr_accessor :ballcount
  attr_accessor :decision
  attr_accessor :lastPokemon
  attr_reader   :timer

  CONTESTANT_NAMES = [
    _INTL("Bug Catcher Ed"),
    _INTL("Bug Catcher Benny"),
    _INTL("Bug Catcher Josh"),
    _INTL("Camper Barry"),
    _INTL("Cool Trainer Nick"),
    _INTL("Lass Abby"),
    _INTL("Picnicker Cindy"),
    _INTL("Youngster Samuel")
  ]
  TIME_ALLOWED = Settings::BUG_CONTEST_TIME

  def initialize
    clear
    @lastContest = nil
  end

  # Returns whether the last contest ended less than 24 hours ago.
  def pbContestHeld?
    return false if !@lastContest
    timenow = pbGetTimeNow
    return timenow.to_i - @lastContest < 24 * 60 * 60   # 24 hours
  end

  def expired?
    return false if !undecided?
    return false if TIME_ALLOWED <= 0
    curtime = @timer + (TIME_ALLOWED * Graphics.frame_rate)
    curtime = [curtime - Graphics.frame_count, 0].max
    return (curtime <= 0)
  end

  def clear
    @ballcount    = 0
    @ended        = false
    @inProgress   = false
    @decision     = 0
    @lastPokemon  = nil
    @otherparty   = []
    @contestants  = []
    @places       = []
    @start        = nil
    @contestMaps  = []
    @reception    = []
  end

  def inProgress?
    return @inProgress
  end

  def undecided?
    return (@inProgress && @decision == 0)
  end

  def decided?
    return (@inProgress && @decision != 0) || @ended
  end

  def pbSetPokemon(chosenpoke)
    @chosenPokemon = chosenpoke
  end

  def pbSetContestMap(*maps)
    @contestMaps = maps
  end

  # Reception map is handled separately from contest map since the reception map
  # can be outdoors, with its own grassy patches.
  def pbSetReception(*maps)
    @reception = maps
  end

  def pbOffLimits?(map)
    return false if @contestMaps.include?(map)
    return false if @reception.include?(map)
    return true
  end

  def pbSetJudgingPoint(startMap, startX, startY, dir = 8)
    @start = [startMap, startX, startY, dir]
  end

  def pbJudge
    judgearray = []
    if @lastPokemon
      judgearray.push([-1, @lastPokemon.species, pbBugContestScore(@lastPokemon)])
    end
    maps_with_encounters = []
    @contestMaps.each do |map|
      enc_type = :BugContest
      enc_type = :Land if !$PokemonEncounters.map_has_encounter_type?(@contestMaps, enc_type)
      if $PokemonEncounters.map_has_encounter_type?(@contestMaps, enc_type)
        maps_with_encounters.push([map, enc_type])
      end
    end
    raise _INTL("There are no Bug Contest/Land encounters for any Bug Contest maps.") if maps_with_encounters.empty?
    @contestants.each do |cont|
      enc_data = maps_with_encounters.sample
      enc = $PokemonEncounters.choose_wild_pokemon_for_map(enc_data[0], enc_data[1])
      raise _INTL("No encounters for map {1} somehow, so can't judge contest.", enc_data[0]) if !enc
      pokemon = Pokemon.new(enc[0], enc[1])
      pokemon.hp = rand(1...pokemon.totalhp)
      score = pbBugContestScore(pokemon)
      judgearray.push([cont, pokemon.species, score])
    end
    if judgearray.length < 3
      raise _INTL("Too few bug catching contestants")
    end
    judgearray.sort! { |a, b| b[2] <=> a[2] }   # sort by score in descending order
    @places.push(judgearray[0])
    @places.push(judgearray[1])
    @places.push(judgearray[2])
  end

  def pbGetPlaceInfo(place)
    cont = @places[place][0]
    if cont < 0
      $game_variables[1] = $player.name
    else
      $game_variables[1] = CONTESTANT_NAMES[cont]
    end
    $game_variables[2] = GameData::Species.get(@places[place][1]).name
    $game_variables[3] = @places[place][2]
  end

  def pbClearIfEnded
    clear if !@inProgress && (!@start || @start[0] != $game_map.map_id)
  end

  def pbStartJudging
    @decision = 1
    pbJudge
    if $scene.is_a?(Scene_Map)
      pbFadeOutIn {
        $game_temp.player_transferring  = true
        $game_temp.player_new_map_id    = @start[0]
        $game_temp.player_new_x         = @start[1]
        $game_temp.player_new_y         = @start[2]
        $game_temp.player_new_direction = @start[3]
        $scene.transfer_player
        $game_map.need_refresh = true   # in case player moves to the same map
      }
    end
  end

  def pbIsContestant?(i)
    return @contestants.any? { |item| i == item }
  end

  def pbStart(ballcount)
    @ballcount = ballcount
    @inProgress = true
    @otherparty = []
    @lastPokemon = nil
    @lastContest = nil
    @timer = Graphics.frame_count
    @places = []
    chosenpkmn = $player.party[@chosenPokemon]
    $player.party.length.times do |i|
      @otherparty.push($player.party[i]) if i != @chosenPokemon
    end
    @contestants = []
    [5, CONTESTANT_NAMES.length].min.times do
      loop do
        value = rand(CONTESTANT_NAMES.length)
        next if @contestants.include?(value)
        @contestants.push(value)
        break
      end
    end
    $player.party = [chosenpkmn]
    @decision = 0
    @ended = false
    $stats.bug_contest_count += 1
  end

  def place
    3.times do |i|
      return i if @places[i][0] < 0
    end
    return 3
  end

  def pbEnd(interrupted = false)
    return if !@inProgress
    @otherparty.each { |pkmn| $player.party.push(pkmn) }
    if interrupted
      @ended = false
    else
      pbNicknameAndStore(@lastPokemon) if @lastPokemon
      @ended = true
    end
    $stats.bug_contest_wins += 1 if place == 0
    @ballcount = 0
    @inProgress = false
    @decision = 0
    @lastPokemon = nil
    @otherparty = []
    @contestMaps = []
    @reception = []
    timenow = pbGetTimeNow
    @lastContest = timenow.to_i
    $game_map.need_refresh = true
  end
end

#===============================================================================
#
#===============================================================================
class TimerDisplay # :nodoc:
  def initialize(start, maxtime)
    @timer = Window_AdvancedTextPokemon.newWithSize("", Graphics.width - 120, 0, 120, 64)
    @timer.z = 99999
    @total_sec = nil
    @start = start
    @maxtime = maxtime
  end

  def dispose
    @timer.dispose
  end

  def disposed?
    @timer.disposed?
  end

  def update
    curtime = [(@start + @maxtime) - Graphics.frame_count, 0].max
    curtime /= Graphics.frame_rate
    if curtime != @total_sec
      # Calculate total number of seconds
      @total_sec = curtime
      # Make a string for displaying the timer
      min = @total_sec / 60
      sec = @total_sec % 60
      @timer.text = _ISPRINTF("<ac>{1:02d}:{2:02d}", min, sec)
    end
  end
end

#===============================================================================
#
#===============================================================================
# Returns a score for this Pokemon in the Bug Catching Contest.
# Not exactly the HGSS calculation, but it should be decent enough.
def pbBugContestScore(pkmn)
  levelscore = pkmn.level * 4
  ivscore = 0
  pkmn.iv.each_value { |iv| ivscore += iv.to_f / Pokemon::IV_STAT_LIMIT }
  ivscore = (ivscore * 100).floor
  hpscore = (100.0 * pkmn.hp / pkmn.totalhp).floor
  catch_rate = pkmn.species_data.catch_rate
  rarescore = 60
  rarescore += 20 if catch_rate <= 120
  rarescore += 20 if catch_rate <= 60
  return levelscore + ivscore + hpscore + rarescore
end

def pbBugContestState
  if !$PokemonGlobal.bugContestState
    $PokemonGlobal.bugContestState = BugContestState.new
  end
  return $PokemonGlobal.bugContestState
end

# Returns true if the Bug Catching Contest in progress
def pbInBugContest?
  return pbBugContestState.inProgress?
end

# Returns true if the Bug Catching Contest in progress and has not yet been judged
def pbBugContestUndecided?
  return pbBugContestState.undecided?
end

# Returns true if the Bug Catching Contest in progress and is being judged
def pbBugContestDecided?
  return pbBugContestState.decided?
end

def pbBugContestStartOver
  $player.party.each do |pkmn|
    pkmn.heal
    pkmn.makeUnmega
    pkmn.makeUnprimal
  end
  pbBugContestState.pbStartJudging
end

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_map_or_spriteset_change, :show_bug_contest_timer,
  proc { |scene, _map_changed|
    next if !pbInBugContest? || pbBugContestState.decision != 0 || BugContestState::TIME_ALLOWED == 0
    scene.spriteset.addUserSprite(
      TimerDisplay.new(pbBugContestState.timer,
                       BugContestState::TIME_ALLOWED * Graphics.frame_rate)
    )
  }
)

EventHandlers.add(:on_frame_update, :bug_contest_counter,
  proc {
    next if !pbBugContestState.expired?
    next if $game_player.move_route_forcing || pbMapInterpreterRunning? ||
            $game_temp.message_window_showing
    pbMessage(_INTL("ANNOUNCER: BEEEEEP!"))
    pbMessage(_INTL("Time's up!"))
    pbBugContestState.pbStartJudging
  }
)

EventHandlers.add(:on_enter_map, :end_bug_contest,
  proc { |_old_map_id|
    pbBugContestState.pbClearIfEnded
  }
)

EventHandlers.add(:on_leave_map, :end_bug_contest,
  proc { |new_map_id, new_map|
    next if !pbInBugContest? || !pbBugContestState.pbOffLimits?(new_map_id)
    # Clear bug contest if player flies/warps/teleports out of the contest
    pbBugContestState.pbEnd(true)
  }
)

#===============================================================================
#
#===============================================================================
EventHandlers.add(:on_calling_wild_battle, :bug_contest_battle,
  proc { |species, level, handled|
    # handled is an array: [nil]. If [true] or [false], the battle has already
    # been overridden (the boolean is its outcome), so don't do anything that
    # would override it again
    next if !handled[0].nil?
    next if !pbInBugContest?
    handled[0] = pbBugContestBattle(species, level)
  }
)

def pbBugContestBattle(species, level)
  # Record information about party Pokémon to be used at the end of battle (e.g.
  # comparing levels for an evolution check)
  EventHandlers.trigger(:on_start_battle)
  # Generate a wild Pokémon based on the species and level
  pkmn = pbGenerateWildPokemon(species, level)
  foeParty = [pkmn]
  # Calculate who the trainers and their party are
  playerTrainer     = [$player]
  playerParty       = $player.party
  playerPartyStarts = [0]
  # Create the battle scene (the visual side of it)
  scene = BattleCreationHelperMethods.create_battle_scene
  # Create the battle class (the mechanics side of it)
  battle = BugContestBattle.new(scene, playerParty, foeParty, playerTrainer, nil)
  battle.party1starts = playerPartyStarts
  battle.ballCount    = pbBugContestState.ballcount
  setBattleRule("single")
  BattleCreationHelperMethods.prepare_battle(battle)
  # Perform the battle itself
  decision = 0
  pbBattleAnimation(pbGetWildBattleBGM(foeParty), 0, foeParty) {
    decision = battle.pbStartBattle
    BattleCreationHelperMethods.after_battle(decision, true)
    if [2, 5].include?(decision)   # Lost or drew
      $game_system.bgm_unpause
      $game_system.bgs_unpause
      pbBugContestStartOver
    end
  }
  Input.update
  # Update Bug Contest game data based on result of battle
  pbBugContestState.ballcount = battle.ballCount
  if pbBugContestState.ballcount == 0
    pbMessage(_INTL("ANNOUNCER:  The Bug-Catching Contest is over!"))
    pbBugContestState.pbStartJudging
  end
  # Save the result of the battle in Game Variable 1
  BattleCreationHelperMethods.set_outcome(decision, 1)
  # Used by the Poké Radar to update/break the chain
  EventHandlers.trigger(:on_wild_battle_end, species, level, decision)
  # Return false if the player lost or drew the battle, and true if any other result
  return (decision != 2 && decision != 5)
end

#===============================================================================
#
#===============================================================================
class PokemonPauseMenu
  alias __bug_contest_pbShowInfo pbShowInfo unless method_defined?(:__bug_contest_pbShowInfo)

  def pbShowInfo
    __bug_contest_pbShowInfo
    return if !pbInBugContest?
    if pbBugContestState.lastPokemon
      @scene.pbShowInfo(_INTL("Caught: {1}\nLevel: {2}\nBalls: {3}",
                              pbBugContestState.lastPokemon.speciesName,
                              pbBugContestState.lastPokemon.level,
                              pbBugContestState.ballcount))
    else
      @scene.pbShowInfo(_INTL("Caught: None\nBalls: {1}", pbBugContestState.ballcount))
    end
  end
end

MenuHandlers.add(:pause_menu, :quit_bug_contest, {
  "name"      => _INTL("Quit Contest"),
  "order"     => 60,
  "condition" => proc { next pbInBugContest? },
  "effect"    => proc { |menu|
    menu.pbHideMenu
    if pbConfirmMessage(_INTL("Would you like to end the Contest now?"))
      menu.pbEndScene
      pbBugContestState.pbStartJudging
      next true
    end
    menu.pbRefresh
    menu.pbShowMenu
    next false
  }
})
