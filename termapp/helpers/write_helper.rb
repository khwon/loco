module TermApp
  class WriteHelper < TermHelper
    def write
      term.erase_all
      term.mvaddstr(2, 0, '제 목 : ')
      str = term.editline(n: term.columns - 10)
      term.mvaddstr(5, 0, str)
      term.get_wch
    end
  end
end
