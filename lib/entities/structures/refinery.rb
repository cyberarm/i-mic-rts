tiles = [
  [false, false, false, false, false],
  [false, true,  true,  false, false],
  [false, true,  true,  true,  false],
  [false, true,  true,  true,  false],
  [false, false, :path, :path, false],
]

IMICRTS::Entity.define_entity(:refinery, :structure, 1_400, 200, "Generates credits", tiles) do |entity|
  unless entity.proto_entity
    entity.has(:structure)
  end

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

  entity.particle_emitters << IMICRTS::SmokeEmitter.new(position: p1, emitting: false)

  entity.on_tick do
    if entity.component(:structure).data.state == :idle

      entity.particle_emitters.each do |emitter|
        emitter.emitting = true
      end
    end
  end

  entity.on_order do |type, order|
    case type
    when IMICRTS::Order::CONSTRUCTION_COMPLETE
      pos = entity.position.clone
      pos.x += 32
      pos.y += 64

      entity.director.spawn_entity(player_id: entity.player.id, name: :harvester, position: pos)
    end
  end
end
