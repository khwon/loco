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

  it 'should not be created with same name under same parent' do
    duplicated_child_board = build(:child_board,
                                   parent: child_board.parent,
                                   name: child_board.name)
    root_board.save!
    child_board.save!
    expect(duplicated_child_board).not_to be_valid
    expect(duplicated_child_board.errors.keys).to include(:name)
  end

  it 'should be created with an unique name under same parent' do
    another_child_board = build(:child_board, parent: child_board.parent)
    root_board.save!
    child_board.save!
    expect(another_child_board).to be_valid
    expect(another_child_board.save).to be true
  end

  it 'should be created with same name under different parent' do
    root_board.save!
    child_board.save!
    another_root_board = create(:root_board)
    another_child_board = build(:child_board,
                                parent: another_root_board,
                                name: child_board.name)
    expect(another_child_board).to be_valid
    expect(another_child_board.save).to be true
  end

  it 'should be created with an empty owner when it is dir' do
    root_board.owner = nil
    expect(root_board).to be_valid
    expect(root_board.save).to be true
  end

  it 'should not be created with an empty owner when it is not dir' do
    root_board.save!
    child_board.owner = nil
    expect(child_board).not_to be_valid
    expect(child_board.errors.keys).to include(:owner)
  end
end
