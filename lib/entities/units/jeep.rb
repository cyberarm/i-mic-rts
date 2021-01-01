IMICRTS::Entity.define_entity(:jeep, :unit, 400, "Attacks ground targets") do |entity|
  entity.has(:movement)
  entity.has(:turret)

  entity.radius = 14
  entity.movement = :ground
  entity.max_health = 100.0

  entity.body_image = "vehicles/jeep/jeep.png"
  entity.shell_image = "vehicles/jeep/jeep_shell.png"

  entity.component(:turret).shell_image = "vehicles/jeep/jeep_turret_shell.png"
  entity.component(:turret).center.y = 0.3125

  entity.on_tick do
  end
end
