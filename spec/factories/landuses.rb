# frozen_string_literal: true

FactoryBot.define do
  factory :landuse do
    sequence(:name) { |n| "Landuse #{n}" }
    association :place
  end
end
