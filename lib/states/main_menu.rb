class MainMenu < CyberarmEngine::GameState
  def setup
    self.show_cursor = true

    background 0xff7a0d71
    stack do
      background 0xaabada55

      flow(padding: 10, margin: 10) do
        # background 0xff00aa00

        stack do
          # background 0xffaa0000
          # fill Gosu::Color::BLACK
          button("Play")
          button("About")
          button("Exit") do
            $window.close
          end
        end

        stack do
          image("assets/logo.png", height: 256) do
            pop_state
          end
        end

        stack do
          background Gosu::Color.rgba(50, 50, 50, 200)

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
          end
        end
      end
    end

    $window.width = @root_container.children.first.width.to_i
    $window.height = @root_container.children.first.height.to_i
  end
end