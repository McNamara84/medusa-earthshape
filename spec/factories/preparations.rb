FactoryBot.define do
  factory :preparation do
    info { "Test preparation info" }
    association :stone, factory: :stone
    association :preparation_type, factory: :preparation_type
  end
end
