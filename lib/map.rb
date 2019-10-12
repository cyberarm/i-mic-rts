class IMICRTS
  class Map
    Tile = Struct.new(:position, :color, :image, :state, :type)

    attr_reader :tiles, :ores
    def initialize(map_file:)
      @tiled_map = TiledMap.new(map_file)

      @width, @height = @tiled_map.width, @tiled_map.height
      @tile_size = @tiled_map.tile_size

      @tiles = []
      @ores  = []

      @tiled_map.layers.each do |layer|
        layer.height.times do |y|
          layer.width.times do |x|
            add_terrain(x, y, layer.data(x, y)) if layer.name.downcase == "terrain"
            add_ore(x, y, layer.data(x, y)) if layer.name.downcase == "ore"
          end
        end
      end

      @tiles.freeze
      @ores.freeze
    end

    def add_terrain(x, y, tile_id)
      if tile = @tiled_map.get_tile(tile_id - 1)
        @tiles << Tile.new(
          CyberarmEngine::Vector.new(x * @tile_size, y * @tile_size, ZOrder::TILE),
          nil,
          tile.image,
          :yes,
          tile.data.type
        )
      else
        raise "No such tile!"
      end
    end

    def add_ore(x, y, tile_id)
      if tile = @tiled_map.get_tile(tile_id - 1)
        @ores << Tile.new(
          CyberarmEngine::Vector.new(x * @tile_size, y * @tile_size, ZOrder::ORE),
          nil,
          tile.image,
          :yes,
          nil
        )
      else
        @ores << nil
      end
    end

    def draw(camera)
      visible_tiles(camera).each do |tile|
        tile.image.draw(tile.position.x, tile.position.y, tile.position.z)
      end
    end

    def visible_tiles(camera)
      _tiles = []

      top_left = (camera.center - camera.position) - CyberarmEngine::Vector.new($window.width / 2, $window.height / 2) / camera.zoom
      top_left /= @tile_size

      top_left.x = top_left.x.floor
      top_left.y = top_left.y.floor


      # +1 to overdraw a bit to hide pop-in
      _width  = ((($window.width / @tile_size)  + 2) / camera.zoom).ceil
      _height = ((($window.height / @tile_size) + 2) / camera.zoom).ceil

      _height.times do |y|
        _width.times do |x|
          _x, _y = x + top_left.x, y + top_left.y
          next if _x < 0 || _x > @width
          next if _y < 0 || _y > @height

          if tile = tile_at(_x, _y)
            _tiles.push(tile) if tile.state != :unexplored
          end

          if ore = ore_at(_x, _y)
            _tiles.push(ore) if ore.state != :unexplored
          end
        end
      end

      return _tiles
    end

    def tile_at(x, y)
      @tiles[x + y * @width]
    end

    def ore_at(x, y)
      @ores[x + y * @width]
    end
  end
end