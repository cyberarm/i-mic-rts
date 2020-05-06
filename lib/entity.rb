class IMICRTS
  class Entity
    Stub = Struct.new(:name, :type, :cost, :description, :tiles, :setup)
    @entities = {}

    def self.get(name)
      @entities.dig(name)
    end

    def self.define_entity(name, type, cost, description, tiles = [[]], &block)
      if entity = get(name)
        raise "#{name.inspect} is already defined!"
      else
        @entities[name] = Stub.new(name, type, cost, description, tiles, block)
      end
    end

    attr_reader :director, :player, :id, :name, :type, :speed, :data
    attr_accessor :position, :angle, :radius, :target, :state,
                  :movement, :health, :max_health,
                  :turret, :center, :particle_emitters, :color
    def initialize(name:, player:, id:, position:, angle:, director:, proto_entity: false)
      @player = player
      @id = id
      @position = position
      @angle = angle
      @director = director
      @proto_entity = proto_entity

      @data = FriendlyHash.new

      @speed = 0.5
      @color = Gosu::Color.rgba(255, 255, 255, 255)

      @sight_radius = 5 # tiles
      @range_radius = 3 # tiles
      @radius = 32 / 2 # pixels
      @target = nil
      @state  = :idle
      @center = CyberarmEngine::Vector.new(0.5, 0.5)
      @particle_emitters = []

      @components = {}

      if entity = Entity.get(name)
        @name = entity.name
        @type = entity.type

        entity.setup.call(self, director)
      else
        raise "Failed to find entity #{name.inspect} definition"
      end

      @boid_radius = @radius + 8
      component(:turret).angle = @angle if component(:turret)

      @goal_color   = Gosu::Color.argb(175, 25, 200, 25)
      @target_color = Gosu::Color.argb(175, 200, 25, 25)

      @orders = []
    end

    def serialize
    end

    def deserialize
    end

    def clear_orders
      @orders.clear
    end

    def add_order(order)
      @orders.push(order)
    end

    def has(symbol)
      component = Component.get(symbol)

      if component
        @components[symbol] = component.new(parent: self)
      else
        raise "Unknown component: #{symbol.inspect}"
      end
    end

    def component(symbol)
      @components.dig(symbol)
    end

    def body_image=(image)
      @body_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def shell_image=(image)
      @shell_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def overlay_image=(image)
      @overlay_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def target=(entity)
      @target = entity
      component(:movement).pathfinder = @director.find_path(player: @player, entity: self, goal: @target) if component(:movement)
    end

    def hit?(x_or_vector, y = nil)
      vector = nil
      if x_or_vector.is_a?(CyberarmEngine::Vector)
        vector = x_or_vector
      else
        raise "Y cannot be nil!" if y.nil?
        vector = CyberarmEngine::Vector.new(x_or_vector, y)
      end

      @position.distance(vector) < @radius + 1
    end

    def die?
      if @health
        @health <= 0
      else
        false
      end
    end

    def render
      @render = Gosu.render(@shell_image.width, @shell_image.height, retro: true) do
        @body_image.draw(0, 0, 0) if @body_image
        @shell_image.draw(0, 0, 0, 1, 1, @player.color)
        @overlay_image.draw(0, 0, 0) if @overlay_image
      end
    end

    def draw
      render unless @render
      @render.draw_rot(@position.x, @position.y, @position.z, @angle, @center.x, @center.y, 1, 1, @color)

      unless @proto_entity
        @components.values.each(&:draw)
        @particle_emitters.each(&:draw)
      end
    end

    def update
      @components.values.each(&:update)

      @particle_emitters.each do |emitter|
        @particle_emitters.delete(emitter) if emitter.die?
        emitter.update
      end
    end

    def tick(tick_id)
      @on_tick.call if @on_tick
      component(:building).construction_work(1) if component(:building)
    end

    def on_tick(&block)
      @on_tick = block
    end

    def selected_draw
      draw_radius
      draw_gizmos
    end

    def draw_radius
      Gosu.draw_arc(@position.x, @position.y, @radius, 1.0, 18, 1, @player.color, ZOrder::ENTITY_RADIUS)
      Gosu.draw_arc(@position.x, @position.y, @boid_radius, 1.0, 18, 1, @player.color, ZOrder::ENTITY_RADIUS)
    end

    def draw_gizmos
      # healthbar
      Gosu.draw_rect(@position.x - @radius, @position.y - (@radius + 2), @radius * 2, 2, Gosu::Color::GREEN, ZOrder::ENTITY_GIZMOS)

      if Setting.enabled?(:debug_pathfinding) && component(:movement) && component(:movement).pathfinder && component(:movement).pathfinder.path_current_node
        current_node = component(:movement).pathfinder.path_current_node.tile.position + @director.map.tile_size / 2
        Gosu.draw_line(
          @position.x, @position.y, Gosu::Color::RED,
          current_node.x, current_node.y, Gosu::Color::RED,
          ZOrder::ENTITY_GIZMOS
        )

        node = component(:movement).pathfinder.path_current_node.tile.position + @director.map.tile_size / 2
        component(:movement).pathfinder.path[component(:movement).pathfinder.path_current_node_index..component(:movement).pathfinder.path.size - 1].each do |next_node|
          if node
            next_node = next_node.tile.position + @director.map.tile_size / 2

            Gosu.draw_line(
              node.x, node.y, Gosu::Color::RED,
              next_node.x, next_node.y, Gosu::Color::RED,
              ZOrder::ENTITY_GIZMOS
            )

            node = next_node
          end
        end
      end

      if @target.is_a?(IMICRTS::Entity)
        Gosu.draw_line(@position.x, @position.y, @target_color, @target.position.x, @target.position.y, @target_color, ZOrder::ENTITY_GIZMOS) if @target
      else
        Gosu.draw_line(@position.x, @position.y, @goal_color, @target.x, @target.y, @goal_color, ZOrder::ENTITY_GIZMOS) if @target
      end
    end
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/entities/**/*.rb").each do |entity|
  require_relative entity
end
