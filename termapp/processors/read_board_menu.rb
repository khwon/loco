# Corresponding Processor of LocoMenu::Item.new('Read', :read_board_menu). Print
# the Post list of current Board.
class ReadBoardMenu < TermApp::Processor
  def process
    term.erase_body
    if term.current_board
      term.current_board.post.each_with_index do |x, i|
        term.mvaddstr(i + 4, 1, "#{format('%8d', x.num)} #{x.title}")
      end
    else
      term.mvaddstr(8, 8, '보드를 먼저 선택해 주세요')
    end
    term.getch
    :loco_menu
  end
end
