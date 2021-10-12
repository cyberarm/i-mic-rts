class IMICRTS
  class GameSave
    def initialize(mode:, gamesave_file:, map_file: nil, players: nil, gamesave: false, player_id: nil)
      @mode = mode
      @gamesave_file = File.open(gamesave_file, "#{@mode == :write ? 'w' : 'r'}")
      @map_file = map_file
      @players = players
      @gamesave = gamesave
      @player_id = player_id

      @version = IMICRTS::VERSION
      @map_file_digest = Digest::SHA256.digest(File.read("#{IMICRTS::GAME_ROOT_PATH}/assets/#{@map_file}")) if @map_file
    end

    def parse
      #
    end

    def feed_tick(tick_id)

    end

    def write_header
      player_data = @players.map do |player|
        {
          id: player.id,
          name: player.name,
          team: player.team,
          spawnpoint: player.spawnpoint,
          color: player.color&.gl,
          bot: player.bot
        }
      end

s = %{#{@version}
#{@map_file}?#{@map_file_digest}
#{@gamesave ? "GAMESAVE?#{@player_id}" : "REPLAY"}
#{JSON.dump(player_data)}}

      @gamesave_file.puts(s)
    end

    def write_order(raw_order)
      @gamesave_file.puts(raw_order)
    end

    def finalize
      @gamesave_file&.close
    end
  end
end