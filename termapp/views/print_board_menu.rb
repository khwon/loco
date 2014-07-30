class PrintBoardMenu < TermApp::View
  def process
    term.erase_body
    Board.get_list(parent_board: term.current_board).each_with_index do |x, i|
      term.mvaddstr(i + 4, 3, x.path_name)
    end
    term.mvaddstr(3, 20, 'Press any key..')
    term.getch
    :loco_menu
  end
end