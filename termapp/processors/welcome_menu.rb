# Corresponding Processor of LocoMenu::Item.new('Welcome'). Processed when user
# logged in. Print welcome message to screen.
class WelcomeMenu < TermApp::Processor
  def process
    term.erase
    term.mvaddstr(15, 30, 'welcome to new loco!')
    term.getch
    :loco_menu
  end
end
