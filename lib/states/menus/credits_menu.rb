class IMICRTS
  class CreditsMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      flow(width: 1.0, height: 1.0) do
        stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
          background [0xff555555, Gosu::Color::GRAY]

          banner "Credits", margin: 20

          licenses = Gosu::LICENSES.lines
          preamble = licenses.shift
          licenses.shift # remove blank line

          label preamble, text_wrap: :word_wrap

          licenses.each do |l|
            name, website, license, license_website = l.strip.split(",")
            flow(width: 1.0) do
              label name.strip, width: 0.49
              label license.strip, width: 0.49
            end
          end

          button("Back", width: 1.0, margin_top: 20) do
            push_state(MainMenu)
          end
        end
      end
    end
  end
end