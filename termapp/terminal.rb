require_relative 'core_ext/string'

module TermApp
  class Terminal
    extend Forwardable

    def_delegators :Ncurses, :erase, :noecho, :echo, :beep
    def_delegator :Ncurses, :endwin, :terminate # alias

    def_delegators :@stdscr, :refresh, :move, :getch

    COLOR_BLACK = 0
    COLOR_RED = 1
    COLOR_GREEN = 2
    COLOR_YELLOW = 3
    COLOR_BLUE = 4
    COLOR_MAGENTA = 5
    COLOR_CYAN = 6
    COLOR_WHITE = 7
    COLORS = [COLOR_BLACK, COLOR_RED, COLOR_GREEN, COLOR_YELLOW,
              COLOR_BLUE, COLOR_MAGENTA, COLOR_CYAN, COLOR_WHITE].freeze
    COLOR_SYMBOLS = %i(color_black color_red color_green color_yellow
                       color_blue color_magenta color_cyan color_white).freeze
    private_constant :COLORS, :COLOR_SYMBOLS

    COLOR_SYMBOLS.each do |sym|
      define_method(sym) do |reverse: false, &block|
        color = Terminal.const_get(sym.upcase)
        color += 8 if reverse
        if block
          @stdscr.attrset(Ncurses.COLOR_PAIR(color))
          block.call
          @stdscr.attrset(Ncurses.COLOR_PAIR(@cur_color))
        else
          @cur_color = color
          @stdscr.attrset(Ncurses.COLOR_PAIR(color))
        end
      end
    end

    attr_accessor :current_user
    attr_accessor :current_board

    def initialize(encoding = nil)
      @encoding = encoding
      @cur_color = 0
      @stdscr = Ncurses.initscr
      Ncurses.keypad(@stdscr, true) # enable arrow keys
      Ncurses.ESCDELAY = 25 # wait only 10ms for esc
      if Ncurses.has_colors?
        Ncurses.start_color

        Ncurses.init_pair(1, Ncurses::COLOR_RED, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(2, Ncurses::COLOR_GREEN, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(3, Ncurses::COLOR_YELLOW, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(4, Ncurses::COLOR_BLUE, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(5, Ncurses::COLOR_MAGENTA, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(6, Ncurses::COLOR_CYAN, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(7, Ncurses::COLOR_WHITE, Ncurses::COLOR_BLACK)
        Ncurses.init_pair(8, Ncurses::COLOR_BLACK, Ncurses::COLOR_WHITE)
        Ncurses.init_pair(9, Ncurses::COLOR_WHITE, Ncurses::COLOR_RED)
        Ncurses.init_pair(10, Ncurses::COLOR_BLACK, Ncurses::COLOR_GREEN)
        Ncurses.init_pair(11, Ncurses::COLOR_BLACK, Ncurses::COLOR_YELLOW)
        Ncurses.init_pair(12, Ncurses::COLOR_WHITE, Ncurses::COLOR_BLUE)
        Ncurses.init_pair(13, Ncurses::COLOR_BLACK, Ncurses::COLOR_MAGENTA)
        Ncurses.init_pair(14, Ncurses::COLOR_BLACK, Ncurses::COLOR_CYAN)
        Ncurses.init_pair(15, Ncurses::COLOR_BLACK, Ncurses::COLOR_WHITE)
      end
      getmaxyx
      Ncurses.raw
    end

    def color_sample(*args, &block)
      if block
        send(COLOR_SYMBOLS.sample, *args) do
          block.call
        end
      else
        send(COLOR_SYMBOLS.sample, *args)
      end
    end

    def clrtoeol(y = nil)
      if y.nil?
        @stdscr.clrtoeol
      else
        old_pos = getyx
        y = [y] unless y.is_a? Enumerable
        y.each do |yy|
          @stdscr.move(yy, 0)
          @stdscr.clrtoeol
        end
        @stdscr.move(old_pos[0], old_pos[1])
      end
    end

    def mvaddstr(y, x, str)
      str.encode!(@encoding) if @encoding
      @stdscr.mvaddstr(y, x, str)
    end

    def getyx
      y = []
      x = []
      Ncurses.getyx(@stdscr, y, x)
      [y[0], x[0]]
    end

    def mvgetnstr(y, x, str, n, echo: true)
      Ncurses.noecho unless echo
      Ncurses.mvgetnstr(y, x, str, n)
      str.encode!(@encoding) if @encoding
      Ncurses.echo
    end

    def erase_body
      erase_all
      print_header
      print_footer
    end

    def erase_all
      getmaxyx
      clrtoeol(0...@lines)
    end

    def getmaxyx
      lines = []
      columns = []
      @stdscr.getmaxyx(lines, columns)
      @lines = lines[0]
      @columns = columns[0]
    end

    def print_block(y, x, str)
      str.each_line.with_index do |line, index|
        mvaddstr(y + index, x + line[/^\s*/].size, line.chomp.lstrip)
      end
    end

    def print_header
      # TODO: design headers
      str = '[새편지없음]'
      offset = @columns - str.size_for_print - 2
      mvaddstr(0, 0, '[NEWLOCO]')
      mvaddstr(0, offset, str)
      color_blue { mvaddstr(1, 0, current_board.path_name) } if current_board
    end

    def print_footer
      # TODO: design footers
      mvaddstr(@lines - 1, 10, 'sample footer')
    end
  end
end
