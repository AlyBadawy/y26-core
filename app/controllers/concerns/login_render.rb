module LoginRender
  extend ActiveSupport::Concern

  private

  def render_login
    user_json = JSON.parse(render_to_string(partial: "api/v1/accounts/user", formats: [:json], locals: { user: @user }))
      SessionCreator.create_session!(@user, request)
      render status: :created,
             json: {
               access_token: AuthEncoder.encode(Current.session),
               refresh_token: Current.session.refresh_token,
               refresh_token_expires_at: Current.session.refresh_token_expires_at,
               user: user_json,
             }
  end
end
