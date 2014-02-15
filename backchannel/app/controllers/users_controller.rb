class UsersController < ApplicationController
  before_filter :get_user, only: [:show, :update, :edit, :destroy]

  def create
    if user_params[:password] != user_params[:confirm_password]
      flash[:error] = "Password and confirmation didn't match! :("
    elsif User.exists?(:email => user_params[:email])
      flash[:error] = "That email address is taken! :("
    else
      @user = User.new(user_params.except(:confirm_password))
      if @user.save != false
        flash[:notice] = "New user created! :)"
      else
        flash[:error] = "Failed to create user for an unknown reason! :("
      end
    end
    redirect_to users_path
  end

  def show
  end

  def index
    @users = User.all
  end

  def edit
  end

  def update
    @user.update(user_params.except(:confirm_password))
    if @user.save == false
      flash[:error] = "Failed up save user update."
    else
      flash[:notice] = "User updated!"
    end
    redirect_to users_path
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def login
  end

  private

  def user_params
    params.require(:user).permit(:email, :user_name, :password, :rights, :id, :confirm_password)
  end

  def get_user
    @user = User.find(params[:id])
  end

end
