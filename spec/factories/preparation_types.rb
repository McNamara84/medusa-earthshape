FactoryBot.define do
  factory :preparation_type do
    sequence(:name) { |n| "Preparation Type #{n}" }
  end
end
