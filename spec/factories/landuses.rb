# frozen_string_literal: true

FactoryBot.define do
  factory :landuse do
    sequence(:name) { |n| "Landuse #{n}" }
  end
end
