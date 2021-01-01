IMICRTS::Order.define_handler(IMICRTS::Order::BUILDING_SET_WAYPOINT, arguments: [:player_id, :entity_id, :vector]) do |order, director|
  director.player(order.player_id).entity(order.entity_id).component(:waypoint).set(order.vector)
end

IMICRTS::Order.define_serializer(IMICRTS::Order::BUILDING_SET_WAYPOINT) do |order, director|
  # Order ID | Player ID | Entity ID |  Target X | Target Y
  # char     | char      | integer   | double   | double

  [IMICRTS::Order::BUILDING_SET_WAYPOINT, order.player_id, order.entity_id, order.vector.x, order.vector.y].pack("CCNGG")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::BUILDING_SET_WAYPOINT) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID | Entity ID |  Target X | Target Y
  # char      | integer   | double   | double
  data = string.unpack("CNGG")
  [data[0], data[1], CyberarmEngine::Vector.new(data[2], data[3])]
end
