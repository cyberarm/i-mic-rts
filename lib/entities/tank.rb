IMICRTS::Entity.define_entity(:tank, :unit, 800, "Attacks ground targets") do |entity|
  entity.radius = 14
  entity.movement = :ground
  entity.max_health = 100.0

  entity.shell_image = "vehicles/tank/tank_shell.png"

  entity.turret_shell_image = "vehicles/tank/tank_turret_shell.png"

  entity.on_tick do
  end
end
