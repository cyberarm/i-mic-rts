class IMICRTS
  class Game < CyberarmEngine::GuiState
    def setup
      window.show_cursor = true

      @player = Player.new(id: 0)
      @director = Director.new(map: Map.new(map_file: "maps/test_map.tmx"), players: [@player])

      @selected_entities = []

      @debug_info = CyberarmEngine::Text.new("", y: 10, z: Float::INFINITY, shadow_color: Gosu::Color.rgba(0, 0, 0, 200))

      @sidebar = stack(height: 1.0) do
        background [0x55555555, 0x55666666]

        label "SIDEBAR", text_size: 78, margin_bottom: 20

        flow do
          @buttons = stack(width: 75) do
            @h = button("Harvester", width: 1.0) do
              @player.entities << Entity.new(
                name: :harvester,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
                angle: rand(360)
              )
            end
            @c = button("Construction Worker", width: 1.0) do
              @player.entities << Entity.new(
                name: :construction_worker,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
                angle: rand(360)
              )
            end
          end

          stack(width: 0.25, height: 1.0) do
            background Gosu::Color::GREEN
          end
        end


        button("Leave", width: 1.0, margin_top: 20) do
          finalize
          push_state(MainMenu)
        end
      end

      100.times { |i| [@c, @h].sample.instance_variable_get("@block").call }
    end

    def draw
      super

      # Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgb(10, 175, 35))

      @player.camera.draw do
        @director.map.draw(@player.camera)
        @director.entities.each(&:draw)
        @selected_entities.each(&:selected_draw)

        # center = @player.camera.center - @player.camera.position
        # draw_rect(center.x - 10, center.y - 10, 20, 20, Gosu::Color::RED, Float::INFINITY)

        # mouse = @player.camera.transform(window.mouse)
        # draw_rect(mouse.x - 10, mouse.y - 10, 20, 20, Gosu::Color::YELLOW, Float::INFINITY)

        # Goal
        # draw_rect(@goal.x - 10, @goal.y - 10, 20, 20, Gosu::Color::WHITE, Float::INFINITY) if @goal

        Gosu.draw_rect(@box.min.x, @box.min.y, @box.width, @box.height, Gosu::Color.rgba(50, 50, 50, 150), Float::INFINITY) if @box
      end

      @debug_info.draw
    end

    def update
      super

      @director.update
      @player.camera.update

      if @selection_start
        select_entities
      end

      mouse = @player.camera.transform(window.mouse)
      tile  = @director.map.tile_at(mouse.x / @director.map.tile_size, mouse.y / @director.map.tile_size)
      @debug_info.text = %(
        FPS: #{Gosu.fps}
        Aspect Ratio: #{@player.camera.aspect_ratio}
        Zoom: #{@player.camera.zoom}
        Window Mouse X: #{window.mouse.x}
        Window Mouse Y: #{window.mouse.y}

        Camera Position X: #{@player.camera.position.x / @player.camera.zoom}
        Camera Position Y: #{@player.camera.position.y / @player.camera.zoom}

        World Mouse X: #{mouse.x}
        World Mouse Y: #{mouse.y}

        Director Tick: #{@director.current_tick}
        Tile: X: #{tile.position.x} Y: #{tile.position.y} Type: #{tile.type}
      ).lines.map { |line| line.strip }.join("\n")

      @debug_info.x = @sidebar.width + 20
    end

    def button_down(id)
      super

      case id
      when Gosu::KB_S
        @director.schedule_order(Order::STOP, @player.id)

      when Gosu::MS_LEFT
        unless @sidebar.hit?(window.mouse_x, window.mouse_y)
          @selection_start = @player.camera.transform(window.mouse)
        end
      when Gosu::MS_RIGHT
        @director.schedule_order(Order::MOVE, @player.id, @player.camera.transform(window.mouse))
      end

      @player.camera.button_down(id) unless @sidebar.hit?(window.mouse_x, window.mouse_y)
    end

    def button_up(id)
      super

      case id
      when Gosu::MS_RIGHT
      when Gosu::MS_LEFT
        @box = nil
        @selection_start = nil

        diff = (@player.selected_entities - @selected_entities)

        @director.schedule_order(Order::DESELECTED_UNITS, @player.id, diff)
        @director.schedule_order(Order::SELECTED_UNITS, @player.id, @selected_entities)
      end

      @player.camera.button_up(id)
    end

    def select_entities
      @box = CyberarmEngine::BoundingBox.new(@selection_start, @player.camera.transform(window.mouse))

      selected_entities = @player.entities.select do |ent|
        @box.point?(ent.position - ent.radius) ||
        @box.point?(ent.position + ent.radius)
      end

      if Gosu.button_down?(Gosu::KB_LEFT_SHIFT) || Gosu.button_down?(Gosu::KB_RIGHT_SHIFT)
        @selected_entities = @selected_entities.union(selected_entities)
      else
        @selected_entities = selected_entities
      end
    end

    def finalize
      # TODO: Release bound objects/remove self from Window.states array
    end
  end
end