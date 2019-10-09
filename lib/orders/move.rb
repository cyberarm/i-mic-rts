IMICRTS::Order.define_handler(IMICRTS::Order::MOVE, arguments: [:player_id, :vector]) do |order, director|
  director.player(order.player_id).selected_entities.each do |entity|
    entity.target = order.vector
  end
end

IMICRTS::Order.define_serializer(IMICRTS::Order::MOVE) do |order, director|
  # Order ID | Player ID | Target X | Target Y
  # char     | char      | double   | double

  [IMICRTS::Order::MOVE, order.player_id, order.vector.x, order.vector.y].pack("CCGG")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::MOVE) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID | Target X | Target Y
  # char      | double   | double
  data = string.unpack("CGG")
  [data[0], CyberarmEngine::Vector.new(data[1], data[2])]
end
