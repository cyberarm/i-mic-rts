#!/usr/bin/env ruby

begin
  require_relative "../cyberarm_engine/lib/cyberarm_engine"
rescue LoadError
  require "cyberarm_engine"
end

require "nokogiri"

require "json"
require "socket"

require_relative "lib/version"
require_relative "lib/errors"
require_relative "lib/window"
require_relative "lib/camera"
require_relative "lib/setting"

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
require_relative "lib/component"
require_relative "lib/particle_emitter"
require_relative "lib/entity"
require_relative "lib/map"
require_relative "lib/tiled_map"
require_relative "lib/pathfinder"

require_relative "lib/order"
require_relative "lib/friendly_hash"
require_relative "lib/director"
require_relative "lib/player"
require_relative "lib/entity_controller"
require_relative "lib/connection"

require_relative "lib/networking/protocol"
require_relative "lib/networking/packet"
require_relative "lib/networking/server"
require_relative "lib/networking/client"
require_relative "lib/networking/connection"

IMICRTS::Setting.setup

IMICRTS::Window.new(width: Gosu.screen_width / 4 * 3, height: Gosu.screen_height / 4 * 3, fullscreen: false, resizable: true).show