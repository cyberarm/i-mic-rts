class IMICRTS
  class Game < CyberarmEngine::GuiState
    def setup
      @units = []
      @selected_entities = []
      @camera = Camera.new
      @mouse_pos = CyberarmEngine::Text.new("X: 0\nY: 0", x: 500, y: 10, z: Float::INFINITY)

      @sidebar = stack(height: 1.0) do
        background [0x55555555, 0x55666666]

        label "SIDEBAR", text_size: 78, margin_bottom: 20

        @h = button("Harvester", width: 1.0) do
          @units << Entity.new(
            images: Gosu::Image.new("#{ASSETS_PATH}/vehicles/harvester/images/harvester.png", retro: true),
            position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
            angle: rand(360)
          )
        end
        @c = button("Construction Worker", width: 1.0) do
          @units << Entity.new(
            images: Gosu::Image.new("#{ASSETS_PATH}/vehicles/construction_worker/images/construction_worker.png", retro: true),
            position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
            angle: rand(360)
        )
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

      Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgb(10, 175, 35))

      @camera.draw do
        @units.each(&:draw)
        @selected_entities.each(&:selected_draw)

        # draw_rect(@camera.center.x - 10, @camera.center.y - 10, 20, 20, Gosu::Color::BLACK, Float::INFINITY)

        # mouse = @camera.mouse_pick(window.mouse_x, window.mouse_y)
        # draw_rect(mouse.x - 10, mouse.y - 10, 20, 20, Gosu::Color::YELLOW, Float::INFINITY)
        Gosu.draw_rect(@box.min.x, @box.min.y, @box.width, @box.height, Gosu::Color.rgba(50, 50, 50, 150), Float::INFINITY) if @box
      end

      @mouse_pos.draw
    end

    def update
      super

      @camera.update

      if @selection_start
        select_entities
      end

      mouse = @camera.mouse_pick(window.mouse_x, window.mouse_y)
      @mouse_pos.text = "Aspect Ratio: #{@camera.aspect_ratio}\nZoom: #{@camera.zoom}\nX: #{window.mouse_x}\nY: #{window.mouse_y}\n\nX: #{mouse.x}\nY: #{mouse.y}"
    end

    def button_down(id)
      super

      case id
      when Gosu::MS_LEFT
        unless @sidebar.hit?(window.mouse_x, window.mouse_y)
          @selection_start = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @camera.position
        end
      when Gosu::MS_RIGHT
        @anchor = nil
      end
      @camera.button_down(id) unless @sidebar.hit?(window.mouse_x, window.mouse_y)
    end

    def button_up(id)
      super

      case id
      when Gosu::MS_LEFT
        @box = nil
        @selection_start = nil
      end

      @camera.button_up(id)
    end

    def select_entities
      @box = CyberarmEngine::BoundingBox.new(@selection_start, CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @camera.position)

      selected_entities = @units.select do |ent|
        @box.point?(ent.position)
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