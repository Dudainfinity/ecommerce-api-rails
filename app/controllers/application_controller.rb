class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_entity

  attr_reader :current_user

  private

  # Reads the Bearer token, decodes it and loads the current user.
  def authenticate_request!
    header = request.headers["Authorization"]
    token = header.to_s.split(" ").last
    decoded = JsonWebToken.decode(token)

    @current_user = User.find_by(id: decoded[:user_id]) if decoded

    render_unauthorized unless @current_user
  end

  def authorize_admin!
    render json: { error: "Forbidden: admin access required" }, status: :forbidden unless current_user&.admin?
  end

  def render_unauthorized
    render json: { error: "Unauthorized: missing or invalid token" }, status: :unauthorized
  end

  def not_found(exception)
    render json: { error: exception.message }, status: :not_found
  end

  def unprocessable_entity(exception)
    render json: { errors: exception.record.errors.full_messages }, status: :unprocessable_entity
  end
end
