json.array!(@collectors) do |collector|
  json.extract! collector, :id, :name, :affiliation, :stone_id
  json.url collector_url(collector, format: :json)
end
