class IMICRTS
  class Player
    attr_reader :id, :name, :color, :team, :bot, :visiblity_map, :entities, :orders, :camera, :spawnpoint
    attr_reader :selected_entities

    def initialize(id:, spawnpoint:, name: nil, color: IMICRTS::TeamColors.values.sample, team: nil, bot: false, visiblity_map:)
      @id = id
      @spawnpoint = spawnpoint
      @name = name ? name : "Novice-#{id}"
      @color = color
      @team = team
      @bot = bot
      @visiblity_map = visiblity_map

      @entities = []
      @orders = []
      @camera = Camera.new(viewport: [0, 0, $window.width, $window.height])
      @last_camera_position = @camera.position.clone
      @camera_moved = true
      @camera_move_threshold = 5

      @selected_entities = []
      @current_entity_id = 0
    end

    def tick(tick_id)
      @camera_moved = (@last_camera_position - @camera.position.clone).sum > @camera_move_threshold
      @last_camera_position = @camera.position.clone

      @entities.each { |ent| ent.tick(tick_id); @visiblity_map.update(ent) }
    end

    def update
      @entities.each(&:update)
    end

    def entity(id)
      @entities.find { |ent| ent.id == id }
    end

    def next_entity_id
      @current_entity_id += 1
    end

    def camera_moved?
      @camera_moved
    end

    class ScheduledOrder
      attr_reader :order_id, :tick_id, :serialized_order

      def initialize(order_id, tick_id, serialized_order)
        @order_id = order_id
        @tick_id, @serialized_order = tick_id, serialized_order

        raise ArgumentError, "Tick ID is nil!" unless @tick_id
        raise ArgumentError, "Serialized order for #{Order.order_name(order_id)} is nil!" unless @serialized_order
      end
    end
  end
end