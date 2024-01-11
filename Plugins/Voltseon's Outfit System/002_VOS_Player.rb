# In order to keep track of your current outfit
class Player < Trainer
  attr_accessor :vos_outfit

  def vos_outfit
    @vos_outfit = Vosoutfit.new if !@vos_outfit
    return @vos_outfit
  end

  def vos_outfit=(value); @vos_outfit = value; end
end