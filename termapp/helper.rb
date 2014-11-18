module TermApp
  # Helper methods for TermApp.
  class TermHelper
    def initialize(app)
      @app = app
    end

    protected

    def term
      @app.term
    end
  end
end
