require 'rails_helper'

RSpec.describe "Api::V1::Orders", type: :request do
  let(:customer) { create(:user) }
  let(:product)  { create(:product, price: 100, stock: 10) }

  describe "POST /api/v1/orders" do
    it "creates an order and decrements stock" do
      post "/api/v1/orders",
           params: { items: [{ product_id: product.id, quantity: 2 }] },
           headers: auth_headers(customer)

      expect(response).to have_http_status(:created)
      expect(response.parsed_body.dig("data", "attributes", "total").to_f).to eq(200.0)
      expect(product.reload.stock).to eq(8)
    end

    it "rejects orders that exceed available stock" do
      post "/api/v1/orders",
           params: { items: [{ product_id: product.id, quantity: 999 }] },
           headers: auth_headers(customer)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(product.reload.stock).to eq(10)
    end

    it "requires authentication" do
      post "/api/v1/orders", params: { items: [{ product_id: product.id, quantity: 1 }] }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/orders" do
    it "only returns the current user's orders" do
      other = create(:user)
      post "/api/v1/orders", params: { items: [{ product_id: product.id, quantity: 1 }] }, headers: auth_headers(customer)
      post "/api/v1/orders", params: { items: [{ product_id: product.id, quantity: 1 }] }, headers: auth_headers(other)

      get "/api/v1/orders", headers: auth_headers(customer)
      expect(response.parsed_body["data"].size).to eq(1)
    end
  end

  describe "POST /api/v1/orders/:id/cancel" do
    it "cancels a pending order and restores stock" do
      post "/api/v1/orders", params: { items: [{ product_id: product.id, quantity: 3 }] }, headers: auth_headers(customer)
      order_id = response.parsed_body.dig("data", "id")

      post "/api/v1/orders/#{order_id}/cancel", headers: auth_headers(customer)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "attributes", "status")).to eq("cancelled")
      expect(product.reload.stock).to eq(10)
    end
  end
end
