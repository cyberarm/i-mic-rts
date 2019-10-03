IMICRTS::Order.define_handler(IMICRTS::Order::CAMERA_MOVED, arguments: [:player_id, :x, :y]) do |order, director|
  director.player(order.player_id).move_camera(order.x, order.y)
end

