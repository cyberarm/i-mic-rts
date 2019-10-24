class IMICRTS
  class SoloLobbyMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]

        label "Lobby", text_size: 78, margin: 20
        stack do
          flow do

            elements = [:edit_line, :button, :button, :toggle_button]
            ["Players", "Color", "Team", "Map Preview"].each_with_index do |item, index|
              stack do
                label item, background: 0xff7a0d71

                stack do
                  case elements[index]
                  when :edit_line
                    edit_line Setting.get(:player_name)
                  when :button
                    button item
                  when :toggle_button
                    toggle_button
                  end
                end
              end
            end
          end

          stack(height: 100) do
          end
        end

        flow do
          button("Accept", width: 0.4) do
            push_state(Game)
          end

          button("Back", width: 0.4, margin_left: 20) do
            push_state(MainMenu)
          end
        end
      end
    end
  end
end