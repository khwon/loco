#coding: utf-8
require 'ncursesw'

class LocoTerm

  COLOR_BLACK = 0
  COLOR_RED = 1
  COLOR_GREEN = 2
  COLOR_YELLOW = 3
  COLOR_BLUE = 4
  COLOR_MAGENTA = 5
  COLOR_CYAN = 6
  COLOR_WHITE = 7
  @@colors = [COLOR_BLACK, COLOR_RED, COLOR_GREEN, COLOR_YELLOW,
    COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE]

  def initialize(encoding=nil)
    @encoding = encoding
    @cur_color = 0
    @stdscr = Ncurses.initscr
    if Ncurses.has_colors?
      Ncurses.start_color()

      Ncurses.init_pair(1, Ncurses::COLOR_RED, Ncurses::COLOR_BLACK)
      Ncurses.init_pair(2, Ncurses::COLOR_GREEN, Ncurses::COLOR_BLACK);
      Ncurses.init_pair(3, Ncurses::COLOR_YELLOW, Ncurses::COLOR_BLACK);
      Ncurses.init_pair(4, Ncurses::COLOR_BLUE, Ncurses::COLOR_BLACK);
      Ncurses.init_pair(5, Ncurses::COLOR_MAGENTA, Ncurses::COLOR_BLACK);
      Ncurses.init_pair(6, Ncurses::COLOR_CYAN, Ncurses::COLOR_BLACK);
      Ncurses.init_pair(7, Ncurses::COLOR_WHITE, Ncurses::COLOR_BLACK);
    end
  end

  def self.colors
    @@colors
  end

  def set_color color, &block
    raise "unknown color" unless @@colors.include? color
    if block_given?
      @stdscr.attrset(Ncurses.COLOR_PAIR(color))
      yield
      @stdscr.attrset(Ncurses.COLOR_PAIR(@cur_color))
    else
      @cur_color = color
      @stdscr.attrset(Ncurses.COLOR_PAIR(color))
    end
  end

  def terminate
    Ncurses.endwin
  end

  def move(y,x)
    @stdscr.move(y,x)
  end

  def clrtoeol(y=nil)
    if y.nil?
      @stdscr.clrtoeol
    else
      old_pos = getyx
      y = [y] unless y.kind_of? Enumerable
      y.each do |yy|
        @stdscr.move(yy,0)
        @stdscr.clrtoeol
      end
      @stdscr.move(old_pos[0],old_pos[1])
    end
  end

  def mvaddstr(y,x,str)
    str = str.encode(@encoding) unless @encoding.nil?
    @stdscr.mvaddstr(y,x,str)
  end

  def refresh
    @stdscr.refresh
  end

  def getyx
    y = []
    x = []
    Ncurses.getyx(@stdscr,y,x)
    [y[0],x[0]]
  end

end
