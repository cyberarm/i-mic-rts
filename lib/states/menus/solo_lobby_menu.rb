class IMICRTS
  class SoloLobbyMenu < CyberarmEngine::GuiState
    def setup
      background [0xff7b6ead, 0xff7a0d71, 0xff7a0d71, 0xff7b6ead]

      stack(width: 1.0, height: 1.0, padding: IMICRTS::MENU_PADDING) do
        background [0xff555555, Gosu::Color::GRAY]

        banner "Lobby", margin: 20
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
              @player_color.style.default[:background] = (TeamColors[@player_color.value.to_sym])
              @player_color.style.color = Gosu::Color.new(@player_color.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE
              @player_color.style.default[:color] = Gosu::Color.new(@player_color.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE

              @player_color.subscribe(:changed) do |sender, value|
                @player_color.style.background = TeamColors[value.to_sym]
                @player_color.style.color = Gosu::Color.new(@player_color.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE
                :handled
              end

              7.times do |i|
                box = list_box items: TeamColors.keys, choose: TeamColors.keys[i + 1], width: 1.0
                box.style.background = (TeamColors[box.value.to_sym])
                box.style.default[:background] = (TeamColors[box.value.to_sym])
                box.style.color = Gosu::Color.new(box.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE
                box.style.default[:color] = Gosu::Color.new(box.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE
                box.subscribe(:changed) do |sender, value|
                  box.style.background = TeamColors[value.to_sym]
                  box.style.default[:background] = TeamColors[value.to_sym]
                  box.style.color = Gosu::Color.new(box.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE
                  box.style.default[:color] = Gosu::Color.new(box.style.background&.gl).value > 0.9 ? Gosu::Color::BLACK : Gosu::Color::WHITE
                  :handled
                end
              end
            end

            stack(width: 0.15) do
              label "Team"
              @player_team = list_box items: Array(1..8), choose: Setting.get(:player_team), width: 1.0

              7.times do |i|
                list_box items: Array(1..8), choose: i + 2, width: 1.0
              end
            end

            stack(width: 0.15) do
              label "Position"
              @player_position = list_box items: Array("A".."H"), choose: Setting.get(:player_position), width: 1.0

              7.times do |i|
                list_box items: Array("A".."H"), choose: Array("A".."H")[i + 1], width: 1.0
              end
            end
          end

          stack(width: 0.30, height: 1.0) do
            label "Map"
            maps_list = Dir.glob("#{GAME_ROOT_PATH}/assets/maps/*.tmx").map do |m|
              File.basename(m, ".tmx").to_sym
            end

            @map_name = list_box items: maps_list, choose: Setting.get(:default_map).to_sym, width: 1.0
            @map_name.subscribe(:changed) do |sender, value|
              @map_preview.value = map_preview(value)
            end

            @map_preview = image map_preview(@map_name.value), width: 1.0, margin_top: 4, border_thickness: 1, border_color: 0xffff5500, background: Gosu::Color::BLACK
          end
        end

        flow(width: 1.0, height: 0.2) do
          button("Accept") do
            save_playerdata

            players = [
              { id: 0, team: @player_team.value.to_i, spawnpoint: @player_position.value, color: @player_color.value.to_sym, bot: false },
              { id: 1, team: 2, spawnpoint: @player_position.value == "A" ? "B" : "A", color: :lightblue, bot: :brutal }
            ]

            push_state(Game, networking_mode: :virtual, map: @map, players: players)
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
      Setting.set(:player_position, @player_position.value)
      Setting.set(:default_map, @map_name.value.to_s)

      Setting.save!
    end

    def map_preview(map_name)
      @map = Map.new(map_file: "maps/#{map_name}.tmx")
      @map.render_preview
    end
  end
end
