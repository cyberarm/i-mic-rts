class MainMenu < CyberarmEngine::GameState
  def setup
    self.show_cursor = true

    background 0xff7a0d71
    stack do
      background 0xaabada55

      flow(padding: 10, margin: 10) do
        # background 0xff00aa00

        stack do
          background 0xffaaeedd
          # fill Gosu::Color::BLACK
          button("Play")
          button("About")
          button("Exit") do
            $window.close
          end
        end

        stack do
          image("assets/logo.png", height: 256) do
            pop_state if last_state
          end
        end

        stack do
          background Gosu::Color.rgba(50, 50, 50, 200)

          1.times do
            label "Username"
            @username = edit_line ""
            label "Password"
            @password = edit_line "", type: :password

            flow do
              button "Log In" do
                push_state(Boot)
                puts "Logging in... #{@username.value}:#{Base64.encode64(@password.value)}"
              end
              button "Sign Up"

              check_box checked: true
            end
          end
        end
      end
    end

    $window.width = Gosu.screen_width/2
    $window.height = Gosu.screen_height/2
    $window.fullscreen = false

    @root_container.recalculate
  end
end