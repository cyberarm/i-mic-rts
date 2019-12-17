class IMICRTS
  class BuildQueue < Component
    Item = Struct.new(:entity, :progress)
    def setup
      @queue = []
    end

    def add(type)
      @queue << Item.new(Entity.get(type), 0.0)
    end
  end
end