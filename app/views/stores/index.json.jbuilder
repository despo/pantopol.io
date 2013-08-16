json.array!(@stores) do |store|
  json.extract! store, :city_id, :name, :address, :identifier_string
  json.url store_url(store, format: :json)
end
