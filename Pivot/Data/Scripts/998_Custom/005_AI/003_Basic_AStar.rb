# Define a class for simple tiles
class SimpleTile
  # Create getter and setter methods for map_id, x, y, parent, g_score, and f_score
  attr_accessor :map_id, :x, :y, :parent, :g_score, :f_score

  # Initialize a new SimpleTile with a map_id, x, and y position
  def initialize(map_id, x, y)
    @map_id = map_id
    @x = x
    @y = y
  end

  # Get the game map associated with this tile
  def map
    return $map_factory.getMap(@map_id, false)
  end

  # Get the x, y position of this tile as an array
  def position
    return [@x, @y]
  end

  # Get the neighboring tiles of this tile
  def get_neighbors
    my_map = map
    neighbors = []

    # Iterate over the x and y positions of neighboring tiles
    (-1..1).each do |x|
      (-1..1).each do |y|
        next if x == 0 && y == 0
        check_x = @x + x
        check_y = @y + y

        # Skip tiles that are outside the bounds of the map
        next if check_x < 0 || check_x >= my_map.width || check_y < 0 || check_y >= my_map.height

        # Skip tiles that are occupied by an event
        event_at = map.check_event(x, y)
        if !event_at.nil?
          next unless event_at.through
        end

        n = SimpleTile.new(@map_id, check_x, check_y)
        d = SimpleTile.get_dir(self,n)

        # Skip tiles that are impassable to pathfind
        next unless my_map.passable?(x, y, d)

        # Add valid neighboring tiles to the neighbors array
        neighbors.push(n)
      end
    end

    return neighbors
  end

  # Define a distance function for calculating the cost of moving between two tiles
  def self.distance(tile1, tile2)
    dx = (tile1.x - tile2.x).abs
    dy = (tile1.y - tile2.y).abs
    return 14 * [dx, dy].min + 10 * ([dx, dy].max - [dx, dy].min)
  end

  # Define a heuristic function for estimating the cost of moving from a given tile to the goal tile
  def self.heuristic(tile, goal)
    dx = (tile.x - goal.x).abs
    dy = (tile.y - goal.y).abs
    return 14 * [dx, dy].min + 10 * ([dx, dy].max - [dx, dy].min)
  end

  def self.get_dir(tile1, tile2)
    x = tile1.x - tile2.x
    y = tile1.y - tile2.y
    # Get the direction from this tile to the neighbor
    d = 0
    if x == 0
      if y > 0
        d = 8
      else
        d = 2
      end
    elsif x > 0
      if y == 0
        d = 6
      elsif y > 0
        d = 3
      else
        d = 9
      end
    else
      if y == 0
        d = 4
      elsif y > 0
        d = 1
      else
        d = 7
      end
    end
    return d
  end

  # Return the move route required to move between two tiles
  def self.path(tile1, tile2)
    x = tile1.x - tile2.x
    y = tile1.y - tile2.y
    if x == 0
      if y > 0
        return [PBMoveRoute::Up, [tile1.x, tile1.y-1]]
      else
        return [PBMoveRoute::Down, [tile1.x, tile1.y+1]]
      end
    elsif x > 0
      if y == 0
        return [PBMoveRoute::Left, [tile1.x-1, tile1.y]]
      elsif y > 0
        return [PBMoveRoute::UpperLeft, [tile1.x-1, tile1.y-1]]
      else
        return [PBMoveRoute::LowerLeft, [tile1.x-1, tile1.y+1]]
      end
    else
      if y == 0
        return [PBMoveRoute::Right, [tile1.x+1, tile1.y]]
      elsif y > 0
        return [PBMoveRoute::UpperRight, [tile1.x+1, tile1.y-1]]
      else
        return [PBMoveRoute::LowerRight, [tile1.x+1, tile1.y+1]]
      end
    end
    return [PBMoveRoute::Up, [tile1.x, tile1.y-1]]
  end
end
=begin
# Define the A* algorithm
def a_star(start, goal)
  start = SimpleTile.new($game_map.map_id, start[0], start[1]) if start.is_a?(Array)
  goal = SimpleTile.new($game_map.map_id, goal[0], goal[1])

  # Initialize the open and closed sets
  open_set = [start]
  closed_set = []

  # Initialize the g_score and f_score for the start node
  start.g_score = 0
  start.f_score = SimpleTile.heuristic(start, goal)

  # Run the A* algorithm
  while !open_set.empty?
    # Get the node with the lowest f_score from the open set
    current = open_set.min_by { |node| node.f_score }

    # If we've reached the goal, return the path
    if current.position == goal.position
      path = [current]
      while current.position != start.position
        current = current.parent
        path.unshift(current)
      end
      return path
    end

    # Move the current node from the open set to the closed set
    open_set.delete(current)
    closed_set << current

    # Check each neighbor of the current node
    current.get_neighbors.each do |neighbor|
      # Skip neighbors that have already been visited
      next if closed_set.include?(neighbor)

      # Calculate the tentative g_score for the neighbor
      tentative_g_score = current.g_score + SimpleTile.distance(current, neighbor)

      # Add the neighbor to the open set if it's new or has a lower g_score
      if !open_set.include?(neighbor) || tentative_g_score < neighbor.g_score
        open_set << neighbor

        # Update the g_score and f_score for the neighbor
        neighbor.g_score = tentative_g_score
        neighbor.f_score = neighbor.g_score + SimpleTile.heuristic(neighbor, goal)

        # Record the previous node for the neighbor (used to reconstruct the path later)
        neighbor.parent = current
      end
    end
  end

  # If the algorithm finishes without finding a path, return nil
  return nil
end
=end