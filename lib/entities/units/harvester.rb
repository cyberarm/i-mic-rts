IMICRTS::Entity.define_entity(:harvester, :unit, 1400, "Harvests ore") do |entity, director|
  entity.has(:movement)

  entity.radius = 10
  entity.movement = :ground
  entity.max_health = 100.0

  entity.body_image = "vehicles/harvester/images/harvester.png"
  entity.shell_image = "vehicles/harvester/images/harvester_shell.png"

  @capacity = 10.0
  @bed = 0.0

  entity.on_tick do
    if @bed >= @capacity
      entity.seek_refinery
    else
      entity.seek_ore
    end
  end

  entity.define_singleton_method(:seek_ore) do
    # ore = director.map.ores.compact.sort_by { |ore| next unless ore; ore.position.distance(entity.position) }.first

    # n = (ore.position - entity.position).normalized
    # n.z = 0
    # entity.position += n * 3
  end

  entity.define_singleton_method(:seek_refinery) do
  end

  entity.component(:movement).define_singleton_method(:rotate_towards) do |target|
    entity.angle = Gosu.angle(target.x, target.y, entity.position.x, entity.position.y)
  end
end
