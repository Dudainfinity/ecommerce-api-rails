Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Health check — returns 200 if the app boots with no exceptions.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Authentication
      post "auth/register", to: "authentication#register"
      post "auth/login",    to: "authentication#login"
      get  "auth/me",       to: "authentication#me"

      # Catalog
      resources :categories
      resources :products

      # Orders
      resources :orders, only: %i[index show create] do
        member do
          post :cancel
        end
      end
    end
  end

  # API root — basic service metadata
  root to: ->(_env) {
    [ 200, { "Content-Type" => "application/json" },
     [ { name: "ecommerce-api-rails", status: "ok", docs: "/README.md" }.to_json ] ]
  }
end
