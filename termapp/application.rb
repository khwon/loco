require 'active_support/inflector'
require_relative 'terminal'

module TermApp
  class Application
    attr_reader :term

    def self.run
      new.run
    end

    def initialize
      @term = Terminal.new
      @cached_views = {}
    end

    def process(name, *args)
      view = @cached_views[name] ||=
        begin
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
    ensure
      @term.terminate
    end
  end

  def self.run
    Application.run
  end
end
