class IMICRTS
  class Game < CyberarmEngine::GuiState
    Overlay = Struct.new(:image, :position, :angle, :alpha)

    attr_reader :sidebar, :sidebar_actions, :overlays
    def setup
      window.show_cursor = true
      @options[:networking_mode] ||= :host

      @player = Player.new(id: 0)
      @director = Director.new(game: self, map: Map.new(map_file: "maps/test_map.tmx"), networking_mode: @options[:networking_mode], players: [@player])
      @entity_controller = EntityController.new(game: self, director: @director, player: @player)

      @overlays = []

      @debug_info = CyberarmEngine::Text.new("", y: 10, z: Float::INFINITY, shadow_color: Gosu::Color.rgba(0, 0, 0, 200))

      @sidebar = stack(height: 1.0) do
        background [0x55555555, 0x55666666]

        label "SIDEBAR", text_size: 78, margin_bottom: 20

        flow(width: 1.0) do
          @sidebar_actions = stack(width: 0.9) do
            button("Harvester", width: 1.0) do
              @player.entities << Entity.new(
                name: :harvester,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
                angle: rand(360)
              )
            end
            button("Construction Worker", width: 1.0) do
              @player.entities << Entity.new(
                name: :construction_worker,
                director: @director,
                player: @player,
                id: @player.next_entity_id,
                position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
                angle: rand(360)
              )
            end
            button("Tank", width: 1.0) do
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
      @director.spawn_entity(
        player_id: @player.id, name: :construction_yard,
        position: CyberarmEngine::Vector.new(spawnpoint.x, spawnpoint.y, ZOrder::BUILDING)
      )

      @director.spawn_entity(
        player_id: @player.id, name: :construction_worker,
        position: CyberarmEngine::Vector.new(spawnpoint.x - 64, spawnpoint.y + 64, ZOrder::GROUND_VEHICLE)
      )

      @director.spawn_entity(
        player_id: @player.id, name: :power_plant,
        position: CyberarmEngine::Vector.new(spawnpoint.x + 64, spawnpoint.y + 64, ZOrder::BUILDING)
      )

      @director.spawn_entity(
        player_id: @player.id, name: :refinery,
        position: CyberarmEngine::Vector.new(spawnpoint.x + 130, spawnpoint.y + 64, ZOrder::BUILDING)
      )

      @director.spawn_entity(
        player_id: @player.id, name: :war_factory,
        position: CyberarmEngine::Vector.new(spawnpoint.x + 130, spawnpoint.y - 64, ZOrder::BUILDING)
      )

      @director.spawn_entity(
        player_id: @player.id, name: :helipad,
        position: CyberarmEngine::Vector.new(spawnpoint.x - 32, spawnpoint.y - 96, ZOrder::BUILDING)
      )

      @director.spawn_entity(
        player_id: @player.id, name: :barracks,
        position: CyberarmEngine::Vector.new(spawnpoint.x - 32, spawnpoint.y + 128, ZOrder::BUILDING)
      )
    end

    def draw
      super

      # Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgb(10, 175, 35))

      @player.camera.draw do
        @director.map.draw(@player.camera)
        @director.entities.each(&:draw)
        @entity_controller.selected_entities.each(&:selected_draw)

        @overlays.each do |overlay|
          overlay.image.draw_rot(overlay.position.x, overlay.position.y, overlay.position.z, overlay.angle, 0.5, 0.5, 1, 1, Gosu::Color.rgba(255, 255, 255, overlay.alpha))
          overlay.angle += 3.0
          overlay.alpha -= 5.0

          @overlays.delete(overlay) if overlay.alpha <= 0
        end

        @entity_controller.draw
      end

      @debug_info.draw if Setting.enabled?(:debug_info_bar)
    end

    def update
      super

      @director.update
      @player.camera.update
      @entity_controller.update

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

      @entity_controller.button_down(id)
      @player.camera.button_down(id) unless @sidebar.hit?(window.mouse_x, window.mouse_y)
    end

    def button_up(id)
      super

      @entity_controller.button_up(id)
      @player.camera.button_up(id)
    end

    def set_tool(tool, *args)
      pp tool, args
    end

    def finalize
      @director.finalize
    end
  end
end
