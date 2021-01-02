class IMICRTS
  class SoloLobbyMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: 0.5, min_width: 720, height: 1.0) do
        background [0xff555555, Gosu::Color::GRAY]

        label "Lobby", text_size: 78, margin: 20
        flow(width: 1.0, height: 0.8) do
          flow(width: 0.70, height: 1.0) do
            stack(width: 0.40) do
              label "Name"
              @player_name = edit_line Setting.get(:player_name), width: 1.0

              7.times do |i|
                list_box items: [:open, :closed, :easy, :hard, :brutal], width: 1.0
              end
            end

            stack(width: 0.29) do
              label "Color"
              @player_color = list_box items: TeamColors.keys, choose: Setting.get(:player_color).to_sym, width: 1.0
              @player_color.style.background = (TeamColors[@player_color.value.to_sym])
              @player_color.subscribe(:changed) do |sender, value|
                @player_color.style.background = TeamColors[value.to_sym]
                :handled
              end

              7.times do |i|
                box = list_box items: TeamColors.keys, choose: TeamColors.keys[i + 1], width: 1.0
                box.style.background = (TeamColors[box.value.to_sym])
                box.subscribe(:changed) do |sender, value|
                  box.style.background = TeamColors[value.to_sym]
                  :handled
                end
              end
            end

            stack(width: 0.29) do
              label "Team"
              @player_team = list_box items: Array(1..8), choose: Setting.get(:player_team), width: 1.0

              7.times do |i|
                list_box items: Array(1..8), choose: i + 2, width: 1.0
              end
            end
          end

          stack(width: 0.30, height: 1.0) do
            # TODO: Show preview image
            label "Map"
            @map_name = list_box items: [:test_map], choose: :test_map, width: 1.0
            image "#{GAME_ROOT_PATH}/assets/logo.png", width: 1.0
          end
        end

        flow(width: 1.0, height: 0.2) do
          button("Accept") do
            save_playerdata
            map = Map.new(map_file: "maps/#{@map_name.value}.tmx")
            players = [
              { id: 0, team: @player_team.value.to_i, spawnpoint: map.spawnpoints.last, color: @player_color.value.to_sym },
              { id: 1, team: 2, spawnpoint: map.spawnpoints.first, color: :lightblue }
            ]
            push_state(Game, networking_mode: :virtual, map: map, players: players)
          end

          button("Back", align: :right) do
            save_playerdata
            push_state(MainMenu)
          end
        end
      end
    end

    def save_playerdata
      Setting.set(:player_name, @player_name.value)
      Setting.set(:player_color, @player_color.value.to_sym)
      Setting.set(:player_team, @player_team.value.to_i)

      Setting.save!
    end
  end
end
