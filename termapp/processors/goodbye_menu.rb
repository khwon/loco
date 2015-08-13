module TermApp
  # Corresponding Processor of MenuItem.new('Goodbye'). Terminate the
  # Application after processing.
  class GoodbyeMenu < Processor
    def process
      term.erase
      term.mvaddstr(5, 5, 'goodbye!')
      term.refresh
      term.get_wch
      nil
    end
  end
end
