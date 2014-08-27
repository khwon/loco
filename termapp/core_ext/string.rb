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

  # Slice the String with max length.
  #
  # length - An Integer print size to slice.
  #
  # Returns the sliced String.
  def unicode_slice(length)
    if size_for_print <= length
      self
    elsif ascii_only?
      self[0...(length - 2)] + '..'
    else
      result = each_char.with_object(str: '', print_size: 0) do |x, hash|
        break hash if hash[:print_size] >= length - 3
        hash[:str] << x
        hash[:print_size] += x.size_for_print
      end
      result[:str] + '..'
    end
  end
end
