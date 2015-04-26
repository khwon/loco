module TermApp
  # Corresponding Processor of LocoMenu::Item.new('Read', :read_board_menu).
  # Print the Post list of current Board.
  class ReadBoardMenu < Processor
    def process
      term.erase_body
      print_header
      unless term.current_board
        print_select_board
        return :loco_menu
      end
      process_init
      term.noecho
      if @posts.size == 0
        print_no_post
        term.echo
        return :loco_menu
      end
      result = loop do
        sanitize_current_index
        print_posts
        @past_index = @cur_index
        control, *args = process_key(term.get_wch)
        while control
          control, *args =
            case control
            when :break then break args
            when :beep
              term.beep
              nil
            when :scroll
              scroll(*args)
              nil
            when :read
              result = read_post(args[0])
              @posts[@cur_index].read_status = 'R'
              result
            when :visit
              visit_post(args[0])
            when :write
              write_post
              process_init
              nil
            when :reply
              write_post(args[0])
              process_init
              nil
            when :read_next
              if @cur_index == @list_size - 1 && !scrollable?(:down)
                nil
              else
                if @cur_index == @list_size - 1
                  scroll :down
                else
                  @cur_index += 1
                end
                [:read, @posts[@cur_index]]
              end
            when :read_prev
              if @cur_index == 0 && !scrollable?(:up)
                nil
              else
                if @cur_index == 0
                  scroll :up
                else
                  @cur_index -= 1
                end
                [:read, @posts[@cur_index]]
              end
            when :toggle_highlighted
              toggle_highlighted(@posts[@cur_index])
            when :find_next_highlighted
              find_next_highlighted
            when :find_prev_highlighted
              find_prev_highlighted
            else
              nil
            end
        end
        break args if control == :break
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
      if @posts.size < @list_size
        @list_size = @posts.size
      end
      cache_read_status
      @edge_posts = [cur_board.post.first, cur_board.post.last]
    end

    # Process key input for ReadBoardMenu.
    #
    # key - An Array of key input which is returned from term.get_wch.
    #
    # Returns nil or a Symbol :beep, :scroll_down, :scroll_up or :break with
    #   additional arguments.
    def process_key(key)
      tmp_num = @num || ''
      @num = ''
      case KeyHelper.key_symbol(key)
      when :esc, :q, :e
        return :break, :loco_menu
      when :space, :r
        return :break, :loco_menu unless @posts[@cur_index]
        return :read, @posts[@cur_index]
      when :R
        return :reply, @posts[@cur_index]
      when :v
        return :visit, @posts[@cur_index]
      when :enter
        @pivot = term.current_board.post.find_by_num(tmp_num.to_i)
        return :scroll, :around if @pivot
        return :beep
      when :'$'
        return :scroll, :bottom
      when :ctrl_u, :P
        return :scroll, :up, preserve_position: true
      when :ctrl_d, :N
        return :scroll, :down, preserve_position: true
      when :j, :down, :n
        return :scroll, :down if @cur_index == @list_size - 1
        @cur_index += 1
      when :k, :up, :p
        return :scroll, :up if @cur_index == 0
        @cur_index -= 1
      when :o
        return :toggle_highlighted
      when :ctrl_p
        return :write
      when :J
        return :find_next_highlighted
      when :K
        return :find_prev_highlighted
      when *(0..9).map(&:to_s).map(&:to_sym)
        @num = tmp_num
        @num += key[2]
        return :nothing
      else
        return :beep
      end
    end

    def cache_read_status
      board = term.current_board
      board = board.alias_board while board.alias_board
      vr_max = VisitreadMax.find_by(user_id: term.current_user.id,
                                    board_id: board.id)
      vr_max_num = vr_max ? vr_max.num : 0

      if @posts.size > 0
        read_status = BoardRead.where('user_id = ? and board_id = ?',
                                      term.current_user.id, board.id)
                      .where('posts && int4range(?,?)',
                             @posts.first.num, @posts.last.num + 1)
        @posts.each do |post|
          st = read_status.find do |x|
            x.posts.include? post.num
          end
          if st
            post.read_status = st[:status]
          elsif post.num <= vr_max_num
            post.read_status = 'V'
          end
        end
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
      when :around
        return true
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
        case direction
        when :bottom, :down
          @cur_index = @list_size - 1
        when :up
          @cur_index = 0
        else
          term.beep
        end
        return
      end
      cur_board = term.current_board
      @past_index = nil
      case direction
      when :bottom
        @cur_index = @list_size - 1
        @posts = cur_board.post.order('num desc').limit(@list_size).reverse
        cache_read_status
      when :down
        @cur_index = 1 unless preserve_position
        @posts = cur_board.posts_from(@posts[-1].num, @list_size)
        if @posts.size < @list_size # reached last
          @cur_index = @list_size - @posts.size + 1 unless preserve_position
          @posts = cur_board.post.order('num desc').limit(@list_size).reverse
        end
        cache_read_status
      when :up
        @cur_index = @list_size - 2 unless preserve_position
        @posts = cur_board.posts_to(@posts[0].num, @list_size)
        if @posts.size < @list_size # reached first
          @cur_index = @posts.size - 2 unless preserve_position
          @posts = cur_board.post.order('num asc').limit(@list_size)
        end
        cache_read_status
      when :around
        if cur_board.post.where('num <= ?', @pivot.num).count <= @list_size / 2
          # goto first page
          @posts = cur_board.post.order('num asc').limit(@list_size)
          @cur_index = @posts.index(@pivot)
        elsif cur_board.post.where('num >= ?', @pivot.num).count <=
              @list_size / 2
          # goto last page
          @posts = cur_board.post.order('num desc').limit(@list_size).reverse
          @cur_index = @posts.index(@pivot)
        else
          @posts = cur_board.posts_to(@pivot.num, @list_size / 2)
          @posts += cur_board.post.order('num asc').where('num > ?', @pivot.num)
                    .limit(@list_size - @posts.size)
          @cur_index = @posts.index(@pivot)
        end
        cache_read_status
      end
    end

    def toggle_highlighted(post)
      if post
        post.highlighted = !post.highlighted
        post.save!
        print_item(@posts[@cur_index], @cur_index, x: 0, reverse: true)
        term.mvaddstr(@cur_index + 4, 0, '>')
        term.refresh
      end
    end

    def find_next_highlighted
      cur_board = term.current_board
      num = @posts[@cur_index].num
      @pivot = cur_board.post.where('num > ?', num)
               .where(highlighted: true)
               .order('num asc').limit(1).first
      if @pivot
        return :scroll, :around
      else
        term.beep
      end
    end

    def find_prev_highlighted
      cur_board = term.current_board
      num = @posts[@cur_index].num
      @pivot = cur_board.post.where('num < ?', num)
               .where(highlighted: true)
               .order('num desc').limit(1).first
      if @pivot
        return :scroll, :around
      else
        term.beep
      end
    end

    # Display message saying select the board first.
    #
    # Returns nothing.
    def print_select_board
      term.mvaddstr(8, 8, '보드를 먼저 선택해 주세요')
      term.get_wch
    end

    # Display message saying there is no post and some introduction to write a
    # new Post.
    #
    # Returns nothing.
    def print_no_post
      term.mvaddstr(10, 12, '* 현재 이 게시판에는 글이 없습니다.')
      term.mvaddstr(11, 14, '글을 쓰시려면 아무키나 누르신 후')
      term.mvaddstr(13, 14, 'P를 눌러 Post 메뉴를 선택하셔서')
      term.mvaddstr(14, 14, '글을 써주시기 바랍니다.')
      term.get_wch
    end

    # Display the header of ReadBoardMenu. Contains labels for each section of
    # Post and the information of the Board.
    #
    # Returns nothing.
    def print_header
      header_str = ' 번호   글쓴이        날짜 조회수     제목' \
                   '        관리자 : '
      name = term.current_board.owner.username.unicode_slice(12)
      header_str << name + ' ' * (12 - name.size_for_print)
      term.color_black(reverse: true) do
        term.mvaddstr(3, 0, header_str)
      end
    end

    # Print Post list. Current Post is displayed in reversed color. Refresh only
    # highlighted lines if the list hasn't been scrolled.
    #
    # Returns nothing.
    def print_posts(range: nil)
      if @past_index.nil?
        term.erase_body
        print_header
        @posts.each_with_index do |post, i|
          print_item(post, i, x: 0, reverse: @cur_index == i)
        end
      elsif range
        range.each do |i|
          print_item(@posts[i], i, x: 0, reverse: @cur_index == i)
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

    def item_block(item, &block)
      if item.highlighted
        term.bold do
          block.yield
        end
      else
        block.yield
      end
    end

    # Display a given Post on terminal.
    #
    # post - The Post instance to read.
    #
    # Returns nil or a Symbol of control to process next.
    def read_post(post)
      @past_index = nil # Redraw list.
      read_post_helper = ReadPostHelper.new(@app, post)
      key = read_post_helper.read_post
      case KeyHelper.key_symbol(key)
      when :n then :read_next
      when :p then :read_prev
      when :r,:R then [:reply, post]
      else nil
      end
    end

    def visit_post(post)
      BoardRead.mark_visit(term.current_user, post, post.board)
      post.read_status = 'V' if post.read_status.nil?
      print_posts(range: [@cur_index])
    end

    # Write a new Post or reply to parent_post
    # through terminal.
    #
    # Returns nothing.
    def write_post(parent_post)
      write_helper = WriteHelper.new(@app)
      write_helper.write(parent: parent_post)
    end
  end
end
