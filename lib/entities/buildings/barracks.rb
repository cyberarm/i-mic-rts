tiles = [
  [false, false, false, false, false],
  [false, true,  true,  true,  false],
  [false, true,  true,  true,  false],
  [false, true,  true,  true,  false],
  [false, :path, :path, :path, false],
]

IMICRTS::Entity.define_entity(:barracks, :building, 400, 40, "Builds and heals soldiers", tiles) do |entity|
  unless entity.proto_entity
    entity.has(:building)
    entity.has(:waypoint)
    entity.has(:spawner)
    entity.has(:build_queue)
  end

  entity.radius = 44
  entity.max_health = 100.0

  entity.shell_image = "buildings/barracks/barracks.png"

  entity.on_tick do
  end
end
