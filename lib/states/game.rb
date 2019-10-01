class IMICRTS
  class Game < CyberarmEngine::GuiState
    def setup
      @units = []
      @camera = Camera.new
      @mouse_pos = CyberarmEngine::Text.new("X: 0\nY: 0", x: 500, y: 10, z: Float::INFINITY)

      @sidebar = stack(height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]

        label "SIDEBAR", text_size: 78
        label ""

        button("Harvest", width: 1.0) do
          @units << Entity.new(
            images: Gosu::Image.new("assets/vehicles/harvester/images/harvester.png", retro: true),
            position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
            angle: rand(360)
          )
        end
        button("Construction Worker", width: 1.0) do
          @units << Entity.new(
            images: Gosu::Image.new("assets/vehicles/construction_worker/images/construction_worker.png", retro: true),
            position: CyberarmEngine::Vector.new(rand(window.width), rand(window.height), ZOrder::GROUND_VEHICLE),
            angle: rand(360)
        )
        end


        button("Leave", width: 1.0) do
          finalize
          push_state(MainMenu)
        end
      end
    end

    def draw
      super

      Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgb(10, 175, 35))

      @camera.draw do
        @units.each(&:draw)

        draw_rect(@anchor.x - 10, @anchor.y - 10, 20, 20, Gosu::Color::RED, Float::INFINITY) if @anchor
        # draw_rect(@camera.center.x - 10, @camera.center.y - 10, 20, 20, Gosu::Color::BLACK, Float::INFINITY)

        # mouse_center = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @camera.position
        # draw_rect(mouse_center.x - 10, mouse_center.y - 10, 20, 20, Gosu::Color::YELLOW, Float::INFINITY)
      end

      @mouse_pos.draw
    end

    def update
      super

      @camera.update

      if @anchor
        @camera.center_around(@anchor, 0.9)
      end

      @mouse_pos.text = "X: #{window.mouse_x}\nY: #{window.mouse_y}"
    end

    def button_down(id)
      super

      case id
      when Gosu::MS_LEFT
        unless @sidebar.hit?(window.mouse_x, window.mouse_y)
          @anchor = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @camera.position
        end
      when Gosu::MS_RIGHT
        @anchor = nil
      end
      @camera.button_down(id)
    end

    def button_up(id)
      super

      @camera.button_up(id)
    end

    def finalize
      # TODO: Release bound objects/remove self from Window.states array
    end
  end
end