#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#                                                                              #
#                          Mid Battle Dialogue and Script                      #
#                                       v1.8                                   #
#                                 By Golisopod User                            #
#                                                                              #
#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#                                                                              #
# Implements Functionality for easily setting up dialogue in between trainer   #
# battles. The dialogue can be called at many different instances, including   #
# but not limited to, a specific turn number, on each individual Pokemon being #
# sent out by the player or opponent, usage of items, when A Pokémon is less   #
# than 1/2th or 1/4th of its HP and much more. It works with both Trainer and  #
# Wild Battles so you can bring some extra spice to your Boss Battles and Gym  #
#  Battles. It allows you to create battles with varying intensity and with    #
# story and character, right in the battle. It allows directly manipulating    #
# the battle and the battle scene which allows you to interact with battles    #
# like never before. The only limit is your imagination.                       #
#                                                                              #
# This Script is meant for the default Essentials battle system. The upcoming  #
# EBDX already has very similar functionality inbuilt.                         #
#                                                                              #
#==============================================================================#
#                              INSTRUCTIONS                                    #
#------------------------------------------------------------------------------#
# 1. Place the script1.txt and script2.txt from the ZIP in a new section above #
#    Main                                                                      #
#                                                                              #
# 2. Start a new save (Not nescessary, but just to be on the safe side)        #
#------------------------------------------------------------------------------#
#        INFO ABOUT THE PARAMETERS AND METHODS FOR TRAINER DIALOGUE            #
#------------------------------------------------------------------------------#
#                                                                              #
# All the info has been mentioned clearly in the Main Post. Please read all of #
# it thoroughly and don't skip any parts. 90% of errors you'll get while       #
# starting a battle are gonna be Syntax Errors you get when you don't use the  #
# commands properly.                                                           #
#                                                                              #
#------------------------------------------------------------------------------#
#                          CUSTOMIZABLE OPTIONS                                #
#==============================================================================#

#------------------------------------------------------------------------------#
# Adding a few extra battler realed properties
#------------------------------------------------------------------------------#
class PokeBattle_DamageState
  attr_accessor :bigDamage   # For Big DMG Dialogue
  attr_accessor :smlDamage   # For Small Dmg Dialogue
  attr_accessor :lowHP   # For Small Dmg Dialogue
  attr_accessor :halfHP   # For Small Dmg Dialogue
  attr_accessor :firstAttack # For Attack Dialogue
  attr_accessor :superEff   # For Big DMG Dialogue
  attr_accessor :notEff   # For Small Dmg Dialogue

  def reset
    @initialHP          = 0
    @typeMod            = 0
    @unaffected         = false
    @protected          = false
    @magicCoat          = false
    @magicBounce        = false
    @totalHPLost        = 0
    @fainted            = false
    @bigDamage          = 0
    @smlDamage          = 0
    @halfHP             = false
    @lowHP              = false
    @firstAttack        = false
    @superEff           = 0
    @notEff             = 0
    resetPerHit
  end
end

#------------------------------------------------------------------------------#
# Edits to the entire battle system to include Dialogue
#------------------------------------------------------------------------------#
class PokeBattle_Battle
# For Turn Based Messages
  def pbBattleLoop
    @turnCount = 0
    loop do   # Now begin the battle loop
      PBDebug.log("")
      PBDebug.log("***Round #{@turnCount+1}***")
      if @debug && @turnCount>=100
        @decision = pbDecisionOnTime
        PBDebug.log("")
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      TrainerDialogue.display("turnStart#{@turnCount}",self,@scene)
      break if @decision>0
      PBDebug.log("")
      # Command phase
      PBDebug.logonerr { pbCommandPhase }
      break if @decision>0
      # Attack phase
      PBDebug.logonerr { pbAttackPhase }
      break if @decision>0
      # End of round phase
      PBDebug.logonerr { pbEndOfRoundPhase }
      break if @decision>0
      TrainerDialogue.display("turnEnd#{@turnCount}",self,@scene)
      break if @decision>0
      if TrainerDialogue.hasData?
        for key in TrainerDialogue.get.keys
          next if !key.is_a?(String)
          if key.starts_with?("rand")
            value = key.split("rand")
            next if !value[1] || value[1].length<1
            value1 = rand(value[1].to_i).floor
            next if value1>0
            TrainerDialogue.display(key,self,@scene)
          end
        end
      end
      break if @decision>0
      @turnCount += 1
      TrainerDialogue.setFinal
    end
    pbEndOfBattle
    TrainerDialogue.resetAll
  end

