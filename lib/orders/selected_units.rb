IMICRTS::Order.define_handler(IMICRTS::Order::SELECTED_UNITS, arguments: [:player_id, :entities]) do |order, director|
  director.player(order.player_id).selected_entities.clear
  director.player(order.player_id).selected_entities.push(*order.entities)
end

IMICRTS::Order.define_serializer(IMICRTS::Order::SELECTED_UNITS) do |order, director|
  # Order ID | Player ID | Entity IDs
  # char     | char      | integers

  [IMICRTS::Order::SELECTED_UNITS, order.player_id].pack("CC") + order.entities.map { |ent| ent.id }.pack("N*")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::SELECTED_UNITS) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID | Entity IDs
  # char      | integers
  player_id = string.unpack("C").first
  entities = string[1..string.length - 1].unpack("N*").map { |ent_id| director.player(player_id).entity(ent_id) }

  [player_id, entities]
end
