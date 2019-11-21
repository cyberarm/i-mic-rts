class IMICRTS
  class ParticleEmitter
    def initialize(position:, direction: CyberarmEngine::Vector.up, time_to_live: 1000, particle_time_to_live: 500, speed: 10.0, max_particles: 128, frequency: 10.0, images: [], color: Gosu::Color::WHITE.dup, jitter: 10.0)
      @position = position
      @direction = direction
      @time_to_live = time_to_live
      @particle_time_to_live = particle_time_to_live
      @speed = speed
      @max_particles = max_particles
      @frequency = frequency
      @images = images
      @color = color
      @jitter = jitter

      @born_at = Gosu.milliseconds
      @last_emitted_at = 0
      @particles = []
      @factor = CyberarmEngine::Vector.new(1.0 ,1.0)

      setup
    end

    def setup
    end

    def emit
      dir = @direction.clone
      dir.x = rand(-@jitter.to_f..@jitter.to_f) * 1
      dir.normalized

      @particles << Particle.new(
        position: @position, direction: dir,
        factor: @factor.clone, angle: rand(360.0),
        speed: @speed, time_to_live: @particle_time_to_live, image: @images.sample,
        color: @color.dup
      )

      @last_emitted_at = Gosu.milliseconds
    end

    def draw
      @particles.each(&:draw)
    end

    def update
      if @particles.count < @max_particles && Gosu.milliseconds >= @last_emitted_at + (1000.0 / @frequency)
        emit
      end

      @particles.each do |particle|
        @particles.delete(particle) if particle.die?
        particle.update
      end
    end

    def die?
      Gosu.milliseconds >= @born_at + @time_to_live
    end
  end

  class Particle
    attr_accessor :position, :direction, :factor, :angle, :speed, :time_to_live, :image, :color, :born_at
    def initialize(position:, direction:, factor:, angle:, speed:, time_to_live:, image:, color:)
      @position = position
      @direction = direction
      @factor = factor
      @angle = angle
      @speed = speed
      @time_to_live = time_to_live
      @image = image
      @color = color

      @born_at = Gosu.milliseconds
    end

    def draw
      @image.draw_rot(*@position.to_a[0..2], @angle, 0.5, 0.5, @factor.x, @factor.y, @color)
    end

    def update
      @position -= (@direction * @speed) * $window.dt
    end

    def die?
      Gosu.milliseconds >= @born_at + @time_to_live
    end
  end
end

Dir.glob("#{IMICRTS::GAME_ROOT_PATH}/lib/particle_emitters/**/*.rb").each do |emitter|
  require_relative emitter
end