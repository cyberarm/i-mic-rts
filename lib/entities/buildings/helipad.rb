IMICRTS::Entity.define_entity(:helipad, :building, 1_000, "Builds and rearms helicopters") do |entity|
  entity.radius = 26
  entity.max_health = 100.0

  entity.shell_image = "buildings/helipad/helipad_shell.png"
  entity.overlay_image = "buildings/helipad/helipad_overlay.png"

  entity.on_tick do
  end
end
