class String
  # Public: Calculate the size of the String to print on Ncurses screen. Each
  # ASCII characters have size 1, other characters have size 2.
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
    length + each_char.reject { |x| x.ascii_only? }.length
  end
end
