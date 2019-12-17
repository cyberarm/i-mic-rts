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

    def method_missing(method, argument = nil)
      if value = @hash.dig(method)
        value
      elsif argument != nil
        @hash[method.to_s.sub("=", "").to_sym] = argument
      else
        return false unless argument # May result in bugginess!
        raise "Unknown value for: #{method}"
      end
    end
  end
end