class Player
  attr_writer :online_trainer_type
  def online_trainer_type
    return @online_trainer_type || self.trainer_type
  end
end