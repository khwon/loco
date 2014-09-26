require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:post) { build(:post) }

  it 'is a valid factory' do
    expect(post).to be_valid
    expect(post.save).to be true
  end

  it 'should have board' do
    post.board = nil
    expect(post).not_to be_valid
    expect(post.errors.keys).to include(:board)
  end

  it 'should have writer' do
    post.writer = nil
    expect(post).not_to be_valid
    expect(post.errors.keys).to include(:writer)
  end

  it 'should have num' do
    post.num = nil
    expect(post).not_to be_valid
    expect(post.errors.keys).to include(:num)
  end

  it 'should have num which is greater than or equal to 1' do
    [0, -1, -99].each do |num|
      post.num = num
      expect(post).not_to be_valid
      expect(post.errors.keys).to include(:num)
    end
  end

  it 'should not be created with same num in same board' do
    duplicated_post = build(:post, board: post.board, num: post.num)
    post.save!
    expect(duplicated_post).not_to be_valid
    expect(duplicated_post.errors.keys).to include(:num)
  end

  it 'should be created with same num in different board' do
    another_board = create(:child_board)
    another_post = build(:post, board: another_board, num: post.num)
    post.save!
    expect(another_post).to be_valid
    expect(another_post.save).to be true
  end
end
