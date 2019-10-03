class IMICRTS
  class Window < CyberarmEngine::Engine
    def setup
      @last_update_time = Gosu.milliseconds

      self.caption = "#{IMICRTS::NAME} (#{IMICRTS::VERSION} #{IMICRTS::VERSION_NAME})"
      if ARGV.join.include?("--fast")
        push_state(MainMenu)
      elsif ARGV.join.include?("--debug")
        push_state(Game)
      else
        push_state(Boot)
      end
    end

    def update
      super

      @last_update_time = Gosu.milliseconds
    end

    def close
      push_state(Closing) unless current_state.is_a?(Closing)
    end

    def delta_time
      Gosu.milliseconds - @last_update_time
    end

    def dt
      delta_time / 1000.0
    end
  end
end