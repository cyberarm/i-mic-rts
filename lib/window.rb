class IMICRTS
  class Window < CyberarmEngine::Engine
    def setup
      Gosu.milliseconds # Start counter

      self.caption = "I-MIC RTS (#{Gosu.language})"
      push_state(Boot)
      # push_state(MainMenu)
    end
  end
end