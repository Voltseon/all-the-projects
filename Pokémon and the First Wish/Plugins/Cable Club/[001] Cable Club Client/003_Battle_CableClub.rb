class Battle
  attr_reader :client_id
end

class Battle_CableClub < Battle
  attr_reader :connection
  def initialize(connection, client_id, scene, opponent_party, opponent)
    @connection = connection
    @client_id = client_id
    player = NPCTrainer.new($player.name, $player.trainer_type)
    super(scene, $player.party, opponent_party, [player], [opponent])
    @battleAI  = AI_CableClub.new(self)
  end
  
  # Added optional args to not make v18 break.
  def pbSwitchInBetween(index, checkLaxOnly = false, canCancel = false)
    if pbOwnedByPlayer?(index)
      choice = super(index, checkLaxOnly, canCancel)
      # bug fix for the unknown type :switch. cause: going into the pokemon menu then backing out and attacking, which sends the switch symbol regardless.
      if !canCancel # forced switches do not allow canceling, and both sides would expect a response.
        @connection.send do |writer|
          writer.sym(:switch)
          writer.int(choice)
        end
      end
      return choice
    else
      frame = 0
      @scene.pbShowWindow(Battle::Scene::MESSAGE_BOX)
      cw = @scene.sprites["messageWindow"]
      cw.letterbyletter = false
      begin
        loop do
          frame += 1
          cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
          @scene.pbFrameUpdate(cw)
          Graphics.update
          Input.update
          raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::BACK) && pbConfirmMessageSerious("Would you like to disconnect?")
          @connection.update do |record|
            case (type = record.sym)
            when :forfeit
              pbSEPlay("Battle flee")
              pbDisplay(_INTL("{1} forfeited the match!", @opponent[0].full_name))
              @decision = 1
              pbAbort

            when :switch
              return record.int

            else
              raise "Unknown message: #{type}"
            end
          end
        end
      ensure
        cw.letterbyletter = false
      end
    end
  end

  def pbRun(idxBattler, duringBattle = false)
    ret = super(idxBattler, duringBattle)
    if ret == 1
      @connection.send do |writer|
        writer.sym(:forfeit)
      end
      @connection.discard(1)
    end
    return ret
  end

  # Rearrange the battlers into a consistent order, do the function, then restore the order.
  def pbCalculatePriority(*args)
    begin
      battlers = @battlers.dup
      order = CableClub::pokemon_order(@client_id)
      for i in 0..3
        @battlers[i] = battlers[order[i]]
      end
      return super(*args)
    ensure
      @battlers = battlers
    end
  end
  
  def pbCanShowCommands?(idxBattler)
    last_index = pbGetOpposingIndicesInOrder(0).reverse.last
    return true if last_index==idxBattler
    return super(idxBattler)
  end
  
  # avoid unnecessary checks and check in same order
  def pbEORSwitch(favorDraws=false)
    return if @decision>0 && !favorDraws
    return if @decision==5 && favorDraws
    pbJudge
    return if @decision>0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      # check in same order
      battlers = []
      order = CableClub::pokemon_order(@client_id)
      for i in 0..3
        battlers[i] = @battlers[order[i]]
      end
      battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          pbRecallAndReplace(idxBattler,idxPartyNew)
          switched.push(idxBattler)
        else
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
          switched.push(idxBattler)
        end
      end
      break if switched.length==0
      pbOnBattlerEnteringBattle(switched)
    end
  end
end

class Battle
  class AI_CableClub < AI
    def pbDefaultChooseEnemyCommand(index)
      # Hurray for default methods. have to reverse it to show the expected order.
      our_indices = @battle.pbGetOpposingIndicesInOrder(1).reverse
      their_indices = @battle.pbGetOpposingIndicesInOrder(0).reverse
      # Sends our choices after they have all been locked in.
      if index == their_indices.last
        # TODO: patch this up to be index agnostic.
        # Would work fine if restricted to single/double battles
        target_order = CableClub::pokemon_target_order(@battle.client_id)
        for our_index in our_indices
          @battle.connection.send do |writer|
            pkmn = @battle.battlers[our_index]
            writer.sym(:choice)
            # choice picked was changed to be a symbol now.
            writer.sym(@battle.choices[our_index][0])
            writer.int(@battle.choices[our_index][1])
            move = @battle.choices[our_index][2] && pkmn.moves.index(@battle.choices[our_index][2])
            writer.nil_or(:int, move)
            # -1 invokes the RNG, out of order (somehow?!) which causes desync.
            # But this is a single battle, so the only possible choice is the foe.
            if @battle.singleBattle? && @battle.choices[our_index][3] == -1
              @battle.choices[our_index][3] = their_indices[0]
            end
            # Target from their POV.
            our_target = @battle.choices[our_index][3]
            their_target = target_order[our_target] rescue our_target
            writer.int(their_target)
            mega=@battle.megaEvolution[0][0]
            mega^=1 if mega>=0
            writer.int(mega) # mega fix?
          end
        end
        frame = 0
        @battle.scene.pbShowWindow(Battle::Scene::MESSAGE_BOX)
        cw = @battle.scene.sprites["messageWindow"]
        cw.letterbyletter = false
        begin
          loop do
            frame += 1
            cw.text = _INTL("Waiting" + "." * (1 + ((frame / 8) % 3)))
            @battle.scene.pbFrameUpdate(cw)
            Graphics.update
            Input.update
            raise Connection::Disconnected.new("disconnected") if Input.trigger?(Input::BACK) && pbConfirmMessageSerious("Would you like to disconnect?")
            @battle.connection.update do |record|
              case (type = record.sym)
              when :forfeit
                pbSEPlay("Battle flee")
                @battle.pbDisplay(_INTL("{1} forfeited the match!", @battle.opponent[0].full_name))
                @battle.decision = 1
                @battle.pbAbort
  
              when :choice
                their_index = their_indices.shift
                partner_pkmn = @battle.battlers[their_index]
                @battle.choices[their_index][0] = record.sym
                @battle.choices[their_index][1] = record.int
                move = record.nil_or(:int)
                @battle.choices[their_index][2] = move && partner_pkmn.moves[move]
                @battle.choices[their_index][3] = record.int
                @battle.megaEvolution[1][0] = record.int # mega fix?
                return if their_indices.empty?
  
              else
                raise "Unknown message: #{type}"
              end
            end
          end
        ensure
          cw.letterbyletter = true
        end
      end
    end
  
    def pbDefaultChooseNewEnemy(index, party)
      raise "Expected this to be unused."
    end
  end
end