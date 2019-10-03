class IMICRTS
  class Director
    attr_reader :current_tick, :map
    def initialize(map:, players:, networking_mode: :virtual, tick_rate: 10)
      @map = map
      @players = players
      @connection = IMICRTS::Connection.new(director: self, mode: networking_mode)
      @networking_mode = networking_mode
      @tick_rate = tick_rate

      @last_tick_at = Gosu.milliseconds
      @tick_time = 1000.0 / @tick_rate
      @current_tick = 0
    end

    def update
      if (Gosu.milliseconds - @last_tick_at) >= @tick_time
        @last_tick_at = Gosu.milliseconds

        tick
        @connection.update
      end
    end

    def tick
      @players.each { |player| player.tick(@current_tick) }

      @current_tick += 1
    end

    def player(id)
      @players.find { |player| player.id == id }
    end

    def issue_order(order_id, *args)
      if order = Order.get(order_id)
        order.execute(self, *args)
      else
        raise "Undefined order: #{Order.order_name(order_id)}"
      end
    end


    def entities
      @players.map { |player| player.entities }.flatten
    end
  end
end