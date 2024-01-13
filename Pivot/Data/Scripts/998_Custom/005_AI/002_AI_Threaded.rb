module ThreadedAI
  class Actor
    class Data
      attr_accessor :x, :y, :type_to_move, :type_to_attack, :character_id, :difficulty, :movement_type, :active_range
      def initialize(event, character_id, difficulty, movement_type, active_range)
        
      end
    end
    attr_accessor :event
    def initialize(event, character_id, difficulty, movement_type, active_range)
      @event_data = Data.new(event, character_id, difficulty, movement_type, active_range)
      @ractor = Ractor.new(@event_data) { |event_data|
        loop do
          act = Ractor.recieve
          break if act == :terminate
          next if act == :busy
          Ractor.yield :whatever_the_AI_should_do_this_tick
        end
      }
    end
    def tick
      @ractor.send :tick
      @ractor.send @event
      @move = @ractor.take
    end
  end
  @@actors = {}
  def self.add_actor(sym, actor)
    @@actors[sym] = actor
  end
  def self.tick
    @@actors.each_value do |actor|
      actor.tick
    end
  end
end