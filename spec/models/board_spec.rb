require 'rails_helper'

RSpec.describe Board, type: :model do
  it 'is a valid factory' do
    root_board = build(:root_board)
    child_board = build(:child_board)
    expect(root_board).to be_valid
    expect(root_board.save).to be true
    expect(child_board).to be_valid
    expect(child_board.save).to be true
  end

  it 'should not be created with an empty name' do
    [nil, ''].each do |name|
      root_board = build(:root_board, name: name)
      child_board = build(:child_board, name: name)
      expect(root_board).not_to be_valid
      expect(root_board.errors.keys).to include(:name)
      expect(child_board).not_to be_valid
      expect(child_board.errors.keys).to include(:name)
    end
  end

  it 'should not be created with same name under same parent' do
    child_board = create(:child_board)
    duplicated_child_board = build(:child_board,
                                   parent: child_board.parent,
                                   name: child_board.name)
    expect(duplicated_child_board).not_to be_valid
    expect(duplicated_child_board.errors.keys).to include(:name)
  end

  it 'should be created with an unique name under same parent' do
    child_board = create(:child_board, name: '1Board')
    another_child_board = build(:child_board,
                                parent: child_board.parent,
                                name: '2Board')
    expect(another_child_board).to be_valid
    expect(another_child_board.save).to be true
  end

  it 'should be created with same name under different parent' do
    root_board = create(:root_board, name: '1Board')
    another_root_board = create(:root_board, name: '2Board')
    child_board = create(:child_board, parent: root_board)
    another_child_board = build(:child_board,
                                parent: another_root_board,
                                name: child_board.name)
    expect(another_child_board).to be_valid
    expect(another_child_board.save).to be true
  end

  it 'should be created with an empty owner when it is dir' do
    root_board = build(:root_board, owner: nil)
    expect(root_board).to be_valid
    expect(root_board.save).to be true
  end

  it 'should not be created with an empty owner when it is not dir' do
    child_board = build(:child_board, owner: nil)
    expect(child_board).not_to be_valid
    expect(child_board.errors.keys).to include(:owner)
  end
end