# For Start Battle Messages
  def pbStartBattleSendOut(sendOuts)
    # "Want to battle" messages
    if wildBattle?
      foeParty = pbParty(1)
      case foeParty.length
      when 1
        # Edited
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("Oh! A wild {1} appeared!",foeParty[0].name))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,foeParty[0].name))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart["text"],foeParty[0].name))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],foeParty[0].name))
          end
        end
      when 2
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("Oh! A wild {1} and {2} appeared!",foeParty[0].name,
             foeParty[1].name))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,foeParty[0].name,
             foeParty[1].name))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart["text"],foeParty[0].name,
             foeParty[1].name))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],foeParty[0].name,
               foeParty[1].name))
          end
        end
      when 3
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("Oh! A wild {1}, {2} and {3} appeared!",foeParty[0].name,
             foeParty[1].name,foeParty[2].name))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStartfoeParty[0].name,
             foeParty[1].name,foeParty[2].name))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart,foeParty[0].name,
             foeParty[1].name,foeParty[2].name))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],foeParty[0].name,
               foeParty[1].name,foeParty[2].name))
          end
        end
      end
    else   # Trainer battle
      case @opponent.length
      when 1
        # Edited
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("You are challenged by {1}!",@opponent[0].fullname))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart["text"],@opponent[0].fullname))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],@opponent[0].fullname))
          end
        end
      when 2
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("You are challenged by {1} and {2}!",@opponent[0].fullname,@opponent[1].fullname))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart["text"],@opponent[0].fullname,@opponent[1].fullname))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],@opponent[0].fullname,@opponent[1].fullname))
          end
        end
      when 3
        case TrainerDialogue.eval("battleStart")
        when -1
          pbDisplayPaused(_INTL("You are challenged by {1}, {2} and {3}!",
           @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
        when 0
          battleStart= TrainerDialogue.get("battleStart")
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
        when 1
          battleStart= TrainerDialogue.get("battleStart")
          pbBGMPlay(battleStart["bgm"])
          pbDisplayPaused(_INTL(battleStart,@opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
        when 2
          battleStart= TrainerDialogue.get("battleStart")
          battleStart.call(self)
        when 3
          battleStart= TrainerDialogue.get("battleStart")
          for i in 0...battleStart.length
            pbDisplayPaused(_INTL(battleStart[i],@opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
          end
        end
      end
    end
    # Send out Pokémon (opposing trainers first)
    for side in [1,0]
      next if side==1 && wildBattle?
      msg = ""
      toSendOut = []
      trainers = (side==0) ? @player : @opponent
      # Opposing trainers and partner trainers's messages about sending out Pokémon
      trainers.each_with_index do |t,i|
        next if side==0 && i==0   # The player's message is shown last
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][i]
        case sent.length
        when 1
          msg += _INTL("{1} sent out {2}!",t.fullname,@battlers[sent[0]].name)
        when 2
          msg += _INTL("{1} sent out {2} and {3}!",t.fullname,
             @battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("{1} sent out {2}, {3} and {4}!",t.fullname,
             @battlers[sent[0]].name,@battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      # The player's message about sending out Pokémon
      if side==0
        msg += "\r\n" if msg.length>0
        sent = sendOuts[side][0]
        case sent.length
        when 1
          msg += _INTL("Go! {1}!",@battlers[sent[0]].name)
        when 2
          msg += _INTL("Go! {1} and {2}!",@battlers[sent[0]].name,@battlers[sent[1]].name)
        when 3
          msg += _INTL("Go! {1}, {2} and {3}!",@battlers[sent[0]].name,
             @battlers[sent[1]].name,@battlers[sent[2]].name)
        end
        toSendOut.concat(sent)
      end
      pbDisplayBrief(msg) if msg.length>0
      # The actual sending out of Pokémon
      animSendOuts = []
      toSendOut.each do |idxBattler|
        animSendOuts.push([idxBattler,@battlers[idxBattler].pokemon])
      end
      pbSendOut(animSendOuts,true)
    end
  end

# Item Usage Dialogue
  def pbUseItemOnBattler(item,idxParty,userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item,trainerName)
    battler = pbFindBattler(idxParty,userBattler.index)
    ch = @choices[userBattler.index]
    if battler
      if ItemHandlers.triggerCanUseInBattle(item,battler.pokemon,battler,ch[3],true,self,@scene,false)
        if !battler.opposes?
          TrainerDialogue.display("item",self,@scene)
        else
          TrainerDialogue.display("itemOpp",self,@scene)
        end
        ItemHandlers.triggerBattleUseOnBattler(item,battler,@scene)
        ch[1] = nil   # Delete item from choice
        return
      else
        pbDisplay(_INTL("But it had no effect!"))
      end
    else
      pbDisplay(_INTL("But it's not where this item can be used!"))
    end
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item,userBattler.index)
  end

# Item Usage Dialogue
  def pbUseItemOnPokemon(item,idxParty,userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item,trainerName)
    pkmn = pbParty(userBattler.index)[idxParty]
    battler = pbFindBattler(idxParty,userBattler.index)
    ch = @choices[userBattler.index]
    if ItemHandlers.triggerCanUseInBattle(item,pkmn,battler,ch[3],true,self,@scene,false)
      if (battler && battler.opposes?) || userBattler.index == 0
        TrainerDialogue.display("item",self,@scene)
      else
        TrainerDialogue.display("itemOpp",self,@scene)
      end
      ItemHandlers.triggerBattleUseOnPokemon(item,pkmn,battler,ch,@scene)
      ch[1] = nil   # Delete item from choice
      return
    end
    pbDisplay(_INTL("But it had no effect!"))
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item,userBattler.index)
  end

# Item Usage Dialogue
  def pbUseItemInBattle(item,idxBattler,userBattler)
    trainerName = pbGetOwnerName(userBattler.index)
    pbUseItemMessage(item,trainerName)
    battler = (idxBattler<0) ? userBattler : @battlers[idxBattler]
    pkmn = battler.pokemon
    ch = @choices[userBattler.index]
    if ItemHandlers.triggerCanUseInBattle(item,pkmn,battler,ch[3],true,self,@scene,false)
      if !battler.opposes?
        TrainerDialogue.display("item",self,@scene)
      else
        TrainerDialogue.display("itemOpp",self,@scene)
      end
      ItemHandlers.triggerUseInBattle(item,battler,self)
      ch[1] = nil   # Delete item from choice
      return
    end
    pbDisplay(_INTL("But it had no effect!"))
    # Return unused item to Bag
    pbReturnUnusedItemToBag(item,userBattler.index)
  end

# Mega Evolution Dialogue
  def pbMegaEvolve(idxBattler)
    battler = @battlers[idxBattler]
    return if !battler || !battler.pokemon
    return if !battler.hasMega? || battler.mega?
    trainerName = pbGetOwnerName(idxBattler)
    # Break Illusion
    if battler.hasActiveAbility?(:ILLUSION)
      BattleHandlers.triggerTargetAbilityOnHit(battler.ability,nil,battler,nil,self)
    end
    if !battler.opposes?
      TrainerDialogue.display("mega",self,@scene)
    else
      TrainerDialogue.display("megaOpp",self,@scene)
    end
    # Mega Evolve
    case battler.pokemon.megaMessage
    when 1   # Rayquaza
      pbDisplay(_INTL("{1}'s fervent wish has reached {2}!",trainerName,battler.pbThis))
    else
      pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s {4}!",
         battler.pbThis,battler.itemName,trainerName,pbGetMegaRingName(idxBattler)))
    end
    pbCommonAnimation("MegaEvolution",battler)
    battler.pokemon.makeMega
    battler.form = battler.pokemon.form
    battler.pbUpdate(true)
    @scene.pbChangePokemon(battler,battler.pokemon)
    @scene.pbRefreshOne(idxBattler)
    pbCommonAnimation("MegaEvolution2",battler)
    megaName = battler.pokemon.megaName
    if !megaName || megaName==""
      megaName = _INTL("Mega {1}",PBSpecies.getName(battler.pokemon.species))
    end
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!",battler.pbThis,megaName))
    side  = battler.idxOwnSide
    owner = pbGetOwnerIndexFromBattlerIndex(idxBattler)
    @megaEvolution[side][owner] = -2
    if battler.isSpecies?(:GENGAR) && battler.mega?
      battler.effects[PBEffects::Telekinesis] = 0
    end
    pbCalculatePriority(false,[idxBattler]) if NEWEST_BATTLE_MECHANICS
    # Trigger ability
    battler.pbEffectsOnSwitchIn
  end

# Switch in Dialogue
  def pbPartyScreen(idxBattler,checkLaxOnly=false,canCancel=false,shouldRegister=false)
    ret = -1
    @scene.pbPartyScreen(idxBattler,canCancel) { |idxParty,partyScene|
      if checkLaxOnly
        next false if !pbCanSwitchLax?(idxBattler,idxParty,partyScene)
      else
        next false if !pbCanSwitch?(idxBattler,idxParty,partyScene)
      end
      if shouldRegister
        next false if idxParty<0 || !pbRegisterSwitch(idxBattler,idxParty)
      end
      ret = idxParty
      next true
    }
    if ret != -1 && !$ShiftSwitch
      if !@battlers[idxBattler].opposes?
        TrainerDialogue.display("recall",self,@scene)
      else
        TrainerDialogue.display("recallOpp",self,@scene)
      end
    end
    $ShiftSwitch=false
    return ret
  end

# Switch in Dialogue Fix
  def pbEORSwitch(favorDraws=false)
    return if @decision>0 && !favorDraws
    return if @decision==5 && favorDraws
    pbJudge
    return if @decision>0
    # Check through each fainted battler to see if that spot can be filled.
    switched = []
    loop do
      switched.clear
      @battlers.each do |b|
        next if !b || !b.fainted?
        idxBattler = b.index
        next if !pbCanChooseNonActive?(idxBattler)
        if !pbOwnedByPlayer?(idxBattler)   # Opponent/ally is switching in
          next if wildBattle? && opposes?(idxBattler)   # Wild Pokémon can't switch
          idxPartyNew = pbSwitchInBetween(idxBattler)
          opponent = pbGetOwnerFromBattlerIndex(idxBattler)
          # NOTE: The player is only offered the chance to switch their own
          #       Pokémon when an opponent replaces a fainted Pokémon in single
          #       battles. In double battles, etc. there is no such offer.
          if @internalBattle && @switchStyle && trainerBattle? && pbSideSize(0)==1 &&
            opposes?(idxBattler) && !@battlers[0].fainted? && !switched.include?(0) &&
            pbCanChooseNonActive?(0) && @battlers[0].effects[PBEffects::Outrage]==0
            idxPartyForName = idxPartyNew
            enemyParty = pbParty(idxBattler)
            if enemyParty[idxPartyNew].ability == :ILLUSION
              new_index = pbLastInTeam(idxBattler)
              idxPartyForName = new_index if new_index >= 0 && new_index != idxPartyNew
            end
            if pbDisplayConfirm(_INTL("{1} is about to send in {2}. Will you switch your Pokémon?",
              opponent.full_name, enemyParty[idxPartyForName].name))
              idxPlayerPartyNew = pbSwitchInBetween(0,false,true)
              if idxPlayerPartyNew>=0
                pbMessageOnRecall(@battlers[0])
                pbRecallAndReplace(0,idxPlayerPartyNew)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(idxBattler,idxPartyNew)
          switched.push(idxBattler)
        elsif trainerBattle?   # Player switches in in a trainer battle
          $ShiftSwitch=true
          idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
          pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
          switched.push(idxBattler)
        else   # Player's Pokémon has fainted in a wild battle
          switch = false
          if !pbDisplayConfirm(_INTL("Use next Pokémon?"))
            switch = (pbRun(idxBattler,true)<=0)
          else
            switch = true
          end
          if switch
            $ShiftSwitch=true
            idxPlayerPartyNew = pbGetReplacementPokemonIndex(idxBattler)   # Owner chooses
            pbRecallAndReplace(idxBattler,idxPlayerPartyNew)
            switched.push(idxBattler)
          end
        end
      end
      break if switched.length==0
      pbPriority(true).each do |b|
        b.pbEffectsOnSwitchIn(true) if switched.include?(b.index)
      end
      $ShiftSwitch=false
    end
  end


  def pbSwitchInBetween(idxBattler,checkLaxOnly=false,canCancel=false)
    return pbPartyScreen(idxBattler,checkLaxOnly,canCancel) if pbOwnedByPlayer?(idxBattler)
    ret = @battleAI.pbDefaultChooseNewEnemy(idxBattler,pbParty(idxBattler))
    if BattleScripting.hasOrderData?
      orderArr = BattleScripting.getOrderOf(idxBattler)
      return ret if orderArr.length == 0
      numFainted = 0
      enemyId = (idxBattler-1)/2
      endL = (enemyId == (@sideSizes[1] - 1)) ? pbParty(1).length : @party2starts[enemyId + 1]
      for j in @party2starts[enemyId]...endL
        numFainted += 1 if !pbParty(1)[j].able?
      end
      actualIndex = @party2starts[enemyId] + orderArr[numFainted]
      if pbParty(idxBattler)[actualIndex].able?
        ret = actualIndex
      end
    end
    return ret
  end

# Loss and Win Dialogue
  def pbEndOfBattle
    oldDecision = @decision
    @decision = 4 if @decision==1 && wildBattle? && @caughtPokemon.length>0
    case oldDecision
    ##### WIN #####
    when 1
      PBDebug.log("")
      PBDebug.log("***Player won***")
      if trainerBattle?
        @scene.pbTrainerBattleSuccess
        case @opponent.length
        when 1
          pbDisplayPaused(_INTL("You defeated {1}!",@opponent[0].fullname))
        when 2
          pbDisplayPaused(_INTL("You defeated {1} and {2}!",@opponent[0].fullname,
             @opponent[1].fullname))
        when 3
          pbDisplayPaused(_INTL("You defeated {1}, {2} and {3}!",@opponent[0].fullname,
             @opponent[1].fullname,@opponent[2].fullname))
        end
        ret = TrainerDialogue.eval("endspeech")
        if ret == -1
          @opponent.each_with_index do |_t,i|
            @scene.pbShowOpponent(i)
            msg = (@endSpeeches[i] && @endSpeeches[i]!="") ? @endSpeeches[i] : "..."
            pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
          end
        else
          TrainerDialogue.display("endspeech",self,@scene)
        end
      end
      # Gain money from winning a trainer battle, and from Pay Day
      pbGainMoney if @decision!=4
      # Hide remaining trainer
      @scene.pbShowOpponent(@opponent.length) if trainerBattle? && @caughtPokemon.length>0
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("")
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if @internalBattle
        pbDisplayPaused(_INTL("You have no more Pokémon that can fight!"))
        if trainerBattle?
          TrainerDialogue.display("loss",self,@scene)
          case @opponent.length
          when 1
            pbDisplayPaused(_INTL("You lost against {1}!",@opponent[0].fullname))
          when 2
            pbDisplayPaused(_INTL("You lost against {1} and {2}!",
               @opponent[0].fullname,@opponent[1].fullname))
          when 3
            pbDisplayPaused(_INTL("You lost against {1}, {2} and {3}!",
               @opponent[0].fullname,@opponent[1].fullname,@opponent[2].fullname))
          end
        end
        # Lose money from losing a battle
        pbLoseMoney
        pbDisplayPaused(_INTL("You blacked out!")) if !@canLose
      elsif @decision==2
        if @opponent
          ret = TrainerDialogue.eval("loss")
          if ret == -1
            @opponent.each_with_index do |_t,i|
              @scene.pbShowOpponent(i)
              msg = (@endSpeechesWin[i] && @endSpeechesWin[i]!="") ? @endSpeechesWin[i] : "..."
              pbDisplayPaused(msg.gsub(/\\[Pp][Nn]/,pbPlayer.name))
            end
          else
            TrainerDialogue.display("loss",self,@scene)
          end
        end
      end
    ##### CAUGHT WILD POKÉMON #####
    when 4
      @scene.pbWildBattleSuccess if !expGain
    end
    # Register captured Pokémon in the Pokédex, and store them
    pbRecordAndStoreCaughtPokemon
    # Collect Pay Day money in a wild battle that ended in a capture
    pbGainMoney if @decision==4
    # Pass on Pokérus within the party
    if @internalBattle
      infected = []
      $Trainer.party.each_with_index do |pkmn,i|
        infected.push(i) if pkmn.pokerusStage==1
      end
      infected.each do |idxParty|
        strain = $Trainer.party[idxParty].pokerusStrain
        if idxParty>0 && $Trainer.party[idxParty-1].pokerusStage==0
          $Trainer.party[idxParty-1].givePokerus(strain) if rand(3)==0   # 33%
        end
        if idxParty<$Trainer.party.length-1 && $Trainer.party[idxParty+1].pokerusStage==0
          $Trainer.party[idxParty+1].givePokerus(strain) if rand(3)==0   # 33%
        end
      end
    end
    # Clean up battle stuff
    @scene.pbEndBattle(@decision)
    @battlers.each do |b|
      next if !b
      pbCancelChoice(b.index)   # Restore unused items to Bag
      BattleHandlers.triggerAbilityOnSwitchOut(b.ability,b,true) if b.abilityActive?
    end
    pbParty(0).each_with_index do |pkmn,i|
      next if !pkmn
      @peer.pbOnLeavingBattle(self,pkmn,@usedInBattle[0][i],true)   # Reset form
      pkmn.item=@initialItems[0][i] || 0
    end
    return @decision
  end
end

class PokeBattle_Battler
# Faint Dialogue
  alias dialogue_faint pbFaint

  def pbFaint(showMessage=true)
    dialogue_faint(showMessage=true)
    if !opposes?
      TrainerDialogue.display("fainted",@battle,@battle.scene)
    else
      TrainerDialogue.display("faintedOpp",@battle,@battle.scene)
    end
  end

# HP Reduction Dialogue
  def pbReduceHP(amt,anim=true,registerDamage=true,anyAnim=true)
    amt = amt.round
    amt = @hp if amt>@hp
    amt = 1 if amt<1 && !fainted?
    oldHP = @hp
    self.hp -= amt
    PBDebug.log("[HP change] #{pbThis} lost #{amt} HP (#{oldHP}=>#{@hp})") if amt>0
    raise _INTL("HP less than 0") if @hp<0
    raise _INTL("HP greater than total HP") if @hp>@totalhp
    @battle.scene.pbHPChanged(self,oldHP,anim) if anyAnim && amt>0
    @tookDamage = true if amt>0 && registerDamage
    if self.hp < (self.totalhp*0.25).floor && !self.damageState.lowHP && self.hp>0
      self.damageState.lowHP = true
      self.damageState.halfHP = true
      if !opposes?
        TrainerDialogue.display("lowHP",@battle,@battle.scene)
      else
        TrainerDialogue.display("lowHPOpp",@battle,@battle.scene)
      end
    elsif self.hp < (self.totalhp*0.5).floor && self.hp > (self.totalhp*0.25).floor && !self.damageState.halfHP
      self.damageState.halfHP = true
      if !opposes?
        TrainerDialogue.display("halfHP",@battle,@battle.scene)
      else
        TrainerDialogue.display("halfHPOpp",@battle,@battle.scene)
      end
    end
    return amt
  end
end

class PokeBattle_Move
# Attack Dialogue
  def pbDisplayUseMessage(user)
    if !user.damageState.firstAttack
      user.damageState.firstAttack = true
      if !user.opposes?
        TrainerDialogue.display("attack",@battle,@battle.scene)
      else
        TrainerDialogue.display("attackOpp",@battle,@battle.scene)
      end
    end
    @battle.pbDisplayBrief(_INTL("{1} used {2}!",user.pbThis,@name))
  end

# Super Effective Dialogue
  def pbEffectivenessMessage(user,target,numTargets=1)
    return if target.damageState.disguise
    if Effectiveness.super_effective?(target.damageState.typeMod)
      if numTargets>1
        @battle.pbDisplay(_INTL("It's super effective on {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's super effective!"))
      end
      target.damageState.superEff = 1 if target.damageState.superEff==0
      if target.hasActiveAbility?(:NIGHTMAREFUEL)
        @battle.pbShowAbilitySplash(target,true)
        @battle.pbHideAbilitySplash(target)
        target.pbChangeForm(1,_INTL("{1} transformed!",target.name))
      end
    elsif Effectiveness.not_very_effective?(target.damageState.typeMod)
      if numTargets>1
        @battle.pbDisplay(_INTL("It's not very effective on {1}...",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
      target.damageState.notEff = 1 if target.damageState.notEff==0
    end
    if target.damageState.superEff == 1
      if !target.opposes?
        TrainerDialogue.display("superEff",@battle,@battle.scene)
      else
        TrainerDialogue.display("superEffOpp",@battle,@battle.scene)
      end
      target.damageState.superEff = 2
    elsif target.damageState.notEff == 1
      if !target.opposes?
        TrainerDialogue.display("notEff",@battle,@battle.scene)
      else
        TrainerDialogue.display("notEffOpp",@battle,@battle.scene)
      end
      target.damageState.notEff = 2
    end
  end

# Setting Damage Data
  def pbReduceDamage(user,target)
    damage = target.damageState.calcDamage
    # Substitute takes the damage
    if target.damageState.substitute
      damage = target.effects[PBEffects::Substitute] if damage>target.effects[PBEffects::Substitute]
      target.damageState.hpLost       = damage
      target.damageState.totalHPLost += damage
      return
    end
    # Disguise takes the damage
    return if target.damageState.disguise
    # Target takes the damage
    if damage>=target.hp
      damage = target.hp
      # Survive a lethal hit with 1 HP effects
      if nonLethal?(user,target)
        damage -= 1
      elsif target.effects[PBEffects::Endure]
        target.damageState.endured = true
        damage -= 1
      elsif damage==target.totalhp
        if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
          target.damageState.sturdy = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSSASH) && target.hp==target.totalhp
          target.damageState.focusSash = true
          damage -= 1
        elsif target.hasActiveItem?(:FOCUSBAND) && @battle.pbRandom(100)<10
          target.damageState.focusBand = true
          damage -= 1
        end
      end
    end
    damage = 0 if damage<0
    if damage > (target.totalhp*0.6).floor &&  damage != target.hp
      target.damageState.bigDamage = 1
      target.damageState.smlDamage = 1
    elsif damage < (target.totalhp*0.4).floor &&  damage != target.hp
      target.damageState.smlDamage = 1
    end
    target.damageState.hpLost       = damage
    target.damageState.totalHPLost += damage
  end

# Big,Small and Low, Mid HP Dialogue Dialogue
  def pbEndureKOMessage(target)
    if target.damageState.disguise
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("Its disguise served it as a decoy!"))
      else
        @battle.pbDisplay(_INTL("{1}'s disguise served it as a decoy!",target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
      target.pbChangeForm(1,_INTL("{1}'s disguise was busted!",target.pbThis))
      target.pbReduceHP(target.totalhp/8)
    elsif defined?(target.damageState.iceface) && target.damageState.iceface
      @battle.pbShowAbilitySplash(target)
      target.pbChangeForm(1,_INTL("{1} transformed!",target.pbThis))
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
    elsif target.damageState.sturdy
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("{1} endured the hit!",target.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",target.pbThis))
      end
      @battle.pbHideAbilitySplash(target)
    elsif target.damageState.focusSash
      @battle.pbCommonAnimation("UseItem",target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",target.pbThis))
      target.pbConsumeItem
    elsif target.damageState.focusBand
      @battle.pbCommonAnimation("UseItem",target)
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",target.pbThis))
    end
    if target.damageState.bigDamage==1
      target.damageState.bigDamage = -1
      target.damageState.smlDamage = -1
      target.damageState.halfHP = true
      if !target.opposes?
        TrainerDialogue.display("bigDamage",@battle,@battle.scene)
      else
        TrainerDialogue.display("bigDamageOpp",@battle,@battle.scene)
      end
    elsif target.damageState.smlDamage==1
      if !target.opposes?
        TrainerDialogue.display("smlDamage",@battle,@battle.scene)
      else
        TrainerDialogue.display("smlDamageOpp",@battle,@battle.scene)
      end
      target.damageState.smlDamage=-1
    end
    if target.hp < (target.totalhp*0.25).floor && target.hp>0
      if !target.damageState.lowHP
        target.damageState.lowHP = true
        target.damageState.halfHP = true
        if !target.opposes?
          TrainerDialogue.display("lowHP",@battle,@battle.scene)
        else
          TrainerDialogue.display("lowHPOpp",@battle,@battle.scene)
        end
      end
    elsif target.hp < (target.totalhp*0.5).floor && target.hp>0
      if !target.damageState.halfHP
        target.damageState.halfHP = true
        if !target.opposes?
          TrainerDialogue.display("halfHP",@battle,@battle.scene)
        else
          TrainerDialogue.display("halfHPOpp",@battle,@battle.scene)
        end
      end
    end
  end
end

class PokeBattle_Scene
# Sendout Dialogue
  alias mbd_sendoutBattlers pbSendOutBattlers
  def pbSendOutBattlers(sendOuts,startBattle=false)
    mbd_sendoutBattlers(sendOuts,startBattle)
    sendTriggers = []
    sendOuts.each do |b|
      len =  @battle.pbAbleCount(b[0])
      len1 = (@battle.pbParty(b[0]).length > 6) ? 7 : (@battle.pbParty(b[0]).length + 1)
      len2 = len1 - len
      side=["","Opp"]
      if len2>1
        TrainerDialogue.forceSet("lowHP#{side[b[0]]},#{len2-1}")
        TrainerDialogue.forceSet("halfHP#{side[b[0]]},#{len2-1}")
        TrainerDialogue.forceSet("attack#{side[b[0]]},#{len2-1}")
        TrainerDialogue.forceSet("bigDamage#{side[b[0]]},#{len2-1}")
        TrainerDialogue.forceSet("smlDamage#{side[b[0]]},#{len2-1}")
        TrainerDialogue.forceSet("superEff#{side[b[0]]},#{len2-1}")
        TrainerDialogue.forceSet("notEff#{side[b[0]]},#{len2-1}")
      end
      if @battle.pbAbleCount(b[0]) != 1
        sendTriggers.push(["sendout",len2,side[b[0]]])
      elsif @battle.pbAbleCount(b[0]) == 1
        sendTriggers.push(["last","",side[b[0]]]) if !startBattle
      end
    end
    sendTriggers.each do |a|
      TrainerDialogue.display("#{a[0]}#{a[1]}#{a[2]}",@battle,self)
    end
  end
end

class PokeBattle_AI
  def pbChooseBestNewEnemy(idxBattler,party,enemies)
    return -1 if !enemies || enemies.length==0
    best    = -1
    bestSum = 0
    enemies.each do |i|
      pkmn = party[i]
      sum  = 0
      if BattleScripting.hasAceData?
        aceId = BattleScripting.getAceOf(idxBattler)
        if aceId > -1
          anyOther =  false
          enemyId = (idxBattler-1)/2
          endL = (enemyId == (@battle.sideSizes[1] - 1)) ? @battle.pbParty(1).length : @battle.party2starts[enemyId + 1]
          if aceId < (endL - @battle.party2starts[enemyId])
            for j in @battle.party2starts[enemyId]...endL
              anyOther = true if party[j] && party[j].able? && j != (aceId + @battle.party2starts[enemyId])
            end
            next if anyOther && pkmn == party[aceId + @battle.party2starts[enemyId]]
          end
        end
      end
      pkmn.moves.each do |m|
        next if m.base_damage == 0
        @battle.battlers[idxBattler].eachOpposing do |b|
          bTypes = b.pbTypes(true)
          sum += Effectiveness.calculate(m.type, bTypes[0], bTypes[1], bTypes[2])
        end
      end
      if best==-1 || sum>bestSum
        best = i
        bestSum = sum
      end
    end
    return best
  end
end


#------------------------------------------------------------------------------#
# Main Trainer Dialogue Module
#------------------------------------------------------------------------------#
module TrainerDialogue

  def self.set(param,data)
    $PokemonTemp.dialogueData[:DIAL]=true
    $PokemonTemp.dialogueData[param]=data
    $PokemonTemp.dialogueDone[param]=2
    parCheck=param.split(",")
    int=parCheck[1].to_i
    int=1 if !int || !int.is_a?(Numeric)
    $PokemonTemp.dialogueInstances[parCheck[0]] = 1
  end

  def self.resetAll
    $PokemonTemp.dialogueData={:DIAL=>false}
    $PokemonTemp.dialogueDone={}
    $PokemonTemp.dialogueInstances={}
    $PokemonTemp.orderData = {}
  end

  def self.hasData?
    return $PokemonTemp.dialogueData[:DIAL]
  end

  def self.setDone(param)
    $PokemonTemp.dialogueDone[param] = 1 if !param.include?("rand")
  end

  def self.setFinal
    for key in $PokemonTemp.dialogueDone.keys
      if $PokemonTemp.dialogueDone[key]==1
        $PokemonTemp.dialogueDone[key]=0
        $PokemonTemp.dialogueData[key]=nil
      end
    end
  end

  def self.get(param=nil)
    return false if !self.hasData?
    return $PokemonTemp.dialogueData[param] if param
    return $PokemonTemp.dialogueData
  end

  def self.forceSet(parameter)
    $PokemonTemp.dialogueDone[parameter]=1
    param=parameter.split(",")
    $PokemonTemp.dialogueInstances[param[0]] = (param[1].to_i + 1)
  end

  def self.eval(parameter,noPri=false)
    param=parameter
    return -1 if !self.hasData?
    return -1 if !$PokemonTemp.dialogueDone[param]
    return -1 if $PokemonTemp.dialogueDone[param] && ($PokemonTemp.dialogueDone[param]==0 || $PokemonTemp.dialogueDone[param]==1)
    if $PokemonTemp.dialogueData[param].is_a?(String)
      return 0
    end
    if $PokemonTemp.dialogueData[param].is_a?(Hash)
      return 1
    end
    if $PokemonTemp.dialogueData[param].is_a?(Proc)
      return 2
    end
    if $PokemonTemp.dialogueData[param].is_a?(Array)
      return 3
    end
  end

  def self.display(parameter,battle=nil,scene=nil,noPri=false)
    if $PokemonTemp.dialogueInstances[parameter].is_a?(Numeric) && $PokemonTemp.dialogueInstances[parameter]>1
      param="#{parameter},#{$PokemonTemp.dialogueInstances[parameter]}"
    else
      param=parameter
    end
    case TrainerDialogue.eval(param,noPri)
    when 0
      turnStart= TrainerDialogue.get(param)
      scene.pbShowOpponent(0) if !battle.wildBattle?
      scene.disappearDatabox
      scene.sprites["messageWindow"].text = ""
      pbMessage(_INTL(turnStart))
      if !battle.wildBattle?
        for i in 1..battle.opponent.length
          scene.pbHideOpponent(i)
        end
      end
      scene.appearDatabox
      TrainerDialogue.setDone(param)
      TrainerDialogue.setInstance(parameter)
      return true
    when 1
      turnStart= TrainerDialogue.get(param)
      pbBGMPlay(turnStart["bgm"]) if turnStart["bgm"].is_a?(String)
      scene.disappearDatabox if !turnStart["bar"]
      scene.appearBar if turnStart["bar"]
      scene.sprites["messageWindow"].text = ""
      if turnStart["opp"].is_a?(Numeric) && !battle.wildBattle?
        while turnStart["opp"] >= battle.opponent.length && turnStart["opp"] >= 0
          turnStart["opp"]-=1
        end
        scene.pbShowOpponent(turnStart["opp"],turnStart["abovePkmn"])
        turnStart["opp"]=0 if turnStart["opp"] < 0
        if turnStart["text"].is_a?(Array)
          for i in 0...turnStart["text"].length
            pbMessage(_INTL(turnStart["text"][i]))
          end
        else
          pbMessage(_INTL(turnStart["text"]))
        end
      else
        TrainerDialogue.changeTrainerSprite(turnStart["opp"],scene) if turnStart["opp"].is_a?(String)
        scene.pbShowOpponent(0) if !battle.wildBattle? || (battle.wildBattle? && turnStart["opp"].is_a?(String))
        if turnStart["text"].is_a?(Array)
          for i in 0...turnStart["text"].length
            pbMessage(_INTL(turnStart["text"][i]))
          end
        else
          pbMessage(_INTL(turnStart["text"]))
        end
      end
      if battle.opponent.is_a?(Array)
        for i in 1..battle.opponent.length
          scene.pbHideOpponent(battle.opponent.length) if !battle.wildBattle? || (battle.wildBattle? && turnStart["opp"].is_a?(String))
        end
      else
        scene.pbHideOpponent if !battle.wildBattle? || (battle.wildBattle? && turnStart["opp"].is_a?(String))
      end
      scene.sprites["trainer_1"].setBitmap(pbTrainerSpriteFile(battle.opponent[0].trainertype)) if !battle.wildBattle?
      scene.disappearBar if turnStart["bar"]
      scene.appearDatabox if !turnStart["bar"]
      TrainerDialogue.setDone(param)
      TrainerDialogue.setInstance(parameter)
      return true
    when 2
      turnStart= TrainerDialogue.get(param)
      scene.sprites["messageWindow"].text = ""
      turnStart.call(battle)
      TrainerDialogue.setDone(param)
      TrainerDialogue.setInstance(parameter)
      return true
    when 3
      turnStart= TrainerDialogue.get(param)
      scene.pbShowOpponent(0) if !battle.wildBattle?
      scene.disappearDatabox
      scene.sprites["messageWindow"].text = ""
      for i in 0...turnStart.length
        pbMessage(_INTL(turnStart[i]))
      end
      if !battle.wildBattle?
        for i in 1..battle.opponent.length
          scene.pbHideOpponent(i)
        end
      end
      scene.appearDatabox
      TrainerDialogue.setDone(param)
      TrainerDialogue.setInstance(parameter)
      return true
    end
    return false
  end

  def self.changeTrainerSprite(name,scene,delay=2)
    if name.is_a?(String)
      scene.sprites["trainer_1"].setBitmap("Graphics/Trainers/#{name}")
    elsif name.is_a?(Array)
      for i in 0...name.length
        Graphics.update
        pbWait(delay-1)
        scene.sprites["trainer_1"].setBitmap("Graphics/Trainers/#{name[i]}")
      end
    end
  end

  def self.setInstance(parameter)
    noIncrement = ["lowHP","lowHPOpp","halfHP","halfHPOpp","bigDamage","bigDamageOpp","smlDamage",
      "smlDamageOpp","attack","attackOpp","superEff","superEffOpp","notEff","notEffOpp"]
    return if parameter.include?("rand")
    if !noIncrement.include?(parameter)
       $PokemonTemp.dialogueInstances[parameter] += 1
    end
  end
end

#------------------------------------------------------------------------------#
# Copy of the Trainer Dialogue Module with a new name
#------------------------------------------------------------------------------#
module BattleScripting
  def self.set(param,data)
    TrainerDialogue.set(param,data)
  end

  def self.copy(*args)
    param = args[0]
    $PokemonTemp.dialogueData[:DIAL]=true
    for i in 1...args.length
      $PokemonTemp.dialogueData[args[i]] = $PokemonTemp.dialogueData[param]
      $PokemonTemp.dialogueData[args[i]] = 2
      parCheck=args[i].split(",")
      $PokemonTemp.dialogueInstances[parCheck[0]] = 1
    end
  end

  def self.setInScript(param,name)
    if defined?(DialogueModule) && defined?(DialogueModule::name)
      value = getConst(DialogueModule,name)
      TrainerDialogue.set(param,value)
    end
  end

  def self.hasOrderData?
    return $PokemonTemp.orderData["hasOrder"]
  end

  def self.hasAceData?
    return $PokemonTemp.orderData["hasAce"]
  end

  def self.getAceOf(id)
    return $PokemonTemp.orderData["ace#{id}"] if $PokemonTemp.orderData["ace#{id}"]
    return -1
  end

  def self.getOrderOf(id)
    return $PokemonTemp.orderData["order#{id}"] if $PokemonTemp.orderData["order#{id}"]
    return []
  end

  def self.setTrainerOrder(*args)
    fail = false
    $PokemonTemp.orderData["hasOrder"] = true
    args.each_with_index do |a,i|
      if !a.is_a?(Array) || a.length != 6 || $PokemonTemp.orderData["ace#{2*i + 1}"]
        fail = true
        break
      end
      $PokemonTemp.orderData["order#{2*i +1}"] = a
    end
    $PokemonTemp.orderData["hasOrder"] = false if fail
    p "The script did not accept the Trainer Order Data because it's invalid." if fail
  end

  def self.setTrainerAce(*args)
    fail = false
    $PokemonTemp.orderData["hasAce"] = true
    args.each_with_index do |a,i|
      if !a.is_a?(Numeric) || $PokemonTemp.orderData["order#{2*i + 1}"]
        fail = true
        break
      end
      a = a.clamp(0,6)
      $PokemonTemp.orderData["ace#{2*i + 1}"] = a
    end
    $PokemonTemp.orderData["hasAce"] = false if fail
    p "The script did not accept the Trainer Ace Data because it's invalid." if fail
  end
end

#------------------------------------------------------------------------------#
# New Graphics stuff added by the script
#------------------------------------------------------------------------------#
class PokeBattle_Scene
  alias mbd_initSprites pbInitSprites

  def pbInitSprites
    mbd_initSprites
    if @battle.wildBattle?
      trainerfile = "Graphics/Trainers/trainer000"
      spriteX, spriteY = PokeBattle_SceneConstants.pbTrainerPosition(1,1,1)
      trainer = pbAddSprite("trainer_1",spriteX,spriteY,trainerfile,@viewport)
      trainer.visible=false
      return if !trainer.bitmap
      # Alter position of sprite
      trainer.z  = 7
      trainer.ox = trainer.src_rect.width/2
      trainer.oy = trainer.bitmap.height
    end
  end

  def pbShowOpponent(idxTrainer,priority=false)
    # Set up trainer appearing animation
    @sprites["trainer_#{idxTrainer+1}"].z = 200 if priority && @sprites["trainer_#{idxTrainer+1}"]
    appearAnim = TrainerAppearAnimation.new(@sprites,@viewport,idxTrainer)
    @animations.push(appearAnim)
    # Play the animation
    while inPartyAnimation?; pbUpdate; end
  end

  def pbHideOpponent(idxTrainer=1)
    # Set up trainer disappearing animation
    disappearAnim = TrainerDisappearAnimation.new(@sprites,@viewport,idxTrainer)
    @animations.push(disappearAnim)
    # Play the animation
    while inPartyAnimation?; pbUpdate; end
    @sprites["trainer_#{idxTrainer+1}"].z = 7 + idxTrainer if @sprites["trainer_#{idxTrainer+1}"]
  end

  def disappearDatabox
    unfadeAnim = DataboxFadeAnimation.new(@sprites,@viewport,@battle.battlers.length)
    @animations.push(unfadeAnim)
    loop do
      unfadeAnim.update
      pbUpdate
      break if unfadeAnim.animDone?
    end
    unfadeAnim.dispose
  end

  def appearDatabox
    unfadeAnim = DataboxUnfadeAnimation.new(@sprites,@viewport,@battle.battlers.length)
    @animations.push(unfadeAnim)
    loop do
      unfadeAnim.update
      pbUpdate
      break if unfadeAnim.animDone?
    end
    unfadeAnim.dispose
  end

  def appearBar
    pbAddSprite("topBar",Graphics.width,0,"Graphics/Battle animations/blackbar_top",@viewport) if !@sprites["topBar"]
    pbAddSprite("bottomBar",0,Graphics.height,"Graphics/Battle animations/blackbar_bottom",@viewport) if !@sprites["bottomBar"]
    unfadeAnim = BlackBarAppearAnimation.new(@sprites,@viewport,@battle.battlers.length)
    @animations.push(unfadeAnim)
    loop do
      unfadeAnim.update
      pbUpdate
      break if unfadeAnim.animDone?
    end
    unfadeAnim.dispose
  end

  def disappearBar
    unfadeAnim = BlackBarDisappearAnimation.new(@sprites,@viewport,@battle.battlers.length)
    @animations.push(unfadeAnim)
    loop do
      unfadeAnim.update
      pbUpdate
      break if unfadeAnim.animDone?
    end
    unfadeAnim.dispose
  end
end

class TrainerDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,idxTrainer)
    @idxTrainer = idxTrainer
    super(sprites,viewport)
  end

  def createProcesses
    delay = 0
    # Make old trainer sprite move off-screen first if necessary
    if @sprites["trainer_#{@idxTrainer}"].visible
      oldTrainer = addSprite(@sprites["trainer_#{@idxTrainer}"],PictureOrigin::Bottom)
      oldTrainer.moveDelta(delay,8,Graphics.width/4,0)
      oldTrainer.setVisible(delay+8,false)
      delay = oldTrainer.totalDuration
    end
  end
end

class DataboxFadeAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,battlers,delay=nil,specific=nil)
    @battlers = battlers
    @delay = delay
    @specific = specific
    super(sprites,viewport)
  end

  def createProcesses
    delay = 0
    boxes = []
    for i in 0...@battlers
      if @sprites["dataBox_#{i}"]
        next if @specific.is_a?(Array) && @specific.include?(i)
        boxes[i]= addSprite(@sprites["dataBox_#{i}"])
        boxes[i].moveOpacity(delay,3,0)
      end
    end
  end
end

class DataboxUnfadeAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,battlers,delay=nil,specific=nil)
    @battlers = battlers
    @delay = delay
    @specific = specific
    super(sprites,viewport)
  end

  def createProcesses
    delay = (@delay.is_a?(Numeric))? @delay : 0
    boxes = []
    for i in 0...@battlers
      if @sprites["dataBox_#{i}"]
        next if @specific.is_a?(Array) && @specific.include?(i)
        boxes[i]= addSprite(@sprites["dataBox_#{i}"])
        boxes[i].setOpacity(delay,0)
        boxes[i].moveOpacity(delay,3,255)
      end
    end
  end
end

class BlackBarAppearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,battlers)
    @battlers = battlers
    super(sprites,viewport)
  end

  def createProcesses
    delay = 10
    boxes = []
    toMoveBottom = [@sprites["bottomBar"].bitmap.width,Graphics.width].max
    toMoveTop = [@sprites["topBar"].bitmap.width,Graphics.width].max
    topBar = addSprite(@sprites["topBar"],PictureOrigin::TopLeft)
    topBar.setZ(0,200)
    bottomBar = addSprite(@sprites["bottomBar"],PictureOrigin::BottomRight)
    bottomBar.setZ(0,200)
    topBar.setOpacity(0,255)
    bottomBar.setOpacity(0,255)
    topBar.setXY(0,Graphics.width,0)
    bottomBar.setXY(0,0,Graphics.height)
    topBar.moveXY(delay,10,(Graphics.width-toMoveTop),0)
    bottomBar.moveXY(delay,10,toMoveBottom,Graphics.height)
    for i in 0...@battlers
      if @sprites["dataBox_#{i}"]
        boxes[i]= addSprite(@sprites["dataBox_#{i}"])
        boxes[i].moveOpacity(delay,5,0)
      end
    end
  end
end

class BlackBarDisappearAnimation < PokeBattle_Animation
  def initialize(sprites,viewport,battlers)
    @battlers = battlers
    super(sprites,viewport)
  end

  def createProcesses
    delay = 10
    boxes = []
    topBar = addSprite(@sprites["topBar"],PictureOrigin::TopLeft)
    topBar.setZ(0,200)
    bottomBar = addSprite(@sprites["bottomBar"],PictureOrigin::BottomRight)
    bottomBar.setZ(0,200)
    topBar.moveOpacity(delay,8,0)
    bottomBar.moveOpacity(delay,8,0)
    for i in 0...@battlers
      if @sprites["dataBox_#{i}"]
        boxes[i]= addSprite(@sprites["dataBox_#{i}"])
        boxes[i].setOpacity(0,0)
        boxes[i].moveOpacity(delay,5,255)
      end
    end
    topBar.setXY(delay+5,Graphics.width,0)
    bottomBar.setXY(delay+5,0,Graphics.height)
  end
end


#------------------------------------------------------------------------------#
# Main Dialogue Data Storage
#------------------------------------------------------------------------------#
class PokemonTemp
  attr_accessor :dialogueData
  attr_accessor :dialogueDone
  attr_accessor :dialogueInstances
  attr_accessor :orderData

  def dialogueData
    @dialogueData = {:DIAL=>false} if !@dialogueData
    return @dialogueData
  end

  def dialogueDone
    @dialogueDone = {} if !@dialogueDone
    return @dialogueDone
  end

  def dialogueInstances
    @dialogueInstances = {} if !@dialogueInstances
    return @dialogueInstances
  end

  def orderData
    @orderData = {} if !@orderData
    return @orderData
  end
end
$ShiftSwitch=false