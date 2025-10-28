FactoryGirl.define do
  factory :analysis do
    name "分析１"
    description "説明１"
    association :technique, factory: :technique
    association :device, factory: :device
    operator "オペレータ１"
    
    # Analysis has many stones through analysis_stones (many-to-many relationship)
    # To add stones, use: after(:create) { |analysis| analysis.stones << create(:stone) }
    # or create analysis_stones separately
  end
end