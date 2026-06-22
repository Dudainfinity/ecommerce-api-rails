# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Folder where the generated OpenAPI files live (served by rswag-api).
  config.openapi_root = Rails.root.join('swagger').to_s

  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'E-commerce API',
        version: 'v1',
        description: 'API RESTful pura de e-commerce em Ruby on Rails, com autenticação JWT, ' \
                     'serialização JSON:API e PostgreSQL.',
        contact: { name: 'Dudainfinity', url: 'https://github.com/Dudainfinity/ecommerce-api-rails' },
        license: { name: 'MIT', url: 'https://opensource.org/licenses/MIT' }
      },
      servers: [
        { url: 'http://localhost:3000', description: 'Desenvolvimento' },
        {
          url: '{scheme}://{host}',
          description: 'Customizado',
          variables: {
            scheme: { default: 'https', enum: %w[http https] },
            host: { default: 'localhost:3000' }
          }
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: 'JWT',
            description: 'Informe o token retornado por /auth/login ou /auth/register.'
          }
        },
        schemas: {
          Error: {
            type: :object,
            properties: { error: { type: :string, example: 'Unauthorized: missing or invalid token' } }
          },
          ValidationErrors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string },
                example: [ "Email has already been taken", "Password is too short (minimum is 6 characters)" ]
              }
            }
          },
          AuthResponse: {
            type: :object,
            properties: {
              token: { type: :string, example: 'eyJhbGciOiJIUzI1NiJ9...' },
              user: {
                type: :object,
                properties: {
                  name:  { type: :string, example: 'Maria Cliente' },
                  email: { type: :string, example: 'cliente@example.com' },
                  role:  { type: :string, enum: %w[customer admin], example: 'customer' },
                  created_at: { type: :string, format: 'date-time' }
                }
              }
            }
          }
        }
      },
      paths: {}
    }
  }

  config.openapi_format = :yaml
end
