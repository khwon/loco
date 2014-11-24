module TermApp
  # Base Processor class. The process method must be implemented. The process
  # method must return the Symbol of Processor to be processed next with its
  # arguments or nil for termination.
  class Processor
    # Initialize a Processor. It holds the Application instance.
    #
    # app - The Application instance which is now running.
    def initialize(app)
      @app = app
    end

    # Main process of Processor. Child classes should extend Processor and
    # implement this method.
    #
    # _args - Zero or more values to pass to process as parameters.
    #
    # Raises NotImplementedError.
    def process(*_args)
      fail NotImplementedError
    end

    # Delegates all missing methods to the application.
    #
    # meth - The Symbol of a missing method.
    # args - Zero or more values to pass to method as parameters.
    def method_missing(meth, *args)
      @app.send(meth, *args)
    end

    private

    # Print a given item to terminal.
    #
    # item    - The Object item to print.
    # index   - The Integer position of item in list.
    # options - The Hash options used to control background color (default:
    #           { x: 3, reverse: false}).
    #           :x       - The Integer x position to print (optional).
    #           :reverse - The Boolean whether to reverse the foreground and
    #                      background color or not (optional).
    def print_item(item, index, x: 3, reverse: false)
      term.color_black(reverse: reverse) do
        term.print_block(index + 4, x, item_title(item))
      end
    end

    # Title of item for terminal. Child classes using `print_item` should
    # implement this method.
    #
    # _item - The Object item to print.
    #
    # Raises NotImplementedError.
    def item_title(_item)
      fail NotImplementedError
    end
  end
end
