require 'active_support/inflector'
require_relative 'terminal'

module TermApp
  class Application
    # Returns the Terminal instance of the application.
    attr_reader :term

    # Initialize a Application and run it.
    #
    # Returns nothing.
    def self.run
      new.run
    end

    # Initialize a Application. Initialize a Terminal.
    def initialize
      @term = Terminal.new
      @cached_views = {}
    end

    # Run process of a passed Processors. Get the name of a Processor and
    # process it with the passed arguments.
    #
    # name - The Symbol of a class inheriting Processor to process.
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

    # Main routine of the Application. Process a Processor until it returns next
    # processor as nil. Terminate the term at the finish.
    #
    # Returns nothing.
    def run
      next_processor = :login_menu
      next_processor = process(*next_processor) while next_processor
    ensure
      @term.terminate
    end
  end

  # Main routine of the TermApp. Run the Application.
  #
  # Returns nothing.
  def self.run
    Application.run
  end
end
