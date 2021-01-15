IMICRTS::Entity.define_entity(:helicopter, :unit, 400, 40, "Attacks ground targets") do |entity|
  entity.has(:movement)
  entity.has(:rotors)

  entity.speed = 2.5
  entity.radius = 14
  entity.movement = :air
  entity.max_health = 100.0
  entity.position.z = IMICRTS::ZOrder::AIR_VEHICLE

  entity.body_image = "vehicles/helicopter/helicopter.png"
  entity.shell_image = "vehicles/helicopter/helicopter_shell.png"
  entity.overlay_image = "vehicles/helicopter/helicopter_overlay.png"

  entity.component(:rotors).body_image = "vehicles/helicopter/helicopter_rotors.png"
  entity.component(:rotors).center.y = 0.593
  entity.component(:rotors).speed = 500 / 60.0

  entity.on_tick do
  end
end
