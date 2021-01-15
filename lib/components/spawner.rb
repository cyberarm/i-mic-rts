class IMICRTS
  class Spawner < Component
    def tick(tick_id)
      item = @parent.component(:build_queue).queue.first

      return unless item

      item.progress += 1 if @parent.component(:structure).construction_complete?

      return unless item.progress >= item.entity.build_steps && !item.completed

      item.completed = true
      @parent.director.schedule_order(IMICRTS::Order::BUILD_UNIT_COMPLETE, @parent.player.id, @parent.id)
    end
  end
end