class Partner
  attr_accessor :id
  attr_accessor :client_id
  attr_accessor :event
  attr_accessor :name
  attr_accessor :map_id
  attr_accessor :x
  attr_accessor :y
  attr_accessor :x_offset
  attr_accessor :y_offset
  attr_accessor :real_x
  attr_accessor :real_y
  attr_accessor :direction
  attr_accessor :graphic
  attr_accessor :pattern
  attr_accessor :bob_height
  attr_accessor :outfit_hues
  attr_accessor :thrown_ball
  attr_accessor :surfing
  attr_accessor :mounting
  attr_accessor :mounted_pkmn
  attr_accessor :bridge
  attr_accessor :state

  attr_accessor :follower_toggled
  attr_accessor :follower_x
  attr_accessor :follower_y
  attr_accessor :follower_x_offset
  attr_accessor :follower_y_offset
  attr_accessor :follower_real_x
  attr_accessor :follower_real_y
  attr_accessor :follower_direction
  attr_accessor :follower_graphic
  attr_accessor :follower_pattern
  attr_accessor :follower_bob_height
  attr_accessor :follower_pokemon

  attr_accessor :party
  
  def initialize(id, name)
    @id = id
    @name = name
  end

  def client_id; @client_id; end
  def id; @id; end
  def event; @event; end
  def name; @name; end
  def map_id; @map_id; end
  def x; @x; end
  def y; @y; end
  def x_offset; @x_offset; end
  def y_offset; @y_offset; end
  def real_x; @real_x; end
  def real_y; @real_y; end
  def direction; @direction; end
  def graphic; @graphic; end
  def pattern; @pattern; end
  def bob_height; @bob_height; end
  def outfit_hues; @outfit_hues; end
  def thrown_ball; @thrown_ball; end
  def surfing; @surfing; end
  def mounting; @mounting; end
  def mounted_pkmn; @mounted_pkmn; end
  def bridge; @bridge; end
  def state; @state; end
  def follower_toggled; @follower_toggled; end
  def follower_x; @follower_x; end
  def follower_y; @follower_y; end
  def follower_x_offset; @follower_x_offset; end
  def follower_y_offset; @follower_y_offset; end
  def follower_real_x; @follower_real_x; end
  def follower_real_y; @follower_real_y; end
  def follower_direction; @follower_direction; end
  def follower_graphic; @follower_graphic; end
  def follower_pattern; @follower_pattern; end
  def follower_bob_height; @follower_bob_height; end
  def party; @party; end

  def client_id=(value); @client_id = value; end
  def id=(value); @id = value; end
  def event=(value); @event = value; end
  def name=(value); @name = value; end
  def map_id=(value); @map_id = value; end
  def x=(value); @x = value; end
  def y=(value); @y = value; end
  def x_offset=(value); @x_offset = value; end
  def y_offset=(value); @y_offset = value; end
  def real_x=(value); @real_x = value; end
  def real_y=(value); @real_y = value; end
  def direction=(value); @direction = value; end
  def graphic=(value); @graphic = value; end
  def pattern=(value); @pattern = value; end
  def bob_height=(value); @bob_height = value; end
  def outfit_hues=(value); @outfit_hues = value; end
  def thrown_ball=(value); @thrown_ball = value; end
  def surfing=(value); @surfing = value; end
  def mounting=(value); @mounting = value; end
  def mounted_pkmn=(value); @mounted_pkmn = value; end
  def bridge=(value); @bridge = value; end
  def state=(value); @state = value; end
  def follower_toggled=(value); @follower_toggled = value; end
  def follower_x=(value); @follower_x = value; end
  def follower_y=(value); @follower_y = value; end
  def follower_x_offset=(value); @follower_x_offset = value; end
  def follower_y_offset=(value); @follower_y_offset = value; end
  def follower_real_x=(value); @follower_real_x = value; end
  def follower_real_y=(value); @follower_real_y = value; end
  def follower_direction=(value); @follower_direction = value; end
  def follower_graphic=(value); @follower_graphic = value; end
  def follower_pattern=(value); @follower_pattern = value; end
  def follower_bob_height=(value); @follower_bob_height = value; end
  def party=(value); @party = value; end
end