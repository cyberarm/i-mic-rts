begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require_relative "lib/version"
require_relative "lib/window"
require_relative "lib/camera"

require_relative "lib/states/boot"
require_relative "lib/states/game"
require_relative "lib/states/closing"
require_relative "lib/states/menus/main_menu"
require_relative "lib/states/menus/credits_menu"
require_relative "lib/states/menus/settings_menu"
require_relative "lib/states/menus/solo_play_menu"
require_relative "lib/states/menus/multiplayer_menu"
require_relative "lib/states/menus/solo_lobby_menu"
require_relative "lib/states/menus/multiplayer_lobby_menu"

require_relative "lib/zorder"
require_relative "lib/entity"
# require_relative "lib/entities/"

IMICRTS::Window.new(width: Gosu.screen_width / 4 * 3, height: Gosu.screen_height / 4 * 3, fullscreen: false, resizable: true).show