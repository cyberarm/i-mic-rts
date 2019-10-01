class IMICRTS
  class Game < CyberarmEngine::GuiState
    def setup
      @units = []

      stack(height: 1.0) do
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

        label ""

        button("Leave", width: 1.0) do
          finalize
          push_state(MainMenu)
        end
      end
    end

    def draw
      super
      Gosu.draw_rect(0, 0, window.width, window.height, Gosu::Color.rgb(10, 175, 35))

      @units.each(&:draw)
    end

    def finalize
      # TODO: Release bound objects/remove self from Window.states array
    end
  end
end