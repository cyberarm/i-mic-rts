require "base64"

begin
  require "cyberarm_engine"
rescue LoadError
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
end

require_relative "lib/states/boot"
require_relative "lib/states/main_menu"

class Window < CyberarmEngine::Engine
  def setup
    self.caption = "I-MIC RTS (#{Gosu.language})"
    push_state(Boot)
  end
end

# Window.new(Gosu.screen_width, Gosu.screen_height, true).show
Window.new(Gosu.screen_width, Gosu.screen_height, false).show