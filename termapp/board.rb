def select_board(locoterm)
  str = ''
  cur_boards = []
  selected = []
  loop do
    # TODO : consider setting start point as locoterm.current_board
    cur_boards = [] if str == ''
    locoterm.erase_body
    if selected.last.nil? || selected.last.is_dir
      list = Board.get_list(parent_board: selected.last)
    else
      list = Board.get_list(parent_board: selected[-2])
    end
    list.each_with_index do |x, i|
      # TODO : redraw only changed lines
      if x == cur_boards.first
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
      if cur_boards.size == 1 && str != cur_boards.first.path_name
        selected << cur_boards.first
        str = selected.last.path_name
      else
        locoterm.beep
      end
    when 27 # esc
      return
    when Ncurses::KEY_ENTER, 10 # enter
      if cur_boards.size == 1 && !cur_boards.first.is_dir
        # TODO : for now, only allow selecting non-dir boards
        locoterm.current_board = cur_boards.first
        return
      else
        locoterm.beep
      end
    when 127, Ncurses::KEY_BACKSPACE
      if selected.size > 0 && str == selected.last.path_name
        cur_boards = [selected[-1]]
        selected = selected[0..-2]
      end
      str = str[0..-2]
    else
      if c < 127
        matched = list.select { |x| x.path_name.starts_with? str + c.chr }
        if matched.size > 0
          cur_boards = matched
          str += c.chr
        else
          locoterm.beep
        end
      end
    end
  end
end
