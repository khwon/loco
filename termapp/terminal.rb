require_relative 'core_ext/string'

module TermApp
  # Wrapper for Ncurses to do terminal operations. Make sure to call terminate
  # before termination of the program.
  #
  # Examples
  #
  #   begin
  #     term = Terminal.new
  #   ensure
  #     term.terminate
  #   end
  class Terminal
    extend Forwardable

    # Delegates noecho, echo, beep to each method of Ncurses.
    delegate [:noecho, :echo, :beep] => :Ncurses

    # Delegates terminate to Ncurses.endwin.
    def_delegator :Ncurses, :endwin, :terminate

    # Delegates refresh, move, erase to each method of @stdscr.
    def_delegators :@stdscr, :refresh, :move, :erase

    # Returns the Integer number of screen lines.
    attr_reader :lines

    # Returns the Integer number of screen columns.
    attr_reader :columns

    # The constants for color of Ncurses.
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

    # Set a color of Terminal. This method will be available for each color
    # initialized on Ncurses.
    #
    # options - The Hash options used to refine the color
    #           (default: { reverse: false }):
    #           :reverse - The Boolean whether to reverse the foreground and
    #                      background color or not (optional).
    # block   - An optional block that can be used as an sandbox. If it is
    #           present, color of terminal will be set to previous color after
    #           the finish of block call.
    #
    # Examples
    #
    #   color_black
    #   # => :color_black
    #
    #   color_red(reverse: true)
    #   # => :color_red
    #
    #   color_green do
    #     term.mvaddstr(14, 52, 'Successfully saved!')
    #   end
    #   # => :color_green
    #
    # Returns the Symbol of used color.
    #
    # Signature
    #
    #   color_<color>(reverse: false, &block)
    #
    # color - A color name.
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
        sym
      end
    end

    # Gets/Sets the User who is logged in.
    attr_accessor :current_user

    # Gets/Sets the selected Board.
    attr_accessor :current_board

    # Initialize a Terminal. Set initial Ncurses configurations and start
    # Ncurses screen.
    #
    # encoding - The Encoding of Terminal.
    #
    # Examples
    #
    #   Terminal.new
    #
    #   Terminal.new(Encoding::UTF_8)
    def initialize(encoding: nil, debug: false)
      @encoding = encoding
      @cur_color = 0
      @stdscr = Ncurses.initscr
      Ncurses.keypad(@stdscr, true) # enable arrow keys
      Ncurses.ESCDELAY = 25 # wait only 10ms for esc
      initialize_colors if Ncurses.has_colors?
      getmaxyx
      Ncurses.raw
      if Rails.env.development? && debug
        win = Ncurses.newwin(0, @columns / 2, 0, @columns / 2 - 1)
        win.refresh
        @stdscr = win
        @columns = @columns / 2 - 1
      end
    end

    # Set a random color of Terminal. Delegates to color_<color> method.
    #
    # args  - Zero or more values to pass to color_<color> method.
    # block - An optional block that can be used as an sandbox. If it is
    #         present, color of terminal will be set to previous color after the
    #         finish of block call.
    #
    # Examples
    #
    #   color_sample(reverse: true)
    #
    #   color_sample do
    #     term.mvaddstr(14, 52, 'Random color text')
    #   end
    #
    #   color_sample(reverse: true) do
    #     term.mvaddstr(14, 52, 'Random reversed color text')
    #   end
    #
    # Returns the Symbol of the random color.
    def color_sample(*args, &block)
      send(COLOR_SYMBOLS[0..-2].sample, *args, &block)
    end

    # Erase the line from the right of the cursor to the end of the line. With
    # given y positions, erase the lines.
    #
    # y_indices - An Integer y position or an Array of Integer y positions to
    #             clear (default: nil).
    #
    # Returns nothing.
    def clrtoeol(y_indices = nil)
      if y_indices.nil?
        @stdscr.clrtoeol
      else
        old_y, old_x = getyx
        y_indices = [y_indices] unless y_indices.is_a?(Enumerable)
        y_indices.each do |y|
          @stdscr.move(y, 0)
          @stdscr.clrtoeol
        end
        @stdscr.move(old_y, old_x)
      end
    end

    # Move the cursor and add a String to screen.
    #
    # y   - An Integer y position which cursor moves to.
    # x   - An Integer x position which cursor moves to.
    # str - A String to add to screen.
    #
    # Returns nothing.
    def mvaddstr(y, x, str)
      str.encode!(@encoding) if @encoding
      @stdscr.mvaddstr(y, x, str)
    end

    # Get the position of current cursor.
    #
    # Returns an Array of Integer consists of y position and x position.
    def getyx
      y = []
      x = []
      @stdscr.getyx(y, x)
      [y[0], x[0]]
    end

    # Move the cursor and accept a String from terminal.
    #
    # y       - An Integer y position which cursor moves to.
    # x       - An Integer x position which cursor moves to.
    # str     - A String variable which will store the accepted String.
    # n       - The Integer size of str.
    # options - The Hash options used to control screen output
    #           (default: { echo: true }).
    #           :echo - The Boolean whether to echo input to screen or not.
    #
    # Returns nothing.
    def mvgetnstr(y, x, str, n, echo: true)
      Ncurses.noecho unless echo
      @stdscr.mvgetnstr(y, x, str, n)
      str.encode!(@encoding) if @encoding
      Ncurses.echo
    end

    # Erase body of screen. Print header and footer again.
    #
    # Returns nothing.
    def erase_body
      erase_all
      print_header
      print_footer
    end

    # Erase whole screen.
    #
    # Returns nothing.
    def erase_all
      getmaxyx
      clrtoeol(0...@lines)
    end

    # Get the number of lines and columns of screen.
    #
    # Returns nothing.
    def getmaxyx
      lines = []
      columns = []
      @stdscr.getmaxyx(lines, columns)
      @lines = lines[0]
      @columns = columns[0]
    end

    # Get one wide-character from terminal.
    #
    # Returns an Array of status code, character code, character as string if
    #   status code is Ncurses::OK.
    def get_wch # rubocop:disable Style/AccessorMethodName
      # TODO : encoding issues
      result = @stdscr.get_wch
      result << ((result[0] == Ncurses::OK) ? [result[1]].pack('U') : nil)
      result
    end

    def editline(y: nil, x: nil, str: '', n: 80, echo: true)
      # TODO : encoding issues
      if y && x
        move(y, x)
      else
        y, x = getyx
      end
      Ncurses.noecho
      idx = 0
      ch = nil
      loop do
        if ch.nil?
          if echo
            move(y, x)
            clrtoeol
            mvaddstr(y, x, str)
            move(y, x + str[0...idx].size_for_print)
          end
          ch = get_wch
        end
        case ch[0]
        when Ncurses::OK
          case ch[1]
          when ctrl('j')
            break
          when ctrl('a')
            idx = 0
          when ctrl('b')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_LEFT]
            next
          when ctrl('d')
            if idx < str.size
              idx += 1
              ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_BACKSPACE]
              next
            end
          when ctrl('e')
            idx = str.size
          when ctrl('f')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_RIGHT]
            next
          when ctrl('k')
            str = str[0...idx]
          when ctrl('u')
            # TODO: following previous implementation in eagle bbs,
            # but actually ctrl-u is undo in emacs binding
            str = str[idx..-1]
            idx = 0
          when 127 # backspace
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_BACKSPACE]
            next
          else
            if str.size_for_print >= n - 1
              beep
            else
              str.insert(idx, ch[2])
              idx += 1
            end
          end
        when Ncurses::KEY_CODE_YES
          case ch[1]
          when Ncurses::KEY_BACKSPACE
            if str.size > 0 && idx > 0
              str[(idx - 1)..(idx - 1)] = ''
              idx -= 1
            end
          when Ncurses::KEY_LEFT
            idx -= 1 if idx > 1
          when Ncurses::KEY_RIGHT
            idx += 1 if idx < str.size
          when Ncurses::KEY_ENTER
            break
          end
        end
        ch = nil
      end
      str
    end

    def editor(str: '')
      NanoEditor.new(self).edit(str: str)
    end

    # Print the multi-line String to screen.
    #
    # y   - An Integer y position of top-left corner of str.
    # x   - An Integer x position of top-left corner of str.
    # str - A String to print to screen.
    #
    # Returns nothing.
    def print_block(y, x, str)
      str.each_line.with_index do |line, index|
        mvaddstr(y + index, x, line.chomp)
      end
    end

    # Print header to screen.
    #
    # Returns nothing.
    def print_header
      # TODO: design headers
      str = '[새편지없음]'
      offset = @columns - str.size_for_print - 2
      mvaddstr(0, 0, '[NEWLOCO]')
      mvaddstr(0, offset, str)
      color_blue { mvaddstr(1, 0, current_board.path_name) } if current_board
    end

    # Print footer to screen.
    #
    # Returns nothing.
    def print_footer
      # TODO: design footers
      mvaddstr(@lines - 1, 10, 'sample footer')
    end

    def ctrl(chr)
      x = chr.codepoints.first
      x & 0x1f
    end

    def call_pry
      Ncurses.def_prog_mode
      Ncurses.reset_shell_mode
      binding.pry
      Ncurses.reset_prog_mode
    end

    private

    # Initialize color pairs for Ncurses.
    #
    # Returns nothing.
    def initialize_colors
      Ncurses.start_color
      [[Ncurses::COLOR_RED, Ncurses::COLOR_WHITE],
       [Ncurses::COLOR_GREEN, Ncurses::COLOR_BLACK],
       [Ncurses::COLOR_YELLOW, Ncurses::COLOR_BLACK],
       [Ncurses::COLOR_BLUE, Ncurses::COLOR_WHITE],
       [Ncurses::COLOR_MAGENTA, Ncurses::COLOR_BLACK],
       [Ncurses::COLOR_CYAN, Ncurses::COLOR_BLACK],
       [Ncurses::COLOR_WHITE, Ncurses::COLOR_BLACK]
      ].each.with_index(1) do |pair, i|
        # Initialize color.
        Ncurses.init_pair(i, pair[0], Ncurses::COLOR_BLACK)
        # Initialize reversed color.
        Ncurses.init_pair(i + 8, pair[1], pair[0])
      end
      Ncurses.init_pair(8, Ncurses::COLOR_BLACK, Ncurses::COLOR_WHITE)
    end
  end
end
