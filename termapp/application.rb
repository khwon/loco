require 'active_support/inflector'
module TermApp
  class Application
    attr_reader :term

    def initialize
      @term = Terminal.new
      @cached_views = {}
    end

    def process(name, *args)
      view = @cached_views[name] ||= begin
        klass = name.to_s.classify.constantize
        klass.new(self)
      rescue NameError
        NotImplementedMenu.new(name, self)
      end
      view.process(*args)
    end

    def run
      next_view = :login_menu
      next_view = process(*next_view) while next_view
    end
  end

  def self.run
    app = Application.new
    app.run
  ensure
    app.term.terminate
  end
end
