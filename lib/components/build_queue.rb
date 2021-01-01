class IMICRTS
  class BuildQueue < Component
    attr_reader :queue

    Item = Struct.new(:entity, :progress)
    def setup
      @queue = []
    end

    def add(type)
      @queue << Item.new(Entity.get(type), 0.0)
    end
  end
end