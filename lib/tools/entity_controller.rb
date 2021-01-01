class IMICRTS
  # Handles entity de/selection and basic move order
  class EntityController < Tool
    def setup
      @drag_start = CyberarmEngine::Vector.new
      @box_color = 0xaa99ff99
      @box_border_size = 2
    end

    def draw
      return unless @box

      Gosu.draw_rect(@box.min.x, @box.min.y, @box.width, @box_border_size, @box_color, ZOrder::SELECTION_BOX)
      Gosu.draw_rect(@box.min.x + @box.width, @box.min.y, @box_border_size, @box.height, @box_color, ZOrder::SELECTION_BOX)
      Gosu.draw_rect(@box.min.x, @box.min.y + @box.height, @box.width, @box_border_size, @box_color, ZOrder::SELECTION_BOX)
      Gosu.draw_rect(@box.min.x, @box.min.y, @box_border_size, @box.height, @box_color, ZOrder::SELECTION_BOX)
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
        unless @player.selected_entities.empty?
          if @player.selected_entities.any? { |ent| ent.component(:movement) }
            @director.schedule_order(Order::MOVE, @player.id, @player.camera.transform(@game.window.mouse))

            @game.overlays << Game::Overlay.new(get_image("#{IMICRTS::ASSETS_PATH}/cursors/move.png"), @player.camera.transform(@game.window.mouse), 0, 255)
            @game.overlays.last.position.z = ZOrder::OVERLAY
          elsif @player.selected_entities.size == 1 && @player.selected_entities.first.component(:waypoint)
            @director.schedule_order(Order::BUILDING_SET_WAYPOINT, @player.id, @player.selected_entities.first.id, @player.camera.transform(@game.window.mouse))

            @game.overlays << Game::Overlay.new(get_image("#{IMICRTS::ASSETS_PATH}/cursors/move.png"), @player.camera.transform(@game.window.mouse), 0, 255)
            @game.overlays.last.position.z = ZOrder::OVERLAY
          end
        end
      end
    end

    def button_up(id)
      case id
      when Gosu::MS_RIGHT
      when Gosu::MS_LEFT
        @box = nil
        @selection_start = nil

        return if @game.sidebar.hit?(@game.window.mouse_x, @game.window.mouse_y)

        diff = (@player.selected_entities - @game.selected_entities)
        @game.sidebar_actions.clear

        @director.schedule_order(Order::DESELECTED_UNITS, @player.id, diff) if diff.size.positive?
        if @game.selected_entities.size.positive?
          @director.schedule_order(Order::SELECTED_UNITS, @player.id, @game.selected_entities)
        else
          pick_entity
        end

        if @game.selected_entities.size < 2 && ent = @game.selected_entities.first
          return unless ent.component(:sidebar_actions)

          @game.sidebar_actions.clear do
            ent.component(:sidebar_actions).actions.each do |action|
              @game.button action.label, tip: action.description, width: 1.0 do
                action.block&.call
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
