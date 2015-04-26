module TermApp
  # Helper methods for writing in terminal.
  class WriteHelper < Helper
    def write(parent: nil)
      term.erase_all
      term.mvaddstr(2, 0, '제 목 : ')
      title = title_for(parent)
      body = body_for(parent)
      body = term.editor.new(term).edit(str: body)
      if body
        Post.save_new_post(title: title, body: body,
                           user: term.current_user, board: term.current_board,
                           parent: parent)
      else
        term.mvaddstr(1, 0, '저장을 취소합니다')
        term.press_any_key
      end
    end

    private

    def title_for(post)
      if post
        orig_post = post
        orig_post = orig_post.parent until orig_post.parent.nil?
        old_title = orig_post.title

        # handle old-style reply titles
        if old_title =~ /^\(re:.*\) (.*)/
          old_title = Regexp.last_match[1]
        end
        title = "(re:#{post.writer.username}) " +
                old_title
        term.addstr(title)
        title
      else
        term.editline(n: term.columns - 10)
      end
    end

    def body_for(post)
      if post
        term.mvaddstr(3, 0, '본문을 복사할까요? (Y/N/E)[N] ')
        key = term.get_wch
        case KeyHelper.key_symbol(key)
        when :y, :Y
          post.content.each_line.map { |x| '> ' + x }.join
        when :e, :E
          post.content
        else
          ''
        end
      else
        ''
      end
    end
  end
end
