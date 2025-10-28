FactoryGirl.define do
  factory :collection do
    sequence(:name) { |n| "Collection #{n}" }
    sequence(:project) { |n| "Project #{n}" }
    samplingstrategy "Random sampling"
  end
end
