IMICRTS::Order.define_handler(IMICRTS::Order::BUILD_ORDER, arguments: [:player_id, :vector, :building]) do |order, director|
  tile = director.map.tile_at(order.vector.x, order.vector.y)
  p order.vector
  position = tile.position + director.map.tile_size / 2

  ent = director.spawn_entity(
    player_id: order.player_id, name: order.building,
    position: CyberarmEngine::Vector.new(position.x, position.y, IMICRTS::ZOrder::BUILDING)
  )

  director.each_tile(order.vector, order.building) do |tile, space_required|
    if space_required == true
      tile.entity = ent
    else
      tile.reserved = ent
    end
  end

  director.player(order.player_id).selected_entities.each do |entity|
    entity.target = position
  end
end

IMICRTS::Order.define_serializer(IMICRTS::Order::BUILD_ORDER) do |order, director|
  # Order ID | Player ID | Vector X | Vector Y | Entity Name
  # char     | char      | integer  | integer  | string

  [IMICRTS::Order::BUILD_ORDER, order.player_id, order.vector.x, order.vector.y, order.building.to_s].pack("CCNNA*")
end

IMICRTS::Order.define_deserializer(IMICRTS::Order::BUILD_ORDER) do |string, director|
  # String fed into deserializer has Order ID removed
  # Player ID | Vector X | Vector Y | Entity Name
  # char      | integer  | integer  | string
  data = string.unpack("CNNA*")
  [data[0], CyberarmEngine::Vector.new(data[1], data[2], IMICRTS::ZOrder::BUILDING), data[3].to_sym]
end
