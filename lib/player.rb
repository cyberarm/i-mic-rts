class IMICRTS
  class Player
    attr_reader :id, :name, :entities, :orders, :camera
    def initialize(id:, name: nil)
      @id = id
      @name = name ? name : "Novice-#{id}"

      @entities = []
      @orders = []
      @camera = Camera.new
    end

    def tick
      puts "Player #{@id}-#{@name} ticked: #{Gosu.milliseconds}"
    end

    def entity(id)
    end
  end
end