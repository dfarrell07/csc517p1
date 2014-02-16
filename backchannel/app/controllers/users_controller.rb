class UsersController < ApplicationController
  before_filter :get_user, only: [:show, :update, :edit, :destroy]
  before_filter :check_logged_in, only: [:edit, :update, :destroy]
  #before_filter :check_logged_in, only: [:check_owns_or_admin]
  before_filter :check_owns_or_admin, only: [:edit, :update, :destroy]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params.except(:confirm_password))
    if @user.save
      redirect_to root_url, :notice => "Signed up!"
    else
      render "new"
    end
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

  def check_owns
    if session[:user_id] != @user.id
      flash[:notice] = "You can only edit your own account!"
      redirect_to users_path
    end
  end

  def check_owns_or_admin
    if session[:user_id] != @user.id and User.find(session[:user_id]).rights == "user"
      flash[:notice] = "You can only edit your own account!"
      redirect_to users_path
    end
  end

  def check_logged_in
    if session[:user_id].nil?
      flash[:notice] = "You must be logged in!"
      redirect_to users_path
    end
  end

end
