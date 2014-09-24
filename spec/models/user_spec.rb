require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  it 'is a valid factory' do
    expect(user).to be_valid
    expect(user.save).to be true
  end

  it 'should not be created with an empty username' do
    [nil, ''].each do |username|
      user.username = username
      expect(user).not_to be_valid
      expect(user.errors.keys).to include(:username)
    end
  end

  it 'should not be created with an duplicated username' do
    duplicated_user = user.dup
    user.save!
    expect(duplicated_user).not_to be_valid
    expect(duplicated_user.errors.keys).to include(:username)
  end

  it 'should be created with an unique username' do
    user.save!
    another_user = build(:user)
    expect(another_user).to be_valid
    expect(another_user.save).to be true
  end
end
