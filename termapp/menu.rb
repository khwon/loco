#coding: utf-8
require_relative 'locoterm'
require_relative 'goodbye'
require_relative 'board'
class LocoMenu
  def self.menu_helper(locoterm, arr)
    cur_menu = 0
    loop do
      locoterm.noecho
      #TODO : 전체를 지우고 다시 쓰기 보다 선택된 메뉴와 이전 메뉴만 refresh
      locoterm.erase_body
      arr.each_with_index do |x, i|
        if i == cur_menu
          locoterm.set_color(LocoTerm::COLOR_BLACK, reverse: true) do
            locoterm.mvaddstr(i + 4, 3, x[1])
          end
        else
          locoterm.mvaddstr(i + 4, 3, x[1])
        end
      end
      locoterm.move(3, 3)
      locoterm.refresh
      c = locoterm.getch
      case c
      when Ncurses::KEY_UP
        cur_menu = (cur_menu == 0 ? arr.size - 1 : cur_menu - 1)
      when Ncurses::KEY_DOWN
        cur_menu = (cur_menu + 1) % arr.size
      when Ncurses::KEY_ENTER, 10 # enter
        locoterm.echo
        arr[cur_menu][2].call(locoterm)
      else
        if c < 127
          arr.each_with_index do |x, i|
            if c.chr =~ x[0]
              cur_menu = i
            end
          end
        end
      end
    end
  end

  def self.main(locoterm)
    arr = []
    arr << [/[Nn]/, "(N)ew", LocoMenu.method(:read_new)]
    arr << [/[Bb]/, "(B)oards", LocoMenu.method(:boards)]
    arr << [/[Ss]/, "(S)elect", LocoMenu.method(:select)]
    arr << [/[Rr]/, "(R)ead", LocoMenu.method(:read)]
    arr << [/[Pp]/, "(P)ost", LocoMenu.method(:post)]
#    arr << [/[Ee]/, "(E)xtra", LocoMenu.method(:extra)]
    arr << [/[Tt]/, "(T)alk", LocoMenu.method(:talk)]
    arr << [/[Mm]/, "(M)ail", LocoMenu.method(:mail)]
    arr << [/[Dd]/, "(D)iary", LocoMenu.method(:diary)]
#    arr << [/[Vv]/, "(V)isit", LocoMenu.method(:visit)]
#    arr << [/[Ww]/, "(W)elcome", LocoMenu.method(:welcome)]
    arr << [/[Xx]/, "(X)yz", LocoMenu.method(:xyz)]
    arr << [/[Gg]/, "(G)oodbye", LocoMenu.method(:goodbye)]
    arr << [/[Hh]/, "(H)elp", LocoMenu.method(:help)]
#    arr << [/[Ii]/, "(I)nfoBBS", LocoMenu.method(:info_bbs)]
    arr << [/[Aa]/, "(A)dmin", LocoMenu.method(:admin)] if locoterm.current_user.is_admin?
    LocoMenu.menu_helper(locoterm, arr)
  end

  def self.admin(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "admin: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.read_new(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "read_new: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.boards(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "boards: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.select(locoterm)
    select_board(locoterm)
  end

  def self.read(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "read: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.post(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "post: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.talk(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "talk: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.mail(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "mail: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.diary(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "diary: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.xyz(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "xyz: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

  def self.goodbye(locoterm)
    do_goodbye(locoterm)
  end

  def self.help(locoterm)
    locoterm.erase_body
    locoterm.mvaddstr(5, 5, "help: Not supported yet")
    locoterm.refresh
    locoterm.getch
  end

end
