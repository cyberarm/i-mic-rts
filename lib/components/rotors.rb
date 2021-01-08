class IMICRTS
  class Rotors < Component
    attr_accessor :angle, :speed, :center

    def setup
      @angle = 0
      @speed = 1
      @center = CyberarmEngine::Vector.new(0.5, 0.5)
    end

    def body_image=(image)
      @body_image = get_image("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def shell_image=(image)
      @shell_image = get_image("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def overlay_image=(image)
      @overlay_image = get_image("#{IMICRTS::ASSETS_PATH}/#{image}", retro: true)
    end

    def render
      image = @shell_image || @body_image || @overlay_image

      @render = Gosu.render(image.width, image.height, retro: true) do
        @body_image&.draw(0, 0, 0)
        @shell_image&.draw_rot(0, 0, 0, 0, 0, 0, 1, 1, @parent.player.color)
        @overlay_image&.draw(0, 0, 0)
      end
    end

    def draw
      render unless @render
      @render.draw_rot(@parent.position.x, @parent.position.y, @parent.position.z, @angle, @center.x, @center.y, @parent.scale.x, @parent.scale.y)
    end

    def update
      @angle += @speed
    end
  end
end