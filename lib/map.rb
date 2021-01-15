class IMICRTS
  class Map
    attr_reader :tile_size, :tiles, :ores, :spawnpoints, :width, :height

    def initialize(map_file:)
      @tiled_map = TiledMap.new(map_file)

      @width = @tiled_map.width
      @height = @tiled_map.height
      @tile_size = @tiled_map.tile_size

      @tiles = {}
      @ores  = {}
      @spawnpoints = @tiled_map.spawnpoints.freeze

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
      if (tile = @tiled_map.get_tile(tile_id - 1))
        _tile = Tile.new(
          position: CyberarmEngine::Vector.new(x * @tile_size, y * @tile_size, ZOrder::TILE),
          image: tile.image,
          type: tile.data.type.to_sym,
          tile_size: @tile_size
        )

        @tiles[x] ||= {}
        @tiles[x][y] = _tile
      else
        raise "No such tile!"
      end
    end

    def add_ore(x, y, tile_id)
      if (tile = @tiled_map.get_tile(tile_id - 1))
        _ore = Tile.new(
          position: CyberarmEngine::Vector.new(x * @tile_size, y * @tile_size, ZOrder::ORE),
          image: tile.image,
          type: nil,
          tile_size: @tile_size
        )

        @ores[x] ||= {}
        @ores[x][y] = _ore
      end
    end

    def draw(observer)
      visible_tiles(observer).each do |tile|
        tile.image.draw(tile.position.x, tile.position.y, tile.position.z)
      end
    end

    def render_preview
      Gosu.render(1024, 1024, retro: true) do
        Gosu.scale(1024 / (@width.to_f * @tile_size), 1024 / (@height.to_f * @tile_size)) do
          @height.times do |y|
            @width.times do |x|
              tile = tile_at(x, y)
              ore  = ore_at(x, y)

              tile.image.draw(tile.position.x, tile.position.y, tile.position.z) if tile
              ore.image.draw(ore.position.x, ore.position.y, ore.position.z) if ore
            end
          end

          @spawnpoints.each do |spawnpoint|
            Gosu.draw_circle(spawnpoint.x, spawnpoint.y, @tile_size.to_f / 4 * 3, 36, Gosu::Color::BLACK, Float::INFINITY)
            Gosu.draw_circle(spawnpoint.x, spawnpoint.y, @tile_size.to_f / 2, 36, Gosu::Color::GRAY, Float::INFINITY)
          end
        end
      end
    end

    def visible_tiles(observer)
      _tiles = []
      visiblity_map = observer.visiblity_map

      top_left = (observer.camera.center - observer.camera.position) - CyberarmEngine::Vector.new($window.width / 2, $window.height / 2) / observer.camera.zoom
      top_left /= @tile_size

      top_left.x = top_left.x.floor
      top_left.y = top_left.y.floor


      # +1 to overdraw a bit to hide pop-in
      _width  = ((($window.width / @tile_size)  + 2) / observer.camera.zoom).ceil
      _height = ((($window.height / @tile_size) + 2) / observer.camera.zoom).ceil

      _height.times do |y|
        _width.times do |x|
          _x, _y = x + top_left.x, y + top_left.y
          next if _x < 0 || _x > @width
          next if _y < 0 || _y > @height

          visible = visiblity_map.visible?(_x, _y)

          if (tile = tile_at(_x, _y))
            _tiles.push(tile) if visible
          end

          if (ore = ore_at(_x, _y))
            _tiles.push(ore) if visible
          end
        end
      end

      return _tiles
    end

    def world_to_grid(vector)
      vector / @tile_size
    end

    def tile_at(x, y)
      @tiles.dig(x, y)
    end

    def ore_at(x, y)
      @ores.dig(x, y)
    end

    class Tile
      attr_accessor :position, :grid_position, :image, :entity, :reserved, :type

      def initialize(position:, image:, type:, tile_size:)
        @position = position
        @grid_position = position.clone
        @grid_position /= tile_size
        @grid_position.x, @grid_position.y = @grid_position.x.floor, @grid_position.y.floor

        @image = image
        @entity = nil
        @reserved = nil
        @type = type
      end
    end
  end
end