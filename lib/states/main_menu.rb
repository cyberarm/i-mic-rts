class MainMenu < CyberarmEngine::GuiState
  def setup
    self.show_cursor = true

    @container = stack do
      background 0xff00aa00

      flow do

        stack(height: 1.0) do
          background Gosu::Color.rgba(50, 50, 50, 200)
          button("Play")
          button("About")
          button("Exit") do
            $window.close
          end
        end

        stack do
          image("assets/logo.png", height: 275) do
            pop_state if previous_state
          end
        end

        stack do
          background Gosu::Color.rgba(50, 50, 50, 200)

          1.times do
            label "Username"
            @username = edit_line ""
            label "Password"
            @password = edit_line "", type: :password

            check_box "Remember me?", checked: true

            flow do
              button "Log In" do
                push_state(Boot)
                puts "Logging in... #{@username.value}:#{Base64.encode64(@password.value)}"
              end
              button "Sign Up"

            end
          end
        end
      end
    end

    $window.width = @container.width
    $window.height = @container.height
    $window.fullscreen = false
  end
end