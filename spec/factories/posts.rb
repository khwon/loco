# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :post do
    association :board, factory: :child_board
    association :writer, factory: :user
    title 'Sample title'
    content 'Lorem ipsum dolor sit amet.'
    sequence(:num) { |n| n }
  end
end
