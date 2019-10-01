begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/window"
require_relative "lib/camera"

require_relative "lib/states/boot"
require_relative "lib/states/game"
require_relative "lib/states/closing"
require_relative "lib/states/about_menu"
require_relative "lib/states/main_menu"

require_relative "lib/zorder"
require_relative "lib/entity"
# require_relative "lib/entities/"

IMICRTS::Window.new(width: Gosu.screen_width, height: Gosu.screen_height, fullscreen: true).show