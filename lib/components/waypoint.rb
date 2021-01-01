class IMICRTS
  class Waypoint < Component
    def setup
      @waypoint = @parent.position.clone
      @waypoint.y += @parent.director.map.tile_size
      @waypoint_color = 0xffffff00
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
        @parent.position.x, @parent.position.y, @waypoint_color,
        @waypoint.x, @waypoint.y, @waypoint_color, ZOrder::ENTITY_GIZMOS
      )

      Gosu.draw_circle(@waypoint.x, @waypoint.y, 4, 9, @waypoint_color, ZOrder::ENTITY_GIZMOS)
    end
  end
end