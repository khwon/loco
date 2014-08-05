require_relative '../config/environment'
require_relative 'application'
require_relative 'processor'
Dir[File.expand_path('../processors/*.rb', __FILE__)].each { |f| require f }

begin
  TermApp.run
rescue
  binding.pry_remote
end
