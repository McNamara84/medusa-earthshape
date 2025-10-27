FactoryGirl.define do
  factory :topographic_position do
    sequence(:name) { |n| "Topographic Position #{n}" }
  end
end
