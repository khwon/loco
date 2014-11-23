module TermApp
  # Helper methods for TermApp.
  class Helper
    # Initialize a Helper. It holds the Application instance.
    #
    # app - The Application instance which is now running.
    def initialize(app)
      @app = app
    end

    protected

    # Get the Terminal instance of the application.
    #
    # Returns the Terminal instance.
    def term
      @app.term
    end
  end
end
