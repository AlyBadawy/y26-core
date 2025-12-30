class Api::V1::SessionsController < ApplicationController
  skip_authentication! only: %i[create update]

  before_action :set_session, only: %i[show destroy]

  def index
    @sessions = Current.user.sessions
  end

  def show
  end

  def create
    params.require([:email_address, :password])
    if user = User.authenticate_by(params.permit([:email_address, :password]))
        render_login_response(user)
    else
        render status: :unauthorized,
               json: {
                 errors: ["Invalid email address or password."],
                 instructions: "Make sure to send the correct 'email_address' and 'password' in the payload",
               }
    end
  end

  def update
    if Current.session = Session.find_by(refresh_token: params[:refresh_token], revoked: false)
        if Current.session.is_valid_session_request?(request)
          Current.session.refresh!
          render status: :ok,
                 json: {
                   access_token: AuthEncoder.encode(Current.session),
                   refresh_token: Current.session.refresh_token,
                   refresh_token_expires_at: Current.session.refresh_token_expires_at,
                 }
          return
        end
    end
      render status: :unprocessable_content, json: {
        error: "Invalid or expired token.",
        instructions: "Please log in again to obtain a new access token.",
      }
  end

  def destroy
    @session.revoke!
      Current.session = nil
      head :no_content
  end

  private

  def set_session
    id = params[:id]
    @session = id ? Current.user.sessions.find(params[:id]) : Current.session
  end

  def render_login_response(user)
      if user.password_expired?
        render status: :forbidden,
               json: {
                 errors: ["Password expired"],
                 instructions: "Please reset your password before logging in.",
               }
      else
        SessionCreator.create_session!(user, request)
        render status: :created,
               json: {
                 access_token: AuthEncoder.encode(Current.session),
                 refresh_token: Current.session.refresh_token,
                 refresh_token_expires_at: Current.session.refresh_token_expires_at,
               }
      end
  end
end
