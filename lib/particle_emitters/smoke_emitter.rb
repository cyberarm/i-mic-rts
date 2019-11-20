class IMICRTS
  class SmokeEmitter < ParticleEmitter
    def setup
      @time_to_live = Float::INFINITY
      @particle_time_to_live = 2_500
      @frequency = 10.0
      @color = Gosu::Color.rgba(255, 255, 255, 255.0 * 0.4)
      @direction = CyberarmEngine::Vector.up
      @direction.y = 4.5
      @jitter = 25.0

      @images = Gosu::Image.load_tiles("#{IMICRTS::ASSETS_PATH}/smoke/smoke.png", 32, 32, retro: false)
    end

    def emit
      super

      @particles.last.factor = CyberarmEngine::Vector.new(0.1, 0.1)
    end

    def update
      super

      @particles.each do |particle|
        life_cycle = (Gosu.milliseconds - particle.born_at.to_f) / particle.time_to_live
        scale = (2.0 * life_cycle) + 0.25
        particle.factor.x = scale
        particle.factor.y = scale

        particle.color.alpha = ((255.0 * (1.0 - life_cycle)) - 255.0 * 0.4).clamp(0.0, 255.0)
        particle.angle += rand(0.1..0.5)

        particle.direction.x = Math.cos(Gosu.milliseconds / 1_000.0) * 0.162
      end
    end
  end
end