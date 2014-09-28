# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :root_board, class: Board do
    parent_id nil
    is_dir true
    sequence(:name) { |n| "continent#{n}" }
  end

  factory :child_board, class: Board do
    association :parent, factory: :root_board
    is_dir false
    sequence(:name) { |n| "country#{n}" }
    association :owner, factory: :user
  end
end
