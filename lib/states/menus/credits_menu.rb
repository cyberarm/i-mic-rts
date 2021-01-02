class IMICRTS
  class CreditsMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: 600, height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]

        label "About I-MIC-RTS", text_size: 78, margin: 20
        label "Words go here. More words also go here. Thank you and have a nice day.", text_wrap: :word_wrap

        button("Back", width: 1.0, margin_top: 20) do
          push_state(MainMenu)
        end
      end
    end
  end
end