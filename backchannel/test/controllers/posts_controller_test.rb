require 'test_helper'

class PostsControllerTest < ActionController::TestCase

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

  private

  def log_out; session[:user_id] = nil; end
  def become_super; session[:user_id] = users(:super).id; end
  def become_admin; session[:user_id] = users(:admin).id; end
  def become_user; session[:user_id] = users(:user).id; end
end
