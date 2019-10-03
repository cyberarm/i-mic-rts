class IMICRTS
  class SettingsMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]

        label "Settings", text_size: 78, margin: 20
        label "Nothing to see here, move along."

        button("Back", width: 1.0, margin_top: 20) do
          push_state(MainMenu)
        end
      end
    end
  end
end