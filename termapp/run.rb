root = File.expand_path(File.dirname(__FILE__))
require "#{root}/../config/environment.rb"
require "#{root}/terminal"
require "#{root}/application"
require "#{root}/view"
Dir["#{root}/views/*.rb"].each{ |f| require f }

require 'pry-remote'

begin
  TermApp.run
rescue => e
  binding.pry_remote
end
  