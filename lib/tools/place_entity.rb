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
      @preview.position = @player.camera.transform(@game.window.mouse)
      @preview.position.z = ZOrder::OVERLAY

      @preview.color.alpha = 150
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
        return if @game.sidebar.hit?(@game.window.mouse_x, @game.window.mouse_y)

        transform = @player.camera.transform(@game.window.mouse)

        @director.spawn_entity(
          player_id: @player.id, name: @entity,
          position: CyberarmEngine::Vector.new(transform.x, transform.y, ZOrder::BUILDING)
        )

        cancel_tool
      end
    end
  end
end