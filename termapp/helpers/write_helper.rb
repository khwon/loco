module TermApp
  class WriteHelper < TermHelper

    def write
      term.erase_all
      term.mvaddstr(2,0,"input : ")
      str = term.editline(n: 40)
      term.mvaddstr(5,0,str)
      term.get_wch
    end

  end
end
