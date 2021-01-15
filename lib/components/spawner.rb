class IMICRTS
  class Spawner < Component
    attr_accessor :spawnpoint

    def setup
      @spawnpoint = @parent.position.clone
      @spawnpoint.y += 64
    end

    def tick(tick_id)
      item = @parent.component(:build_queue).queue.first

      return unless item

      item.progress += 1 if @parent.component(:structure).construction_complete?

      return unless item.progress >= item.entity.build_steps && !item.completed

      item.completed = true
      @parent.director.schedule_order(IMICRTS::Order::BUILD_UNIT_COMPLETE, @parent.player.id, @parent.id)
    end

    def on_order(type, order)
      case type
      when IMICRTS::Order::BUILD_UNIT_COMPLETE
        item = @parent.component(:build_queue).queue.shift

        ent = @parent.director.spawn_entity(player_id: @parent.player.id, name: item.entity.name, position: @spawnpoint)
        ent.target = @parent.component(:waypoint).waypoint if @parent.component(:waypoint)
      end
    end
  end
end