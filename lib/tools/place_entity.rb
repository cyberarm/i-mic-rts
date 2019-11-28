class IMICRTS
  class PlaceEntity < Tool
    attr_reader :entity, :construction_worker

    def setup
      @entity = @options[:entity]
      @construction_worker = @options[:construction_worker]

      @preview = Entity.new(name: @entity, player: @player, id: 0, position: CyberarmEngine::Vector.new, angle: 0, director: @director)
    end

    def draw
      # TODO: draw affected tiles
      @preview.draw
    end

    def update
      # TODO: ensure that construction worker is alive
      cancel_tool if @construction_worker.die?
      vector = vector_to_grid(@game.window.mouse)
      if tile = @director.map.tile_at(vector.x, vector.y)
        position = tile.position.clone
        @preview.position = position
        @preview.position.z = ZOrder::OVERLAY
      else
        @preview.position.z = -10
      end

      @preview.color.alpha = 150
    end

    def use_tool(vector)
      return if @game.sidebar.hit?(@game.window.mouse_x, @game.window.mouse_y)

      tile = @director.map.tile_at(vector.x, vector.y)
      return unless tile
      position = tile.position.clone

      @director.spawn_entity(
        player_id: @player.id, name: @entity,
        position: CyberarmEngine::Vector.new(position.x, position.y, ZOrder::BUILDING)
      )

      cancel_tool
    end

    def button_down(id)
      case id
      when Gosu::MsRight
        cancel_tool
      end
    end

    def button_up(id)
      case id
      when Gosu::MsLeft
        use_tool(vector_to_grid(@game.window.mouse))
      end
    end
  end
end