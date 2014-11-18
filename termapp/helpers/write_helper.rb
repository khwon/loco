module TermApp
  # Helper methods for writing in terminal.
  class WriteHelper < Helper
    def write
      term.erase_all
      term.mvaddstr(2, 0, '제 목 : ')
      title = term.editline(n: term.columns - 10)
      body = term.editor
      if body
        Post.save_new_post(title: title, body: body,
                           user: term.current_user, board: term.current_board)
      else
        term.mvaddstr(1, 0, '저장을 취소합니다')
        term.press_any_key
      end
    end
  end
end
