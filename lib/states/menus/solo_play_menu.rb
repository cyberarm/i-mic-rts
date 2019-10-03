class IMICRTS
  class SoloPlayMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]

        label "Solo Play", text_size: 78, margin: 20
        label "Words go here.\nMore words also go here. Thank you and have a nice day."

        button("Campaign", width: 1.0) do
        end

        button("Skirmish", width: 1.0) do
          push_state(SoloLobbyMenu)
        end

        button("Back", width: 1.0, margin_top: 20) do
          push_state(MainMenu)
        end
      end
    end
  end
end