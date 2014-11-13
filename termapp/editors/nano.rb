module TermApp
  class NanoEditor < Editor
    class Line
      def initialize(str)
        @strs = str.unicode_split(@@column)
      end

      def to_s
        @strs.join('')
      end

      def insert(y, char_idx, str)
        @strs[y].insert(char_idx, str)
        if @strs[y].size_for_print > @@column
          # split
          @strs = @strs.join('').unicode_split(@@column)
          if char_idx == @@column - 1 && str.size_for_print > 1
            [y + 1, 1]
          elsif char_idx == @@column - 1 || (char_idx == @@column - 2 && str.size_for_print > 1)
            [y + 1, 0]
          else
            [y, char_idx + 1]
          end
        elsif @strs[y].size_for_print == @@column && char_idx == @@column - 1
          @strs.insert(y + 1, '')
          [y + 1, 0]
        else
          [y, char_idx + 1]
        end
        # TODO : needs to be more efficient
      end

      def lines
        @strs.size
      end

      def x_pos(y, char_idx)
        @strs[y][0...char_idx].size_for_print
      end

      def nearest_char_idx(y, screen_x)
        @strs[y].unicode_slice_for_len(screen_x).size
      end

      def max_char_idx(y)
        @strs[y].size
      end

      def split(y_idx, char_idx)
        arr1 = []
        arr2 = []
        @strs.each_with_index do |x, i|
          if i < y_idx
            arr1 << x
          elsif i == y_idx
            arr1 << x[0...char_idx]
            arr2 << x[char_idx..-1]
          else
            arr2 << x
          end
        end
        [Line.new(arr1.join('')), Line.new(arr2.join(''))]
      end

      def self.set_column(col)
        @@column = col
      end
    end

    def edit(str: '')
      # TODO : alt key handling (http://stackoverflow.com/a/16248956)
      erase_all
      Line.set_column(@term.columns)
      strs = str.split("\n", -1).map { |x| Line.new(x) }
      i = 0
      strs.each do |x|
        mvaddstr(i, 0, x.to_s)
        i = getyx[0] + 1
        break if i >= @term.lines
      end
      move(0, 0)
      Ncurses.noecho
      str_idx = 0
      char_idx = 0
      str_y_idx = 0
      ch = nil
      loop do
        if ch.nil?
          # FIXME : be more efficient
          erase_all
          i = 0
          strs.each do |x|
            mvaddstr(i, 0, x.to_s)
            i = getyx[0] + 1
            break if i >= @term.lines
          end
          y = strs[0...str_idx].map(&:lines).inject(:+) || 0
          y += str_y_idx
          move(y, strs[str_idx].x_pos(str_y_idx, char_idx))
          ch = get_wch
        end
        case ch[0]
        when Ncurses::OK
          case ch[1]
          when ctrl('j')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_ENTER]
            next
          when ctrl('a')
            char_idx = 0
          when ctrl('b')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_LEFT]
            next
          when ctrl('d')
            # FIXME
          when ctrl('e')
            # FIXME
          when ctrl('f')
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_RIGHT]
            next
          when ctrl('k')
            # FIXME
          when ctrl('x')
            break
          when 127 # backspace
            ch = [Ncurses::KEY_CODE_YES, Ncurses::KEY_BACKSPACE]
            next
          else
            str_y_idx, char_idx = strs[str_idx].insert(str_y_idx, char_idx, ch[2])
          end
        when Ncurses::KEY_CODE_YES
          case ch[1]
          when Ncurses::KEY_BACKSPACE
            # FIXME
          when Ncurses::KEY_UP
          when Ncurses::KEY_DOWN
          when Ncurses::KEY_LEFT
            char_idx -= 1 if char_idx > 0
          when Ncurses::KEY_RIGHT
            char_idx += 1 if char_idx < strs[str_idx].max_char_idx(str_y_idx)
          when Ncurses::KEY_ENTER
            strs[str_idx] = strs[str_idx].split(str_y_idx, char_idx)
            strs.flatten!
            str_idx += 1
            str_y_idx = 0
            char_idx = 0
          end
        end
        ch = nil
      end
      strs.join("\n")
    end
  end
end
