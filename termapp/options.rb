require 'optparse'

module TermApp
  # Handle command line options.
  class Options
    # Initialize a Options.
    def initialize
      @options = {}
    end

    # Parse the passed arguments to a Hash.
    #
    # args - An Array of Strings containing options.
    #
    # Returns an Array containing a Hash options and an Array of Strings
    #   remaining arguments.
    def parse(args)
      OptionParser.new do |opts|
        opts.banner = 'Usage: term [options]'

        opts.on('-d', '--debug', 'Enable debug') do |v|
          @options[:debug] = v
        end
      end.parse!(args)
      [@options, args]
    end
  end
end
