class IMICRTS
  class TiledMap
    attr_reader :width, :height, :tile_size, :layers, :tilesets, :spawnpoints

    def initialize(map_file)
      @xml = Nokogiri::XML(File.read("#{IMICRTS::ASSETS_PATH}/#{map_file}"))

      @width  = 0
      @height = 0
      @tile_size = 32

      @layers = []
      @tilesets = []
      @spawnpoints = []

      @tiles = []

      parse

      terrain = @layers.find { |layer| layer.name.downcase == "terrain" }
      @width  = terrain.width
      @height = terrain.height

      @tilesets.each do |tileset|
        @tiles.push(*tileset.tiles)
      end

      @xml = nil
    end

    def parse
      @xml.search("//tileset").each do |tileset|
        @tilesets << TileSet.new(tileset)
      end

      @xml.search("//layer").each do |layer|
        @layers << Layer.new(layer)
      end

      @xml.search("//objectgroup").each do |objectgroup|
        next unless objectgroup.attr("name") == "spawns"

        objectgroup.children.each do |object|
          next unless object.attr("name") && object.attr("name").downcase.strip == "spawn"

          @spawnpoints << SpawnPoint.new(object)
        end
      end
    end

    def get_tile(tile_id)
      return nil if tile_id < 0

      @tiles.dig(tile_id)
    end



    class Layer
      attr_reader :name, :width, :height

      def initialize(xml_layer)
        @name = xml_layer["name"]
        @width = Integer(xml_layer["width"])
        @height = Integer(xml_layer["height"])
        @data = []

        xml_layer.css("data").inner_html.each_line do |line|
          @data.push(*line.strip.split(",").map { |id| Integer(id) })
        end
      end

      def data(x, y)
        @data[x + y * @width]
      end
    end




    class TileSet
      attr_reader :first_gid, :name, :tile_width, :tile_height, :tile_count, :columns, :rows, :tiles

      Tile = Struct.new(:image, :data)
      def initialize(xml_tileset)
        @first_gid = nil
        @tiles = []

        xml_tileset.attributes.each do |name, attrib|
          case name
          when "firstgid"
            @first_gid = Integer(attrib.value)
          when "source"
            parse(attrib.value)
          end
        end
      end

      def parse(file)
        xml = Nokogiri::XML(File.read("#{IMICRTS::ASSETS_PATH}/#{file.sub("../", "")}"))
        tileset = xml.search("//tileset").first

        data = {}
        tileset.attributes.each { |attrib, value| data[attrib] = value.value }

        data.each do |key, value|
          case key
          when "name"
            @name = value
          when "tilewidth"
            @tile_width = Integer(value)
          when "tileheight"
            @tile_height = Integer(value)
          when "tilecount"
            @tile_count = Integer(value)
          when "columns"
            @columns = Integer(value)
          when "rows"
            @rows = Integer(value)
          end
        end

        path = tileset.search("//image").first.attributes.detect { |a, v| a == "source" }.last.value
        images = Gosu::Image.load_tiles("#{IMICRTS::ASSETS_PATH}/tilesets/#{path}", @tile_width, @tile_height, retro: true, tileable: true)

        tileset.search("//tile").each_with_index do |xml, index|
          tile = Tile.new
          tile.image = images[index]
          tile.data = FriendlyHash.new

          xml.attributes.each do |name, data|
            tile.data[name.to_sym] = data.value if name == "type"
          end

          @tiles << tile
        end
      end
    end



    class SpawnPoint
      attr_reader :x, :y

      def initialize(xml_object)
        @x = Integer(xml_object.attr("x"))
        @y = Integer(xml_object.attr("y"))
      end
    end
  end
end