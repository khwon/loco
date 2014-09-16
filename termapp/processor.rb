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
  end
end
