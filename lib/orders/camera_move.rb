IMICRTS::Order.define_handler(IMICRTS::Order::CAMERA_MOVE, arguments: [:player_id, :x, :y, :zoom]) do |order, director|
  director.player(order.player_id).camera.move_to(order.x, order.y, order.zoom)
end

IMICRTS::Order.define_serializer(IMICRTS::Order::CAMERA_MOVE) do |order, director|
  # Order ID: char as C
  # Player ID: char as C
  # Position X/Y: Double as G
  # Zoom: Double as G

  [IMICRTS::Order::CAMERA_MOVE, order.player_id, order.x, order.y, order.zoom].pack("CCGGG")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::CAMERA_MOVE) do |string, director|
  # Player ID | Camera X | Camera Y | Camera Zoom
  # char      | double   | double   | double
  string.unpack("CGGG")
end
