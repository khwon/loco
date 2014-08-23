# Extend String class of Ruby core.
class String
  # Calculate the size of the String to print on Ncurses screen.
  #
  # Examples
  #
  #   'abc'.size_for_print
  #   # => 3
  #
  #   '가나'.size_for_print
  #   # => 4
  #
  # Returns the Integer size of the String to print on Ncurses screen.
  def size_for_print
    Unicode.width(self, true)
  end

  def unicode_slice(length)
    if size_for_print <= length
      self
    else
      if self.ascii_only?
        self[0..(size - 2)] + '..'
      else
        result = ''
        # TODO : need optimize
        each_char do |x|
          result << x if result.size_for_print < length - 2
        end
        result + '..'
      end
    end
  end
end
