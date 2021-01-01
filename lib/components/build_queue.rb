class IMICRTS
  class BuildQueue < Component
    attr_reader :queue

    Item = Struct.new(:entity, :progress, :completed)
    def setup
      @queue = []
    end

    def add(type)
      @queue << Item.new(Entity.get(type), 0.0, false)
    end
  end
end