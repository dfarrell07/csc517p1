class UsersController < ApplicationController
  before_filter :get_user, only: [:show, :update, :edit, :destroy]
  before_filter :check_logged_in, only: [:edit, :update, :destroy]
  before_filter :check_owns_or_privileged, only: [:edit, :update, :destroy]
  before_filter :check_not_super, only: [:destroy]
  before_filter :check_not_admin_on_admin, only: [:destroy, :edit]

  def new
    if first_user?
      flash[:notice] = "Welcome to your new app! Create your Super Admin!"
    end
    @user = User.new
  end

  def create
    if first_user?
      handle_first_user
      return
    end

    if modifying_super?
      flash[:error] = "There can only be one Super Admin!"
      redirect_to sign_up_path
      return
    end
      
    if is_logged_out? and modifying_admin?
      flash[:error] = "You can't create an admin, who are you?!"
      redirect_to sign_up_path
      return
    end

    if my_rights == "user" and modifying_admin?
      flash[:error] = "You can't create an admin/super, you're a user!"
      redirect_to sign_up_path
      return
    end

    @user = User.new(user_params)
    if @user.save
      flash[:notice] = "Signed up!"
      redirect_to log_in_path
    else
      render "new"
    end
  end

  def show
    if is_logged_out?
      flash[:error] = "You can view credentials! Who are you!?"
      @user = nil
      redirect_to users_path
      return
    end

    if my_rights == "user" and !owns?
      flash[:error] = "Users can't view other user's credentials!"
      @user = nil
      redirect_to users_path
      return
    end

    if my_rights == "admin" and @user.rights != "user" and !owns?
      flash[:error] = "You can only edit user/your credentials!"
      @user = nil
      redirect_to users_path
      return
    end

    if my_rights != "super" and @user.rights == "super"
      flash[:error] = "Only the Super Admin can view their data!"
      @user = nil
      redirect_to users_path
    end
  end

  def index
    @users = User.all
  end

  def edit
  end

  def update
    if @user.rights == "super" and user_params[:rights] != "super"
      flash[:error] = "You can't demote the Super Admin!"
      redirect_to users_path
      return
    end

    @user.update(user_params)
    if @user.save
      flash[:notice] = "User updated!"
    else
      flash[:error] = "Failed up save user update."
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
    params.require(:user).permit(:email, :user_name, :password, :rights, :id, :password_confirmation, :password_digest)
  end

  def first_user?
    User.count == 0
  end

  def handle_first_user
    @user = User.new(user_params)
    flash[:notice] = "You're the first user! You were upgraded to Super Admin!"
    @user.rights = "super"
    if @user.save
      redirect_to root_url
    #else
    #  render "new"
    end
  end
    
  # Helpers for checking the rights of the user being edited
  def modifying_user?; user_params[:rights] == "user"; end
  def modifying_admin?; user_params[:rights] == "admin"; end
  def modifying_super?; user_params[:rights] == "super"; end

  # Helpers for checking the rights of the user we're serving
  def is_logged_out?; session[:user_id] == nil; end
  #def is_user?; session[:user_id] == "user"; end
  #def is_admin?; session[:user_id] == "admin"; end
  #def is_super?; session[:user_id] == "super"; end

  def my_rights
    if is_logged_out?
      return nil
    end
    User.find(session[:user_id]).rights
  end

  def get_user
    @user = User.find(params[:id])
  end

  def owns?
    session[:user_id] == @user.id
  end

  def check_owns_or_privileged
    if session[:user_id] != @user.id and my_rights == "user"
      flash[:error] = "You can only edit your own account!"
      redirect_to users_path
      return
    end
  end

  def check_logged_in
    if session[:user_id].nil?
      flash[:error] = "You must be logged in!"
      redirect_to users_path
    end
  end

  def check_not_super
    if @user.rights == "super"
      flash[:error] = "You can't delete the Super Admin!"
      redirect_to users_path
    end
  end

  def check_not_admin_on_admin
    if @user.rights != "user" and User.find(session[:user_id]).rights == "admin" and session[:user_id] != @user.id
      flash[:error] = "Admins can't edit other admin's data!"
      redirect_to users_path
    end
  end
end
