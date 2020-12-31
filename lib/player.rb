class IMICRTS
  class Player
    attr_reader :id, :name, :color, :team, :entities, :orders, :camera, :spawnpoint
    attr_reader :selected_entities
    def initialize(id:, spawnpoint:, name: nil, color: IMICRTS::TeamColors.values.sample, team: nil)
      @id = id
      @spawnpoint = spawnpoint
      @name = name ? name : "Novice-#{id}"
      @color = color
      @team = team

      @entities = []
      @orders = []
      @camera = Camera.new(viewport: [0, 0, $window.width, $window.height])

      @selected_entities = []
      @current_entity_id = 0
    end

    def tick(tick_id)
      @entities.each { |ent| ent.tick(tick_id) }
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