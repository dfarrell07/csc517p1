class CategoriesController < ApplicationController
  #before_filter :, :only: [:create]

  def new
  end

  def create
    if category_exists?
      flash[:error] = "Category aleady exists!"
    else
      @category = Category.new(category_params)
      @category.status = "pending"
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

  private

  def category_params
    params.require(:category).permit(:name, :status)
  end

  def category_exists?
    Category.exists?(category_params)
  end

end
