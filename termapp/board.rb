require 'ncursesw'
def select_board(locoterm)
  str = ''
  auto_completion = false
  cur_board = nil
  loop do
    cur_board = nil if str == ''
    locoterm.erase_body
    locoterm.mvaddstr(2, 1, 'autocompletion not supported') if auto_completion
    auto_completion = false
    list = Board.get_list
    list.each_with_index do |x, i|
      #TODO : redraw only changed lines
      if x == cur_board
        locoterm.set_color(LocoTerm::COLOR_BLACK, reverse: true) do
          locoterm.mvaddstr(i + 4, 3, x.path_name)
        end
      else
        locoterm.mvaddstr(i + 4, 3, x.path_name)
      end
    end
    locoterm.mvaddstr(3, 1, "select board : #{str}")
    locoterm.refresh
    c = locoterm.getch
    locoterm.clrtoeol(2)
    case c
    when 9, 32 # tab, space
      auto_completion = true
    when 27 # esc
      return
    when 127, Ncurses::KEY_BACKSPACE
      str = str[0..-2]
    else
      if c < 127
        matched = list.find_all { |x| x.path_name.starts_with? str + c.chr }
        if matched.size > 0
          cur_board = matched.first
          str += c.chr
        else
          locoterm.beep
        end
      end
    end
  end
end
