class IMICRTS
  class Tool
    @@tools = {}
    def self.get(tool)
      @@tools.dig(tool)
    end

    def self.inherited(subclass)
      @@tools[subclass.to_s.to_snakecase] = subclass
    end

    attr_reader :game, :director, :player
    def initialize(options = {}, game: nil, director: nil, player: nil)
      @options = options
      @game = game
      @director = director
      @player = player

      setup
    end

    def setup
    end

    def draw
    end

    def update
    end

    def button_down(id)
    end

    def button_up(id)
    end

    def cost
      return 0
    end

    def cancel_tool
      @game.set_tool(nil)
    end

    def use_tool(vector, options = {})
    end

    def can_use?(vector)
    end

    def vector_to_grid(vector)
      temp = @player.camera.transform(vector)
      temp.x = (temp.x / @director.map.tile_size).floor
      temp.y = (temp.y / @director.map.tile_size).floor

      return temp
    end
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/tools/**/*.rb").each do |tool|
  require_relative tool
end