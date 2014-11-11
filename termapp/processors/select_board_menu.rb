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
        key = term.get_wch
        term.clrtoeol(3)
        control, *args = process_key(key)
        case control
        when :break then break args
        when :beep  then term.beep
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
    # key - An Array of key input which is returned from term.get_wch.
    #
    # Examples
    #
    #   process_key(term.get_wch)
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
      case key_symbol(key)
      when :tab, :space
        return :beep unless selected_completable_board?
        @selected << @cur_boards.first
        @str = @selected.last.path_name
      when :esc
        return :break, :loco_menu
      when :enter
        return :beep unless selected_readable_board?
        # TODO : for now, only allow selecting non-dir boards
        term.current_board = @cur_boards.first
        # TODO : for now, return to loco menu
        return :break, :loco_menu, :read_board_menu # focus read menu
      when :backspace
        if @selected.size > 0 && @str == @selected.last.path_name
          @past_boards = @cur_boards
          @cur_boards = [@selected.pop]
        end
        @str = @str[0..-2]
      else
        return :beep if key[0] == Ncurses::OK && !matched?(key[2])
      end
    end

    # Check if the name of the selected board can be completed.
    #
    # Returns the Boolean whether the name can be completed.
    def selected_completable_board?
      @cur_boards.size == 1 && @str != @cur_boards.first.path_name
    end

    # Check if the selected board is non-dir.
    #
    # Returns the Boolean whether the selected board is non-dir.
    def selected_readable_board?
      @cur_boards.size == 1 && !@cur_boards.first.is_dir
    end

    # Check whether the Boards exists of which the name with current string and
    # entered key.
    #
    # char - The Character input user entered.
    #
    # Returns the Boolean whether the matched Boards exist or not.
    def matched?(char)
      matched = @list.select { |x| x.path_name.start_with?(@str + char) }
      return false unless matched.size > 0
      @past_boards = @cur_boards
      @cur_boards = matched
      @str += char
      true
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
        print_item(@past_boards.first, past_board) if past_board
        print_item(@cur_boards.first, cur_board, reverse: true) if cur_board
      else
        term.erase_body
        list.each_with_index do |board, i|
          print_item(board, i, reverse: board == @cur_boards.first)
        end
        @list = list
      end
    end

    # See Processor#item_title.
    #
    # board - The Board instance to print.
    #
    # Returns the String path of the Board.
    def item_title(board)
      board.path_name
    end
  end
end
