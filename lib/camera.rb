class IMICRTS
  class Camera
    attr_reader :position, :velocity, :drag
    def initialize(scroll_speed: 10, position: CyberarmEngine::Vector.new(0.0, 0.0))
      @scroll_speed = scroll_speed
      @position = position
      @velocity = CyberarmEngine::Vector.new(0.0, 0.0)

      @drag = 0.8
    end

    def window; $window; end

    def draw(&block)
      if block
        Gosu.translate(@position.x, @position.y) do
          block.call
        end
      end
    end

    def update
      move
      @velocity *= @drag

      @position += @velocity * @scroll_speed
    end

    def center
      CyberarmEngine::Vector.new(window.width / 2, window.height / 2) - @position
    end

    def center_around(vector, factor)
      @velocity *= 0
      delta = lerp(self.center, vector, factor)
      @position += delta * window.dt
    end

    def lerp(vec1, vec2, factor)
      (vec1 - vec2) * factor.clamp(0.0, 1.0)
    end

    def move
      @velocity.x += @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_LEFT)  || window.mouse_x < 15
      @velocity.x -= @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_RIGHT) || window.mouse_x > window.width - 15
      @velocity.y += @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_UP)    || window.mouse_y < 15
      @velocity.y -= @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_DOWN)  || window.mouse_y > window.height - 15

      if @drag_start
        @velocity *= 0.0
        @position = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @drag_start
      end
    end

    def button_down(id)
      case id
      when Gosu::KB_H
        @position.x, @position.y = 0.0, 0.0
        @velocity *= 0.0
      when Gosu::MS_MIDDLE
        @position_start = @position.clone
        @drag_start = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @position
      end
    end

    def button_up(id)
      case id
      when Gosu::MS_MIDDLE
        @position_start = nil
        @drag_start = nil
      end
    end
  end
end