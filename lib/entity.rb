class IMICRTS
  class Entity
    attr_reader :position, :angle
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
  end
end