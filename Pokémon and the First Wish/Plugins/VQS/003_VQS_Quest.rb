class VQS_Quest
  attr_reader :id
  attr_reader :active
  attr_reader :completed
  attr_reader :name
  attr_reader :description
  attr_reader :request_npc
  attr_reader :location
  attr_reader :rewards
  attr_accessor :container
  attr_accessor :clear_proc
  attr_accessor :progress_proc

  def initialize(active=false, name="Quest", description="A simple quest.", request_npc=[], location=nil, rewards=[], container=[], clear_proc="return false", progress_proc="return 0", id=nil)
    @id = id || $player.quests.length
    @active = active
    @completed = false
    @name = name
    @description = description
    @request_npc = request_npc
    @location = location
    @rewards = rewards
    @container = container
    @clear_proc = clear_proc
    @progress_proc = progress_proc
    questAnim(name)
    $player.quests.push(self)
  end

  def check_clear
    return eval(@clear_proc)
  end

  def progress
    return eval(@progress_proc)
  end

  def trigger
    if check_clear
      @active = false
      @completed = true
      questCompleteAnim(@name)
      @rewards.each { |reward| pbReceiveItem(reward[0], reward[1]) }
    end
  end

  def id=(value); @id = value; end
end