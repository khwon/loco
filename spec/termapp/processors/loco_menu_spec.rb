require 'rails_helper'
require 'processor'
require 'processors/loco_menu'

RSpec.describe TermApp::LocoMenu, type: :termapp do
  it_behaves_like 'a processor'
end
