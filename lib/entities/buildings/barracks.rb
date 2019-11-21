IMICRTS::Entity.define_entity(:barracks, :building, 400, "Builds and soldiers") do |entity|
  entity.has(:build_queue)

  entity.radius = 44
  entity.max_health = 100.0

  entity.shell_image = "buildings/barracks/barracks.png"

  entity.on_tick do
  end
end
