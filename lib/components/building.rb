class IMICRTS
  class Building < Component
    def setup
      data.construction_progress ||= 0
      data.construction_goal ||= Entity.get(@parent.name).build_steps
      data.construction_complete ||= false
      data.construction_complete_ordered ||= false

      @text = CyberarmEngine::Text.new("", y: @parent.position.y, z: Float::INFINITY, size: 12)
      data.state = :construct # deconstruct, building, idle
    end

    def draw
      case data.state
      when :construct
        draw_construction unless @text.text.empty?
        @text.text = "Building: #{(construction_progress * 100.0).round}%"
        @text.x = @parent.position.x - @text.width / 2
        @text.draw
      when :deconstruct
      when :building
      when :idle
      else
        raise "Unknown state!"
      end
    end

    def update
      case data.state
      when :construct
        @parent.color.alpha = 255 * construction_progress
        data.state = :idle if construction_complete?
      end
    end

    def construction_complete?
      data.construction_progress >= data.construction_goal && data.construction_complete
    end

    # WARNING: returns a floating point number, not network safe!
    def construction_progress
      data.construction_progress.to_f / data.construction_goal
    end

    def construction_work(work)
      raise TypeError, "Got a non integer value!" unless work.is_a?(Integer)

      data.construction_progress += work
      return unless data.construction_progress > data.construction_goal

      data.construction_progress = data.construction_goal

      unless data.construction_complete_ordered
        @parent.director.schedule_order(IMICRTS::Order::CONSTRUCTION_COMPLETE, @parent.player.id, @parent.id)
        data.construction_complete_ordered = true
      end
    end

    def draw_construction
      @fencing ||= get_image(IMICRTS::ASSETS_PATH + "/fencing/fencing.png")
      @fencing_edge ||= get_image(IMICRTS::ASSETS_PATH + "/fencing/fencing_edge.png")

      tiles = []
      each_tile(@parent.position / @parent.director.map.tile_size) do |tile, data, x, y|
        tiles << tile
      end

      tiles.each do |tile|
        # X
        if tiles.find { |t| t.grid_position.x < tile.grid_position.x && t.grid_position.y == tile.grid_position.y} == nil
          @fencing_edge.draw(tile.position.x - 30, tile.position.y, Float::INFINITY)
        end
        if tiles.find { |t| t.grid_position.x > tile.grid_position.x && t.grid_position.y == tile.grid_position.y} == nil
          @fencing_edge.draw(tile.position.x, tile.position.y, Float::INFINITY)
        end
        # Y
        if tiles.find { |t| t.grid_position.x == tile.grid_position.x && t.grid_position.y < tile.grid_position.y} == nil
          @fencing.draw(tile.position.x, tile.position.y - 24, Float::INFINITY)
        end
        if tiles.find { |t| t.grid_position.x == tile.grid_position.x && t.grid_position.y > tile.grid_position.y} == nil
          @fencing.draw(tile.position.x, tile.position.y, Float::INFINITY)
        end
      end
    end

    def each_tile(vector, &block)
      if tile = @parent.director.map.tile_at(vector.x, vector.y)
        ent = Entity.get(@parent.name)
        origin = (tile.grid_position - 2)

        ent.tiles.each_with_index do |array, y|
          array.each_with_index do |space_required, x|
            next unless space_required.is_a?(TrueClass)

            other_tile = @parent.director.map.tile_at(origin.x + x, origin.y + y)
            if other_tile
              block.call(other_tile, space_required, origin.x + x, origin.y + y)
            end
          end
        end
      end
    end
  end
end