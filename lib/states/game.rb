class IMICRTS
  class Game < CyberarmEngine::GuiState
    Overlay = Struct.new(:image, :position, :angle, :alpha)

    attr_reader :sidebar, :sidebar_title, :sidebar_actions, :overlays, :director
    attr_accessor :selected_entities

    def setup
      window.show_cursor = true
      @options[:networking_mode] ||= :virtual
      @options[:map] ||= Map.new(map_file: "maps/test_map.tmx")
      @options[:local_player_id] ||= 0

      @director = Director.new(game: self, map: @options[:map], networking_mode: @options[:networking_mode])
      @options[:players] ||= [
        { id: 0, team: 1, spawnpoint: @director.map.spawnpoints.last, color: :orange },
        { id: 1, team: 2, spawnpoint: @director.map.spawnpoints.first, color: :lightblue }
      ]

      @options[:players].each do |pl|
        player = Player.new(id: pl[:id], spawnpoint: pl[:spawnpoint], team: pl[:team], color: TeamColors[pl[:color]])
        @player = player if player.id == @options[:local_player_id]
        @director.add_player(player)
      end

      @selected_entities = []
      @tool = set_tool(:entity_controller)
      @overlays = []

      @debug_info = CyberarmEngine::Text.new("", y: 10, z: Float::INFINITY, shadow_color: Gosu::Color.rgba(0, 0, 0, 200))

      @sidebar = stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, 0xff666666]

        @sidebar_radar = stack(width: 1.0) do
          image @director.map.render_preview, width: 1.0
        end

        flow(width: 1.0) do
          para "$10,000", width: 0.49
          para "Power 250/250", width: 0.49, text_align: :right
        end

        @sidebar_title = title ""

        flow(width: 1.0, height: 1.0) do
          @sidebar_actions = flow(width: 0.9) do
          end

          # Power meter
          stack(width: 0.1, height: 1.0, align: :bottom) do
            background Gosu::Color::GREEN
          end
        end
      end

      @director.players.each do |player|
        construction_yard = @director.spawn_entity(
          player_id: player.id, name: :construction_yard,
          position: CyberarmEngine::Vector.new(player.spawnpoint.x, player.spawnpoint.y, ZOrder::BUILDING)
        )
        construction_yard.component(:structure).data.construction_progress = Entity.get(construction_yard.name).build_steps
        construction_yard.component(:structure).data.construction_complete = true
        @director.each_tile(@director.map.world_to_grid(construction_yard.position), construction_yard.name) do |tile, space_required|
          if space_required == true
            tile.entity = construction_yard
          else
            tile.reserved = construction_yard
          end
        end

        @director.spawn_entity(
          player_id: player.id, name: :construction_worker,
          position: CyberarmEngine::Vector.new(player.spawnpoint.x - 64, player.spawnpoint.y + 64, ZOrder::GROUND_VEHICLE)
        )
      end

      button_down(Gosu::KB_H) if @player
    end

    def draw
      super

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

        @tool.draw if @tool
      end

      @debug_info.draw if Setting.enabled?(:debug_info_bar)
    end

    def update
      super

      @director.update
      @player.camera.update
      @tool.update if @tool

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

      # entity = @director.players.map { |pl| pl.entities.find { |ent| mouse.distance(ent.position) <= ent.radius } }.first
      # @tip.value = "#{entity.player.name}: #{entity.name}" if entity
      # @tip.value = "" unless entity
    end

    def button_down(id)
      super

      @tool.button_down(id) if @tool
      @player.camera.button_down(id) unless @sidebar.hit?(window.mouse_x, window.mouse_y)

      push_state(PauseMenu) if id == Gosu::KB_ESCAPE
    end

    def button_up(id)
      super

      @tool.button_up(id) if @tool
      @player.camera.button_up(id)
    end

    def set_tool(tool, data = {})
      unless tool
        set_tool(:entity_controller)
      else
        @tool = Tool.get(tool).new(data, game: self, director: @director, player: @player)
      end
    end

    def finalize
      @director.finalize
    end
  end
end
