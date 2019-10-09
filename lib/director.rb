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

      @players.each { |player| player.update }
    end

    def tick
      @players.each do |player|
        player.tick(@current_tick)

        # Records where player is looking at tick
        # record_order(Order::CAMERA_MOVE, player.id, *player.camera.to_a)# if player.camera_moved?

        player.orders.sort_by {|order| order.tick_id }.each do |order|
          raise DesyncError, "Have orders from an already processed tick! (#{order.tick_id} < #{current_tick})" if order.tick_id < @current_tick

          if _order = Order.get(Integer(order.serialized_order.unpack("C").first))
            # Chop off Order ID
            _order_data = order.serialized_order
            _order_args = _order.deserialize(_order_data[1.._order_data.length - 1], self)

            execute_order(_order.id, *_order_args)

            player.orders.delete(order)
          else
            raise UndefinedOrderError
          end

          break if order.tick_id > @current_tick
        end
      end

      @current_tick += 1
    end

    def player(id)
      @players.find { |player| player.id == id }
    end

    def record_order(order_id, *args)
      if order = Order.get(order_id)
        struct = order.struct(args)

        player(struct.player_id).orders.push(Player::ScheduledOrder.new( order_id, @current_tick + 1, order.serialize(struct, self) ))
      else
        raise "Undefined order: #{Order.order_name(order_id)}"
      end
    end

    def schedule_order(order_id, *args)
      if order = Order.get(order_id)
        struct = order.struct(args)

        pp Order.order_name(order_id)

        player(struct.player_id).orders.push(Player::ScheduledOrder.new( order_id, @current_tick + 2, order.serialize(struct, self) ))
      else
        raise "Undefined order: #{Order.order_name(order_id)}"
      end
    end

    def execute_order(order_id, *args)
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