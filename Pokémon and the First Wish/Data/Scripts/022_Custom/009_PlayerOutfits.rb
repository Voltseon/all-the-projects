class Player < Trainer
  attr_accessor :outfit_hues
  def outfit_hues; @outfit_hues = [0,0,0] if !@outfit_hues; return @outfit_hues; end
  def outfit_hues=(value); @outfit_hues=(value); end
end