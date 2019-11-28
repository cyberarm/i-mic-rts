tiles = [
  [false, false, false, false, false],
  [false, false, true,  false, false],
  [false, true,  true,  true,  false],
  [false, false, true,  false, false],
  [false, false, false, false, false],
]

IMICRTS::Entity.define_entity(:helipad, :building, 1_000, "Builds and rearms helicopters", tiles) do |entity|
  entity.has(:build_queue)
  entity.has(:sidebar_actions)
  entity.component(:sidebar_actions).add(:add_to_build_queue, {entity: :helicopter})

  entity.radius = 26
  entity.max_health = 100.0

  entity.shell_image = "buildings/helipad/helipad_shell.png"
  entity.overlay_image = "buildings/helipad/helipad_overlay.png"

  entity.on_tick do
  end
end
