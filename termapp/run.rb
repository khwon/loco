require_relative '../config/environment'
require_relative 'locoterm'
require_relative 'user'
require_relative 'welcome'
require_relative 'menu'
require 'pry-remote'
locoterm = nil
begin
  locoterm = LocoTerm.new
  do_login(locoterm)
  show_welcome(locoterm)
  LocoMenu.main(locoterm)
  locoterm.getch
rescue
  binding.remote_pry
  # $stderr.puts $!
  # $stderr.puts $@
ensure
  locoterm.terminate
end
