require 'rails_helper'
require 'processor'
require 'processors/read_board_menu'

RSpec.describe TermApp::ReadBoardMenu, type: :termapp do
  it_behaves_like 'a processor'
end
