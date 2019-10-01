class IMICRTS
  class Entity
    def initialize(images:, position:, angle:)
      @images = images
      @position = position
      @angle = angle
    end

    def draw
      @images.draw_rot(@position.x, @position.y, @position.z, @angle)
    end
  end
end