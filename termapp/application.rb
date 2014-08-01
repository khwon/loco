require 'active_support/inflector'
require_relative 'terminal'

module TermApp
  class Application
    # Internal: Returns the Terminal instance of the application.
    attr_reader :term

    # Internal: Initialize a Application and run it.
    #
    # Returns nothing.
    def self.run
      new.run
    end

    # Internal: Initialize a Application. Initialize a Terminal.
    def initialize
      @term = Terminal.new
      @cached_views = {}
    end

    # Internal: Process the Views.
    #
    # name - The Symbol of a class inheriting TermApp::View to process.
    # args - Zero or more values to pass to process method of class as
    #        parameters.
    #
    # Returns a Symbol of View or an Array consists of a Symbol of View and its
    #   process arguments or nil.
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

    # Internal: Main routine of the Application. Process a View until it returns
    # next view as nil. Terminate the term at the finish.
    #
    # Returns nothing.
    def run
      next_view = :login_menu
      next_view = process(*next_view) while next_view
    ensure
      @term.terminate
    end
  end

  # Internal: Main routine of the TermApp. Run the Application.
  #
  # Returns nothing.
  def self.run
    Application.run
  end
end
