PriceComparison::Application.routes.draw do
  root to: "dashboard#index"
  resources :products do
    get :latest_city_average, on: :collection
    get :city_average, on: :collection
    get :latest_prices_by_store, on: :collection
    get :prices_by_store, on: :collection
    get :price_graph
    get :all_cities_average_price_graph
    get :all_cities_max_price_graph
    get :all_cities_min_price_graph
    get :top_expensive_stores
    get :top_cheapest_stores
    get :min_and_max, on: :collection
    get :city_stores_prices, on: :collection
    get :all, on: :collection
  end

  resources :stores

  resources :cities
end
