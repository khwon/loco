# Corresponding Processor of LocoMenu::Item.new('Select', :select_board_menu).
# User can navigate Boards and select a Board.
class SelectBoardMenu < TermApp::Processor
  def process
    str = ''
    @cur_boards = []
    @past_boards = nil
    @list = nil
    selected = []
    loop do
      # TODO : consider setting start point as locoterm.current_board
      if str == ''
        @past_boards = @cur_boards
        @cur_boards = []
      end
      list = if selected.last.nil? || selected.last.is_dir
               Board.get_list(parent_board: selected.last)
             else
               Board.get_list(parent_board: selected[-2])
             end
      print_boards(list)
      term.mvaddstr(3, 1, "select board : #{str}")
      term.refresh
      c = term.getch
      term.clrtoeol(3)
      case c
      when 9, 32 # tab, space
        unless @cur_boards.size == 1 && str != @cur_boards.first.path_name
          next term.beep
        end
        selected << @cur_boards.first
        str = selected.last.path_name
      when 27 # esc
        break :loco_menu
      when Ncurses::KEY_ENTER, 10 # enter
        next term.beep unless @cur_boards.size == 1 && !@cur_boards.first.is_dir
        # TODO : for now, only allow selecting non-dir boards
        term.current_board = @cur_boards.first
        # TODO : for now, return to loco menu
        break :loco_menu
      when 127, Ncurses::KEY_BACKSPACE
        if selected.size > 0 && str == selected.last.path_name
          @past_boards = @cur_boards
          @cur_boards = [selected.pop]
        end
        str = str[0..-2]
      else
        next unless c < 127
        matched = @list.select { |x| x.path_name.starts_with? str + c.chr }
        next term.beep unless matched.size > 0
        @past_boards = @cur_boards
        @cur_boards = matched
        str += c.chr
      end
    end
  end

  # Print given Board list. Current Board is printed in reversed color. Refresh
  # only changed lines if previous list exists and is same with passed list.
  #
  # list - The Array of Board to print.
  #
  # Returns nothing.
  def print_boards(list)
    if @list && @list == list
      past_board = @list.index(@past_boards.first)
      cur_board = @list.index(@cur_boards.first)
      if past_board
        term.mvaddstr(past_board + 4, 3, @past_boards.first.path_name)
      end
      if cur_board
        term.color_black(reverse: true) do
          term.mvaddstr(cur_board + 4, 3, @cur_boards.first.path_name)
        end
      end
    else
      term.erase_body
      list.each_with_index do |x, i|
        if x == @cur_boards.first
          term.color_black(reverse: true) do
            term.mvaddstr(i + 4, 3, x.path_name)
          end
        else
          term.mvaddstr(i + 4, 3, x.path_name)
        end
      end
      @list = list
    end
  end
end
