module TermApp
  # Corresponding Processor of LocoMenu::Item.new('Select', :select_board_menu).
  # User can navigate Boards and select a Board.
  class SelectBoardMenu < Processor
    def process
      process_init
      loop do
        # TODO : consider setting start point as locoterm.current_board
        if @str == ''
          @past_boards = @cur_boards
          @cur_boards = []
        end
        list = if @selected.last.nil? || @selected.last.is_dir
                 Board.get_list(parent_board: @selected.last)
               else
                 Board.get_list(parent_board: @selected[-2])
               end
        print_boards(list)
        term.mvaddstr(3, 1, "select board : #{@str}")
        term.refresh
        key = term.getch
        term.clrtoeol(3)
        control, *args = process_key(key)
        case control
        when :break
          break args
        when :beep
          term.beep
        end
      end
    end

    private

    # Initialize instance variables before actual processing.
    #
    # Returns nothing.
    def process_init
      @str = ''
      @cur_boards = []
      @past_boards = nil
      @list = nil
      @selected = []
    end

    # Process key input for SelectBoardMenu.
    #
    # key - A Integer key input which is returned from term.getch.
    #
    # Examples
    #
    #   process_key(term.getch)
    #
    #   process_key(10)
    #   # => :beep
    #
    #   process_key(27)
    #   # => [:break, :loco_menu]
    #
    # Returns nil or a Symbol which is one of :break or :beep with additional
    #   arguments.
    def process_key(key)
      case key
      when 9, 32 # Tab, Space
        unless @cur_boards.size == 1 && @str != @cur_boards.first.path_name
          return :beep
        end
        @selected << @cur_boards.first
        @str = @selected.last.path_name
      when 27 # ESC
        return :break, :loco_menu
      when Ncurses::KEY_ENTER, 10 # Enter
        return :beep unless @cur_boards.size == 1 && !@cur_boards.first.is_dir
        # TODO : for now, only allow selecting non-dir boards
        term.current_board = @cur_boards.first
        # TODO : for now, return to loco menu
        return :break, :loco_menu, :read_board_menu # focus read menu
      when 127, Ncurses::KEY_BACKSPACE
        if @selected.size > 0 && @str == @selected.last.path_name
          @past_boards = @cur_boards
          @cur_boards = [@selected.pop]
        end
        @str = @str[0..-2]
      else
        return unless key < 127
        matched = @list.select { |x| x.path_name.starts_with? @str + key.chr }
        return :beep unless matched.size > 0
        @past_boards = @cur_boards
        @cur_boards = matched
        @str += key.chr
      end
    end

    # Print given Board list. Current Board is printed in reversed color.
    # Refresh only changed lines if previous list exists and is same with passed
    # list.
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
          term.color_black(reverse: true) if x == @cur_boards.first
          term.mvaddstr(i + 4, 3, x.path_name)
          term.color_black # Reset color
        end
        @list = list
      end
    end
  end
end
