IMICRTS::Entity.define_entity(:helicopter, :unit, 400, 40, "Attacks ground targets") do |entity|
  entity.has(:movement)

  entity.speed = 2.5
  entity.radius = 14
  entity.movement = :air
  entity.max_health = 100.0

  entity.body_image = "vehicles/helicopter/helicopter.png"
  entity.shell_image = "vehicles/helicopter/helicopter_shell.png"
  entity.overlay_image = "vehicles/helicopter/helicopter_overlay.png"

  entity.on_tick do
  end
end
