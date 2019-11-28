class IMICRTS
  class Movement < Component
    attr_accessor :pathfinder
    def initialize(parent:)
      @parent = parent
    end

    def rotate_towards(vector)
      _angle = Gosu.angle(@parent.position.x, @parent.position.y, vector.x, vector.y)
      a = (360.0 + (_angle - @parent.angle)) % 360.0

      # FIXME: Fails if vector is directly behind entity
      if a.round == 180
        @parent.angle = (_angle + 180.0) % 360.0
      elsif a < 180
        @parent.angle -= 1.0
      else
        @parent.angle += 1.0
      end

      @parent.angle %= 360.0
    end

    def follow_path
      if @pathfinder && node = @pathfinder.path_current_node
        @pathfinder.path_next_node if @pathfinder.at_current_path_node?(@parent)
        @parent.position -= (@parent.position.xy - (node.tile.position + @parent.director.map.tile_size / 2).xy).normalized * @parent.speed
      end
    end
  end
end