FactoryGirl.define do
  factory :analysis_stone do
    association :analysis, factory: :analysis
    association :stone, factory: :stone
  end
end
