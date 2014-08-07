# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    username 'johndoe'
    password 'password'
    nickname 'Rockstar'
    realname 'John Doe'
    sex 'M'
    email 'johndoe@example.com'
  end
end
