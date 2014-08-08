require 'active_support/inflector'
require_relative 'terminal'
require_relative 'processor'
Dir[File.expand_path('../processors/*.rb', __FILE__)].each { |f| require f }

# Terminal application of Loco.
#
# Examples
#
#   TermApp.run
module TermApp
  extend SingleForwardable

  # Delegates self.run to Application.run. Main routine of the TermApp. Run the
  # Application.
  def_delegator 'TermApp::Application', :run

  # Application of TermApp.
  #
  # Examples
  #
  #   TermApp::Application.run
  class Application
    extend SingleForwardable

    # Delegates self.run to new.run. Initialize a Application and run it.
    def_delegator :new, :run

    # Returns the Terminal instance of the application.
    attr_reader :term

    # Initialize a Application. Initialize a Terminal.
    def initialize
      @term = Terminal.new
      @cached_processors = {}
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
      processor = @cached_processors[name] ||=
        begin
          klass = name.to_s.classify.constantize
          klass.new(self)
        rescue NameError
          NotImplementedMenu.new(name, self)
        end
      processor.process(*args)
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
end
