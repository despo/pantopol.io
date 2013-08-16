json.array!(@products) do |product|
  json.extract! product, :store_id, :price, :date, :unit
  json.url product_url(product, format: :json)
end
