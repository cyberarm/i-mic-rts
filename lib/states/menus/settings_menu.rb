class IMICRTS
  class SettingsMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: IMICRTS::MENU_WIDTH, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, Gosu::Color::GRAY]

        label "Settings", text_size: 78, margin: 20

        @skip_intro = check_box "Skip Intro", checked: Setting.enabled?(:skip_intro)

        label "Debug Settings", background: 0xff030303, width: 1.0, margin_top: 20
        @debug_mode                       = check_box "Debug Mode",           checked: Setting.enabled?(:debug_mode)
        @debug_info_bar                   = check_box "Show Debug Info Bar",  checked: Setting.enabled?(:debug_info_bar)
        @debug_pathfinding                = check_box "Debug Pathfinding",    checked: Setting.enabled?(:debug_pathfinding)
        @debug_pathfinding_allow_diagonal = check_box "Allow Diagonal Paths", checked: Setting.enabled?(:debug_pathfinding_allow_diagonal)

        button("Save and Close", width: 1.0, margin_top: 20) do
          if valid_options?
            save_settings

            pop_state
          end
        end

        button("Back", width: 1.0, margin_top: 20) do
          pop_state
        end
      end
    end

    def valid_options?
      true
    end

    def save_settings
      Setting.set(:skip_intro, @skip_intro.value)
      Setting.set(:debug_mode, @debug_mode.value)
      Setting.set(:debug_info_bar, @debug_info_bar.value)
      Setting.set(:debug_pathfinding, @debug_pathfinding.value)
      Setting.set(:debug_pathfinding_allow_diagonal, @debug_pathfinding_allow_diagonal.value)

      Setting.save!
    end
  end
end