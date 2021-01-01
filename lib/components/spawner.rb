class IMICRTS
  class Spawner < Component
    def tick(tick_id)
      # TODO: Ensure that a build order is created before working on entity

      item = @parent.component(:build_queue).queue.first

      if item
        item.progress += 1

        if item.progress >= 100 # TODO: Define work units required for construction
          @parent.component(:build_queue).queue.shift

          spawn_point = @parent.position.clone
          spawn_point.y += 96 # TODO: Use one of entity's reserved tiles for spawning

          ent = @parent.director.spawn_entity(player_id: @parent.player.id, name: item.entity.name, position: spawn_point)
          ent.target = @parent.component(:waypoint).waypoint if @parent.component(:waypoint)
        end
      end
    end
  end
end