IMICRTS::Order.define_handler(IMICRTS::Order::CONSTRUCTION_COMPLETE, arguments: [:player_id, :entity_id]) do |order, director|
  entity = director.player(order.player_id).entity(order.entity_id)

  entity.handle_order(IMICRTS::Order::CONSTRUCTION_COMPLETE, order)
end

IMICRTS::Order.define_serializer(IMICRTS::Order::CONSTRUCTION_COMPLETE) do |order, director|
  # Order ID | Player ID | Entity ID
  # char     | char      | Integer

  [IMICRTS::Order::CONSTRUCTION_COMPLETE, order.player_id, order.entity_id].pack("CCN")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::CONSTRUCTION_COMPLETE) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID | Entity ID
  # char      | integer
  data = string.unpack("CN")
  [data[0], data[1]]
end
