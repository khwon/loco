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
        when :break  then break args
        when :beep   then term.beep
        when :scroll then scroll(*args)
        when :read   then read_post(args[0])
        when :write
          write_post(*args)
          process_init
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
      @list_size = term.lines - 5
      @posts = cur_board.post.order('num desc').limit(@list_size).reverse
      @edge_posts = [cur_board.post.first, cur_board.post.last]
    end

    # Process key input for ReadBoardMenu.
    #
    # key - An Array of key input which is returned from term.get_wch.
    #
    # Returns nil or a Symbol :beep, :scroll_down, :scroll_up or :break with
    #   additional arguments.
    def process_key(key)
      case KeyHelper.key_symbol(key)
      when :esc, :q
        return :break, :loco_menu
      when :enter, :space
        return :break, :loco_menu unless @posts[@cur_index]
        return :read, @posts[@cur_index]
      when :J
        return :scroll, :bottom
      when :ctrl_u, :P
        return :scroll, :up, preserve_position: true
      when :ctrl_d, :N
        return :scroll, :down, preserve_position: true
      when :j, :down
        return :scroll, :down if @cur_index == @list_size - 1
        @cur_index += 1
      when :k, :up
        return :scroll, :up if @cur_index == 0
        @cur_index -= 1
      when :ctrl_p
        return :write
      else
        return :beep
      end
    end

    # Ensure the current index is not out of the range.
    #
    # Returns nothing.
    def sanitize_current_index
      return unless @cur_index.nil? || @cur_index >= @list_size
      @cur_index = @list_size - 1
    end

    # Check if the page can be scrolled with given direction.
    #
    # direction - A Symbol one of :bottom, :down or :up.
    #
    # Returns a Boolean whether the page can be scrolled.
    def scrollable?(direction)
      case direction
      when :bottom, :down
        pivot = @posts[-1]
        return pivot && pivot != @edge_posts[1]
      when :up
        pivot = @posts[0]
        return pivot && pivot != @edge_posts[0]
      end
    end

    # Scroll the page of Posts.
    #
    # direction - A Symbol indicates direction. It can be :bottom, :down or :up.
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
      when :bottom
        @cur_index = @list_size - 1
        @posts = cur_board.post.order('num desc').limit(@list_size).reverse
      when :down
        @cur_index = 1 unless preserve_position
        @posts = cur_board.posts_from(@posts[-1].num, @list_size)
        if @posts.size < @list_size # reached last
          @cur_index = @list_size - @posts.size + 1 unless preserve_position
          @posts = cur_board.post.order('num desc').limit(@list_size).reverse
        end
      when :up
        @cur_index = @list_size - 2 unless preserve_position
        @posts = cur_board.posts_to(@posts[0].num, @list_size)
        if @posts.size < @list_size # reached first
          @cur_index = @posts.size - 2 unless preserve_position
          @posts = cur_board.post.order('num asc').limit(@list_size)
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
          print_item(post, i, x: 0, reverse: @cur_index == i)
        end
      else
        return if @past_index == @cur_index
        print_item(@posts[@past_index], @past_index, x: 0)
        print_item(@posts[@cur_index], @cur_index, x: 0, reverse: true)
      end
      term.mvaddstr(@cur_index + 4, 0, '>')
      term.refresh
    end

    # See Processor#item_title.
    #
    # post - The Post instance to print.
    #
    # Returns the String title of the Post.
    def item_title(post)
      post.format_for_term(term.columns - 32)
    end

    # Display a given Post on terminal.
    #
    # post - The Post instance to read.
    #
    # Returns nothing.
    def read_post(post)
      @past_index = nil # Redraw list.
      read_post_helper = ReadPostHelper.new(@app, post)
      _control, *_args = read_post_helper.read_post
    end

    # Write a new Post through terminal.
    #
    # Returns nothing.
    def write_post
      write_helper = WriteHelper.new(@app)
      write_helper.write
    end
  end
end
