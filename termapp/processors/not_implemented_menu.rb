class NotImplementedMenu < TermApp::Processor
  def initialize(name, *args)
    @name = name
    super(*args)
  end

  def process
    term.erase_body
    term.mvaddstr(5, 5, "#{@name}: Not supported yet")
    term.refresh
    term.getch
    :loco_menu
  end
end
