class IMICRTS
  class MainMenu < CyberarmEngine::GuiState
    def setup
      self.show_cursor = true

      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]
        label "I-MIC-RTS", text_size: 78, margin: 20
        button("Solo Play", width: 1.0) do
          # push_state(SoloPlayMenu)
          push_state(SoloLobbyMenu)
        end

        button("Multiplayer", width: 1.0) do
          push_state(MultiplayerMenu)
        end

        button("Settings", width: 1.0, margin_top: 20) do
          push_state(SettingsMenu)
        end

        button("Credits", width: 1.0) do
          push_state(CreditsMenu)
        end

        button("Exit", width: 1.0, margin_top: 20) do
          push_state(Closing)
        end
      end
    end
  end
end