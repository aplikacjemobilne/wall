include ActionController::HttpAuthentication::Token::ControllerMethods

class ApplicationController < ActionController::API
    def authenticate_token
      authenticate_with_http_token do |token, options|
        @user ||= User.find_by(token: token)
      end
    end

    def render_unauthorized(message)
      errors = { errors: [ { detail: message } ] }
      render json: errors, status: :unauthorized
    end

    def require_token
      authenticate_token || render_unauthorized("Access denied")
    end
end
