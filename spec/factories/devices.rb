FactoryGirl.define do
  factory :device do
    sequence(:name) { |n| "EPMA_#{n}" }
  end
end
