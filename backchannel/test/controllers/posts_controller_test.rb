require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  setup :build_basic_post_dict

  # Testing fixture
  test "should have post one" do
    assert_not_nil posts(:one)
    assert_equal "Post1", posts(:one).title
    assert_equal "Message1", posts(:one).message
  end

  # Getting basic pages

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:posts)
  end

  test "should get show" do
    get(:show, {"id" => posts(:one).id})
    assert_response :success
    assert_not_nil assigns(:post)
    assert_equal posts(:one).id, assigns(:post).id
  end

  test "should get new if logged in" do
    become_user
    get :new
    assert_response :success
    assert_not_nil assigns(:post)
  end

  test "should not get new if not logged in" do
    log_out
    get :new
    assert_equal "Must be logged in!", flash[:error]
    assert_redirected_to posts_path
  end

  # Creating post tests

  test "should not create post when logged out" do
    log_out
    assert_difference("Post.count", 0) do
      post :create, post: @basic_post
    end
    assert_equal "Must be logged in!", flash[:error]
  end

  test "should create post when user" do
    become_user
    assert_difference("Post.count") do
      post :create, post: @basic_post
    end
    assert_equal "Post created!", flash[:notice]
  end

  test "should create post when admin" do
    become_admin
    assert_difference("Post.count") do
      post :create, post: @basic_post
    end
    assert_equal "Post created!", flash[:notice]
  end

  test "should create post when super" do
    become_super
    assert_difference("Post.count") do
      post :create, post: @basic_post
    end
    assert_equal "Post created!", flash[:notice]
  end

  # Edit post tests

  test "should not be able to edit if not owner" do
    assert_not_equal users(:super).id, posts(:one).user_id
    assert_not_equal users(:admin).id, posts(:one).user_id
    assert_not_equal users(:user).id, posts(:one).user_id
    [users(:super).id, users(:admin).id, users(:user).id].each do |user_id|
      session[:user_id] = user_id
      get(:edit, {id: posts(:one)}, {user_id: user_id})
      assert_redirected_to posts_path
      assert_equal "You can only edit your own posts!", flash[:error]
    end
  end
    
  test "should be able to edit if owner" do
    become_poster
    assert_equal session[:user_id], posts(:one).user_id
    get(:edit, {id: posts(:one)}, {user_id: users(:poster).id})
    assert :success
    assert_nil flash[:error]
  end

  # Destroy post tests

  test "should not be able to destroy if user and not owner" do
    become_user
    assert_not_equal users(:user).id, posts(:one).user_id
    assert_difference("Post.count", 0) do
      delete :destroy, id: posts(:one)
    end
    assert_redirected_to posts_path
    assert_equal "You can only edit your own posts!", flash[:error]
  end
    
  test "should be able to destroy if owner" do
    become_poster
    assert_equal session[:user_id], posts(:one).user_id
    assert_difference("Post.count", -1) do
      delete :destroy, id: posts(:one)
    end
    assert :success
    assert_nil flash[:error]
  end

  test "should be able to destroy if admin" do
    assert_not_equal users(:admin).id, posts(:one).user_id
    session[:user_id] = users(:admin).id
    assert_difference("Post.count", -1) do
      delete :destroy, id: posts(:one)
    end
    assert :success
    assert_nil flash[:error]
  end

  test "should be able to destroy if super" do
    assert_not_equal users(:super).id, posts(:one).user_id
    session[:user_id] = users(:super).id
    assert_difference("Post.count", -1) do
      delete :destroy, id: posts(:one)
    end
    assert :success
    assert_nil flash[:error]
  end

  # Show post tests

  test "should always show post" do
    User.all.each do |user|
      session[:user_id] = user.id
      get(:show, {"id" => posts(:one)})
      assert :success
      assert_nil flash[:error]
    end
  end

  # Category tests

  test "should always have category" do
    become_user
    [users(:super).id, users(:admin).id, users(:user).id].each do |user_id|
      session[:user_id] = user_id
      assert_difference("Post.count") do
        post :create, post: @basic_post
      end
      assert_equal "Post created!", flash[:notice]
      assert_not_nil assigns(:post)
      assert_not_nil assigns(:post).category_id, "Category not assigned"
    end
  end

  private

  def build_basic_post_dict
    @basic_post = {title: "Post1",
                   message: "Message1",
                   category: categories(:homework1).name,
                   id: 1}
  end


  def log_out; session[:user_id] = nil; end
  def become_super; session[:user_id] = users(:super).id; end
  def become_admin; session[:user_id] = users(:admin).id; end
  def become_user; session[:user_id] = users(:user).id; end
  def become_poster; session[:user_id] = users(:poster).id; end
end
