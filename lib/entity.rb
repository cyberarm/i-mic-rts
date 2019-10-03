class IMICRTS
  class Entity
    attr_reader :position, :angle, :radius
    def initialize(manifest: nil, images:, position:, angle:)
      @manifest = manifest
      @images = images
      @position = position
      @angle = angle

      @radius = 32 / 2
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

    def selected_draw
      draw_bounding_box
      draw_gizmos
    end

    def draw_bounding_box
    end

    def draw_gizmos
      Gosu.draw_rect(@position.x - @radius, @position.y - (@radius + 2), @radius * 2, 2, Gosu::Color::GREEN, ZOrder::ENTITY_GIZMOS)
    end

    def rotate_towards(vector)
      _angle = Gosu.angle(@position.x, @position.y, vector.x, vector.y)
      a = (360 + (_angle - @angle)) % 360

      # Fails if vector is directly behind entity
      if @angle.between?(_angle - 3, _angle + 3)
        @angle = _angle
      elsif a < 180
        @angle -= 1
      else
        @angle += 1
      end

      @angle %= 360

      pp [a, _angle, @angle]
    end
  end
end