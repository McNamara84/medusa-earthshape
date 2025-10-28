FactoryGirl.define do
  factory :stonecontainer_type do
    sequence(:name) { |n| "Container Type #{n}" }
  end
end
