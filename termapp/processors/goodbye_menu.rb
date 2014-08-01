class GoodbyeMenu < TermApp::Processor
  def process
    term.erase_all
    term.mvaddstr(5, 5, 'goodbye!')
    term.getch
    nil
  end
end
