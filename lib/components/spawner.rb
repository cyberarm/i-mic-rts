class IMICRTS
  class Spawner < Component
    def tick(tick_id)
      item = @parent.component(:build_queue).queue.first

      return unless item

      item.progress += 1

      if item.progress >= item.entity.build_steps
        unless item.completed
          item.completed = true

          @parent.director.schedule_order(IMICRTS::Order::BUILD_UNIT_COMPLETE, @parent.player.id, @parent.id)
        end
      end
    end
  end
end