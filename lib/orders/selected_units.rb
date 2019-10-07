IMICRTS::Order.define_handler(IMICRTS::Order::SELECTED_UNITS, arguments: [:player_id, :ids]) do |order, director|
  director.player(order.player_id).selected_entities.clear
  director.player(order.player_id).selected_entities.push(*order.ids)
end

