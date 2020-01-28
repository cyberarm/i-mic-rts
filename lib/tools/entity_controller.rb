class IMICRTS
  # Handles entity de/selection and basic move order
  class EntityController < Tool
    def setup
      @drag_start = CyberarmEngine::Vector.new
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
        if @game.selected_entities.size > 0
          @director.schedule_order(Order::MOVE, @player.id, @player.camera.transform(@game.window.mouse))

          @game.overlays << Game::Overlay.new(Gosu::Image.new("#{IMICRTS::ASSETS_PATH}/cursors/move.png"), @player.camera.transform(@game.window.mouse), 0, 255)
          @game.overlays.last.position.z = ZOrder::OVERLAY
        end
      end
    end

    def button_up(id)
      case id
      when Gosu::MS_RIGHT
      when Gosu::MS_LEFT
        @box = nil
        @selection_start = nil

        diff = (@player.selected_entities - @game.selected_entities)
        @game.sidebar_actions.clear

        @director.schedule_order(Order::DESELECTED_UNITS, @player.id, diff) if diff.size > 0
        if @game.selected_entities.size > 0
          @director.schedule_order(Order::SELECTED_UNITS, @player.id, @game.selected_entities)
        else
          pick_entity
        end

        if @game.selected_entities.size < 2 && ent = @game.selected_entities.first
          return unless ent.component(:sidebar_actions)

          @game.sidebar_actions.clear do
            ent.component(:sidebar_actions).actions.each do |action|
              @game.button action.label, tip: action.description, width: 1.0 do
                action.block.call if action.block
              end
            end
          end
        end
      end
    end

    def pick_entity
      transform = @player.camera.transform(@game.window.mouse)

      found = @player.entities.find do |ent|
        transform.distance(ent.position) <= ent.radius
      end

      if found
        @game.selected_entities = [found]
        @director.schedule_order(Order::SELECTED_UNITS, @player.id, @game.selected_entities)
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
        @game.selected_entities = @game.selected_entities.union(selected_entities)
      else
        @game.selected_entities = selected_entities
      end
    end
  end
end
