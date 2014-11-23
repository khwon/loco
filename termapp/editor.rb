module TermApp
  # Handle each line of Editor.
  class Line
    def initialize(str)
      @strs = str.unicode_split(@@column)
    end

    def to_s(start_y = 0)
      @strs[start_y..-1].join
    end

    def insert(y, char_idx, str)
      @strs[y].insert(char_idx, str)
      if @strs[y].size_for_print > @@column
        resplit
        if char_idx == @@column - 1 && str.size_for_print > 1
          [y + 1, 1]
        elsif char_idx == @@column - 1 ||
              (char_idx == @@column - 2 && str.size_for_print > 1)
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
      # OPTIMIZE: Needs to be more efficient.
    end

    def delete(y, char_idx)
      result = nil
      if char_idx == 0
        if y == 0
          fail 'cannot delete at (0,0), merge instead'
        else
          @strs[y - 1] = @strs[y - 1][0..-2]
          result = [y - 1, max_char_idx(y - 1)]
          resplit
        end
      else
        @strs[y].slice!(char_idx - 1)
        result = [y, char_idx - 1]
        resplit
      end
      result
      # OPTIMIZE: Needs to be more efficient.
    end

    def merge(line)
      y_idx = ymax - 1
      char_idx = max_char_idx(y_idx)
      @strs = [@strs.join + line.to_s]
      resplit
      [y_idx, char_idx]
      # OPTIMIZE: Needs to be more efficient.
    end

    def ymax
      @strs.size
    end

    def x_pos(y, char_idx)
      @strs[y][0...char_idx].size_for_print
    end

    def nearest_char_idx(y, screen_x)
      @strs[y].unicode_slice_for_len(screen_x).size
    end

    def get_size_for_screen(y, char_idx)
      @strs[y][0...char_idx].size_for_print
    end

    def max_char_idx(y)
      @strs[y].size
    end

    def resplit
      @strs = @strs.join.unicode_split(@@column)
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
      [Line.new(arr1.join), Line.new(arr2.join)]
    end

    def self.set_column(col)
      @@column = col
    end
  end
  # end def of class Line

  # Base editor for terminal.
  class Editor
    def initialize(term)
      @term = term
    end

    def method_missing(meth, *args)
      @term.send(meth, *args)
    end
  end
end
