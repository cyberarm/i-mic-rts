class IMICRTS
  class PlaceEntity < Tool
    attr_reader :entity, :construction_worker

    def setup
      @entity = @options[:entity]
      @construction_worker = @options[:construction_worker]

      @preview = Entity.new(name: @entity, player: @player, id: 0, position: CyberarmEngine::Vector.new, angle: 0, director: @director, proto_entity: true)
    end

    def draw
      @director.each_tile(vector_to_grid(@game.window.mouse), @entity) do |tile, _data, x, y|
        if tile.entity || tile.reserved || tile.type != :ground || @director.map.ore_at(x, y) # tile unavailable
          Gosu.draw_rect(
            tile.position.x + 2, tile.position.y + 2,
            @director.map.tile_size - 4, @director.map.tile_size - 4,
            Gosu::Color.rgba(200, 50, 50, 200), ZOrder::OVERLAY
          )
        else # tile available
          Gosu.draw_rect(
            tile.position.x + 2, tile.position.y + 2,
            @director.map.tile_size - 4, @director.map.tile_size - 4,
            Gosu::Color.rgba(100, 100, 100, 200), ZOrder::OVERLAY
          )
        end
      end

      @preview.draw
    end

    def update
      cancel_tool unless @construction_worker.player.entity(@construction_worker.id)
      vector = vector_to_grid(@game.window.mouse)

      if (tile = @director.map.tile_at(vector.x, vector.y))
        position = tile.position.clone
        @preview.position = position + @director.map.tile_size / 2
        @preview.position.z = ZOrder::OVERLAY
      else
        @preview.position.z = -10
      end

      @preview.color.alpha = 150
    end

    def use_tool(vector)
      return if @game.sidebar.hit?(@game.window.mouse_x, @game.window.mouse_y)

      tile = @director.map.tile_at(vector.x, vector.y)
      pp vector
      return unless tile
      position = tile.position + @director.map.tile_size / 2

      # ent = @director.spawn_entity(
      #   player_id: @player.id, name: @entity,
      #   position: CyberarmEngine::Vector.new(position.x, position.y, ZOrder::BUILDING)
      # )

      @director.schedule_order(Order::CONSTRUCT, @player.id, vector, @entity)

      # each_tile(vector) do |tile, space_required|
      #   if space_required == true
      #     tile.entity = ent
      #   else
      #     tile.reserved = ent
      #   end
      # end

      cancel_tool
    end

    def can_use?(vector)
      return false if @game.sidebar.hit?(@game.window.mouse_x, @game.window.mouse_y)

      if tile = @director.map.tile_at(vector.x, vector.y)
        ent = Entity.get(@entity)
        origin = (tile.grid_position - 2)

        @director.each_tile(vector, @entity) do |tile, _data, x, y|
          return false if tile.entity || tile.reserved || tile.type != :ground || @director.map.ore_at(x, y)
        end
      else
        return false
      end
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
        use_tool(vector_to_grid(@game.window.mouse)) if can_use?(vector_to_grid(@game.window.mouse))
      end
    end
  end
end