require_relative '../config/environment'
require_relative 'application'
require_relative 'view'
Dir[File.expand_path('../views/*.rb', __FILE__)].each { |f| require f }

begin
  TermApp.run
rescue
  binding.pry_remote
end
