require 'rails_helper'

RSpec.describe "Api::V1::Products", type: :request do
  let(:category) { create(:category) }
  let(:admin)    { create(:admin) }
  let(:customer) { create(:user) }

  describe "GET /api/v1/products" do
    it "lists products without authentication" do
      create_list(:product, 3, category: category)
      get "/api/v1/products"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["data"].size).to eq(3)
    end

    it "filters by search term" do
      create(:product, name: "Ruby Mug", category: category)
      create(:product, name: "Coffee", category: category)
      get "/api/v1/products", params: { q: "ruby" }
      expect(response.parsed_body["data"].size).to eq(1)
    end
  end

  describe "POST /api/v1/products" do
    let(:valid_params) do
      { name: "Keyboard", price: 199.9, sku: "KB-1", stock: 5, category_id: category.id }
    end

    it "allows an admin to create a product" do
      post "/api/v1/products", params: valid_params, headers: auth_headers(admin)
      expect(response).to have_http_status(:created)
    end

    it "forbids a regular customer from creating a product" do
      post "/api/v1/products", params: valid_params, headers: auth_headers(customer)
      expect(response).to have_http_status(:forbidden)
    end

    it "rejects unauthenticated requests" do
      post "/api/v1/products", params: valid_params
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "DELETE /api/v1/products/:id" do
    it "allows an admin to delete a product" do
      product = create(:product, category: category)
      delete "/api/v1/products/#{product.id}", headers: auth_headers(admin)
      expect(response).to have_http_status(:no_content)
      expect(Product.exists?(product.id)).to be(false)
    end
  end
end
