class IMICRTS
  class Game < CyberarmEngine::GuiState
    Overlay = Struct.new(:image, :position, :angle, :alpha)
    def setup
      window.show_cursor = true
      @options[:networking_mode] ||= :host

      @player = Player.new(id: 0)
      @director = Director.new(map: Map.new(map_file: "maps/test_map.tmx"), networking_mode: @options[:networking_mode], players: [@player])

      @selected_entities = []
      @overlays = []

      @debug_info = CyberarmEngine::Text.new("", y: 10, z: Float::INFINITY, shadow_color: Gosu::Color.rgba(0, 0, 0, 200))

      @sidebar = stack(height: 1.0) do
        background [0x55555555, 0x55666666]

        label "SIDEBAR", text_size: 78, margin_bottom: 20

        flow(width: 1.0) do
          @buttons = stack(width: 0.9) do
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
            @t = button("Tank", width: 1.0) do
              @player.entities << Entity.new(
                name: :tank,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
                angle: rand(360)
              )
            end
          end

          # Power meter
          stack(width: 0.1, height: 1.0, align: :bottom) do
            background Gosu::Color::GREEN
          end
        end


        button("Leave", width: 1.0, margin_top: 20) do
          finalize
          push_state(MainMenu)
        end
      end

      # 100.times { |i| [@c, @h, @t].sample.instance_variable_get("@block").call }
      spawnpoint = @director.map.spawnpoints.last
      @player.entities << Entity.new(
                name: :construction_yard,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(spawnpoint.x, spawnpoint.y, ZOrder::BUILDING),
                angle: 0
              )
      @player.entities << Entity.new(
                name: :construction_worker,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(spawnpoint.x - 64, spawnpoint.y + 64, ZOrder::GROUND_VEHICLE),
                angle: 0
              )
      @player.entities << Entity.new(
                name: :power_plant,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(spawnpoint.x + 64, spawnpoint.y + 64, ZOrder::BUILDING),
                angle: 0
              )
      @player.entities << Entity.new(
                name: :refinery,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(spawnpoint.x + 130, spawnpoint.y + 64, ZOrder::BUILDING),
                angle: 0
              )
      @player.entities << Entity.new(
                name: :war_factory,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(spawnpoint.x + 130, spawnpoint.y - 64, ZOrder::BUILDING),
                angle: 0
              )
    end

    def draw
      super

      # Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgb(10, 175, 35))

      @player.camera.draw do
        @director.map.draw(@player.camera)
        @director.entities.each(&:draw)
        @selected_entities.each(&:selected_draw)

        @overlays.each do |overlay|
          overlay.image.draw_rot(overlay.position.x, overlay.position.y, overlay.position.z, overlay.angle, 0.5, 0.5, 1, 1, Gosu::Color.rgba(255, 255, 255, overlay.alpha))
          overlay.angle += 3.0
          overlay.alpha -= 5.0

          @overlays.delete(overlay) if overlay.alpha <= 0
        end

        Gosu.draw_rect(@box.min.x, @box.min.y, @box.width, @box.height, Gosu::Color.rgba(50, 50, 50, 150), ZOrder::SELECTION_BOX) if @box
      end

      @debug_info.draw if Setting.enabled?(:debug_info_bar)
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
        #{ tile ? "Tile: X: #{tile.position.x} Y: #{tile.position.y} Type: #{tile.type}" : ""}
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

        @overlays << Overlay.new(Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/cursors/move.png"), @player.camera.transform(window.mouse), 0, 255)
        @overlays.last.position.z = ZOrder::OVERLAY
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
      @director.finalize
    end
  end
end