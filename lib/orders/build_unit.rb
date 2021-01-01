IMICRTS::Order.define_handler(IMICRTS::Order::BUILD_UNIT, arguments: [:player_id, :entity_id, :unit_type]) do |order, director|
  director.player(order.player_id).entity(order.entity_id).component(:build_queue)&.add(order.unit_type)
end

IMICRTS::Order.define_serializer(IMICRTS::Order::BUILD_UNIT) do |order, director|
  # Order ID | Player ID | Entity ID | Unit Type
  # char     | char      | integer   | string

  [IMICRTS::Order::BUILD_UNIT, order.player_id, order.entity_id, order.unit_type.to_s].pack("CCNA*")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::BUILD_UNIT) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID |
  # char      | integer   | string
  data = string.unpack("CNA*")
  [data[0], data[1], data[2].to_sym]
end
