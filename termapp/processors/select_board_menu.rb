class SelectBoardMenu < TermApp::Processor
  def process
    str = ''
    cur_boards = []
    selected = []
    loop do
      # TODO : consider setting start point as locoterm.current_board
      cur_boards = [] if str == ''
      term.erase_body
      if selected.last.nil? || selected.last.is_dir
        list = Board.get_list(parent_board: selected.last)
      else
        list = Board.get_list(parent_board: selected[-2])
      end
      list.each_with_index do |x, i|
        # TODO : redraw only changed lines
        if x == cur_boards.first
          term.color_black(reverse: true) do
            term.mvaddstr(i + 4, 3, x.path_name)
          end
        else
          term.mvaddstr(i + 4, 3, x.path_name)
        end
      end
      term.mvaddstr(3, 1, "select board : #{str}")
      term.refresh
      c = term.getch
      term.clrtoeol(2)
      case c
      when 9, 32 # tab, space
        if cur_boards.size == 1 && str != cur_boards.first.path_name
          selected << cur_boards.first
          str = selected.last.path_name
        else
          term.beep
        end
      when 27 # esc
        break :loco_menu
      when Ncurses::KEY_ENTER, 10 # enter
        if cur_boards.size == 1 && !cur_boards.first.is_dir
          # TODO : for now, only allow selecting non-dir boards
          term.current_board = cur_boards.first
          # TODO : for now, return to loco menu
          break :loco_menu
        else
          term.beep
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
            term.beep
          end
        end
      end
    end
  end
end
