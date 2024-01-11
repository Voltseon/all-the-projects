#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#                                                                              #
#                          Mid Battle Dialogue and Script                      #
#                                       v1.5                                   #
#                                 By Golisopod User                            #
#                                                                              #
#==============================================================================#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\#
#==============================================================================#
#                                                                              #
# This is the dialogue portion of the script. If for some reason the script    #
# window is too small for you, you can input the dialogue data over here and   #
# call it when needed in Battle. This will keep your events much cleaner.      #
#                                                                              #
# THIS IS ONLY AN OPTIONAL WAY OF INPUTTING BATTLE DIALOGUE,IT'S NOT NECESSARY #
#==============================================================================#

#DON'T DELETE THIS LINE
module DialogueModule


# Format to add new stuff here
# Name = data
#
# To set in a script command
# BattleScripting.setInScript("condition",:Name)
# The ":" is important

#  Joey_TurnStart0 = {"text"=>"Hello","bar"=>true}
#  BattleScripting.set("turnStart0",:Joey_TurnStart0)



  # This is an example of Scene Manipulation where I manipulate the color tone of each individual graphic in the scene to simulate a ""fade to black"
  FRLG_Turn0 = Proc.new{|battle|
                for i in 0...8
                  val = 25+(25*i)
                  battle.scene.sprites["battle_bg"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["base_0"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["base_1"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["dataBox_0"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["pokemon_0"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["pokemon_1"].color=Color.new(-255,-255,-255,val)
                  pbWait(1)
                end
                pbMessage("\\bOh, for Pete's sake...\\nSo pushy, as always.")
                pbMessage("\\b\\PN,\\nYou've never had a Pokémon Battle before, have you?")
                pbMessage("\\bA Pokémon battle is when Trainer's pit their Pokémon against each other.")
                for i in 0...8
                  val = 200 - (25+(25*i))
                  battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                  pbWait(1)
                end
                pbMessage("\\bThe Trainer that makes the other Trainer's Pokémon faint by lowering their HP to 0, wins.")
                for i in 0...8
                  val = 25+(25*i)
                  battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                  pbWait(1)
                end
                pbMessage("\\bBut rather than talking about it, you'll learn more from experience.")
                pbMessage("\\bTry battling and see for yourself.")
                for i in 0...8
                  val = 200-(25+(25*i))
                  battle.scene.sprites["battle_bg"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["base_0"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["base_1"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["dataBox_0"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["pokemon_0"].color=Color.new(-255,-255,-255,val)
                  battle.scene.sprites["pokemon_1"].color=Color.new(-255,-255,-255,val)
                  pbWait(1)
                end
              }

  FRLG_Damage = Proc.new{|battle|
                  for i in 0...8
                    val = 25+(25*i)
                    battle.scene.sprites["battle_bg"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["base_0"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["base_1"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["dataBox_0"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["pokemon_0"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["pokemon_1"].color=Color.new(-255,-255,-255,val)
                    pbWait(1)
                  end
                  pbMessage("\\bInflicting damage on the foe is the key to winning a battle")
                  for i in 0...8
                    val = 200-(25+(25*i))
                    battle.scene.sprites["battle_bg"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["base_0"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["base_1"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["dataBox_0"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["pokemon_0"].color=Color.new(-255,-255,-255,val)
                    battle.scene.sprites["pokemon_1"].color=Color.new(-255,-255,-255,val)
                    pbWait(1)
                  end
                }

  FRLG_End = Proc.new{|battle|
              battle.scene.pbShowOpponent(0)
              pbMessage("WHAT!\\nUnbelievable!\\nI picked the wrong Pokémon!")
              for i in 0...8
                val = 25+(25*i)
                battle.scene.sprites["trainer_1"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["battle_bg"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["base_0"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["base_1"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["dataBox_0"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["pokemon_0"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["pokemon_1"].color=Color.new(-255,-255,-255,val)
                pbWait(1)
              end
              pbMessage("\\bHm! Excellent!")
              pbMessage("\\bIf you win, you will earn prize money and your Pokémon will grow.")
              pbMessage("\\bBattle other Trainers and make your Pokémon strong!")
              for i in 0...8
                val = 200-(25+(25*i));battle.scene.sprites["trainer_1"].color=Color.new(-255,-255,-255,val);
                battle.scene.sprites["battle_bg"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["base_0"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["base_1"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["dataBox_1"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["dataBox_0"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["pokemon_0"].color=Color.new(-255,-255,-255,val)
                battle.scene.sprites["pokemon_1"].color=Color.new(-255,-255,-255,val)
                pbWait(1)
              end
            }

  Catching_Start = {"text"=>["This is the 1st time you're catching Pokemon right Red?", "Well let me tell you it's surprisingly easy!","1st weaken the Pokemon",
                    "Healthy Pokemon are much harder to catch"],"opp"=>"trainer024"}

  Catching_Catch = Proc.new{|battle|
                      BattleScripting.set("turnStart#{battle.turnCount+1}",Proc.new{|battle|
                        battle.scene.pbShowOpponent(0)
                        # Checking for Status to display different dialogue
                        if battle.battlers[1].pbHasAnyStatus?
                          pbMessage("Nice strategy! Inflicting a status condiition on the Pokémon further increases your chance at catching it.")
                          pbMessage("Now is the perfect time to throw a PokeBall!")
                        else
                          pbMessage("Great work! You're a natural!")
                          pbMessage("Now is the perfect time to throw a PokeBall!")
                        end
                        ball=0
                        battle.scene.pbHideOpponent
                        # Forcefully Opening the Bag and Throwing the Pokevall
                        pbFadeOutIn(99999){
                          scene = PokemonBag_Scene.new
                          screen = PokemonBagScreen.new(scene,$PokemonBag)
                          while ball==0
                            ball = screen.pbChooseItemScreen(Proc.new{|item| pbIsPokeBall?(item) })
                            if pbIsPokeBall?(ball)
                              break
                            end
                          end
                        }
                        battle.pbThrowPokeBall(1,ball,300,false)
                      })
                   }
# My Goal here was to have the message appear on the end of the turn after Opal sends out her Pokemon
   Opal_Send1 = Proc.new{|battle|
                  BattleScripting.set("turnEnd#{battle.turnCount}",Proc.new{|battle|
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Question!")
                    # Choice Box Stuff
                    cmd=0
                    cmd= pbMessage("You...\\nDo you know my nickname?",["The Magic-User","The wizard"],0,nil,0)
                    if cmd == 1
                      pbMessage("\\se[SwShCorrect]Ding ding ding! Congratulations, you are correct!")
                      battle.scene.pbHideOpponent
                      battle.scene.disappearBar
                      battle.battlers[0].pbRaiseStatStage(PBStats::SPEED,1,battle.battlers[0])
                    else
                      pbMessage("\\se[SwShIncorrect]Bzzzzt! Too bad!")
                      battle.scene.pbHideOpponent
                      battle.scene.disappearBar
                      battle.battlers[0].pbLowerStatStage(PBStats::SPEED,1,battle.battlers[0])
                    end
                  })
                }

   Opal_Send2 = Proc.new{|battle|
                  BattleScripting.set("turnEnd#{battle.turnCount+1}",Proc.new{|battle|
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Question!")
                    cmd=0
                    cmd= pbMessage("What is my favorite color?",["Pink","Purple"],0,nil,0)
                    if cmd == 1
                      pbMessage("\\se[SwShCorrect]Yes, a nice, deep purple... Truly grand, don't you think?")
                      battle.scene.pbHideOpponent
                      battle.scene.disappearBar
                      battle.battlers[0].pbRaiseStatStage(PBStats::DEFENSE,1,battle.battlers[0])
                      battle.battlers[0].pbRaiseStatStage(PBStats::SPDEF,1,battle.battlers[0])
                    else
                      pbMessage("\\se[SwShIncorrect]That's what I like to see in other people, but it's not what I like for myself.")
                      battle.scene.pbHideOpponent
                      battle.scene.disappearBar
                      battle.battlers[0].pbLowerStatStage(PBStats::DEFENSE,1,battle.battlers[0])
                      battle.battlers[0].pbLowerStatStage(PBStats::SPDEF,1,battle.battlers[0])
                    end
                  })
                }

   Opal_Send3 = Proc.new{|battle|
                  BattleScripting.set("turnEnd#{battle.turnCount+1}",Proc.new{|battle|
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Question!")
                    cmd=0
                    cmd= pbMessage("All righty then... How old am I?",["16 years old","88 years old"],1,nil,1)
                    if cmd == 0
                      pbMessage("\\se[SwShCorrect]Hah! I like your answer!")
                      battle.scene.pbHideOpponent
                      battle.scene.disappearBar
                      battle.battlers[0].pbRaiseStatStage(PBStats::ATTACK,1,battle.battlers[0])
                      battle.battlers[0].pbRaiseStatStage(PBStats::SPATK,1,battle.battlers[0])
                    else
                      pbMessage("\\se[SwShIncorrect]Well, you're not wrong. But you could've been a little more sensitive.")
                      battle.scene.pbHideOpponent
                      battle.scene.disappearBar(battle)
                      battle.battlers[0].pbLowerStatStage(PBStats::ATTACK,1,battle.battlers[0])
                      battle.battlers[0].pbLowerStatStage(PBStats::SPATK,1,battle.battlers[0])
                    end
                  })
                }

   Opal_Last = Proc.new{|battle|
                 battle.scene.appearBar
                 battle.scene.pbShowOpponent(0)
                 TrainerDialogue.changeTrainerSprite("BerthaPlatinum_2",battle.scene)
                 pbMessage("My morning tea is finally kicking in...")
                 TrainerDialogue.changeTrainerSprite("trainer069",battle.scene)
                 pbWait(5)
                 pbMessage("\\xl[Opal]and not a moment too soon!")
                 battle.scene.pbHideOpponent
                 battle.scene.disappearBar
              }

   Opal_Mega = Proc.new{|battle|
                battle.scene.appearBar
                battle.scene.pbShowOpponent(0)
                TrainerDialogue.changeTrainerSprite(["BerthaPlatinum_2"],battle.scene)
                pbMessage("Are you prepared?")
                pbSEPlay("SwShImpact")
                TrainerDialogue.changeTrainerSprite(["BerthaPlatinum_2","trainer069","BerthaPlatinum"],battle.scene,2)
                pbWait(5)
                pbMessage("I'm going to have some fun with this!")
                battle.scene.pbHideOpponent
                TrainerDialogue.changeTrainerSprite(["trainer069"],battle.scene)
                battle.scene.disappearBar
              }

   Opal_LastAttack = Proc.new{|battle|
                      battle.scene.appearBar
                      battle.scene.pbShowOpponent(0)
                      TrainerDialogue.changeTrainerSprite(["BerthaPlatinum_2"],battle.scene)
                      pbMessage("You lack pink! Here, let us give you some.")
                      pbSEPlay("SwShImpact")
                      TrainerDialogue.changeTrainerSprite(["BerthaPlatinum_2","trainer069","BerthaPlatinum"],battle.scene,2)
                      pbWait(16)
                      battle.scene.pbHideOpponent
                      TrainerDialogue.changeTrainerSprite(["trainer069"],battle.scene)
                      battle.scene.disappearBar
                    }

   Brock_LastPlayer = Proc.new{|battle|
                      # Displaying Differen Dialogue if the Pokemon is a Pikachu
                        if battle.battlers[0].isSpecies?(:PIKACHU)
                          battle.scene.pbShowOpponent(0)
                          battle.scene.disappearDatabox
                          pbMessage("It's that Pikachu again.")
                          pbMessage("I honestly feel sorry for it.")
                          pbMessage("Being raised by such a weak and incapable Pokémon Trainer.")
                          pbMessage("Let's show him how weak we are Pikachu.")
                      # Setting the Geodude's typing to Water to allow Pikachu to hit it super Effectively
                          battle.battlers[1].pbChangeTypes(getConst(PBTypes,:WATER))
                          battle.scene.pbHideOpponent
                          battle.scene.appearDatabox
                        elsif battle.battlers[0].isSpecies?(:PIDGEOTTO)
                      # Setting the Geodude's typing to Grass to allow Pidgeotto to hit it super Effectively
                          battle.battlers[1].pbChangeTypes(getConst(PBTypes,:GRASS))
                          battle.battlers[1].pbChangeTypes(getConst(PBTypes,:BUG))
                        end
                      # Using the Laser Focus and Endure Effects to force a Ctitical Hit and make sure that the Player's Pokemon Endures the next hit.
                        battle.battlers[0].effects[PBEffects::LaserFocus] = 2
                        battle.battlers[0].effects[PBEffects::Endure] = true
                      }
   Brock_MockPlayer = Proc.new{|battle|
                        battle.scene.pbShowOpponent(0)
                        battle.scene.disappearDatabox
                        # If the Player starts with a Pidgeotto then show this dialogue, else the other one
                        if battle.battlers[0].pbHasType?(:FLYING)
                          pbMessage("Hmph. Bad Strategy.")
                          pbMessage("Don't you know Flying Types are weak against Rock type.")
                          pbMessage("Ummm... I guess I forgot about that.")
                          pbMessage("C'mon \\PN, use your head.")
                        else
                          pbMessage("Look's like you haven't trained a bit since last time \\PN.")
                          pbMessage("I'm gonna make you eat those words Brock!")
                        end
                        battle.scene.pbHideOpponent
                        battle.scene.appearDatabox
                      }

   Brock_GiveUp = Proc.new{|battle|
                    battle.scene.pbShowOpponent(0)
                    battle.scene.disappearDatabox
                    pbMessage("Are you giving up already, \\PN?")
                    # Forcefully Setting the Fainted Condition to be done so that it doesn't show up later.
                    TrainerDialogue.setDone("fainted")
                    battle.scene.pbHideOpponent
                    battle.scene.appearDatabox
                  }

   Brock_Sprinklers = Proc.new{|battle|
                      # Immedialtely the Next Turn after the Player's HP is less than half, do this
                        BattleScripting.set("turnStart#{battle.turnCount+1}",Proc.new{|battle|
                          battle.pbAnimation(getID(PBMoves,:BIND),battle.battlers[1],battle.battlers[0])
                          battle.pbCommonAnimation("Bind",battle.battlers[0],nil)
                          battle.scene.disappearDatabox
                          battle.pbDisplay(_INTL("Onix constricted its tail around {1}!",battle.battlers[0].pbThis(true)))
                          battle.scene.pbDamageAnimation(battle.battlers[0])
                          battle.pbDisplay(_INTL("{1} struggles to escape Onix' grasp!",battle.battlers[0].pbThis))
                          battle.scene.pbDamageAnimation(battle.battlers[0])
                          pbMessage(_INTL("{1} hang on a little longer!",battle.battlers[0].name))
                          pbMessage("...")
                          pbBGMFade(2)
                          battle.scene.pbShowOpponent(0)
                          pbMessage("Onix stop!")
                          pbMessage("No Brock, I want to play this match till the end.")
                          pbMessage("There's no point in going on, besides, I don't want to hurt your Pokémon more.")
                          pbMessage("Hrgh..")
                          battle.scene.pbHideOpponent
                          pbMessage("...")
                          battle.pbCommonAnimation("Rain",nil,nil)
                          battle.pbDisplay("The sprinklers turned on!")
                          pbPlayCrySpecies(:ONIX,0,70,70)
                          battle.pbDisplay("Onix became soaking wet!")
                          pbBGMPlay("BrockWin")
                          battle.scene.pbShowOpponent(0)
                          battle.scene.disappearDatabox
                          pbMessage("\\PN! Rock Pokemon are weakened by water!")
                          battle.battlers[0].effects[PBEffects::LaserFocus] = 2
                          battle.battlers[1].effects[PBEffects::Endure] = true
                          if battle.battlers[0].isSpecies?(:PIKACHU)
                            # Setting the Geodude's typing to Water to allow Pikachu to hit it super Effectively
                            battle.battlers[1].pbChangeTypes(getConst(PBTypes,:WATER))
                          elsif battle.battlers[0].isSpecies?(:PIDGEOTTO)
                            # Setting the Geodude's typing to Grass to allow Pidgeotto to hit it super Effectively
                            battle.battlers[1].pbChangeTypes(getConst(PBTypes,:GRASS))
                            battle.battlers[1].pbChangeTypes(getConst(PBTypes,:BUG))
                          end
                          pbMessage(_INTL("{1}! Let's get 'em!",battle.battlers[0].pbThis(true)))
                          battle.battlers[1].effects[PBEffects::Flinch]=1
                          battle.scene.appearDatabox
                        })
                      }

   Brock_Forfeit = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    pbMessage(_INTL("Okay {1}! Lets finish him off with a...",battle.battlers[0].name))
                    pbBGMFade(2)
                    pbWait(10)
                    pbBGMPlay("BrockGood")
                    pbMessage("My consience is holding me back!")
                    pbMessage("I can't bring myself to beat Brock!")
                    pbMessage("I'm imagining his little brothers and sisters stopping me from defeating the one person they love!")
                    pbMessage("\\PN, I think you better open your eyes.")
                    pbMessage("Huh!")
                    pbMessage("Stop hurting our brother you big bully!")
                    pbMessage("Believe me kid! I'm no bully.")
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Stop it! Get off, all of you.")
                    pbMessage("This is an official match, and we're gonna finish this no matter what.")
                    pbMessage("But Brock, we know you love you Pokémon so much!")
                    pbMessage("That's why we can't watch Onix suffer from another attack!")
                    pbMessage("...")
                    pbMessage("...")
                    pbMessage(_INTL("{1}! Return!",battle.battlers[0].name))
                    battle.scene.pbRecall(0)
                    pbMessage("What do you think you're doing! This match isn't over yet \\PN.")
                    pbMessage("Those sprinklers going off was an accident. Winning a match because of that wouldn't have proven anything.")
                    pbMessage("Next time we meet, I'll beat you my way, fair and square!")
                    battle.scene.pbHideOpponent
                    battle.pbDisplay("You forfeited the match...")
                    battle.decision=3
                    pbMessage("Hmph! Just when he finally gets a lucky break. He decides to be a nice guy too.")
                  }

  Joey_Test = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    battle.scene.appearBar
                    pbMessage("You thought I was done, huh?")
                    pbWait(4)
                    pbMessage("Larvet, use Tackle!!")
                    pbWait(30)
                    pbMessage("Larvet??")
                    pbMessage("Ugh, you stupid Larvet not following my orders!")
                    battle.scene.pbRecall(1)
                    battle.scene.pbHideOpponent
                    battle.scene.disappearBar
                    battle.scene.pbRecall(0)
                    battle.decision=1
                  }

  Rival1Start = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("\\rWhen you defend the weak as we do, you cannot afford to let your defenses slip.")
                    pbMessage("\\rFerrier and I are pillars of justice!")
                    pbMessage("\\rNow it's time for my secret Howlight Harlequin technique. Sunlight Shield!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  Rival1BigDmg = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("\\rIt seems we underestimated you, trainer.")
                    pbMessage("\\rBut fear not! Our bodies are made of steel, and we will stand proudly in this fight.")
                    pbMessage("\\rFerrier, Sunlight Screech!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[0].pbLowerStatStage(:ATTACK,1,battle.battlers[0])
                    battle.scene.pbHideOpponent
                  }

  DavidAttackOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("David: \\bEvery gym leader has their own special technique that they use to spice up the battle.")
                    pbMessage("\\bMine isn't quite so special, but it certainly packs a punch.")
                    pbMessage("\\bMousnot, draw from your inner strength!")
                    pbMessage("\\bSpecial technique: Claw Sharpen!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  DavidHalfHPOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("David: \\bIt seems I allowed our defenses to faulter.")
                    pbMessage("\\bIt's time for another Defense Curl!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.pbAnimation(:DEFENSECURL,battle.battlers[1],battle.battlers[1])
                    battle.battlers[1].pbOpposingSide.effects[PBEffects::DefenseCurl]=true
                    battle.scene.pbHideOpponent
                  }

  DavidLastOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("David: \\bThis battle is really a cliffhanger, huh?")
                    pbMessage("\\bWell, I didn't earn my spot as a gym leader by letting my Pokémon be easy prey.")
                    pbMessage("\\bRabbun, allow yourself to feel the wind beneath your fur.")
                    pbMessage("\\bIt's time for an Agility!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.pbAnimation(:AGILITY,battle.battlers[1],battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPEED,2,battle.battlers[1])
                    battle.scene.pbHideOpponent
                  }

  DavidItemOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("David: \\bOh jeez, it seems like I've been put into a bit of a corner!")
                    pbMessage("\\bI guess I 'ought to use a Super Potion.")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.scene.pbHideOpponent
                  }

  DavidEndSpeech = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("David: \\bOur battle is finally complete!")
                    pbMessage("\\bAnd with that, I must congratulate you, \\PN.")
                    pbMessage("\\bYour Pokémon training skills were superior.")
                    battle.scene.pbHideOpponent
                  }

  FinchTurnStart1 = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Fitch: \\b1, 2, 3, 4! Let's all hit the dance floor.")
                    pbMessage("\\b5, 6, 7, 8, Recrit, let's strengthen our cores!")
                    pbMessage("\\bSpecial technique: Core Enforcer!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  FinchSendout2Opp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Fitch: \\bMy Pokémon and I are really in sync.")
                    pbMessage("\\bAre you in sync with your own?")
                    pbMessage("\\bSpecial technique: Energy Boost!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  FinchLastOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Fitch: \\bI've gotten out of worse jams before!")
                    pbMessage("\\bWe just have to catch up to your blazing speed.")
                    pbMessage("\\bOne more time, special technique: Core Enforcer!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  FinchBigDamage = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Fitch: \\bExcellent, a direct hit!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.scene.pbHideOpponent
                  }

  FinchBigDamageOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Fitch: \\bLooks like I was the one who got caught off guard that time.")
                    pbMessage("\\bBut no worries! I've always got a plan...")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.scene.pbHideOpponent
                  }

  FinchEndSpeech = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Fitch: \\bAw, darn it! I really thought I had you for a second there.")
                    pbMessage("\\bWell it's time to shut down the stages and turn off the music.")
                    pbMessage("\\bYou won fair and square!")
                    battle.scene.pbHideOpponent
                  }

  LauraTurnStart1 = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Laura-Gene: \\rOh, I'm supposed to have some cool speech right about now, I think...")
                    pbMessage("\\rOkay, uh...")
                    pbMessage("\\rPokémon are cool. And so is photography.")
                    pbMessage("\\rThat's it.")
                    battle.scene.pbHideOpponent
                    pbWait(10)
                    pbMessage("Feverat and Reptear were so inspired by Laura-Gene's confidence that...")
                    pbMessage("Laura's special technique: Radiant Strength!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1],false)
                    battle.battlers[3].pbRaiseStatStage(:DEFENSE,1,battle.battlers[3])
                    battle.battlers[3].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[3],false)
                  }

  LauraSendOut3Opp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Laura-Gene: \\rRight, I was supposed to have some lines here. Let me read the script...")
                    pbWait(10)
                    pbMessage("\\rOh, \\PN, you've utterly defeated my first team member. However will I recover?!")
                    pbMessage("\\r...Something like that sound right?")
                    pbMessage("\\rI'll have my Pokémon make it rain now. Rain always makes for more atmospheric shot composition.")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.pbStartWeather(battle.battlers[1],:Rain)
                    battle.scene.pbHideOpponent
                  }

  LauraBigDamageOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Laura-Gene: \\rWow! You're uh... A bit stronger than I expected.")
                    pbMessage("\\rAlright, I guess I have to get up and actually do something now, huh?")
                    pbMessage("\\r...Special technique. That's what Dave and Fitch call them, right?")
                    pbMessage("\\rWell mine is a bit different than theirs.")
                    pbMessage("\\rPiercing Glare!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[0].pbPetrify if battle.battlers[0].pbCanPetrify?(battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  LauraLastOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Laura-Gene: \\rFinally down to my last Pokémon, huh?")
                    pbMessage("\\rWell it's not right of me to go down without a fight.")
                    pbMessage("\\r...Uh, I don't really have a plan or anything. Sooo...")
                    pbMessage("\\rSpecial Technique: Slipstream?")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    if battle.battlers[1].isSpecies?(:DISHORE)
                      battle.pbAnimation(:SLIPSTREAM,battle.battlers[1],battle.battlers[1])
                      battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1])
                    else
                      battle.pbAnimation(:SLIPSTREAM,battle.battlers[3],battle.battlers[3])
                      battle.battlers[3].pbRaiseStatStage(:SPEED,1,battle.battlers[3])
                    end
                    battle.scene.pbHideOpponent
                  }

  LauraItemOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Laura-Gene: \\rSomething, something, strengthen the bonds in our inner cores.")
                    pbMessage("\\rI'm gonna use an X Attack now.")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.scene.pbHideOpponent
                  }

  LauraEndSpeech = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Laura-Gene: \\rOh no. I lost. How tragic.")
                    pbMessage("\\rI suppose you earned that victory, fair and square.")
                    battle.scene.pbHideOpponent
                  }

  CrushGirlAmy = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("\\rYou still wanna know why they call me a Crush Girl?")
                    pbMessage("\\rIt's because I have a massive crush on Fitch!")
                    battle.scene.pbHideOpponent
                  }

  RangerEthan = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("\\bRats and fish, rats and fish...")
                    pbMessage("\\bThose are the Pokémon I have!")
                    battle.scene.pbHideOpponent
                  }

  NOVAJaredLana = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Jared: \\bOh no, our Pokémon weren't as strong as yours!")
                    pbMessage("Lana: \\rHow could we let this happen?")
                    battle.scene.pbHideOpponent
                  }

  Rival2BattleStart = Proc.new{|battle|
                    pbMessage("You are challenged by the Sunlight Crusader:")
                    pbMessage("Rival Howlight Harlequin!")
                  }

  Rival2TurnStart1 = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rI cannot bare the fact that one such as you beat me to the scene of the crime!")
                    pbMessage("\\rThat simply must not do. We must bolster our resolve, and increase our reflexes.")
                    pbMessage("\\rSpecial Technique: Sunlight Overdrive!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:SPEED,2,battle.battlers[1])
                    battle.scene.pbHideOpponent
                  }

  Rival2TurnEnd3 = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rI have another special technique prepared, just for good measure.")
                    pbMessage("\\rHere's my new technique: Sunlight Inferno!")
                    battle.scene.disappearBar
                    battle.pbAnimation(:EMBER,battle.battlers[1],battle.battlers[0])
                    if battle.battlers[0].pbCanInflictStatus?(:BURN,battle.battlers[1],false)
                      battle.battlers[0].pbInflictStatus(:BURN,1,nil)
                    else
                      battle.pbDisplay(_INTL("{1} resisted the technique!",battle.battlers[0].name))
                    end
                    battle.scene.appearDatabox
                    battle.scene.pbHideOpponent
                  }

  Rival2BigDamageOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rI've underestimated you once again, citizen.")
                    pbMessage("\\rYou know how the saying goes, though...")
                    pbMessage("\\rFool me once, shame on you.")
                    pbMessage("\\rBut fool me twice...")
                    pbMessage("\\rSpecial Technique: Sunlight Shield!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:DEFENSE,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPECIAL_DEFENSE,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  Rival2HalfHPOpp = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rWe're in a pinch.")
                    pbMessage("\\rBut that's nothing a special technique won't fix.")
                    pbMessage("\\rSpecial Technique: Sunlight Synthesis!")
                    pbMessage("\\r...I'm actually just using a Super Potion, but it sounded cooler that way.")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRecoverHP(50)
                    battle.scene.pbHideOpponent
                  }

  Rival2SendOut2 = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rAh, another rousing battle. Expected nothing less.")
                    pbMessage("\\rPebblun, steel yourself.")
                    pbMessage("\\rNow it's time for your own Special Technique: Iron Barrier!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:DEFENSE,2,battle.battlers[1])
                    battle.scene.pbHideOpponent
                  }

  Rival2SendOut3 = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.appearBar
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rWe're in the final stretch, citizen.")
                    pbMessage("\\rI can't allow us to faulter now, though.")
                    pbMessage("\\rA true hero rises to the occasion in times of need precisely like this.")
                    pbMessage("\\rSpecial Technique, Ferrier: Sunlight Justice!")
                    battle.scene.disappearBar
                    battle.scene.appearDatabox
                    battle.battlers[1].pbRaiseStatStage(:ATTACK,1,battle.battlers[1])
                    battle.battlers[1].pbRaiseStatStage(:SPECIAL_ATTACK,1,battle.battlers[1],false)
                    battle.battlers[1].pbRaiseStatStage(:SPEED,1,battle.battlers[1],false)
                    battle.scene.pbHideOpponent
                  }

  Rival2EndSpeech = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    battle.scene.pbShowOpponent(0)
                    pbMessage("Harlequin: \\rA true valiant exchange. The most I could ever hope for.")
                    pbMessage("\\rYou have well-earned this victory.")
                    battle.scene.pbHideOpponent
                  }

  EulerSeashoreIntro = Proc.new{|battle|
                    battle.scene.disappearDatabox
                    pbMessage("The Ferrier seems to be \\rEnraged\\c[0]!")
                    battle.battlers[0].pbLowerStatStage(:ACCURACY,1,battle.battlers[0])
                    battle.scene.appearDatabox
                  }

# DONT DELETE THIS END
# ok I won't
end
