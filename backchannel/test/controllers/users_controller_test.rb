require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup :build_basic_user_dict

  def teardown
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
    assert_equal users(:dfarrell07).id, assigns(:user).id
  end

  test "should create user" do
    assert_difference("User.count") do
      post :create, user: @basic_user
    end
    assert_redirected_to root_path
    assert_equal "Signed up!", flash[:notice]
  end

  test "should log user in at creation time" do
    assert_difference("User.count") do
      post :create, user: @basic_user
    end
    assert_not_nil session[:user_id], "KNOWN BUG: See Isses#10"
  end

  test "password and confirm must match" do
    assert_difference("User.count", 0) do
      @basic_user[:password_confirmation] = "not correct"
      post :create, user: @basic_user
    end
    assert_equal "Password confirmation doesn't match Password", get_message
    assert_nil session[:user_id]
  end

  test "email must be unique" do
    assert_difference("User.count", 0) do
      @basic_user[:email] = users(:dfarrell07).email
      post :create, user: @basic_user
    end
    assert_equal "Email has already been taken", get_message
  end

  test "can not create admin when logged out" do
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "admin"
      post :create, user: @basic_user
    end
    assert_equal "You can't create an admin, who are you?!", flash[:error]
  end

  test "can not create admin when user" do
    session[:user_id] = users(:dfarrell07)
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "admin"
      post :create, user: @basic_user
    end
    assert_equal "You can't create an admin/super, you're a user!", flash[:error]
  end

  test "can not create super when user" do
    session[:user_id] = users(:dfarrell07)
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "You can't create an admin/super, you're a user!", flash[:error]
  end

  test "can not create super when admin" do
    session[:user_id] = users(:admin)
    assert_difference("User.count", 0, message: "KNOWN BUG: See Issues#12") do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "There can only be one Super Admin!", flash[:error], "KNOWN BUG: See Issues#12"
  end

  test "can not create super when super" do
    session[:user_id] = users(:super)
    assert_difference("User.count", 0, message: "KNOWN BUG: See Issues#12") do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "There can only be one Super Admin!", flash[:error], "KNOWN BUG: See Issues#12"

  end

  private

  def build_basic_user_dict
    @basic_user = {email: "default@default.com",
                   user_name: "default",
                   rights: "user", 
                   password: "blah", 
                   password_confirmation: "blah"}
  end

  def get_message
    assigns(:user).errors.full_messages[0]
  end
  
end
