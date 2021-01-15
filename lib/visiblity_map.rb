class IMICRTS
  class VisibilityMap
    attr_reader :width, :height, :tile_size

    def initialize(width:, height:, tile_size:)
      @width = width
      @height = height
      @tile_size = tile_size

      @map = Array.new(width * height, false)
    end

    def visible?(x, y)
      @map.dig(index_at(x, y))
    end

    def index_at(x, y)
      ((y.clamp(0, @height - 1) * @width) + x.clamp(0, @width - 1))
    end

    def update(entity)
      range = entity.sight_radius
      pos = entity.position.clone / @tile_size
      pos.x = pos.x.ceil - range
      pos.y = pos.y.ceil - range

      (range * 2).times do |y|
        (range * 2).times do |x|
          if not visible?(pos.x + x, pos.y + y).nil?
            @map[index_at(pos.x + x, pos.y + y)] = true
          end
        end
      end
    end
  end
end