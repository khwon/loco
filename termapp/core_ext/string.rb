# rubocop:disable Style/AsciiComments

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
    else
      result = unicode_slice_for_len(length - 2)
      if result != self
        result + '..'
      else
        result
      end
    end
  end

  def unicode_split(length)
    arr = []
    result = unicode_slice_for_len(length)
    arr << result
    if result != self
      arr += self[(result.size)..-1].unicode_split(length)
    end
    arr
  end

  def unicode_slice_for_len(length)
    if size_for_print <= length
      self
    elsif ascii_only?
      self[0...length]
    else
      result = each_char.with_object(str: '', print_size: 0) do |x, hash|
        break hash if hash[:print_size] >= length - 1
        hash[:str] << x
        hash[:print_size] += x.size_for_print
      end
      result[:str]
      # TODO: Implement binary search.
      # min = length/2
      # max = length
      # loop do
      #
      # end
    end
  end
end
