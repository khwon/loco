require 'rails_helper'
require 'processor'
require 'processors/goodbye_menu'

RSpec.describe TermApp::GoodbyeMenu, type: :termapp do
  it_behaves_like 'a processor'
end
