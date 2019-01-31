class MainMenu < CyberarmEngine::GameState
  def setup
    self.show_cursor = true

    stack do
      background 0xff7a0d71
      flow(padding: 10, margin: 10) do
        background 0xff00ff00
        # image("assets/logo_small.png")
        label "I-MIC RTS", text_size: 30
        label "Main Menu", text_size: 30
      end

      stack do
        background Gosu::Color::RED

        label "I-MIC RTS", text_size: 10

        button("Play")
        button("About")
        button("Exit") do
          $window.close
        end

        check_box do |check|
          puts "Hello World: #{check.value}"
        end
      end
    end
  end
end