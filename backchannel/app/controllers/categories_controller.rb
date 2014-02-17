class CategoriesController < ApplicationController
  before_filter :get_category, only: [:edit, :destroy, :update, :show]
  before_filter :check_logged_in, only: [:edit, :destroy, :update, :create]
  before_filter :check_admin, only: [:edit, :destroy, :update]

  def new
  end

  def show
  end

  def create
    if category_exists?
      flash[:error] = "Category aleady exists!"
    else
      @category = Category.new(category_params)
      if !admin?
        @category.status = "pending"
      else
        @category.status = "approved"
      end
      if @category.save
        flash[:notice] = "Category proposed!"
      else
        flash[:notice] = "Unable to save category for unknown reason! :("
      end
    end
    redirect_to categories_path
  end

  def index
    @categories = Category.all
  end

  def edit
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  def update
    @category.update(category_params)
    if @category.save == false
      flash[:error] = "Failed up save category update."
    else
      flash[:notice] = "Category updated!"
    end
    redirect_to categories_path
  end

  private

  def category_params
    params.require(:category).permit(:name, :status)
  end

  def get_category
    @category = Category.find(params[:id])
  end

  def category_exists?
    Category.exists?(category_params)
  end

  def admin? 
    if User.find(session[:user_id]).rights != "user"
      true
    else
      false
    end
  end

  def check_admin
    if !admin?
      flash[:error] = "You must be an admin to approve/reject categories!"
      redirect_to categories_path
      return
    end
  end

  def check_logged_in
    if !User.exists?(session[:user_id])
      flash[:error] = "You must be logged in!"
      redirect_to categories_path
      return
    end
  end

end
