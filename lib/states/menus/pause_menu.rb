class IMICRTS
  class PauseMenu < CyberarmEngine::GuiState
    def setup
      stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, Gosu::Color::GRAY]
        label "Paused", text_size: 78, margin: 20

        button "Resume", width: 1.0 do
          pop_state
        end

        button "Settings", width: 1.0 do
          push_state(SettingsMenu)
        end

        button "Quit", width: 1.0, margin_top: 20 do
          # TODO: Confirm

          previous_state.director.finalize

          if previous_state&.director.local_game?
            push_state(SoloLobbyMenu)
          else
            push_state(MultiplayerLobbyMenu)
          end
        end
      end
    end

    def draw
      previous_state&.draw

      Gosu.flush

      super
    end

    def update
      super

      previous_state&.director.update unless previous_state&.director.local_game?
    end
  end
end