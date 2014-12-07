# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :root_board, class: Board do
    parent_id nil
    is_dir true
    sequence(:name) { |n| "continent#{n}" }

    factory :board_with_children do
      transient do
        child_count 5
      end

      after(:create) do |board, evaluator|
        create_list(:child_board, evaluator.child_count, parent: board)
      end
    end
  end

  factory :child_board, class: Board do
    association :parent, factory: :root_board
    is_dir false
    sequence(:name) { |n| "country#{n}" }
    association :owner, factory: :user
  end
end
