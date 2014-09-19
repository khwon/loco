require 'rails_helper'
require 'processor'
require 'processors/welcome_menu'

RSpec.describe TermApp::WelcomeMenu, type: :termapp do
  it_behaves_like 'a processor'
end
