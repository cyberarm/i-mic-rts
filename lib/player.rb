class IMICRTS
  class Player
    attr_reader :id, :name, :entities, :orders, :camera
    attr_reader :selected_entities
    def initialize(id:, name: nil)
      @id = id
      @name = name ? name : "Novice-#{id}"

      @entities = []
      @orders = []
      @camera = Camera.new(viewport: [0, 0, $window.width, $window.height])

      @selected_entities = []
      @current_entity_id = 0
    end

    def tick(tick_id)
    end

    def entity(id)
      @entities.find { |ent| ent.id == id }
    end

    def next_entity_id
      @current_entity_id += 1
    end
  end
end