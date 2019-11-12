class IMICRTS
  class Closing < CyberarmEngine::GuiState
    def setup
      @logo = Gosu::Image.new("#{ASSETS_PATH}/logo.png")
      @color = Gosu::Color.new(0xffffffff)

      @started_at = Gosu.milliseconds
      @close_time = 3_000
    end

    def draw
      Gosu.draw_rect(0, 0, window.width, window.height, @color)
      @logo.draw(window.width / 2 - @logo.width / 2, window.height / 2 - @logo.height / 2, 2, 1.0, 1.0, @color)
    end

    def update
      super
      factor = (1.0 - ((Gosu.milliseconds - @started_at) / @close_time.to_f)).clamp(0.0, 1.0)
      @color.alpha = 255 * (factor - 0.1)

      window.close! if Gosu.milliseconds - @started_at >= @close_time
    end

    def button_down(id)
      window.close!
    end
  end
end