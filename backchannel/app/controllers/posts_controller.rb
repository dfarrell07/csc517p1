class PostsController < ApplicationController
  before_filter :get_post, only: [:show, :update, :edit, :destroy]
  before_filter :check_owns, :only => [:edit, :update]
  before_filter :check_owns_or_admin, :only => [:destroy]

  def create
    @post = Post.new(post_params)
    @post.user_id = session[:user_id]
    #@post.user_id = 1234 
    @post.save
    redirect_to @post
  end

  def show
    @user_name = User.find(@post.user_id).user_name
  end

  def index
    @posts = Post.all
  end

  def edit
  end

  def update
    @post.update(post_params)
    if @post.save == false
      flash[:error] = "Failed up save post update."
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
    params.require(:post).permit(:title, :message)
  end

  def get_post
    @post = Post.find(params[:id])
  end

  def check_owns
    if session[:user_id] != @post.user_id
      flash[:notice] = "You can only edit your own posts!"
      redirect_to posts_path
    end
  end

  def check_owns_or_admin
    if session[:user_id] != @post.user_id and User.find(session[:user_id]).rights == "user"
      flash[:notice] = "You can only edit your own posts!"
      redirect_to posts_path
    end
  end

end
