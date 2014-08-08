require_relative '../config/environment'
require_relative 'application'

begin
  TermApp.run
rescue
  binding.pry_remote
end
