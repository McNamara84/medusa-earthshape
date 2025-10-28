FactoryGirl.define do
  factory :technique do
    sequence(:name) { |n| "double_spike_#{n}" }
  end
end