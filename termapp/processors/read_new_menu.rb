module TermApp
  # Corresponding Processor of MenuItem.new('New', :read_new_menu).
  class ReadNewMenu < Processor
    def process
      term.noecho
      flash = nil
      started_time = Time.now.to_f
      init_process
      @leaves.each do |b|
        # next if b.zapped_by? term.current_user
        orig_board = b
        b = b.alias_board while b.alias_board
        max_num = @max_num_cache[b.id] || 0
        next if max_num == (@vr_max_cache[b.id] || 0)
        @checked_board_cnt += 1
        vr_max = VisitreadMax.find_or_create_by!(user_id: term.current_user.id,
                                                 board_id: b.id)
        list = BoardRead.where(user: term.current_user)
               .where(board: b).order('lower(posts)').to_a
        num = (@vr_max_cache[b.id] || 0) + 1
        while num <= max_num
          if !list.empty? && list[0].posts.cover?(num)
            num = list[0].posts.max + 1
            list.shift
            next
          end
          @time_spent = nil
          post = b.post.find_by(num: num)
          term.erase_body
          strs = []
          strs << "[새글 읽기: #{orig_board.path_name} ( #{b.owner.username} )]"
          strs << "   남은글 : #{max_num - post.num + 1}개"
          strs << "   제  목 : \"#{post.title}\""
          strs << "   글쓴이 : #{post.writer.username}"
          strs << '   조회수 : ??'
          strs << '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
          strs << ' (SP,n,j,\n)읽기 (v)통과 (V)게시판visit (Q)마치기 (S)게시판통과 (Z)Zap'
          strs << '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'
          strs.each_with_index do |x, i|
            term.mvaddstr(2 + i, 0, x)
          end
          term.mvaddstr(11, 0, flash) if flash
          flash = nil
          key = term.get_wch
          control, *args = process_key(key)
          case control
          when :quit
            print_stop
            term.echo
            return args
          when :zap
            flash = 'Zap is currently not supported'
            # disable zap for now
            # (because unzap is not implemented)
            # ZapBoard.zap(orig_board,term.current_user)
            break
          when :visit_all
            num = max_num + 1
          when :visit
            BoardRead.mark_visit(term.current_user, post, b)
            num += 1
          when :read
            case read_post(post)
            when :quit
              print_stop
              term.echo
              return :main_menu
            end
            num += 1
          when :break then break args
          when :beep  then term.beep
          end
        end
        vr_max.num = num - 1
        vr_max.save!
      end
      @time_spent = Time.now.to_f - started_time if @time_spent
      print_end
      term.echo
      :main_menu
    end

    def process_key(key)
      case KeyHelper.key_symbol(key)
      when :q
        return :quit, :main_menu
      when :s
        return :break
      when :z
        return :zap
      when :v
        return :visit
      when :space, :enter, :n, :j
        return :read
      end
    end

    def read_post(post)
      post.read_status = nil
      read_post_helper = ReadPostHelper.new(@app, post)
      result = read_post_helper.read_post
      case KeyHelper.key_symbol(result[1])
      when :q then :quit
      else nil
      end
    end

    def init_process
      @time_spent = 0
      @checked_board_cnt = 0
      @leaves = Board.each_leaves_for_newread(term.current_user)
      @vr_max_cache = {}
      VisitreadMax.where(user_id: term.current_user.id,
                         board_id: @leaves.map(&:id))
        .each do |x|
        @vr_max_cache[x.board_id] = x.num
      end
      @max_num_cache = {}
      Post.select('board_id, max(num) as max_num').group(:board_id)
        .having(board_id: @leaves.map(&:id)).each do |x|
        @max_num_cache[x[:board_id]] = x[:max_num]
      end
    end

    def print_end
      term.erase_body
      if @time_spent
        term.mvaddstr(3, 3, '* 새 글이 없습니다.')
        term.mvaddstr(4, 5, '조금 후에 다시 시도하세요.')
        term.mvaddstr(5, 5, "소요 시간 : #{@time_spent}초")
      else
        term.mvaddstr(3, 3, '* 새 글 읽기가 끝났습니다.')
        term.mvaddstr(4, 5, '수고 하셨습니다 (__);')
      end
      term.mvaddstr(7, 5, "전체 보드 수 : #{Board.where(is_dir: false).count}")
      term.mvaddstr(8, 5, "새글을 확인한 보드 수 : #{@checked_board_cnt}")
      term.mvaddstr(9, 5, '(이외의 보드에서는 새글이 없는 것이 확실하여 확인하지 않음)')
      term.get_wch
    end

    def print_stop
      term.erase_body
      term.mvaddstr(4, 3, '* 새 글 읽기를 중간에 멈춥니다.')
      term.get_wch
    end
  end
end
