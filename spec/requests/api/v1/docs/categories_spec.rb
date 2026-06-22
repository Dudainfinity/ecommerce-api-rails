# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Categorias', type: :request do
  path '/api/v1/categories' do
    get 'Lista categorias (público)' do
      tags 'Categorias'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false

      response '200', 'lista de categorias' do
        before { create_list(:category, 2) }
        run_test!
      end
    end

    post 'Cria uma categoria (admin)' do
      tags 'Categorias'
      consumes 'application/json'
      produces 'application/json'
      security [ bearerAuth: [] ]
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Eletrônicos' },
          description: { type: :string, example: 'Gadgets e dispositivos' }
        },
        required: %w[name]
      }

      response '201', 'categoria criada' do
        let(:admin) { create(:admin) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: admin.id)}" }
        let(:category) { { name: 'Eletrônicos', description: 'Gadgets e dispositivos' } }
        run_test!
      end

      response '403', 'usuário sem permissão de admin' do
        schema '$ref' => '#/components/schemas/Error'
        let(:customer) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: customer.id)}" }
        let(:category) { { name: 'Eletrônicos' } }
        run_test!
      end
    end
  end
end
