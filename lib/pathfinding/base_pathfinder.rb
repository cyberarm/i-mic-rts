class IMICRTS
  class Pathfinder
    class BasePathfinder
      Node = Struct.new(:tile, :parent, :distance, :cost)
      CACHE = {}

      def self.cached_path(source, goal, travels_along)
        found_path = CACHE.dig(travels_along, source, goal)
        if found_path
          found_path = nil unless found_path.valid?
        end

        return found_path
      end

      def self.cache_path(path)
        CACHE[path.travels_along] ||= {}
        CACHE[path.travels_along][path.source] ||= {}
        CACHE[path.travels_along][path.source][path.goal] = path

        return path
      end

      attr_reader :map, :source, :goal, :travels_along, :allow_diagonal
      attr_reader :path, :age
      def initialize(director:, entity:, goal:, travels_along: :ground, allow_diagonal: false)
        @director = director
        @map = @director.map
        @entity = entity
        _goal = goal.clone
        _goal /= @map.tile_size
        _goal.x, _goal.y = _goal.x.floor, _goal.y.floor
        @goal = _goal

        @travels_along = travels_along
        @allow_diagonal = allow_diagonal
        @age = Gosu.milliseconds

        @created_nodes = 0
        @nodes = []
        @path  = []
        @tiles = @map.tiles.values.map { |columns| columns.values }.flatten.select { |tile| tile }

        @visited = Hash.new do |hash, value|
          hash[value] = Hash.new {|h, v| h[v] = false}
        end

        @depth = 0
        @max_depth = @tiles.size
        @seeking = true

        position = entity.position.clone
        position.x, position.y = position.x.floor, position.y.floor
        position /= @map.tile_size

        @current_node = create_node(position.x, position.y)
        unless @current_node
          puts "Failed to find path!" if true
          return
        end

        @current_node.distance = 0
        @current_node.cost = 0
        add_node @current_node

        find

        Pathfinder.cache_path(self) if @path.size > 0 && false#Setting.enabled?(:cache_paths)
      end

      # Checks if Map still has all of paths required tiles
      def valid?
        valid = true
        @path.each do |node|
          unless @map.tiles.dig(node.tile.grid_position.x, node.tile.grid_position.y).entity == node.tile.entity
            valid = false
            break
          end
        end

        return valid
      end

      def find
        while(@seeking && @depth < @max_depth)
          seek
        end

        if @depth >= @max_depth
          puts "Failed to find path from: #{@source.x}:#{@source.y} (#{@map.grid.dig(@source.x,@source.y).element.class}) to: #{@goal.position.x}:#{@goal.position.y} (#{@goal.element.class}) [#{@depth}/#{@max_depth} depth]" if true#Setting.enabled?(:debug_mode)
        end
      end

      def at_goal?
        @current_node.tile.grid_position.distance(@goal) < 1.1
      end

      def seek
        unless @current_node && @map.tiles.dig(@goal.x, @goal.y)
          @seeking = false
          return
        end

        @nodes.delete(@current_node) # delete visited nodes
        @visited[@current_node.tile.grid_position.x][@current_node.tile.grid_position.y] = true

        if at_goal?
          until(@current_node.parent.nil?)
            @path << @current_node
            @current_node = @current_node.parent
          end
          @path.reverse!

          @seeking = false
          puts "Generated path with #{@path.size} steps, #{@created_nodes} nodes created. [#{@depth}/#{@max_depth} depth]" if true#Setting.enabled?(:debug_mode)
          return
        end

        #LEFT
        add_node create_node(@current_node.tile.grid_position.x - 1, @current_node.tile.grid_position.y, @current_node)
        # RIGHT
        add_node create_node(@current_node.tile.grid_position.x + 1, @current_node.tile.grid_position.y, @current_node)
        # UP
        add_node create_node(@current_node.tile.grid_position.x, @current_node.tile.grid_position.y - 1, @current_node)
        # DOWN
        add_node create_node(@current_node.tile.grid_position.x, @current_node.tile.grid_position.y + 1, @current_node)

        # TODO: Add diagonal nodes, if requested
        if @allow_diagonal
          # LEFT-UP
          if node_above? && node_above_left?
            add_node create_node(@current_node.tile.grid_position.x - 1, @current_node.tile.grid_position.y - 1, @current_node)
          end
          # LEFT-DOWN
          if node_below? && node_below_left?
            add_node create_node(@current_node.tile.grid_position.x - 1, @current_node.tile.grid_position.y + 1, @current_node)
          end
          # RIGHT-UP
          if node_above? && node_above_right?
            add_node create_node(@current_node.tile.grid_position.x + 1, @current_node.tile.grid_position.y - 1, @current_node)
          end
          # RIGHT-DOWN
          if node_below? && node_below_right?
            add_node create_node(@current_node.tile.grid_position.x + 1, @current_node.tile.grid_position.y + 1, @current_node)
          end
        end

        @current_node = next_node
        @depth += 1
      end

      def node_visited?(node)
        @visited[node.tile.grid_position.x][node.tile.grid_position.y]
      end

      def add_node(node)
        return unless node

        @nodes << node
        return node
      end

      def create_node(x, y, parent = nil)
        return unless tile = @map.tiles.dig(x, y)
        return unless tile.type == @travels_along
        return if tile.entity
        return if @visited.dig(x, y)
        return if @nodes.detect {|node| node.tile.grid_position.x == x && node.tile.grid_position.y == y}

        node = Node.new
        node.tile = tile
        node.parent = parent
        node.distance = parent.distance + 1 if parent
        node.cost = 0

        @created_nodes += 1
        return node
      end

      def next_node
        fittest = nil
        fittest_distance = Float::INFINITY

        distance = nil
        @nodes.each do |node|
          next if node == @current_node

          distance = node.tile.grid_position.distance(@goal)

          if distance < fittest_distance
            if fittest && (node.distance + node.cost) < (fittest.distance + fittest.cost)
              fittest = node
              fittest_distance = distance
            else
              fittest = node
              fittest_distance = distance
            end
          end
        end

        return fittest
      end

      def node_above?(node = @current_node)
        node && @map.tiles.dig(node.tile.grid_position.x, node.tile.grid_position.y - 1)
      end

      def node_below?(node = @current_node)
        node && @map.tiles.dig(node.tile.grid_position.x, node.tile.grid_position.y + 1)
      end

      def node_above_left?(node = @current_node)
        node && @map.tiles.dig(node.tile.grid_position.x - 1, node.tile.grid_position.y - 1)
      end

      def node_above_right?(node = @current_node)
        node && @map.tiles.dig(node.tile.grid_position.x + 1, node.tile.grid_position.y - 1)
      end

      def node_below_left?(node = @current_node)
        node && @map.tiles.dig(node.tile.grid_position.x - 1, node.tile.grid_position.y + 1)
      end

      def node_below_right?(node = @current_node)
        node && @map.tiles.dig(node.tile.grid_position.x + 1, node.tile.grid_position.y + 1)
      end
    end
  end
end