IMICRTS::Entity.define_entity(:construction_worker, :unit, 1000, "Constructs buildings") do |entity|
  entity.has(:movement)
  entity.has(:build_queue)
  entity.has(:sidebar_actions)
  [:power_plant, :refinery, :barracks, :war_factory, :helipad, :construction_yard].each do |ent|
    entity.component(:sidebar_actions).add(:set_build_tool, :place_building, ent)
  end

  entity.radius = 14
  entity.movement = :ground
  entity.max_health = 100.0

  entity.body_image = "vehicles/construction_worker/images/construction_worker.png"
  entity.shell_image = "vehicles/construction_worker/images/construction_worker_shell.png"

  entity.on_tick do
  end
end
