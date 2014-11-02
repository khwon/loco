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

    protected

    # Classify the key returned by Terminal#get_wch into a symbol.
    #
    # key - The Array returned by Terminal#get_wch.
    #
    # Returns a Symbol type of the key input.
    def key_symbol(key)
      if key[0] == Ncurses::OK
        case key[1]
        when 4   then :ctrl_d
        when 9   then :tab
        when 10  then :enter
        when 21  then :ctrl_u
        when 27  then :esc
        when 32  then :space
        when 127 then :backspace
        else
          key[2].to_sym if key[1] < 127
        end
      elsif key[0] == Ncurses::KEY_CODE_YES
        case key[1]
        when Ncurses::KEY_ENTER     then :enter
        when Ncurses::KEY_BACKSPACE then :backspace
        when Ncurses::KEY_DOWN      then :down
        when Ncurses::KEY_UP        then :up
        end
      end
    end
  end
end
