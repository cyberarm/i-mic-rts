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
                    @player_name = edit_line Setting.get(:player_name)
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

        flow(width: 1.0) do
          button("Accept", width: 0.5) do
            Setting.set(:player_name, @player_name.value)
            push_state(Game, networking_mode: :virtual)
          end

          button("Back", align: :right) do
            push_state(MainMenu)
          end
        end
      end
    end
  end
end