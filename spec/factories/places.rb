FactoryGirl.define do
  factory :place do
    name "場所１"
    description "説明１"
    latitude 1
    longitude 1
    elevation 0
    is_parent true
    
    trait :child do
      is_parent false
      association :parent, factory: :place, is_parent: true
      association :topographic_position
    end
  end
end
