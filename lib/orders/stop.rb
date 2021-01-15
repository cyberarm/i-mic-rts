IMICRTS::Order.define_handler(IMICRTS::Order::STOP, arguments: [:player_id]) do |order, director|
  director.player(order.player_id).selected_entities.each do |entity|
    entity.handle_order(IMICRTS::Order::STOP, order)
  end
end

IMICRTS::Order.define_serializer(IMICRTS::Order::STOP) do |order, director|
  # Order ID | Player ID
  # char     | char

  [IMICRTS::Order::STOP, order.player_id].pack("CC")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::STOP) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID
  # char
  string.unpack("C")
end
