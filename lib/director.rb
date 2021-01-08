class IMICRTS
  class Director
    attr_reader :current_tick, :map, :game, :players

    def initialize(game:, map:, players: [], networking_mode:, tick_rate: 10, local_game: true, replay: false)
      @game = game
      @map = map
      @players = players
      @connection = IMICRTS::Connection.new(director: self, mode: networking_mode)
      @networking_mode = networking_mode
      @tick_rate = tick_rate
      @local_game = local_game
      @replay = replay

      @last_tick_at = Gosu.milliseconds
      @tick_time = 1000.0 / @tick_rate
      @current_tick = 0
    end

    def local_game?
      @local_game
    end

    def replay?
      @replay
    end

    def add_player(player)
      @players << player
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
        schedule_order(Order::CAMERA_MOVE, player.id, *player.camera.to_a) if player.camera_moved?

        player.orders.sort_by(&:tick_id).each do |order|
          raise DesyncError, "Have orders from an already processed tick! (#{order.tick_id} < #{current_tick})" if order.tick_id < @current_tick
          next if order.tick_id > @current_tick

          raise UndefinedOrderError unless (o = Order.get(Integer(order.serialized_order.unpack1("C"))))

          # Chop off Order ID
          order_data = order.serialized_order
          order_args = o.deserialize(order_data[1..order_data.length - 1], self)

          execute_order(o.id, *order_args)

          player.orders.delete(order)

          break if order.tick_id > @current_tick
        end
      end

      @current_tick += 1
    end

    def player(id)
      @players.find { |player| player.id == id }
    end

    def find_path(player:, entity:, goal:, travels_along: :ground, allow_diagonal: Setting.enabled?(:debug_pathfinding_allow_diagonal), klass: IMICRTS::Pathfinder::BasePathfinder)
      if klass.cached_path(entity, goal, travels_along)
        puts "using a cached path!" if Setting.enabled?(:debug_mode)
        return klass.cached_path(entity, goal, travels_along)
      end

      klass.new(director: self, entity: entity, goal: goal, travels_along: travels_along, allow_diagonal: allow_diagonal)
    end

    def schedule_order(order_id, *args)
      raise UndefinedOrderError, "Undefined order: #{Order.order_name(order_id)}" unless (order = Order.get(order_id))

      struct = order.struct(args)

      puts "Issued order: #{Order.order_name(order_id).inspect} [tick: #{@current_tick}]" if Setting.enabled?(:debug_mode)

      scheduled_order = Player::ScheduledOrder.new(order_id, @current_tick + 2, order.serialize(struct, self))
      @connection.add_order(scheduled_order)
      player(struct.player_id).orders.push(scheduled_order)
    end

    def execute_order(order_id, *args)
      raise UndefinedOrderError, "Undefined order: #{Order.order_name(order_id)}" unless (order = Order.get(order_id))

      order.execute(self, *args)
    end

    def each_tile(vector, entity, &block)
      if tile = @map.tile_at(vector.x, vector.y)
        ent = Entity.get(entity)
        origin = (tile.grid_position - 2)

        ent.tiles.each_with_index do |array, y|
          array.each_with_index do |space_required, x|
            next unless space_required

            other_tile = @map.tile_at(origin.x + x, origin.y + y)
            if other_tile
              block.call(other_tile, space_required, origin.x + x, origin.y + y)
            end
          end
        end
      end
    end

    def spawn_entity(player_id:, name:, position:)
      _player = player(player_id)
      ent = Entity.new(
                name: name,
                director: self,
                player: _player,
                id: _player.next_entity_id,
                position: position,
                angle: 0
              )
      _player.entities << ent

      return ent
    end


    def entities
      @players.map { |player| player.entities }.flatten
    end

    def finalize
      @server&.stop
      @connection&.finalize
    end
  end
end
