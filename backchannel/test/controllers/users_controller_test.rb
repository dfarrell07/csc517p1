require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "the truth" do
    assert true
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get show" do
    get(:show, {"id" => users(:dfarrell07).id})
    assert_response :success
    assert_not_nil assigns(:user)
  end

  test "should create user" do
    assert_difference("User.count") do
      post :create, user: {email: "test@test.com", user_name: "test", rights: "user", password: "blah", confirm_password: "blah"}
    end
    assert_redirected_to root_path
    assert_equal "Signed up!", flash[:notice]
  end

  test "password and confirm must match" do
    # Currently fails, used to pass
    assert_difference("User.count", 0) do
      post :create, user: {email: "test@test.com", user_name: "test", rights: "user", password: "blah", confirm_password: "not_blah"}
    end
  
    assert_redirected_to root_path
    assert_equal "Signed up!", flash[:notice]
  end

  test "email must be unique" do
    assert_difference("User.count", 0) do
      post :create, user: {email: users(:dfarrell07).email, user_name: "test", rights: "user", password: "blah", confirm_password: "blah"}
    end
    assert_equal "Email has already been taken", assigns(:user).errors.full_messages[0]
  end
end
