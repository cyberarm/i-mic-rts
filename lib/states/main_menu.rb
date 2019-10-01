class IMICRTS
  class MainMenu < CyberarmEngine::GuiState
    def setup
      self.show_cursor = true

      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]
        label "I-MIC-RTS", text_size: 78, margin: 20
        button("Play", width: 1.0) do
          push_state(Game)
        end

        button("About", width: 1.0) do
          push_state(AboutMenu)
        end

        button("Exit", width: 1.0) do
          push_state(Closing)
        end
      end
    end
  end
end