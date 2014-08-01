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

    # Internal: Run process of a passed Processors. Get the name of a Processor
    # and process it with the passed arguments.
    #
    # name - The Symbol of a class inheriting TermApp::Processor to process.
    # args - Zero or more values to pass to process method of class as
    #        parameters.
    #
    # Returns a Symbol of Processor with its process arguments or nil.
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

    # Internal: Main routine of the Application. Process a Processor until it
    # returns next processor as nil. Terminate the term at the finish.
    #
    # Returns nothing.
    def run
      next_processor = :login_menu
      next_processor = process(*next_processor) while next_processor
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
