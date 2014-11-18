module TermApp
  # Helper methods for TermApp.
  class Helper
    def initialize(app)
      @app = app
    end

    protected

    def term
      @app.term
    end
  end
end
