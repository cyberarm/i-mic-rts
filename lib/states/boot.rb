class Boot < CyberarmEngine::GameState
  def setup
    @title = Gosu::Font.new(56, name: "Noto Sans Display", bold: true)
    @text  = Gosu::Font.new(18, name: "Noto Sans Thaana", bold: true)
    @name = "I-MIC RTS"
    @logo = Gosu::Image.new("../../Documents/Inkscape/ruby_clan_logo-i_mic_rts.png")

    @messages = ["Loading", "Compiling Protons", "Launching Warhead", "git push origin --force"]
    @messages_index = 0
    @status = @messages[@messages_index]

    @last_update = Gosu.milliseconds
    @update_interval = 250

    @background     = Gosu::Color.new(0x007a0d71)
    @background_two = Gosu::Color.new(0x007b6ead)

    @boot_life = 5_000
    @boot_started = Gosu.milliseconds
  end

  def draw
    Gosu.draw_quad(
      0, 0, @background_two,
      $window.width, 0, @background,
      0, $window.height, @background,
      $window.width, $window.height, @background_two
    )

    Gosu.draw_rect(
      0, $window.height/2 - 35,
      $window.width, 71,
      Gosu::Color.new(0xff949dad)
    )

    c = Gosu::Color.new(0xff55dae1)
    c2 = Gosu::Color.new(0xff3c9ec5)
    Gosu.draw_quad(
      0, $window.height/2 - 30, c,
      $window.width, $window.height/2 - 30, c2,
      0, $window.height/2 + 30, c,
      $window.width, $window.height/2 + 30, c2
    )


    @logo.draw($window.width/2 - @logo.width/2, $window.height/2 - (@logo.height/3 + 14), 0)

    @text.draw_text(@status, $window.width - (@text.text_width(@status.gsub(".", "")) + @text.text_width("...")), $window.height - @text.height, 0)
  end

  def update
    @background.alpha+=1
    @background_two.alpha+=1

    if Gosu.milliseconds > @boot_started + @boot_life
      push_state(MainMenu)
    end

    if Gosu.milliseconds > @last_update + @update_interval
      @last_update = Gosu.milliseconds


      split = @status.scan(".")
      if split.size >= 3
        @messages_index+=1
        @messages_index = 0 unless @messages_index < @messages.size
        @status = @messages[@messages_index]
      else
        @status = "#{@status}."
      end
    end
  end
end