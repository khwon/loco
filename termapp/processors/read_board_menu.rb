# Corresponding Processor of LocoMenu::Item.new('Read', :read_board_menu). Print
# the Post list of current Board.
class ReadBoardMenu < TermApp::Processor
  def process
    term.erase_body
    cur_board = term.current_board
    if cur_board
      posts = cur_board.post.order('num desc').limit(term.lines - 5)
      posts.reverse.each_with_index do |x, i|
        str = format('%8d', x.num)
        str += format(' %13s', x.writer.nickname)
        str += '??' # Date
        str += '??' # View count
        str += x.title
        term.mvaddstr(i + 4, 1, str)
      end
    else
      term.mvaddstr(8, 8, '보드를 먼저 선택해 주세요')
    end
    term.getch
    :loco_menu
  end
end
