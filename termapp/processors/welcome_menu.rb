module TermApp
  # Corresponding Processor of LocoMenu::Item.new('Welcome'). Processed when
  # user logged in. Print welcome message to screen.
  class WelcomeMenu < Processor
    def process
      term.erase
      term.mvaddstr(15, 30, 'welcome to new loco!')
      term.refresh
      term.getch
      :loco_menu
    end
  end
end
