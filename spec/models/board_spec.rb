require 'rails_helper'

RSpec.describe Board, type: :model do
  let(:root_board) { build(:root_board) }
  let(:child_board) { build(:child_board) }

  it 'is a valid factory' do
    expect(root_board).to be_valid
    expect(root_board.save).to be true
    expect(child_board).to be_valid
    expect(child_board.save).to be true
  end

  it 'should not be created with an empty name' do
    [nil, ''].each do |name|
      root_board.name = name
      child_board.name = name
      expect(root_board).not_to be_valid
      expect(root_board.errors.keys).to include(:name)
      expect(child_board).not_to be_valid
      expect(child_board.errors.keys).to include(:name)
    end
  end
end
