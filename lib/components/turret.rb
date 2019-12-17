class IMICRTS
  class Turret < Component
    attr_accessor :angle, :center
    def setup
      @angle = 0
      @center = CyberarmEngine::Vector.new(0.5, 0.5)
    end

    def body_image=(image)
      @body_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def shell_image=(image)
      @shell_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def overlay_image=(image)
      @overlay_image = Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def render
      @render = Gosu.render(32, 32, retro: true) do
        @body_image.draw(0, 0, 0) if @body_image
        @shell_image.draw_rot(0, 0, 0, 0, 0, 0, 1, 1, @parent.player.color) if @shell_image
        @overlay_image.draw(0, 0, 0) if @overlay_image
      end
    end

    def draw
      render unless @render
      @angle += 0.1
      @render.draw_rot(@parent.position.x, @parent.position.y, @parent.position.z, @angle, @center.x, @center.y)
    end
  end
end