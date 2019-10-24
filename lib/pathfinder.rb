class IMICRTS
  class Pathfinder
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/pathfinding/*.rb").each do |pathing_method|
  require_relative pathing_method
end