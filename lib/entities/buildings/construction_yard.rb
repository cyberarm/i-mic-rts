tiles = [
  [false, false, false, false, false],
  [false, true,  true,  true,  false],
  [false, true,  true,  true,  false],
  [false, true,  true,  true,  false],
  [false, :path, :path, :path, false],
]

IMICRTS::Entity.define_entity(:construction_yard, :building, 2_000, 310, "Provides radar and builds construction workers", tiles) do |entity|
  entity.has(:building)
  entity.has(:waypoint)
  entity.has(:spawner)
  entity.has(:build_queue)
  entity.has(:sidebar_actions)
  entity.component(:sidebar_actions).add(:add_to_build_queue, { entity: :construction_worker })

  entity.radius = 40
  entity.max_health = 100.0

  entity.body_image = "buildings/construction_yard/construction_yard.png"
  entity.shell_image = "buildings/construction_yard/construction_yard_shell.png"
  entity.overlay_image = "buildings/construction_yard/construction_yard_overlay.png"

  position = entity.position.clone
  position.z = IMICRTS::ZOrder::OVERLAY
  emitters = []

  p1 = position.clone
  p1.x -= 25
  p1.y -= 8
  p2 = p1.clone
  p2.y += 25

  p3 = position.clone
  p3.x += 8
  p3.y -= 15
  p4 = p3.clone
  p4.x += 21

  emitters.push(p1, p2, p3, p4)


  emitters.each do |pos|
    entity.particle_emitters << IMICRTS::SmokeEmitter.new(position: pos, emitting: false)
  end

  entity.on_tick do

    if entity.component(:building).data.state == :idle
      item = entity.component(:build_queue).queue.first

      entity.particle_emitters.each_with_index do |emitter, i|
        emitter.emitting = true
        emitter.emitting = !!item if i < 2
      end
    end
  end
end
