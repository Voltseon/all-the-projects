################################################################################
  #
  # Alternate Methods
  #
  ################################################################################
  #
  # You can ignore these methods as they do not have any comments explaining them
  # These are here in case you prefer to use for example:
  # vReceiveItem over vRI, just in case
  # All of these methods use vA,vB,vC... as their input, they dont mean anything
  # They are just indexes. If you are interested in adding your own methods,
  # Go ahead, it's free, but don't forget to re-add them when updating the script
  # <3 Voltseon
  #
  # In case these alternate methods are in the way when scrolling through
  # the script, I recommend you put these in another seperate section
  # !But dont forget to update the Alternate Methods when doing that!
  #
  ################################################################################
  
  #Item Manipulation
  def vReceiveItem(vA, vB=1)
    vRI(vA, vB)
    end
    
    def vItemReceive(vA, vB=1)
    vRI(vA, vB)
    end
    
    def vGI(vA, vB=1)
    vRI(vA, vB)
    end
    
    def vGetItem(vA, vB=1)
    vRI(vA, vB)
    end
    
    def vItemGet(vA, vB=1)
    vRI(vA, vB)
    end
    
    def vFindItem(vA, vB=1)
    vFI(vA, vB)
    end
    
    def vItemFind(vA, vB=1)
    vFI(vA, vB)
    end
    
    def vItemBall(vA, vB=1)
    vFI(vA, vB)
    end
    
    def vDeleteItem(vA, vB=1)
    vDI(vA, vB)
    end
    
    def vItemDelete(vA, vB=1)
    vDI(vA, vB)
    end
    
    def vRemoveItem(vA, vB=1)
    vDI(vA, vB)
    end
    
    def vItemRemove(vA, vB=1)
    vDI(vA, vB)
    end
    
    def vAddItem(vA, vB=1)
    vAI(vA, vB)
    end
    
    def vAddItemSilent(vA, vB=1)
    vAI(vA, vB)
    end
    
    def vItemAdd(vA, vB=1)
    vAI(vA, vB)
    end
    
    def vItemSilent(vA, vB=1)
    vAI(vA, vB)
    end
    
    def vAddItem(vA, vB=1)
    vAI(vA, vB)
    end
    
    def vItemQuantity(vA)
    vIQ(vA)
    end
    
    def vQuantityItem(vA)
    vIQ(vA)
    end
    
    def vHasItem(vA)
    vHI(vA)
    end
    
    #Pokemon Manipulation
    def vGivePokemon(vA, vB)
    vGP(vA, vB)
    end
    
    def vAddPokemon(vA, vB)
    vAP(vA, vB)
    end
    
    def vGivePokemonSilent(vA, vB)
    vGPS(vA, vB)
    end
    
    def vAddPokemonSilent(vA, vB)
    vAPS(vA, vB)
    end
    
    def vReceivePokemon(vA, vB, vC, vD, vE=0)
    vRP(vA, vB, vC, vD, vE)
    end
    
    def vDeletePokemon(vA)
    vDP(vA)
    end
    
    def vRemovePokemon(vA)
    vDP(vA)
    end
    
    def vHasPokemon(vA)
    vHP(vA)
    end
    
    def vHS(vA)
    vHP(vA)
    end
    
    def vHasSpecies(vA)
    vHP(vA)
    end
    
    #Battles
    def vWildBattle(vA, vB, vC=0, vD=true, vE=false)
    vWB(vA, vB, vC, vD, vE)
    end
    
    def vTrainerBattle(vA, vB, vC, vD=false, vE=0, vF=false, vG=0)
    vTB(vA, vB, vC, vD, vE, vF, vG)
    end
    
    #Player
    def vOutfit(vA)
    vO(vA)
    end
    
    def vSO(vA)
    vO(vA)
    end
    
    def vSetOutfit(vA)
    vO(vA)
    end
    
    def vCharacter(vA)
    vC(vA)
    end
    
    def vSC(vA)
    vC(vA)
    end

    def vG(vA)
    echoln "vG and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vC(index) instead."
    vC(vA)
    end

    def vGender(vA)
    echoln "vGender and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vCharacter(index) instead."
    vC(vA)
    end
      
    def vSG(vA)
    echoln "vSG and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vSC(index) instead."
    vC(vA)
    end
    
    def vSetGender(vA)
    echoln "vSetGender and its alternate methods will be removed in future updates of Voltseon's Handy Tools. Use vSetCharacter(index) instead."
    vC(vA)
    end

    def vSetCharacter(vA)
    vC(vA)
    end
    
    def vToggleGender()
    vTG()
    end
    
    def vToggleRegionDex(vA)
    vTRD(vA)
    end
    
    def vTogglePokedex()
    vTP()
    end
    
    def vTogglePokeDex()
    vTP()
    end
    
    def vToggleRunningShoes()
    vTRS()
    end
    
    def vRS()
    vTRS()
    end
    
    def vRunningShoes()
    vTRS()
    end
    
    def vTogglePokegear()
    vTPG()
    end
    
    def vTogglePokeGear()
    vTPG()
    end
    
    #Miscellaneous
    def vPC(vA, vB=80, vC=100, vD=0)
    vCry(vA, vB, vC, vD)
    end
    
    def vPlayCry(vA, vB=80, vC=100, vD=0)
    vCry(vA, vB, vC, vD)
    end
    
    def vSST(vA, vB="A")
    vSS(vA, vB)
    end
    
    def vSSt(vA, vB="A")
    vSS(vA, vB)
    end
    
    def vSetSelfSwitch(vA, vB="A")
    vSS(vA, vB)
    end
    
    def vSetSelfSwitchTrue(vA, vB="A")
    vSS(vA, vB)
    end
    
    def vSetSelfSwitchFalse(vA, vB="A")
    vSSF(vA, vB)
    end
    
    def vSSf(vA, vB="A")
    vSSF(vA, vB)
    end
    
    def vtSS(vA, vB="A")
    vTSS(vA, vB)
    end
    
    def vToggleSelfSwitch(vA, vB="A")
    vTSS(vA, vB)
    end
    
    def vtGS(vA)
    vTGS(vA)
    end
    
    def vTS(vA)
    vTGS(vA)
    end
    
    def vToggleGlobalSwitch(vA)
    vTGS(vA)
    end
    
    def vToggleGameSwitch(vA)
    vTGS(vA)
    end
    
    def vTS(vA)
    vTGS(vA)
    end
    
    def vToggleSelfSwitchRange(vA, vB, vC)
    vTSSR(vA, vB, vC)
    end
    
    def vRTSS(vA, vB, vC)
    vTSSR(vA, vB, vC)
    end
    
    def vRangeToggleSelfSwitch(vA, vB, vC)
    vTSSR(vA, vB, vC)
    end