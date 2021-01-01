class IMICRTS
  class SidebarActions < Component
    Action = Struct.new(:label, :image, :description, :block)

    attr_reader :actions
    def setup
      @actions = []
    end

    def add(type, data = {})
      action = Action.new

      case type
      when :add_to_build_queue
        ent = IMICRTS::Entity.get(data[:entity])
        raise "Failed to find entity: #{data[:entity].inspect}" unless ent

        action.label = ent.name.to_s.split("_").map{ |s| s.capitalize }.join(" ")
        action.description = "Cost: #{ent.cost}\n#{ent.description}"
        action.block = proc do
          @parent.director.schedule_order(IMICRTS::Order::BUILD_UNIT, @parent.player.id, @parent.id, data[:entity])
        end

      when :set_tool
        ent = IMICRTS::Entity.get(data[:entity])
        raise "Failed to find entity: #{data[:entity].inspect}" unless ent

        action.label = ent.name.to_s.split("_").map { |s| s.capitalize }.join(" ")
        action.description = "Cost: #{ent.cost}\n#{ent.description}"
        action.block = proc { @parent.director.game.set_tool(data[:tool], data) }

      else
        raise "Unhandled sidebar action: #{type.inspect}"
      end

      @actions << action
    end
  end
end
