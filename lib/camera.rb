class IMICRTS
  class Camera
    attr_reader :position, :velocity, :zoom, :drag
    def initialize(scroll_speed: 10, position: CyberarmEngine::Vector.new(0.0, 0.0))
      @scroll_speed = scroll_speed
      @position = position
      @velocity = CyberarmEngine::Vector.new(0.0, 0.0)

      @zoom = 1.0
      @min_zoom = 0.25
      @max_zoom = 4.0

      @drag = 0.8 # Used to arrest velocity
      @grab_drag = 0.5 # Used when camera is panned using middle mouse button
    end

    def window; $window; end

    def draw(&block)
      if block
        center_point = center
        Gosu.translate(@position.x, @position.y) do
          Gosu.scale(@zoom, @zoom, center.x, center.y) do
            block.call
          end
        end
      end
    end

    def update
      @zoom = 1.0

      move
      @velocity *= @drag

      @position += @velocity * @scroll_speed
    end

    def mouse_pick(x, y)
      mouse = CyberarmEngine::Vector.new(x, y)

      worldspace = (mouse - @position) / @zoom
      worldspace.x = worldspace.x.floor
      worldspace.y = worldspace.y.floor

      return worldspace
    end

    def center
      (CyberarmEngine::Vector.new(window.width / 2, window.height / 2) - @position)
    end

    def center_around(vector, factor)
      @velocity *= 0
      @position += center.lerp(vector, factor) * window.dt
    end

    def aspect_ratio
      window.height / window.width.to_f
    end

    def move
      @velocity.x += @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_LEFT)  || window.mouse_x < 15
      @velocity.x -= @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_RIGHT) || window.mouse_x > window.width - 15
      @velocity.y += @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_UP)    || window.mouse_y < 15
      @velocity.y -= @scroll_speed * window.dt if Gosu.button_down?(Gosu::KB_DOWN)  || window.mouse_y > window.height - 15

      if @drag_start
        @velocity *= 0.0
        @position = @position.lerp(@drag_start - CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y), @grab_drag)
      end
    end

    def button_down(id)
      case id
      when Gosu::KB_H
        @position.x, @position.y = 0.0, 0.0
        @velocity *= 0.0
      when Gosu::MS_WHEEL_UP
        @zoom = (@zoom + 0.25).clamp(@min_zoom, @max_zoom)
      when Gosu::MS_WHEEL_DOWN
        @zoom = (@zoom - 0.25).clamp(@min_zoom, @max_zoom)
      when Gosu::MS_MIDDLE
        @drag_start = CyberarmEngine::Vector.new(window.mouse_x, window.mouse_y) - @position
      end
    end

    def button_up(id)
      case id
      when Gosu::MS_MIDDLE
        @drag_start = nil
      end
    end
  end
end