require 'rails_helper'
require 'processor'
require 'processors/not_implemented_menu'

RSpec.describe TermApp::NotImplementedMenu, type: :termapp do
  it_behaves_like 'a processor'
end
