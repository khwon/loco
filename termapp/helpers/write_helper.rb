module TermApp
  class WriteHelper < TermHelper
    def write
      #       term.erase_all
      #       term.mvaddstr(2, 0, '제 목 : ')
      #       str = term.editline(n: term.columns - 10)
      #       term.mvaddstr(5, 0, str)
      a = "asdf\n"
      (0..30).each do |x|
        a << x.to_s + '가나다라마바사' * 20 + "\n"
      end
      term.editor(str: a)
    end
  end
end
