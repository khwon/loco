module TermApp
  # Corresponding Processor of LocoMenu::Item.new('Read', :read_board_menu).
  # Print the Post list of current Board.
  class ReadBoardMenu < Processor
    def process
      term.erase_body
      cur_board = term.current_board
      unless cur_board
        term.mvaddstr(8, 8, '보드를 먼저 선택해 주세요')
        term.getch
        return :loco_menu
      end
      @cur_index = nil
      @num_lists = term.lines - 5
      term.noecho
      @posts = cur_board.post.order('num desc').limit(@num_lists).reverse
      @edge_posts = [cur_board.post.first, cur_board.post.last]
      result = loop do
        # TODO : redraw only highlighted line when not scrolling
        if @cur_index.nil? || @cur_index >= @num_lists
          @cur_index = @num_lists - 1
        end
        term.erase_body
        @posts.each_with_index do |x, i|
          strs = []
          strs << format('%6d', x.num)
          strs << format('%-12s', x.writer.nickname)
          strs << x.created_at.strftime('%m/%d') # Date
          strs << '????' # View count
          strs << x.title.unicode_slice(term.columns - 32)
          if @cur_index == i
            term.color_black(reverse: true)
          end
          term.mvaddstr(i + 4, 0, ' ' + strs.join(' '))
          term.color_black # reset color
        end
        term.mvaddstr(@cur_index + 4, 0, '>')
        term.refresh
        control, *args = process_key(term.getch)
        case control
        when :break
          break args
        when :beep
          term.beep
        when :scroll_down
          scroll(:down)
        when :scroll_up
          scroll(:up)
        end
        term.echo
        result
      end
    end

    def process_key(key)
      case key
      when 27, 113 # ESC, q
        return :break, :loco_menu
      when 10, 32 # enter, space
        return :break, :loco_menu # FIXME : read post
      when Ncurses::KEY_DOWN, 106 # j
        if @cur_index == @num_lists - 1
          return :scroll_down
        else
          @cur_index += 1
        end
      when Ncurses::KEY_UP, 107 # k
        if @cur_index == 0
          return :scroll_up
        else
          @cur_index -= 1
        end
      when 74 # J
        return :beep # TODO : scroll to end of list
      else
        return :beep
      end
    end

    def scroll(direction)
      cur_board = term.current_board
      case direction
      when :down
        pivot = @posts[-1]
        if pivot.nil? || pivot == @edge_posts[1]
          term.beep
        else
          @cur_index = 0
          @posts = cur_board.post.order('num asc').limit(@num_lists)
          .where('num > ?', pivot.num)
          if @posts.size < @num_lists # reached last
            @cur_index = @num_lists - @posts.size
            @posts = cur_board.post.order('num desc').limit(@num_lists).reverse
          end
        end
      when :up
        pivot = @posts[0]
        if pivot.nil? || pivot == @edge_posts[0]
          term.beep
        else
          @cur_index = @num_lists - 1
          @posts = cur_board.post.order('num desc').limit(@num_lists)
          .where('num < ?', pivot.num).reverse
          if @posts.size < @num_lists # reached first
            @cur_index = @posts.size - 1
            @posts = cur_board.post.order('num asc').limit(@num_lists)
          end
        end
      end
    end
  end
end
