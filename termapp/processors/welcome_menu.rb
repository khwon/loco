class WelcomeMenu < TermApp::Processor
  def process
    term.erase
    term.mvaddstr(15, 30, 'welcome to new loco!')
    term.getch
    :loco_menu
  end
end
