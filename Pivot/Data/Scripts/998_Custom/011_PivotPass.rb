class PivotPassReward
  attr_accessor :collectible, :claimed, :unlock_level

  def initialize(collectible, unlock_level)
    @collectible = collectible
    @claimed = false
    @unlock_level = unlock_level
  end
end

class Player < Trainer
  attr_accessor :pivot_pass_rewards

  def pivot_pass_rewards
    @pivot_pass_rewards = [
      PivotPassReward.new(:lootbox, 5),
      PivotPassReward.new(:lootbox, 10),
      PivotPassReward.new(:lootbox, 15),
      PivotPassReward.new(:lootbox, 20),
      PivotPassReward.new(:lootbox, 25),
      PivotPassReward.new(:lootbox, 30),
      PivotPassReward.new(:lootbox, 35),
      PivotPassReward.new(:lootbox, 40),
      PivotPassReward.new(:lootbox, 45),
      PivotPassReward.new(:lootbox, 50),
      PivotPassReward.new(:lootbox, 55),
      PivotPassReward.new(:lootbox, 60),
      PivotPassReward.new(:lootbox, 65),
      PivotPassReward.new(:lootbox, 70),
      PivotPassReward.new(:lootbox, 75),
      PivotPassReward.new(:lootbox, 80),
      PivotPassReward.new(:lootbox, 85),
      PivotPassReward.new(:lootbox, 90),
      PivotPassReward.new(:lootbox, 95),
      PivotPassReward.new(:lootbox, 100)
    ] if @pivot_pass_rewards.nil?
    return @pivot_pass_rewards
  end
end