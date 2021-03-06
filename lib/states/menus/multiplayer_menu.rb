class IMICRTS
  class MultiplayerMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, Gosu::Color::GRAY]

        banner "Multiplayer", margin: 20
        title "Games"
        @games_list = stack(border_color: Gosu::Color::WHITE, border_thickness: 2) do
        end
        flow do
          button("Refresh") do
            refresh_games
          end
          button("Host Game") do
            # push_state(HostMultiplayerGameMenu)
          end
          button("Join Game") do
            # push_state(MultiplayerLobbyMenu)
          end
        end

        button("Back", width: 1.0, margin_top: 20) do
          push_state(MainMenu)
        end
      end
    end

    def refresh_games
      @games_list.clear do
        label "No games found..."
      end
    end
  end
end
