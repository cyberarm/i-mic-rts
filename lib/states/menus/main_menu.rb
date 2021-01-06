class IMICRTS
  class MainMenu < CyberarmEngine::GuiState
    def setup
      self.show_cursor = true

      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, Gosu::Color::GRAY]
        banner IMICRTS::NAME, margin: 20
        button("Campaign", width: 1.0, enabled: false, tip: "No campaign available, yet...") do
          push_state(CampaignMenu)
        end

        button("Skirmish", width: 1.0) do
          push_state(SoloLobbyMenu)
        end

        button("Multiplayer", width: 1.0) do
          push_state(MultiplayerMenu)
        end

        button("Load", width: 1.0, margin_top: 20) do
          push_state(LoadMenu)
        end

        button("Settings", width: 1.0) do
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