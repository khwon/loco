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

    # The colors of Ncurses of which the value start from zero.
    COLOR_SYMBOLS = %i(color_black color_red color_green color_yellow
                       color_blue color_magenta color_cyan color_white).freeze
    private_constant :COLOR_SYMBOLS

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
    COLOR_SYMBOLS.each_with_index do |sym, i|
      define_method(sym) do |reverse: false, &block|
        color = i
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
    # options - The Hash options used to set additional options (default:
    #           { encoding: nil, debug: false }).
    #           :encoding - The Encoding of Termianl (optional).
    #           :debug    - The Boolean whether to debug terminal or not
    #                       (optional).
    #
    # Examples
    #
    #   Terminal.new
    #
    #   Terminal.new(encoding: Encoding::UTF_8)
    #
    #   Terminal.new(debug: true)
    def initialize(encoding: nil, debug: false)
      @encoding = encoding
      @cur_color = 0
      @stdscr = Ncurses.initscr
      Ncurses.keypad(@stdscr, true) # Enable arrow keys.
      Ncurses.ESCDELAY = 25 # Wait only 10ms for ESC.
      initialize_colors if Ncurses.has_colors?
      getmaxyx
      Ncurses.raw
      @debug = debug
      if Rails.env.development? && @debug
        @debugscr = @stdscr
        @cur_debug_line = 0
        win = Ncurses.newwin(0, @columns / 2, 0, @columns / 2 - 1)
        win.refresh
        Ncurses.keypad(win, true) # Enable arrow keys.
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
    #           :echo - The Boolean whether to echo input to screen or not
    #                   (optional).
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
      # TODO: Encoding issues.
      result = @stdscr.get_wch
      result << ((result[0] == Ncurses::OK) ? [result[1]].pack('U') : nil)
      result
    end

    # Handle editing a line.
    #
    # options - The Hash options to handle line
    #           (default: { y: nil, x: nil, str: '', n: 80, echo: true }).
    #           :y    - An Integer y position (optional).
    #           :x    - An Integer x position (optional).
    #           :str  - A String initial value of line (optional).
    #           :n    - An Integer max size of line (optional).
    #           :echo - The Boolean whether to echo input to screen or not
    #                   (optional).
    #
    # Returns the String result after editing.
    def editline(y: nil, x: nil, str: '', n: 80, echo: true)
      # TODO: Encoding issues.
      if y && x
        move(y, x)
      else
        y, x = getyx
      end
      Ncurses.noecho
      idx = 0
      key = nil
      loop do
        if key.nil?
          if echo
            move(y, x)
            clrtoeol
            mvaddstr(y, x, str)
            move(y, x + str[0...idx].size_for_print)
          end
          key = get_wch
        end
        case KeyHelper.key_symbol(key)
        when :ctrl_j, :enter
          break
        when :ctrl_a
          idx = 0
        when :ctrl_b, :left
          idx -= 1 if idx > 1
        when :ctrl_d
          if idx < str.size
            idx += 1
            key = [Ncurses::KEY_CODE_YES, Ncurses::KEY_BACKSPACE]
            next
          end
        when :ctrl_e
          idx = str.size
        when :ctrl_f, :right
          idx += 1 if idx < str.size
        when :ctrl_k
          str = str[0...idx]
        when :ctrl_u
          # TODO: Following previous implementation in Eagles BBS,
          #   but actually ctrl-u is undo in Emacs binding.
          str = str[idx..-1]
          idx = 0
        when :backspace
          if str.size > 0 && idx > 0
            str.slice!(idx - 1)
            idx -= 1
          end
        else
          if key[0] == Ncurses::OK
            if str.size_for_print >= n - 1
              beep
            else
              str.insert(idx, key[2])
              idx += 1
            end
          end
        end
        key = nil
      end
      str
    end

    # Gets writable Editor.
    #
    # Returns NanoEditor class.
    def editor
      NanoEditor
    end

    # Gets readable Editor.
    #
    # Returns LessEditor class.
    def readonly_editor
      LessEditor
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
      # TODO: Design headers.
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
      # TODO: Design footers.
      mvaddstr(@lines - 1, 10, 'sample footer')
    end

    # Process 'Press any key' task.
    #
    # Returns an Array of status code, character code, character as string if
    #   status code is Ncurses::OK. See #get_wch.
    def press_any_key
      # TODO: Print footer.
      get_wch
    end

    # Bind Pry for debugging.
    #
    # Returns nothing.
    def call_pry
      return unless Rails.env.development? && @debug
      Ncurses.def_prog_mode
      Ncurses.reset_shell_mode
      binding.pry # rubocop:disable Lint/Debugger
      Ncurses.reset_prog_mode
    end

    # Print String on debug screen. Only works for debug environment.
    #
    # str - The String to print.
    #
    # Returns nothing.
    def debug_print(str)
      return unless Rails.env.development? && @debug
      @debugscr.move(@cur_debug_line, 0)
      @debugscr.clrtoeol
      @debugscr.mvaddstr(@cur_debug_line, 0, str)
      @cur_debug_line = (@cur_debug_line + 1) % @lines
      @debugscr.refresh
    end

    # Clear debug screen. Only works for debug environment.
    #
    # Returns nothing.
    def clear_debug_console
      @debugscr.clrtoeol(0...@lines) if Rails.env.development? && @debug
    end

    def bold(&block)
      if block
        Ncurses.attron(Ncurses::A_BOLD)
        yield
        Ncurses.attroff(Ncurses::A_BOLD)
      end
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
