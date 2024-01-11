class UI_Handler
  def initialize
    @buttonIndex = 0
    @buttonAmount = 1
  end

  def buttonIndex; @buttonIndex; end
  def buttonIndex(value); @buttonIndex = value; end
  def buttonAmount(value); @buttonAmount = value; end

  def pbUpdate
    Input.update
    
    case Input.dir4
    when 2
      if @buttonIndex == @buttonAmount-1
        @buttonIndex = 0
      else
        @buttonIndex += 1
      end
    when 8
      if @buttonIndex == 0
        @buttonIndex = @buttonAmount-1
      else
        @buttonIndex -= 1
      end
    end
  end
end