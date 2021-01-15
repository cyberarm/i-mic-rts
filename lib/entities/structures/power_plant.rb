tiles = [
  [false, false, false, false, false],
  [false, false, true,  false, false],
  [false, false, true,  false, false],
  [false, false, true,  false, false],
  [false, false, :path, false, false],
]

IMICRTS::Entity.define_entity(:power_plant, :structure, 800, 45, "Generates power", tiles) do |entity|
  unless entity.proto_entity
    entity.has(:structure)
  end

  entity.radius = 24
  entity.max_health = 100.0

  entity.body_image = "buildings/power_plant/power_plant.png"
  entity.shell_image = "buildings/power_plant/power_plant_shell.png"
  entity.overlay_image = "buildings/power_plant/power_plant_overlay.png"

  position = entity.position.clone
  position.z = IMICRTS::ZOrder::OVERLAY
  emitters = []

  p1 = position.clone
  p1.y -= 14
  p2 = p1.clone
  p2.y += 40

  emitters.push(p1, p2)


  emitters.each do |pos|
    entity.particle_emitters << IMICRTS::SmokeEmitter.new(position: pos, emitting: false)
  end

  entity.on_tick do
    # entity.produce_power

    if entity.component(:structure).construction_complete?
      entity.particle_emitters.each do |emitter|
        emitter.emitting = true
      end
    end
  end

  # define_singleton_method(:produce_power) do
  #   @player.power += 10
  # end
end
