# Corresponding Processor of LocoMenu::Item.new('Select', :select_board_menu).
# User can navigate Boards and select a Board.
class SelectBoardMenu < TermApp::Processor
  def process
    str = ''
    cur_boards = []
    past_board = nil
    selected = []
    past_list = nil
    loop do
      # TODO : consider setting start point as locoterm.current_board
      if str == ''
        past_board = cur_boards.first
        cur_boards = []
      end
      if selected.last.nil? || selected.last.is_dir
        list = Board.get_list(parent_board: selected.last)
      else
        list = Board.get_list(parent_board: selected[-2])
      end
      if past_list && past_list == list
        # If past_board is nil, past_idx will be also nil.
        past_idx = past_list.index(past_board)
        cur_idx = past_list.index(cur_boards.first)
        if past_idx
          term.mvaddstr(past_idx + 4, 3, past_board.path_name)
        end
        if cur_idx
          term.color_black(reverse: true) do
            term.mvaddstr(cur_idx + 4, 3, cur_boards.first.path_name)
          end
        end
      else
        term.erase_body
        list.each_with_index do |x, i|
          if x == cur_boards.first
            term.color_black(reverse: true) do
              term.mvaddstr(i + 4, 3, x.path_name)
            end
          else
            term.mvaddstr(i + 4, 3, x.path_name)
          end
        end
        past_list = list
      end
      term.mvaddstr(3, 1, "select board : #{str}")
      term.refresh
      c = term.getch
      term.clrtoeol(3)
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
          past_board = cur_boards.first
          cur_boards = [selected[-1]]
          selected = selected[0..-2]
        end
        str = str[0..-2]
      else
        next unless c < 127
        matched = list.select { |x| x.path_name.starts_with? str + c.chr }
        if matched.size > 0
          past_board = cur_boards.first
          cur_boards = matched
          str += c.chr
        else
          term.beep
        end
      end
    end
  end
end
