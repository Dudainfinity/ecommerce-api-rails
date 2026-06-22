# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Autenticação', type: :request do
  path '/api/v1/auth/register' do
    post 'Registra um novo usuário' do
      tags 'Autenticação'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: 'Maria Cliente' },
          email: { type: :string, example: 'maria@example.com' },
          password: { type: :string, example: 'password123', minLength: 6 }
        },
        required: %w[name email password]
      }

      response '201', 'usuário criado, retorna o token JWT' do
        schema '$ref' => '#/components/schemas/AuthResponse'
        let(:user) { { name: 'Maria Cliente', email: 'maria@example.com', password: 'password123' } }
        run_test!
      end

      response '422', 'dados inválidos' do
        schema '$ref' => '#/components/schemas/ValidationErrors'
        let(:user) { { name: '', email: 'invalido', password: '1' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/login' do
    post 'Autentica um usuário' do
      tags 'Autenticação'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, example: 'cliente@example.com' },
          password: { type: :string, example: 'password123' }
        },
        required: %w[email password]
      }

      response '200', 'autenticado, retorna o token JWT' do
        schema '$ref' => '#/components/schemas/AuthResponse'
        let(:registered) { create(:user, email: 'cliente@example.com', password: 'password123') }
        let(:credentials) { { email: registered.email, password: 'password123' } }
        run_test!
      end

      response '401', 'credenciais inválidas' do
        schema '$ref' => '#/components/schemas/Error'
        let(:credentials) { { email: 'ninguem@example.com', password: 'errada' } }
        run_test!
      end
    end
  end

  path '/api/v1/auth/me' do
    get 'Retorna o usuário autenticado' do
      tags 'Autenticação'
      produces 'application/json'
      security [ bearerAuth: [] ]

      response '200', 'dados do usuário' do
        let(:current) { create(:user) }
        let(:Authorization) { "Bearer #{JsonWebToken.encode(user_id: current.id)}" }
        run_test!
      end

      response '401', 'token ausente ou inválido' do
        schema '$ref' => '#/components/schemas/Error'
        let(:Authorization) { '' }
        run_test!
      end
    end
  end
end
