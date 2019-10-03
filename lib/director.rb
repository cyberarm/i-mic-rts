class IMICRTS
  class Director
    def initialize(map:, players:, networking_mode: :virtual, tick_rate: 10)
      @map = map
      @players = players
      @networking_mode = networking_mode
      @tick_rate = tick_rate

      @last_tick_at = Gosu.milliseconds
      @tick_time = 1000.0 / @tick_rate
    end

    def update
      if (Gosu.milliseconds - @last_tick_at) >= @tick_time
        @last_tick_at = Gosu.milliseconds

        tick
      end
    end

    def tick
      @players.each(&:tick)
    end

    def player(id)
      @players.find { |player| player.id == id }
    end

    def issue_order(player_id, order_id, *args)
      # pp Order.order_name(order_id)
      # pp args
    end


    def entities
      @players.map { |player| player.entities }.flatten
    end
  end
end