class IMICRTS
  class Camera
    include CyberarmEngine::Common

    attr_reader :viewport, :position, :velocity, :zoom, :drag

    def initialize(viewport: [0, 0, window.width, window.height], scroll_speed: 10, position: CyberarmEngine::Vector.new(0.0, 0.0))
      @viewport = CyberarmEngine::BoundingBox.new(viewport[0], viewport[1], viewport[2], viewport[3])
      @scroll_speed = scroll_speed
      @position = position
      @velocity = CyberarmEngine::Vector.new(0.0, 0.0)

      @zoom = 1.0
      @min_zoom = 0.50
      @max_zoom = 5.0

      @drag = 0.8 # Used to arrest velocity
      @grab_drag = 0.5 # Used when camera is panned using middle mouse button
    end

    def draw(&block)
      if block
        Gosu.clip_to(@viewport.min.x, @viewport.min.y, @viewport.max.x, @viewport.max.y) do
          Gosu.transform(*worldspace.elements) do
            block.call
          end
        end
      end
    end

    def update
      move
      @velocity *= @drag

      @position += @velocity * @scroll_speed

      @viewport.max.x = window.width
      @viewport.max.y = window.height
    end

    def transform(vector)
      neg_center = CyberarmEngine::Vector.new(-center.x, -center.y)

      scaled_position = (vector) / @zoom
      scaled_translation = (neg_center / @zoom + center)

      inverse = (scaled_position + scaled_translation) - @position

      inverse.x = inverse.x.floor
      inverse.y = inverse.y.floor

      return inverse
    end

    def center
      CyberarmEngine::Vector.new(window.width / 2, window.height / 2)
    end

    def center_around(vector, factor)
      @velocity *= 0
      @position += center.lerp(vector, factor) * window.dt
    end

    def worldspace
      zoom_vector = CyberarmEngine::Vector.new(@zoom, @zoom)
      position_matrix = CyberarmEngine::Transform.translate(@position)

      CyberarmEngine::Transform.concat(CyberarmEngine::Transform.scale(zoom_vector, center - @position), position_matrix)
    end

    def visible?(object)
      if object.is_a?(Map::Tile)
        object.position.x - object.size >= @viewport.min.x - @position.x &&
          object.position.y - object.size >= @viewport.min.y - @position.y &&
          object.position.x <= @viewport.max.x - @position.x &&
          object.position.y <= @viewport.max.y - @position.y
      else
        pp object.class
        exit
      end
    end

    def aspect_ratio
      window.height / window.width.to_f
    end

    def move
      @velocity.x += (@scroll_speed / @zoom) * window.dt if Gosu.button_down?(Gosu::KB_LEFT)  || window.mouse_x < 15
      @velocity.x -= (@scroll_speed / @zoom) * window.dt if Gosu.button_down?(Gosu::KB_RIGHT) || window.mouse_x > window.width - 15
      @velocity.y += (@scroll_speed / @zoom) * window.dt if Gosu.button_down?(Gosu::KB_UP)    || window.mouse_y < 15
      @velocity.y -= (@scroll_speed / @zoom) * window.dt if Gosu.button_down?(Gosu::KB_DOWN)  || window.mouse_y > window.height - 15

      if @drag_start
        @velocity *= 0.0

        @position = window.mouse - @drag_start
      end
    end

    def move_to(x, y, zoom)
      @velocity *= 0.0
      @position.x, @position.y = x, y
      @zoom = zoom
    end

    def button_down(id)
      case id
      when Gosu::MS_WHEEL_UP
        @zoom = (@zoom + 0.25).clamp(@min_zoom, @max_zoom)
      when Gosu::MS_WHEEL_DOWN
        @zoom = (@zoom - 0.25).clamp(@min_zoom, @max_zoom)
      when Gosu::MS_MIDDLE
        @drag_start = window.mouse - @position
      end
    end

    def button_up(id)
      case id
      when Gosu::MS_MIDDLE
        @drag_start = nil
      end
    end

    def to_a
      [@position.x, @position.y, @zoom]
    end
  end
end