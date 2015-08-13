module TermApp
  # Print the message saying this menu is not implemented yet.
  class NotImplementedMenu < Processor
    # Initialize a NotImplementedMenu. It holds the Symbol of the menu which is
    # not implemented yet.
    #
    # name - The Symbol of the menu which is not implemented yet.
    # args - Zero or more values to pass to initialize of super class as
    #        parameters.
    #
    # Examples
    #
    #   NotImplementedMenu.new(:future_menu, app)
    def initialize(name, *args)
      @name = name
      super(*args)
    end

    def process
      term.erase_body
      term.mvaddstr(5, 5, "#{@name}: Not supported yet")
      term.refresh
      term.get_wch
      :main_menu
    end
  end
end
