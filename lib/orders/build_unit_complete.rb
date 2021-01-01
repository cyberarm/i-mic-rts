IMICRTS::Order.define_handler(IMICRTS::Order::BUILD_UNIT_COMPLETE, arguments: [:player_id, :entity_id]) do |order, director|
  entity = director.player(order.player_id).entity(order.entity_id)
  item = entity.component(:build_queue).queue.shift

  spawn_point = entity.position.clone
  spawn_point.y += 96 # TODO: Use entity defined spawnpoint

  ent = entity.director.spawn_entity(player_id: entity.player.id, name: item.entity.name, position: spawn_point)
  ent.target = entity.component(:waypoint).waypoint if entity.component(:waypoint)
end

IMICRTS::Order.define_serializer(IMICRTS::Order::BUILD_UNIT_COMPLETE) do |order, director|
  # Order ID | Player ID
  # char     | char

  [IMICRTS::Order::BUILD_UNIT_COMPLETE, order.player_id, order.entity_id].pack("CCN")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::BUILD_UNIT_COMPLETE) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID | Entity ID
  # char      | integer
  data = string.unpack("CN")
  [data[0], data[1]]
end
