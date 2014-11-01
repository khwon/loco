module TermApp
  # Corresponding Processor of LocoMenu::Item.new('Read', :read_board_menu).
  # Print the Post list of current Board.
  class ReadBoardMenu < Processor
    def process
      term.erase_body
      unless term.current_board
        print_select_board
        return :loco_menu
      end
      process_init
      term.noecho
      result = loop do
        sanitize_current_index
        print_posts
        @past_index = @cur_index
        control, *args = process_key(term.get_wch)
        case control
        when :break       then break args
        when :beep        then term.beep
        when :scroll_down then scroll(:down, *args)
        when :scroll_up   then scroll(:up, *args)
        when :read        then read_post(args[0])
        end
      end
      term.echo
      result
    end

    private

    # Initialize instance variables before actual processing.
    #
    # Returns nothing.
    def process_init
      cur_board = term.current_board
      @cur_index = nil
      @past_index = nil
      @num_lists = term.lines - 5
      @posts = cur_board.post.order('num desc').limit(@num_lists).reverse
      @edge_posts = [cur_board.post.first, cur_board.post.last]
    end

    # Process key input for ReadBoardMenu.
    #
    # key - An aray of key input which is returned from term.get_wch.
    #
    # Returns nil or a Symbol :beep, :scroll_down, :scroll_up or :break with
    #   additional arguments.
    def process_key(key)
      if key[0] == Ncurse::OK
        case key[1]
        when 27, 113 # ESC, q
          return :break, :loco_menu
        when 10, 32 # enter, space
          return :break, :loco_menu unless @posts[@cur_index]
          return :read, @posts[@cur_index]
        when 74 # J
          return :beep # TODO : scroll to end of list
        when 21, 80 # ctrl+u, P
          return :scroll_up, preserve_position: true
        when 4, 78 # ctrl+d, N
          return :scroll_down, preserve_position: true
        when 106 # j
          return :scroll_down if @cur_index == @num_lists - 1
          @cur_index += 1
        when 107 # k
          return :scroll_up if @cur_index == 0
          @cur_index -= 1
        end
      elsif key[0] == Ncurse::KEY_CODE_YES
        case key[1]
        when Ncurses::KEY_DOWN
          return :scroll_down if @cur_index == @num_lists - 1
          @cur_index += 1
        when Ncurses::KEY_UP
          return :scroll_up if @cur_index == 0
          @cur_index -= 1
        end
      end
      return :beep
    end

    # Ensure the current index is not out of the range.
    #
    # Returns nothing.
    def sanitize_current_index
      return unless @cur_index.nil? || @cur_index >= @num_lists
      @cur_index = @num_lists - 1
    end

    # Check if the page can be scrolled with given direction.
    #
    # direction - A Symbol one of :down or :up.
    #
    # Returns a Boolean whether the page can be scrolled.
    def scrollable?(direction)
      case direction
      when :down
        pivot = @posts[-1]
        return pivot && pivot != @edge_posts[1]
      when :up
        pivot = @posts[0]
        return pivot && pivot != @edge_posts[0]
      end
    end

    # Scroll the page of Posts.
    #
    # direction - A Symbol indicates direction. It can be :down or :up.
    # options   - The Hash options used to control position of cursor
    #             (default: { preserve_position: false }).
    #             :preserve_position - The Boolean whether to preserve current
    #                                  position of cursor or not (optional).
    #
    # Examples
    #
    #   scroll(:down)
    #
    #   scroll(:up, preserve_position: true)
    #
    # Returns nothing.
    def scroll(direction, preserve_position: false)
      unless scrollable?(direction)
        term.beep
        return
      end
      cur_board = term.current_board
      @past_index = nil
      case direction
      when :down
        @cur_index = 1 unless preserve_position
        @posts = cur_board.posts_from(@posts[-1].num, @num_lists)
        if @posts.size < @num_lists # reached last
          @cur_index = @num_lists - @posts.size + 1 unless preserve_position
          @posts = cur_board.post.order('num desc').limit(@num_lists).reverse
        end
      when :up
        @cur_index = @num_lists - 2 unless preserve_position
        @posts = cur_board.posts_to(@posts[0].num, @num_lists)
        if @posts.size < @num_lists # reached first
          @cur_index = @posts.size - 2 unless preserve_position
          @posts = cur_board.post.order('num asc').limit(@num_lists)
        end
      end
    end

    # Display message saying select the board first.
    #
    # Returns nothing.
    def print_select_board
      term.mvaddstr(8, 8, '보드를 먼저 선택해 주세요')
      term.get_wch
    end

    # Print Post list. Current Post is displayed in reversed color. Refresh only
    # highlighted lines if the list hasn't been scrolled.
    #
    # Returns nothing.
    def print_posts
      if @past_index.nil?
        term.erase_body
        @posts.each_with_index do |post, i|
          print_post(post, i, reverse: @cur_index == i)
        end
      else
        return if @past_index == @cur_index
        print_post(@posts[@past_index], @past_index)
        print_post(@posts[@cur_index], @cur_index, reverse: true)
      end
      term.mvaddstr(@cur_index + 4, 0, '>')
      term.refresh
    end

    # Print a given Post to terminal.
    #
    # post    - The Post instance to print.
    # index   - The Integer position of Post in list.
    # options - The Hash options used to control background color (default:
    #           { reverse: false }).
    #           :reverse - The Boolean whether to reverse the foreground and
    #                      background color or not (optional).
    def print_post(post, index, reverse: false)
      term.color_black(reverse: reverse) do
        term.mvaddstr(index + 4, 0, post.format_for_term(term.columns - 32))
      end
    end

    # Display a given Post on terminal.
    #
    # post - The Post instance to read.
    #
    # Returns nothing.
    def read_post(post)
      @past_index = nil # redraw list
      read_post_helper = ReadPostHelper.new(@app, post)
      _control, *_args = read_post_helper.show
    end
  end
end
