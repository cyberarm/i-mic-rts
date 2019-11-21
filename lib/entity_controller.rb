class IMICRTS
  # Handles entity de/selection and order manipulation
  class EntityController
    attr_reader :selected_entities
    def initialize(game:, director:, player:)
      @game = game
      @director = director
      @player = player

      @drag_start = CyberarmEngine::Vector.new
      @selected_entities = []
    end

    def draw
      Gosu.draw_rect(
        @box.min.x, @box.min.y,
        @box.width, @box.height,
        Gosu::Color.rgba(50, 50, 50, 150), ZOrder::SELECTION_BOX
      ) if @box
    end

    def update
      if @selection_start
        select_entities
      end
    end

    def button_down(id)
      case id
      when Gosu::KB_H
        ent = @player.entities.find { |ent| ent.name == :construction_yard }
        ent ||= @player.entities.find { |ent| ent.name == :construction_worker }
        ent ||= @player.starting_position

        @player.camera.move_to(
          @game.window.width / 2 - ent.position.x,
          @game.window.height / 2 - ent.position.y,
          @player.camera.zoom
        )

      when Gosu::KB_S
        @director.schedule_order(Order::STOP, @player.id)

      when Gosu::MS_LEFT
        unless @game.sidebar.hit?(@game.window.mouse_x, @game.window.mouse_y)
          @selection_start = @player.camera.transform(@game.window.mouse)
        end
      when Gosu::MS_RIGHT
        @director.schedule_order(Order::MOVE, @player.id, @player.camera.transform(@game.window.mouse))

        @game.overlays << Game::Overlay.new(Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/cursors/move.png"), @player.camera.transform(@game.window.mouse), 0, 255)
        @game.overlays.last.position.z = ZOrder::OVERLAY
      end
    end

    def button_up(id)
      case id
      when Gosu::MS_RIGHT
      when Gosu::MS_LEFT
        @box = nil
        @selection_start = nil

        diff = (@player.selected_entities - @selected_entities)

        @director.schedule_order(Order::DESELECTED_UNITS, @player.id, diff)
        @director.schedule_order(Order::SELECTED_UNITS, @player.id, @selected_entities)
      end
    end

    def select_entities
      transform = @player.camera.transform(@game.window.mouse)
      @box = CyberarmEngine::BoundingBox.new(@selection_start.xy, transform.xy)

      selected_entities = @player.entities.select do |ent|
        @box.point?(ent.position) ||
        @box.point?(ent.position - ent.radius) || @box.point?(ent.position + ent.radius)
      end

      if Gosu.button_down?(Gosu::KB_LEFT_SHIFT) || Gosu.button_down?(Gosu::KB_RIGHT_SHIFT)
        @selected_entities = @selected_entities.union(selected_entities)
      else
        @selected_entities = selected_entities
      end
    end
  end
end