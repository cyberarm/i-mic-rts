class MainMenu < CyberarmEngine::Container
  def setup
    show_cursor = true
    set_layout_y(10, 20)

    flow(width: $window.width, padding: 10, margin: 10) do
      image("assets/logo_small.png")
      text "Main Menu", align: "center", size: 30
    end

    stack(width: 250) do
      button("Play")
      button("About")
      button("Exit") do
        close
      end
    end
  end

  def draw
    fill(Gosu::Color.new(0xff7a0d71))
  end
end