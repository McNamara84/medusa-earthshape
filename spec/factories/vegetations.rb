# frozen_string_literal: true

FactoryBot.define do
  factory :vegetation do
    sequence(:name) { |n| "Vegetation #{n}" }
  end
end
