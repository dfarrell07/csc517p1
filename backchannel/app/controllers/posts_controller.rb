class PostsController < ApplicationController
  attr_accessor :category_list
  before_filter :get_post, only: [:show, :update, :edit, :destroy]
  before_filter :get_category, only: [:create]
  before_filter :get_category_list, only: [:new]
  before_filter :check_logged_in, :only => [:new, :create, :edit, :update, :destroy]
  before_filter :check_owns, :only => [:edit, :update]
  before_filter :check_owns_or_admin, :only => [:destroy]
  

  def new
    if logged_in?
      @post = Post.new
    end
  end

  def create
    @post = Post.new(post_params.except(:category))
    #@post.category_id = Category.where(:name => post_params[:category])
    @post.category_id = @category.id
    @post.user_id = session[:user_id]
    @post.save
    flash[:notice] = "Post created!"
    redirect_to @post
  end

  def show
    @user_name = User.find(@post.user_id).user_name
    @category_name = Category.find(@post.category_id).name
  end

  def index
    @posts = Post.all
  end

  def edit
  end

  def update
    @post.update(post_params)
    if @post.save == false
      flash[:error] = "Failed up save post update!"
    else
      flash[:notice] = "Post updated!"
    end
    redirect_to posts_path
  end

  def destroy
    @post.destroy
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :message, :category)
  end

  def get_post
    @post = Post.find(params[:id])
  end

  def get_category
    if Category.where(:name => post_params[:category]).empty?
      @category = nil
    else
      @category = Category.where(:name => post_params[:category])[0]
    end
  end

  def get_category_list
    @category_list = []
    Category.where(:status => "approved").each do |category|
      @category_list << [category.name.capitalize, category.name]
    end
  end

  def check_owns
    if session[:user_id] != @post.user_id
      flash[:error] = "You can only edit your own posts!"
      redirect_to posts_path
    end
  end

  def logged_in?
    session[:user_id] != nil
  end

  def check_logged_in
    if session[:user_id].nil?
      flash[:error] = "Must be logged in!"
      redirect_to posts_path
    end
  end

  def check_owns_or_admin
    if session[:user_id] != @post.user_id and User.find(session[:user_id]).rights == "user"
      flash[:error] = "You can only edit your own posts!"
      redirect_to posts_path
    end
  end

end
