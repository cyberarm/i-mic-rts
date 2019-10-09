class IMICRTS
  class Map
    Tile = Struct.new(:position, :color, :image, :state)

    def initialize(width:, height:, tile_size: 32)
      @width, @height = width, height
      @tile_size = tile_size

      @tileset = Gosu::Image.load_tiles("#{ASSETS_PATH}/tilesets/default.png", tile_size, tile_size, retro: true)

      @tiles = []

      height.times do |y|
        width.times do |x|
          @tiles.push(
            Tile.new(
              CyberarmEngine::Vector.new(x * @tile_size, y * @tile_size, ZOrder::TILE),
              Gosu::Color.rgb(rand(25), rand(150..200), rand(25)),
              @tileset.sample,
              # :unexplored
              :visible
            )
          )
        end
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
        end
      end

      return _tiles
    end

    def tile_at(x, y)
      @tiles[x + y * @width]
    end
  end
end