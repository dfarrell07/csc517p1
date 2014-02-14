class UsersController < ApplicationController
  before_filter :get_user, only: [:show, :update, :edit, :destroy]

  def create
    if params[:password] != params[:confirm_password]
      flash[:error] = "Password and confirmation didn't match."
    else
      @user = User.new(user_params)
      @user.save
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
    @user.update(user_params)
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

  private

  def user_params
    params.require(:user).permit(:email, :user_name, :password, :rights, :id)
  end

  def get_user
    @user = User.find(params[:id])
  end

end
