class IMICRTS
  class Waypoint < Component
    def setup
      @waypoint = @parent.position.clone
      @waypoint.y += @parent.director.map.tile_size
    end

    def set(vector)
      @waypoint = vector
    end

    def waypoint
      @waypoint.clone
    end

    def draw
      return unless @parent.player.selected_entities.include?(@parent)

      Gosu.draw_line(
        @parent.position.x, @parent.position.y, @parent.player.color,
        @waypoint.x, @waypoint.y, @parent.player.color, ZOrder::ENTITY_GIZMOS
      )

      Gosu.draw_circle(@waypoint.x, @waypoint.y, 4, 9, @parent.player.color, ZOrder::ENTITY_GIZMOS)
    end
  end
end