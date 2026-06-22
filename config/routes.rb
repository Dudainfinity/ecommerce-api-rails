Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"
  # Health check — retorna 200 se a aplicação sobe sem exceções.
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Autenticação
      post "auth/register", to: "authentication#register"
      post "auth/login",    to: "authentication#login"
      get  "auth/me",       to: "authentication#me"

      # Catálogo
      resources :categories
      resources :products

      # Pedidos
      resources :orders, only: %i[index show create] do
        member do
          post :cancel
        end
      end
    end
  end

  # Raiz da API — metadados básicos do serviço
  root to: ->(_env) {
    [ 200, { "Content-Type" => "application/json" },
     [ { name: "ecommerce-api-rails", status: "ok", docs: "/README.md" }.to_json ] ]
  }
end
