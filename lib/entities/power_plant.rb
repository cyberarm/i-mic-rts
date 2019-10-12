IMICRTS::Entity.define_entity(:power_plant, :building, 800, "Generates power") do |entity|
  entity.radius = 14
  entity.max_health = 100.0

  entity.body_image = "vehicles/power_plant/images/power_plant.png"
  entity.shell_image = "vehicles/power_plant/images/power_plant.png"

  entity.on_tick do
    entity.produce_power
  end

  define_singleton_method(:produce_power) do
    @player.power += 10
  end
end
