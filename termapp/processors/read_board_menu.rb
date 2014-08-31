# Corresponding Processor of LocoMenu::Item.new('Read', :read_board_menu). Print
# the Post list of current Board.
class ReadBoardMenu < TermApp::Processor
  def process
    term.erase_body
    cur_board = term.current_board
    if cur_board
      posts = cur_board.post.order('num desc').limit(term.lines - 5)
      posts.reverse.each_with_index do |x, i|
        strs = []
        strs << format('%6d', x.num)
        strs << format('%-12s', x.writer.nickname)
        strs << x.created_at.strftime('%m/%d') # Date
        strs << '????' # View count
        strs << x.title.unicode_slice(term.columns-32)
        term.mvaddstr(i + 4, 1, strs.join(' '))
      end
    else
      term.mvaddstr(8, 8, '보드를 먼저 선택해 주세요')
    end
    term.refresh
    term.getch
    :loco_menu
  end
end
