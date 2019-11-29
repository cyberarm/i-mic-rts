tiles = [
  [false, false, false, false, false],
  [false, true,  true,  false, false],
  [false, true,  true,  true,  false],
  [false, true,  true,  true,  false],
  [false, false, :path, :path, false],
]

IMICRTS::Entity.define_entity(:refinery, :building, 1_400, "Generates credits", tiles) do |entity|
  entity.radius = 44
  entity.max_health = 100.0

  entity.body_image = "buildings/refinery/refinery.png"
  entity.shell_image = "buildings/refinery/refinery_shell.png"
  entity.overlay_image = "buildings/refinery/refinery_overlay.png"

  position = entity.position.clone
  position.z = IMICRTS::ZOrder::OVERLAY

  p1 = position.clone
  p1.x += 2
  p1.y += 12

  entity.particle_emitters << IMICRTS::SmokeEmitter.new(position: p1)

  entity.on_tick do
  end
end
