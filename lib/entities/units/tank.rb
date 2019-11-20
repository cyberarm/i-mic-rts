IMICRTS::Entity.define_entity(:tank, :unit, 800, "Attacks ground targets") do |entity|
  entity.has(:movement)
  entity.has(:turret)

  entity.radius = 14
  entity.movement = :ground
  entity.max_health = 100.0
  entity.center.y = 0.3125

  entity.shell_image = "vehicles/tank/tank_shell.png"

  entity.component(:turret).shell_image = "vehicles/tank/tank_turret_shell.png"
  entity.component(:turret).center.y = 0.3125

  entity.on_tick do
  end
end
