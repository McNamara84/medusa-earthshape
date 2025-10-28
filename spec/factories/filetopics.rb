FactoryGirl.define do
  factory :filetopic do
    sequence(:name) { |n| "Filetopic #{n}" }
  end
end
