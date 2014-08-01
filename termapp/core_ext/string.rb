class String
  # Internal: Calculate the size of the String to print on Ncurses screen.
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
end
