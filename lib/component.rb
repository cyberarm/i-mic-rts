class IMICRTS
  class Component
    include CyberarmEngine::Common

    @@components = {}

    def self.get(name)
      @@components.dig(name)
    end

    def self.inherited(klass)
      name = klass.to_s.to_snakecase

      if get(name)
        raise "#{klass.inspect} is already defined!"
      else
        @@components[name] = klass
      end
    end

    attr_reader :parent
    def initialize(parent:)
      @parent = parent

      setup
    end

    def data
      @parent.data
    end

    def data=(key, value)
      @parent.data[key] = value
    end

    def setup
    end

    def draw
    end

    def update
    end

    def tick(tick_id)
    end

    def on_order(type, order)
    end
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/components/**/*.rb").each do |component|
  require_relative component
end