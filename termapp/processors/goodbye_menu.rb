# Corresponding Processor of LocoMenu::Item.new('Goodbye'). Terminate the
# Application after processing.
class GoodbyeMenu < TermApp::Processor
  def process
    term.erase_all
    term.mvaddstr(5, 5, 'goodbye!')
    term.refresh
    term.getch
    nil
  end
end
