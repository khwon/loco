module TermApp
  class View
    def initialize(app)
      @app = app
    end

    # delegates all missing methods to application
    def method_missing(name, *args)
      @app.send(name, *args)
    end
  end
end
