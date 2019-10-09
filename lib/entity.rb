class IMICRTS
  class Entity
    attr_reader :player, :id, :position, :angle, :radius, :target, :state
    def initialize(player:, id:, manifest: nil, images:, position:, angle:)
      @player = player
      @id = id
      @manifest = manifest
      @images = images
      @position = position
      @angle = angle

      @radius = 32 / 2
      @target = nil
      @state  = :idle

      # process_manifest

      @goal_color   = Gosu::Color.argb(175, 25, 200, 25)
      @target_color = Gosu::Color.argb(175, 200, 25, 25)
    end

    def serialize
    end

    def deserialize
    end

    def target=(entity)
      @target = entity
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
      @images.draw_rot(@position.x, @position.y, @position.z, @angle)
    end

    def update
      rotate_towards(@target) if @target
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