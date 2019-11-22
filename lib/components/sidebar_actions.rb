class IMICRTS
  class SidebarActions < Component
    Action = Struct.new(:label, :image, :description, :block)

    attr_reader :actions
    def initialize(parent:)
      @parent = parent

      @actions = []
    end

    def add(type, *args)
      action = Action.new

      case type
      when :add_to_build_queue
        ent = IMICRTS::Entity.get(args.first)
        raise "Failed to find entity: #{args.first.inspect}" unless ent

        action.label = ent.name.to_s.split("_").map{ |s| s.capitalize }.join(" ")
        action.description = "Cost: #{ent.cost}\n#{ent.description}"
        action.block = proc { @parent.component(:build_queue).add(args.first) }

      when :set_build_tool
        ent = IMICRTS::Entity.get(args[1])
        raise "Failed to find entity: #{args[1].inspect}" unless ent

        action.label = ent.name.to_s.split("_").map { |s| s.capitalize }.join(" ")
        action.description = "Cost: #{ent.cost}\n#{ent.description}"
        action.block = proc { @parent.director.game.set_tool(:building, ent) }

      else
        raise "Unhandled sidebar action: #{action.inspect}"
      end

      @actions << action
    end
  end
end
