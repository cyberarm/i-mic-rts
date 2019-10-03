class IMICRTS
  class Order
    @@orders = {}

    def self.order_name(order_id)
      IMICRTS::Order.constants(false).find { |const| IMICRTS::Order.const_get(const) == order_id }
    end

    def self.get(order_id)
      @@orders.dig(order_id)
    end

    def self.define_handler(order_id, arguments: [], &handler)
      raise "Handler from #{order_name(order_id)} already defined!" if @@orders.dig(order_id)

      @@orders[order_id] = IMICRTS::Order.new(id: order_id, arguments: arguments, &handler)
    end

    attr_reader :id
    def initialize(id:, arguments:, &handler)
      @id = id
      @arguments = arguments
      @handler = handler
    end

    def execute(director, *arguments)
      @handler.call(arguments(arguments), director)
    end

    def arguments(args)
      raise "Did not receive correct number of arguments: got #{args.size} expected #{@arguments.size}." unless @arguments.size == args.size

      hash = FriendlyHash.new
      @arguments.each_with_index do |key, value|
        hash[key] = args[value]
      end

      return hash
    end

    def serialize
    end

    def deserialize
    end
  end

  orders = [
    :CAMERA_MOVED,
    :CAMERA_ZOOMED,

    :ENTITY_SELECTED,
    :ENTITY_DESELECTED,
    :ENTITY_DESTROYED,
    :ENTITY_DAMAGED,
    :ENTITY_REPAIRED,

    :SELECTED_UNITS,
    :DESELECTED_UNITS,

    :MOVE,
    :STOP,
    :GUARD,
    :ATTACK,
    :PATROL,

    :BUILD_ORDER,
    :CANCEL_BUILD_ORDER,
    :BUILD_ORDER_COMPLETE,

    :BUILDING_POWER_STATE,
    :BUILDING_REPAIR,
    :BUILDING_SELL,

    :MESSAGE_BROADCAST,
    :MESSGE_TEAM,
    :MESSAGE_DIRECT,
  ]

  offset = 0
  orders.each_with_index do |order, i|
    IMICRTS::Order.const_set(order, i + offset)
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/orders/*.rb").each do |order|
  require_relative order
end