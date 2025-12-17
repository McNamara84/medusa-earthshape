FactoryBot.define do
  factory :preparation do
    info { "Test preparation info" }
    stone { nil }
    preparation_type { nil }

    # Trait for preparation with stone association
    trait :with_stone do
      association :stone, factory: :stone
    end

    # Trait for preparation with preparation_type association
    trait :with_preparation_type do
      association :preparation_type, factory: :preparation_type
    end

    # Trait for preparation with both associations
    trait :with_associations do
      with_stone
      with_preparation_type
    end
  end
end
