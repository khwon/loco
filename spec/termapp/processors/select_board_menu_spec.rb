require 'rails_helper'
require 'processor'
require 'processors/select_board_menu'

RSpec.describe SelectBoardMenu, type: :termapp do
  it_behaves_like 'a processor'
end
