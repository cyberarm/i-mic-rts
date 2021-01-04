class IMICRTS
  class Window < CyberarmEngine::Window
    attr_reader :mouse

    def setup
      @last_update_time = Gosu.milliseconds
      @mouse = CyberarmEngine::Vector.new
      @cursor = get_image("#{IMICRTS::ASSETS_PATH}/cursors/pointer.png")

      self.caption = "#{IMICRTS::NAME} (#{IMICRTS::VERSION} #{IMICRTS::VERSION_NAME})"
      if ARGV.join.include?("--debug-game")
        push_state(Game)
      elsif Setting.enabled?(:skip_intro)
        push_state(MainMenu)
      else
        push_state(Boot)
      end

      # TODO: Jukebox
      s = get_song("#{GAME_ROOT_PATH}/assets/audio/music/EmptyCity.ogg")
      s.play(true)
    end

    def draw
      super

      @cursor.draw(mouse_x, mouse_y, Float::INFINITY) if @show_cursor
    end

    def update
      @mouse.x = mouse_x
      @mouse.y = mouse_y

      super

      @last_update_time = Gosu.milliseconds
    end

    def needs_cursor?
      false
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
