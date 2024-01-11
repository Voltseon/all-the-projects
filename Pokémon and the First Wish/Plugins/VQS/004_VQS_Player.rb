class Player < Trainer
  attr_accessor :quests

  def quests
    @quests = [] if !@quests
    return @quests
  end

  def quests=(value)
    @quests = value
  end
end