class PANTSMission
    attr_accessor :id_number
    attr_accessor :id
    attr_accessor :name
    attr_accessor :description
    attr_accessor :completed
    attr_accessor :active
    attr_accessor :main_quest

    def initialize(hash)
        @id_number   = hash[:id_number]
        @id          = hash[:id]
        @name        = hash[:name]
        @description = hash[:description]
        @completed   = hash[:completed] || false
        @active      = hash[:active] || false
        @main_quest  = hash[:main_quest] || false
    end

    def start
        @active = true
    end

    def complete
        @completed = true
        @active = false
    end

    def completed?
        return @completed
    end

    def active?
        return @active
    end

    def available?
        return true if !@active && !@completed
    end
end

#===============================================================================

PANTS1 = {
    :id_number   => 0,
    :id          => :PANTS1,
    :name        => _INTL("Three Starters"),
    :description => _INTL("I would really like to see these three Pokémon: Combusken, Ivysaur and Croconaw. Go to the Safari Zone to catch them, and show them to me when you get back."),
    :completed   => false,
    :active      => false,
    :main_quest  => false
}

PANTS2 = {
    :id_number   => 1,
    :id          => :PANTS2,
    :name        => _INTL("Lost in Koromiko Cave"),
    :description => _INTL("Someone seems to have been digging a new cave in Route 9 and new Pokémon have been showing up there. We already sent a journalist down there but they we haven't heard from them since. Retrieve the Journalist from Koromiko Cave and catch me a Machoke while you're there."),
    :completed   => false,
    :active      => false,
    :main_quest  => true
}

PANTS3 = {
    :id_number   => 2,
    :id          => :PANTS3,
    :name        => _INTL("Complete the South Peskan Dex"),
    :description => _INTL("This one is more of a side-mission. I want you to complete the entire South Peskan Pokédex, and show it to me."),
    :completed   => false,
    :active      => false,
    :main_quest  => false
}

PANTS4 = {
    :id_number   => 3,
    :id          => :PANTS4,
    :name        => _INTL("Complete the North Peskan Dex"),
    :description => _INTL("This one is more of a side-mission. I want you to complete the entire North Peskan Pokédex, and show it to me."),
    :completed   => false,
    :active      => false,
    :main_quest  => false
}

PANTS5 = {
    :id_number   => 4,
    :id          => :PANTS5,
    :name        => _INTL("Legendary Beasts"),
    :description => _INTL("We recently discovered some art on the walls of the Undersea Temple depicting the legendary beasts Raikou, Entei and Suicune. I've heard rumors that a certain Kimono Girl up in Scarlet Village has the ability to summon these legendary Pokémon. Go talk to her, and catch me one of those beasts!"),
    :completed   => false,
    :active      => false,
    :main_quest  => true
}

PANTS6 = {
    :id_number   => 5,
    :id          => :PANTS6,
    :name        => _INTL("The Ancient Undersea Temple"),
    :description => _INTL("You've heard of the Undersea Temple of the Peskan Sea, right? We've received intel that there is some valuable treasure hidden somewhere deep inside the temple. We will provide you with the proper equipment to explore the Temple, and you can use my Lapras on Route 15 to travel there."),
    :completed   => false,
    :active      => false,
    :main_quest  => true
}

PANTS7 = {
    :id_number   => 6,
    :id          => :PANTS7,
    :name        => _INTL("Signatures from the Gym Leaders"),
    :description => _INTL("You have connections with all the Gym Leaders in the Peskan Region, right? Could you get me a signature from each of them? I'd really appreciate it."),
    :completed   => false,
    :active      => false,
    :main_quest  => true
}


def pbGetPANTSMission(id)
  if $Trainer.pantsMissions == {}
    $Trainer.pushMission(PANTS1[:id], PANTSMission.new(PANTS1))
    $Trainer.pushMission(PANTS2[:id], PANTSMission.new(PANTS2))
    $Trainer.pushMission(PANTS3[:id], PANTSMission.new(PANTS3))
    $Trainer.pushMission(PANTS4[:id], PANTSMission.new(PANTS4))
    $Trainer.pushMission(PANTS5[:id], PANTSMission.new(PANTS5))
    $Trainer.pushMission(PANTS6[:id], PANTSMission.new(PANTS6))
    $Trainer.pushMission(PANTS7[:id], PANTSMission.new(PANTS7))
  end
  return $Trainer.pantsMissions[id]
end

def nextPANTSMainMission
    return nil if pbGetPANTSMission(:PANTS7).completed?
    return pbGetPANTSMission(:PANTS7) if pbGetPANTSMission(:PANTS5).completed?
    return pbGetPANTSMission(:PANTS5) if pbGetPANTSMission(:PANTS6).completed?
    return pbGetPANTSMission(:PANTS6) if pbGetPANTSMission(:PANTS2).completed?
    return pbGetPANTSMission(:PANTS2)
end

def pbPANTSMissions
    commands = []
    missions = []
    active = false
    missions.push(nextPANTSMainMission) if nextPANTSMainMission != nil && nextPANTSMainMission.available?
    $Trainer.pantsMissions.each do |m|
      mission = m[1]
        if mission.active?
            active = true
        end
        missions.push(mission) if mission.available? && !mission.main_quest
    end
    if active
        if !pbConfirmMessage("\\xn[Director PANTS]\\bYou already have a mission active. Would you like another one?")
            return false
        end
    end
    if missions != nil
        missions.each { |thismission| commands.push(thismission.name)}
    else
        pbMessage("\\xn[Director PANTS]\\bI currently don't have any more missions for you, I'm afraid.")
        return false
    end
    commands.push("Cancel")
    command = pbMessage("\\xn[Director PANTS]\\bWhat mission would you like?",commands,commands.length)
    if commands[command] != "Cancel"
        pbMessage("\\xn[Director PANTS]\\b"+missions[command].description)
        if pbConfirmMessage(_INTL("\\xn[Director PANTS]\\bDo you accept this mission?"))
            missions[command].start
            activateQuest(missions[command].id,colorQuest("blue"))
            pbMessage("\\xn[Director PANTS]\\bCome back when you've completed the mission!")
            return true
        else
            pbMessage("\\xn[Director PANTS]\\bCome back if you want to start a mission.")
            return false
        end
    else
        pbMessage("\\xn[Director PANTS]\\bCome back if you want to start a mission.")
        return false
    end
end

class Player < Trainer
  attr_accessor :pantsMissions
    
  def pushMission(key, value)
    @pantsMissions[key] = value
    return @pantsMissions
  end

  def pantsMissions
    @pantsMissions = {} if !@pantsMissions
    return @pantsMissions
  end
end