module Api
  module V1
    class AuthenticationController < ApplicationController
      before_action :authenticate_request!, only: :me

      # POST /api/v1/auth/register
      def register
        user = User.new(user_params)

        if user.save
          render json: auth_payload(user), status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # POST /api/v1/auth/login
      def login
        user = User.find_by(email: params[:email].to_s.downcase.strip)

        if user&.authenticate(params[:password])
          render json: auth_payload(user), status: :ok
        else
          render json: { error: "Invalid email or password" }, status: :unauthorized
        end
      end

      # GET /api/v1/auth/me
      def me
        render json: UserSerializer.new(current_user).serializable_hash, status: :ok
      end

      private

      def user_params
        params.permit(:name, :email, :password, :password_confirmation)
      end

      def auth_payload(user)
        {
          token: JsonWebToken.encode(user_id: user.id),
          user: UserSerializer.new(user).serializable_hash[:data][:attributes]
        }
      end
    end
  end
end
