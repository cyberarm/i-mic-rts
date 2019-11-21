class IMICRTS
  class SidebarActions < Component
    Action = Struct.new(:label, :image, :description, :block)

    attr_reader :actions
    def initialize(parent:)
      @parent = parent

      @actions = []
    end

    def add(action, *args)
      case action
      when :add_to_build_queue
        action = Action.new
        ent = IMICRTS::Entity.get(args.first)
        action.label = ent.name.to_s
        action.description = "Cost: #{ent.cost}\n#{ent.description}"
        action.block = proc { @parent.component(:build_queue).add(args.first) }

        @actions << action
      else
        raise "Unhandled sidebar action: #{action.inspect}"
      end
    end
  end
end