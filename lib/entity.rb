class IMICRTS
  class Entity
    Stub = Struct.new(:name, :type, :cost, :description, :setup)
    @entities = {}

    def self.get(name)
      @entities.dig(name)
    end

    def self.define_entity(name, type, cost, description, &block)
      if entity = get(name)
        raise "#{name.inspect} is already defined!"
      else
        @entities[name] = Stub.new(name, type, cost, description, block)
      end
    end

    attr_reader :player, :id, :name, :type
    attr_accessor :position, :angle, :radius, :target, :state,
                  :movement, :health, :max_health,
                  :turret
    def initialize(name:, player:, id:, position:, angle:, director:)
      @player = player
      @id = id
      @position = position
      @angle = angle
      @director = director
      @speed = 0.5

      @radius = 32 / 2
      @target = nil
      @state  = :idle

      if entity = Entity.get(name)
        @name = entity.name
        @type = entity.type

        entity.setup.call(self, director)
      else
        raise "Failed to find entity #{name.inspect} definition"
      end

      @goal_color   = Gosu::Color.argb(175, 25, 200, 25)
      @target_color = Gosu::Color.argb(175, 200, 25, 25)

      @orders = []
    end

    def serialize
    end

    def deserialize
    end

    def body_image=(image)
      @body_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def shell_image=(image)
      @shell_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def turret_body_image=(image)
      @turret_body_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def turret_shell_image=(image)
      @turret_shell_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def target=(entity)
      @target = entity
      @pathfinder = @director.find_path(player: @player, entity: self, goal: @target)
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

    def draw
      @body_image.draw_rot(@position.x, @position.y, @position.z, @angle) if @body_image
      @shell_image.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1, 1, @player.color)
      @overlay_image.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1, 1) if @overlay_image

      @turret_body_image.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1, 1) if @turret_body_image
      @turret_shell_image.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1, 1, @player.color) if @turret_shell_image
      @turret_overlay_image.draw_rot(@position.x, @position.y, @position.z, @angle, 0.5, 0.5, 1, 1) if @turret_overlay_image
    end

    def update
      rotate_towards(@target) if @target && @movement

      if @movement
        follow_path
      end
    end

    def tick(tick_id)
      @on_tick.call if @on_tick
    end

    def on_tick(&block)
      @on_tick = block
    end

    def follow_path
      if @pathfinder && node = @pathfinder.path_current_node
        @pathfinder.path_next_node if @pathfinder.at_current_path_node?(@position)
        @position -= (@position.xy - node.tile.position.xy).normalized * @speed
      end
    end

    def selected_draw
      draw_radius
      draw_gizmos
    end

    def draw_radius
      Gosu.draw_circle(@position.x, @position.y, @radius, ZOrder::ENTITY_RADIUS, @player.color)
    end

    def draw_gizmos
      Gosu.draw_rect(@position.x - @radius, @position.y - (@radius + 2), @radius * 2, 2, Gosu::Color::GREEN, ZOrder::ENTITY_GIZMOS)

      if @pathfinder && Setting.enabled?(:debug_pathfinding) && @pathfinder.path.first
        Gosu.draw_line(
          @position.x, @position.y, Gosu::Color::RED,
          @pathfinder.path.first.tile.position.x, @pathfinder.path.first.tile.position.y, Gosu::Color::RED,
          ZOrder::ENTITY_GIZMOS
        )

        @pathfinder.path.each_with_index do |node, i|
          next_node = @pathfinder.path.dig(i + 1)
          if next_node
            Gosu.draw_line(
              node.tile.position.x, node.tile.position.y, Gosu::Color::RED,
              next_node.tile.position.x, next_node.tile.position.y, Gosu::Color::RED,
              ZOrder::ENTITY_GIZMOS
            )
          end
        end
      end

      if @target.is_a?(IMICRTS::Entity)
        Gosu.draw_line(@position.x, @position.y, @target_color, @target.position.x, @target.position.y, @target_color, ZOrder::ENTITY_GIZMOS) if @target
      else
        Gosu.draw_line(@position.x, @position.y, @goal_color, @target.x, @target.y, @goal_color, ZOrder::ENTITY_GIZMOS) if @target
      end
    end

    def rotate_towards(vector)
      _angle = Gosu.angle(@position.x, @position.y, vector.x, vector.y)
      a = (360.0 + (_angle - @angle)) % 360.0

      # Fails if vector is directly behind entity
      if @angle.between?(_angle - 3, _angle + 3)
        @angle = _angle
      elsif a < 180
        @angle -= 1.0
      else
        @angle += 1.0
      end

      @angle %= 360.0
    end
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/entities/**/*.rb").each do |entity|
  require_relative entity
end