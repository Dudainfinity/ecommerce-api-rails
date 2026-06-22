# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Pedidos', type: :request do
  path '/api/v1/orders' do
    get 'Lista os pedidos do usuário autenticado' do
      tags 'Pedidos'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'lista de pedidos' do
        let(:customer) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: customer.id)}" }
        before { create(:order, user: customer) }
        run_test!
      end

      response '401', 'não autenticado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { '' }
        run_test!
      end
    end

    post 'Cria um pedido a partir de itens' do
      tags 'Pedidos'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer, example: 1 },
                quantity: { type: :integer, example: 2 }
              },
              required: %w[product_id quantity]
            }
          }
        },
        required: %w[items]
      }

      response '201', 'pedido criado (baixa o estoque)' do
        let(:customer) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: customer.id)}" }
        let(:product) { create(:product, stock: 10) }
        let(:order) { { items: [ { product_id: product.id, quantity: 2 } ] } }
        run_test!
      end

      response '422', 'quantidade acima do estoque' do
        schema '$ref' => '#/components/schemas/ValidationErrors'
        let(:customer) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: customer.id)}" }
        let(:product) { create(:product, stock: 1) }
        let(:order) { { items: [ { product_id: product.id, quantity: 999 } ] } }
        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}/cancel' do
    parameter name: :id, in: :path, type: :integer

    post 'Cancela um pedido e devolve o estoque' do
      tags 'Pedidos'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'pedido cancelado' do
        let(:customer) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: customer.id)}" }
        let(:id) { create(:order, user: customer).id }
        run_test!
      end
    end
  end
end
