require 'rails_helper'

RSpec.describe Post, type: :model do
  it 'is a valid factory' do
    post = build(:post)
    expect(post).to be_valid
    expect(post.save).to be true
  end

  it 'should have board' do
    post = build(:post, board: nil)
    expect(post).not_to be_valid
    expect(post.errors.keys).to include(:board)
  end

  it 'should have writer' do
    post = build(:post, writer: nil)
    expect(post).not_to be_valid
    expect(post.errors.keys).to include(:writer)
  end

  it 'should have num' do
    post = build(:post, num: nil)
    expect(post).not_to be_valid
    expect(post.errors.keys).to include(:num)
  end

  it 'should have num which is greater than or equal to 1' do
    [0, -1, -99].each do |num|
      post = build(:post, num: num)
      expect(post).not_to be_valid
      expect(post.errors.keys).to include(:num)
    end
  end

  it 'should not be created with same num in same board' do
    post = create(:post)
    duplicated_post = build(:post, board: post.board, num: post.num)
    expect(duplicated_post).not_to be_valid
    expect(duplicated_post.errors.keys).to include(:num)
  end

  it 'should be created with same num in different board' do
    child_board = create(:child_board, name: '1Board')
    another_board = create(:child_board, name: '2Board')
    post = create(:post, board: child_board)
    another_post = build(:post, board: another_board, num: post.num)
    expect(another_post).to be_valid
    expect(another_post.save).to be true
  end
end
