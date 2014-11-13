require 'active_support/inflector'
require_relative 'terminal'
require_relative 'processor'
require_relative 'helper'
require_relative 'editor'
Dir[File.expand_path('../processors/*.rb', __FILE__)].each { |f| require f }
Dir[File.expand_path('../helpers/*.rb', __FILE__)].each { |f| require f }
Dir[File.expand_path('../editors/*.rb', __FILE__)].each { |f| require f }

# Terminal application of Loco. To run, use Application class.
#
# Examples
#
#   TermApp::Application.new.run
module TermApp
  # Application of TermApp.
  #
  # Examples
  #
  #   app = TermApp::Application.new
  #   app.run
  class Application
    # Returns the Terminal instance of the application.
    attr_reader :term

    # Initialize a Application. Initialize a Terminal.
    def initialize(debug: false)
      @term = Terminal.new(debug: debug)
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
          klass = "TermApp::#{name.to_s.classify}".constantize
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
