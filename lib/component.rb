class IMICRTS
  class Component
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
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/components/**/*.rb").each do |component|
  require_relative component
end