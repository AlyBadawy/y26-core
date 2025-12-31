class Api::V1::AccountsController < ApplicationController
  skip_authentication! only: [:create]

  def show
    username = params[:id]
    # TODO: Replace with proper lookup logic for other users
    @user = username == "me" ? Current.user : nil
    if @user
      render :show, status: :ok
    else
      render json: {
        errors: ["User not found"],
        instructions: "Please check the username and try again.",
      }, status: :not_found
    end
  end

  def create
    @user = User.new(user_params)
    if @user.save
      render :show,
             status: :created
    else
      render json: { errors: @user.errors.full_messages },
             status: :unprocessable_content
    end
  end

  def update
    if @user.authenticate(params.expect(user: [:current_password]).dig(:current_password))
      if @user.update(user_params)
        render :show, status: :ok
      else
        render json: { errors: @user.errors.full_messages },
               status: :unprocessable_content
      end
    else
      render json: {
        errors: ["Current password is incorrect"],
        instructions: "Please verify your current password and try again.",
      }, status: :unprocessable_content
    end
  end

  def destroy
    @user = Current.user
    if @user.authenticate(params.expect(user: [:current_password]).dig(:current_password))
      @user.destroy
      render json: { message: "Account deleted successfully" }, status: :ok
    else
      render json: {
        errors: ["Current password is incorrect"],
        instructions: "Please verify your current password and try again.",
      }, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [:email_address, :password, :password_confirmation, :first_name, :last_name, :phone, :username, :bio])
  end
end
