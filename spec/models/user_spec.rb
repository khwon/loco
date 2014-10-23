require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is a valid factory' do
    user = build(:user)
    expect(user).to be_valid
    expect(user.save).to be true
  end

  it 'should not be created with an empty username' do
    [nil, ''].each do |username|
      user = build(:user, username: username)
      expect(user).not_to be_valid
      expect(user.errors.keys).to include(:username)
    end
  end

  it 'should not be created with an duplicated username' do
    user = create(:user)
    duplicated_user = build(:user, username: user.username)
    expect(duplicated_user).not_to be_valid
    expect(duplicated_user.errors.keys).to include(:username)
  end

  it 'should be created with an unique username' do
    user = create(:user, username: 'user1')
    another_user = build(:user,
                         username: 'user2',
                         nickname: user.nickname,
                         realname: user.realname,
                         email: user.email)
    expect(another_user).to be_valid
    expect(another_user.save).to be true
  end
end
