module TermApp
  # Corresponding Processor of MenuItem.new('Read', :read_board_menu).
  # Print the Post list of current Board.
  class ReadBoardMenu < ReadMenu
    def initialize(app)
      super
      @prev_menu = :main_menu
    end

    def before_process_init
      unless term.current_board
        print_select_board
        return :main_menu
      end
      nil
    end

    def after_process_init
      if @item_list.size == 0
        print_no_post
        term.echo
        return :main_menu
      else
        nil
      end
    end

    def process_hooks(control, args)
      case control
      when :visit
        visit_post(args[0])
      when :toggle_highlighted
        toggle_highlighted(@item_list[@cur_index])
      when :find_next_highlighted
        find_next_highlighted
      when :find_prev_highlighted
        find_prev_highlighted
      else
        nil
      end
    end

    private

    # Initialize instance variables before actual processing.
    #
    # Returns nothing.
    def process_init
      super
      cache_read_status
    end

    def items(from: nil, to:nil, size: nil)
      size ||= @list_size
      if !from.nil?
        term.current_board.posts_from(from, size)
      elsif !to.nil?
        term.current_board.posts_to(to, size)
      else
        term.current_board.post.order('num desc').limit(size).reverse
      end
    end

    def count_items(from: nil, to: nil)
      if !from.nil?
        term.current_board.post.where('num >= ?', from).count
      elsif !to.nil?
        term.current_board.post.where('num <= ?', to).count
      else
        0
      end
    end

    def get_edge_items
      [term.current_board.post.first, term.current_board.post.last]
    end

    def item_idx(item)
      item.num
    end

    # Process key input for ReadBoardMenu.
    #
    # key - An Array of key input which is returned from term.get_wch.
    #
    # Returns nil or a Symbol :beep, :scroll_down, :scroll_up or :break with
    #   additional arguments.
    def process_key(key)
      case KeyHelper.key_symbol(key)
      when :v
        return :visit, @item_list[@cur_index]
      when :o
        return :toggle_highlighted
      when :J
        return :find_next_highlighted
      when :K
        return :find_prev_highlighted
      else
        return super(key)
      end
    end

    def get_pivot(num)
      term.current_board.post.find_by_num(num)
    end

    def cache_read_status
      board = term.current_board
      board = board.alias_board while board.alias_board
      vr_max = VisitreadMax.find_by(user_id: term.current_user.id,
                                    board_id: board.id)
      vr_max_num = vr_max ? vr_max.num : 0

      if @item_list.size > 0
        read_status = BoardRead.where('user_id = ? and board_id = ?',
                                      term.current_user.id, board.id)
                      .where('posts && int4range(?,?)',
                             @item_list.first.num, @item_list.last.num + 1)
        @item_list.each do |post|
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

    def after_scroll
      cache_read_status
    end

    def toggle_highlighted(post)
      if post
        post.highlighted = !post.highlighted
        post.save!
        print_item(@item_list[@cur_index], @cur_index, x: 0, reverse: true)
        term.mvaddstr(@cur_index + 4, 0, '>')
        term.refresh
      end
    end

    def find_next_highlighted
      cur_board = term.current_board
      num = @item_list[@cur_index].num
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
      num = @item_list[@cur_index].num
      @pivot = cur_board.post.where('num < ?', num)
               .where(highlighted: true)
               .order('num desc').limit(1).first
      term.debug_print(@pivot.inspect)
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
    def read_item(post)
      @past_index = nil # Redraw list.
      read_post_helper = ReadPostHelper.new(@app, post)
      key = read_post_helper.read_post
      @item_list[@cur_index].read_status = 'R'
      case KeyHelper.key_symbol(key)
      when :n then :read_next
      when :p then :read_prev
      when :r, :R then [:reply, post]
      else nil
      end
    end

    def visit_item(post)
      BoardRead.mark_visit(term.current_user, post, post.board)
      post.read_status = 'V' if post.read_status.nil?
      print_items(range: [@cur_index])
    end

    # Write a new Post or reply to parent_post
    # through terminal.
    #
    # Returns nothing.
    def write_item(parent_post)
      write_helper = WriteHelper.new(@app)
      write_helper.write(parent: parent_post)
    end
  end
end
