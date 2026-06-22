# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Produtos', type: :request do
  path '/api/v1/products' do
    get 'Lista produtos (público)' do
      tags 'Produtos'
      produces 'application/json'
      parameter name: :q, in: :query, type: :string, required: false, description: 'Busca por nome/descrição'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filtra por categoria'
      parameter name: :active, in: :query, type: :string, required: false, description: 'Apenas ativos ("true")'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'lista de produtos' do
        before { create_list(:product, 3) }
        run_test!
      end
    end

    post 'Cria um produto (admin)' do
      tags 'Produtos'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Teclado Mecânico' },
          description: { type: :string, example: 'Switches blue' },
          price: { type: :number, format: :float, example: 299.9 },
          sku: { type: :string, example: 'KB-001' },
          stock: { type: :integer, example: 25 },
          active: { type: :boolean, example: true },
          category_id: { type: :integer, example: 1 }
        },
        required: %w[name price sku category_id]
      }

      response '201', 'produto criado' do
        let(:admin) { create(:admin) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin.id)}" }
        let(:category) { create(:category) }
        let(:product) { { name: 'Teclado', price: 299.9, sku: 'KB-001', stock: 25, category_id: category.id } }
        run_test!
      end

      response '403', 'usuário sem permissão de admin' do
        schema '$ref' => '#/components/schemas/Error'
        let(:customer) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: customer.id)}" }
        let(:category) { create(:category) }
        let(:product) { { name: 'Teclado', price: 299.9, sku: 'KB-002', stock: 25, category_id: category.id } }
        run_test!
      end

      response '401', 'não autenticado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { '' }
        let(:product) { { name: 'Teclado', price: 1, sku: 'KB-003', stock: 1, category_id: 1 } }
        run_test!
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: :id, in: :path, type: :integer

    get 'Detalha um produto (público)' do
      tags 'Produtos'
      produces 'application/json'

      response '200', 'produto encontrado' do
        let(:id) { create(:product).id }
        run_test!
      end

      response '404', 'produto não encontrado' do
        schema '$ref' => '#/components/schemas/Error'
        let(:id) { 0 }
        run_test!
      end
    end
  end
end
