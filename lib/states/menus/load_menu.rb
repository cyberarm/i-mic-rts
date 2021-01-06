class IMICRTS
  class LoadMenu < CyberarmEngine::GuiState
    def setup
      self.show_cursor = true

      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, Gosu::Color::GRAY]
        banner "Load", margin: 20

        label "Replays"
        stack(width: 1.0, height: 0.30) do
          ["2020-01-31_16-31-45.replay"].each do |item|
            button item, width: 1.0
          end
        end

        label "Saves"
        stack(width: 1.0, height: 0.30) do
          ["2020-01-31_16-31-45.save"].each do |item|
            button item, width: 1.0
          end
        end

        button("Back", width: 1.0, margin_top: 20) do
          pop_state
        end
      end
    end
  end
end