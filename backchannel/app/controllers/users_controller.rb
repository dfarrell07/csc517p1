class UsersController < ApplicationController
  before_filter :get_user, only: [:show, :update, :edit, :destroy]
  before_filter :check_logged_in, only: [:edit, :update, :destroy]
  before_filter :check_owns_or_admin, only: [:edit, :update, :destroy]
  before_filter :check_not_super, only: [:destroy]

  def new
    if User.count == 0
      flash[:notice] = "Welcome to your new app! Create your Super Admin!"
    end
    @user = User.new
  end

  def create
    if User.count == 0 and user_params[:rights] != "super"
      @only_account = true
    elsif user_params[:rights] != "user"
      if session[:user_id].nil?
        flash[:error] = "You can't create an admin, who are you?!"
        redirect_to log_in_path
        return
      end
      if User.find(session[:user_id]).rights == "user"
        flash[:error] = "You can't create an admin, you're a user!"
        redirect_to users_path
        return
      end
    end

    @user = User.new(user_params.except(:confirm_password))
    if @only_account == true
      flash[:notice] = "You're the first user! You were upgraded to Super Admin!"
      @user.rights = "super"
    end
    if @user.save
      flash[:notice] = "Signed up!"
      redirect_to root_url
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
    if @user.rights == "super" and user_params[:rights] != "super"
      flash[:error] = "You can't demote the Super Admin!"
    else
      @user.update(user_params.except(:confirm_password))
      if @user.save == false
        flash[:error] = "Failed up save user update."
      else
        flash[:notice] = "User updated!"
      end
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

  def check_not_super
    if @user.rights == "super"
      flash[:notice] = "You can't delete the Super Admin!"
      redirect_to users_path
    end
  end

end
