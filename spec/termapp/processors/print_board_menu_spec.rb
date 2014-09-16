require 'rails_helper'
require 'processor'
require 'processors/print_board_menu'

RSpec.describe PrintBoardMenu, type: :termapp do
  it_behaves_like 'a processor'
end
