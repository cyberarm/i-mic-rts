class IMICRTS
  class FriendlyHash
    def initialize
      @hash = {}
    end

    def [](key)
      @hash[key.to_sym]
    end

    def []=(key, value)
      @hash[key.to_sym] = value
    end

    def method_missing(method)
      if value = @hash.dig(method)
        value
      else
        raise "Unknown value for: #{method}"
      end
    end
  end
end