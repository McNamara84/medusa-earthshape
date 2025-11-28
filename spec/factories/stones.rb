FactoryBot.define do
  factory :stone do
    name "ストーン１"
    stone_type "サンプル１"
    description "説明１"
    parent_id ""
    association :place, factory: :place
    association :box, factory: :box
    association :physical_form, factory: :physical_form
    association :classification, factory: :classification
    association :collection, factory: :collection
    association :stonecontainer_type, factory: :stonecontainer_type
    quantity 1
    quantity_unit "数量単位１"
    quantity_initial 1
    sampledepth 0
    date { Date.today }
  end
end
