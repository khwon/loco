module TermApp
  # Corresponding Processor of MenuItem.new('Welcome'). Processed when
  # user logged in. Print welcome message to screen.
  class WelcomeMenu < Processor
    def process
      term.erase
      term.mvaddstr(15, 30, 'welcome to new loco!')
      term.refresh
      term.get_wch
      :main_menu
    end
  end
end
