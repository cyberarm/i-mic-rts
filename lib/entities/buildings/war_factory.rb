IMICRTS::Entity.define_entity(:war_factory, :building, 2_000, "Generates credits") do |entity|
  entity.radius = 48
  entity.max_health = 100.0

  entity.shell_image = "buildings/war_factory/war_factory_shell.png"
  entity.overlay_image = "buildings/war_factory/war_factory_overlay.png"

  position = entity.position.clone
  position.z = IMICRTS::ZOrder::OVERLAY

  p1 = position.clone
  p1.x += 32
  p1.y -= 9
  p2 = p1.clone
  p2.y += 31

  entity.particle_emitters << IMICRTS::SmokeEmitter.new(position: p1)
  entity.particle_emitters << IMICRTS::SmokeEmitter.new(position: p2)

  entity.on_tick do
  end
end