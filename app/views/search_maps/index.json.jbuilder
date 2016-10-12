json.array!(@search_maps) do |search_map|
  json.extract! search_map, :id
  json.url search_map_url(search_map, format: :json)
end
