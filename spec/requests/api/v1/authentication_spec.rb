require 'rails_helper'

RSpec.describe "Api::V1::Authentication", type: :request do
  describe "POST /api/v1/auth/register" do
    it "creates a user and returns a JWT" do
      post "/api/v1/auth/register", params: {
        name: "New User", email: "new@example.com", password: "password123"
      }

      expect(response).to have_http_status(:created)
      body = response.parsed_body
      expect(body["token"]).to be_present
      expect(body["user"]["email"]).to eq("new@example.com")
    end

    it "returns errors for invalid data" do
      post "/api/v1/auth/register", params: { name: "", email: "bad", password: "1" }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.parsed_body["errors"]).to be_present
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, email: "login@example.com", password: "password123") }

    it "returns a token with valid credentials" do
      post "/api/v1/auth/login", params: { email: "login@example.com", password: "password123" }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["token"]).to be_present
    end

    it "rejects invalid credentials" do
      post "/api/v1/auth/login", params: { email: "login@example.com", password: "wrong" }
      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /api/v1/auth/me" do
    let(:user) { create(:user) }

    it "returns the current user when authenticated" do
      get "/api/v1/auth/me", headers: auth_headers(user)
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.dig("data", "attributes", "email")).to eq(user.email)
    end

    it "returns 401 without a token" do
      get "/api/v1/auth/me"
      expect(response).to have_http_status(:unauthorized)
    end
  end
end
