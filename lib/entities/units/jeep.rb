IMICRTS::Entity.define_entity(:jeep, :unit, 400, 40, "Attacks ground targets") do |entity|
  entity.has(:movement)
  entity.has(:turret)

  entity.speed = 1.5
  entity.radius = 14
  entity.movement = :ground
  entity.max_health = 100.0

  entity.body_image = "vehicles/jeep/jeep.png"
  entity.shell_image = "vehicles/jeep/jeep_shell.png"
  entity.overlay_image = "vehicles/jeep/jeep_overlay.png"

  entity.component(:turret).shell_image = "vehicles/jeep/jeep_turret_shell.png"
  entity.component(:turret).center.y = 0.5

  entity.on_tick do
  end

  entity.component(:movement).define_singleton_method(:rotate_towards) do |target|
    entity.angle = Gosu.angle(target.x, target.y, entity.position.x, entity.position.y)
  end
end
