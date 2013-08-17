PriceComparison::Application.routes.draw do
  root to: "dashboard#index"
  resources :products do
    get :latest_city_average, on: :collection
    get :city_average, on: :collection
    get :latest_prices_by_store, on: :collection
    get :prices_by_store, on: :collection
    get :price_graph
  end

  resources :stores

  resources :cities
end
