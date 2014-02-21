require 'test_helper'

class PostsControllerTest < ActionController::TestCase

  setup :build_basic_post_dict, :build_basic_comment_dict

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
    assert_response :success
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
    assert_redirected_to posts_path
    assert_nil flash[:error]
  end

  test "should be able to destroy if admin" do
    assert_not_equal users(:admin).id, posts(:one).user_id
    session[:user_id] = users(:admin).id
    assert_difference("Post.count", -1) do
      delete :destroy, id: posts(:one)
    end
    assert_redirected_to posts_path
    assert_nil flash[:error]
  end

  test "should be able to destroy if super" do
    assert_not_equal users(:super).id, posts(:one).user_id
    session[:user_id] = users(:super).id
    assert_difference("Post.count", -1) do
      delete :destroy, id: posts(:one)
    end
    assert_redirected_to posts_path
    assert_nil flash[:error]
  end

  # Show post tests

  test "should always show post" do
    User.all.each do |user|
      session[:user_id] = user.id
      get(:show, {"id" => posts(:one)})
      assert_response :success
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

  # Vote tests

  test "should up vote" do
    become_user
    assert_difference("Vote.count") do
      get(:up_vote, {id: posts(:one)})
    end
    assert_equal "Vote for post counted!", flash[:notice]
    assert_redirected_to posts_path
  end

  test "should not be able to vote when logged out" do
    log_out
    assert_difference("Vote.count", 0) do
      get(:up_vote, {id: posts(:one)})
    end
    assert_equal "Must be logged in!", flash[:error]
    assert_redirected_to posts_path
  end

  test "should up vote with any rights excluding logged out" do
    assert !vote_exists?(users(:super).id, posts(:one).id), "Vote already exists"
    assert !vote_exists?(users(:admin).id, posts(:one).id), "Vote already exists"
    assert !vote_exists?(users(:user).id, posts(:one).id), "Vote already exists"
    [users(:super).id, users(:admin).id, users(:user).id].each do |user_id|
      session[:user_id] = user_id
      assert_difference("Vote.count") do
        get(:up_vote, {id: posts(:one)})
      end
      assert_equal "Vote for post counted!", flash[:notice]
      assert_redirected_to posts_path
    end
  end

  test "should not be able to vote twice for same post" do
    assert vote_exists?(users(:super).id, posts(:two).id)
    assert vote_exists?(users(:admin).id, posts(:two).id)
    assert vote_exists?(users(:user).id, posts(:two).id)
    [users(:super).id, users(:admin).id, users(:user).id].each do |user_id|
      session[:user_id] = user_id
      assert_difference("Vote.count", 0) do
        get(:up_vote, {id: posts(:two)})
      end
      assert_equal "You've already voted for this post!", flash[:error]
      assert_redirected_to posts_path
    end
  end

  test "should not be able to vote for own post" do
    assert user_owns_post?(users(:super).id, posts(:super_post).id)
    assert user_owns_post?(users(:admin).id, posts(:admin_post).id)
    assert user_owns_post?(users(:user).id, posts(:user_post).id)
    {users(:super).id => posts(:super_post), users(:admin).id => posts(:admin_post), users(:user).id => posts(:user_post)}.each do |user_id, post|
      session[:user_id] = user_id
      assert_difference("Vote.count", 0) do
        get(:up_vote, {id: post})
      end
      assert_equal "You can't vote for your own post!", flash[:error]
      assert_redirected_to posts_path
    end
  end

  # New (action) comment tests

  test "should get new comment if logged in" do
    become_user
    get :new_comment, {post_id: posts(:one).id}
    assert_response :success
    assert_not_nil assigns(:comment)
  end

  test "should not get new comment if not logged in" do
    log_out
    get(:new_comment, {post_id: posts(:one)})
    assert_equal "Must be logged in!", flash[:error]
    assert_redirected_to posts_path
    assert_nil assigns(:comment)
  end

  # Creating comment tests

  test "should not create comment when logged out" do
    log_out
    assert_difference("Comment.count", 0) do
      get :create_comment, {post_id: posts(:one)}
    end
    assert_equal "Must be logged in!", flash[:error]
  end

  test "should create comment when user" do
    become_user
    assert_difference("Comment.count", 1) do
      get :create_comment, @basic_comment
    end
    assert_equal "Commented!", flash[:notice]
    assert_redirected_to post_path(@basic_comment[:post_id])
    assert_not_nil assigns(:comment)
    assert Comment.exists?(post_id: @basic_comment[:post_id], message: @basic_comment[:comment][:message])
    assert_equal @basic_comment[:post_id], assigns(:comment).post_id
    assert_equal @basic_comment[:comment][:message], assigns(:comment).message
  end

  test "should create comment when admin" do
    become_admin
    assert_difference("Comment.count", 1) do
      get :create_comment, @basic_comment
    end
    assert_equal "Commented!", flash[:notice]
    assert_redirected_to posts(:one)
    assert Comment.exists?(post_id: @basic_comment[:post_id], message: @basic_comment[:comment][:message])
    assert_equal @basic_comment[:post_id], assigns(:comment).post_id
    assert_equal @basic_comment[:comment][:message], assigns(:comment).message
  end

  test "should create comment when super" do
    become_super
    assert_difference("Comment.count", 1) do
      get :create_comment, @basic_comment
    end
    assert_equal "Commented!", flash[:notice]
    assert_redirected_to posts(:one)
    assert Comment.exists?(post_id: @basic_comment[:post_id], message: @basic_comment[:comment][:message])
    assert_equal @basic_comment[:post_id], assigns(:comment).post_id
    assert_equal @basic_comment[:comment][:message], assigns(:comment).message
  end

  private

  def build_basic_post_dict
    @basic_post = {title: "Post1",
                   message: "Message1",
                   category: categories(:homework1).name,
                   id: 1}
  end

  def build_basic_comment_dict
    @basic_comment = {post_id: posts(:one).id, comment: {message: "Basic message"}}
  end

  def vote_exists?(user_id, post_id)
    vote = Vote.where(user_id: user_id, post_id: post_id)
    !vote.empty?
  end

  def user_owns_post?(user_id, post_id)
    post = Post.where(user_id: user_id, id: post_id)
  end

  def log_out; session[:user_id] = nil; end
  def become_super; session[:user_id] = users(:super).id; end
  def become_admin; session[:user_id] = users(:admin).id; end
  def become_user; session[:user_id] = users(:user).id; end
  def become_poster; session[:user_id] = users(:poster).id; end
end
