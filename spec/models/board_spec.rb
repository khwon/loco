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

  describe '.get_list' do
    context 'with no Boards' do
      it 'returns an empty array' do
        expect(Board.get_list).to match_array([])
        expect(Board.get_list(parent_board: nil)).to match_array([])
      end
    end

    context 'with root Boards having no child Boards' do
      let!(:boards) { create_list(:root_board, 3) }

      it 'returns root Boards when :parent_board is nil' do
        list = Board.get_list
        expect(list.size).to eq(3)
        expect(list).to match_array(boards)

        list = Board.get_list(parent_board: nil)
        expect(list.size).to eq(3)
        expect(list).to match_array(boards)
      end

      it 'returns an empty array when :parent_board is a Board' do
        boards.each do |parent|
          expect(Board.get_list(parent_board: parent)).to match_array([])
        end
      end
    end

    context 'with root Boards having child Boards' do
      let!(:boards) { create_list(:board_with_children, 3, child_count: 5) }

      it 'returns root Boards when :parent_board is nil' do
        list = Board.get_list
        expect(list.size).to eq(3)
        expect(list).to match_array(boards)

        list = Board.get_list(parent_board: nil)
        expect(list.size).to eq(3)
        expect(list).to match_array(boards)
      end

      it 'returns child Boards when :parent_board is a Board' do
        boards.each do |parent|
          list = Board.get_list(parent_board: parent)
          expect(list.size).to eq(5)
          expect(list).to match_array(parent.children)
        end
      end
    end
  end
end
