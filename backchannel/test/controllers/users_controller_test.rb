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
    become_user
    get(:show, {"id" => users(:user).id})
    assert_response :success
    assert_not_nil assigns(:user)
    assert_equal users(:user).id, assigns(:user).id
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_not_nil assigns(:user)
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

  # Creating admin tests

  test "can not create admin when logged out" do
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "admin"
      post :create, user: @basic_user
    end
    assert_equal "You can't create an admin, who are you?!", flash[:error]
  end

  test "can not create admin when user" do
    become_user
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "admin"
      post :create, user: @basic_user
    end
    assert_equal "You can't create an admin/super, you're a user!", flash[:error]
  end

  # Creating super tests

  test "can not create super when logged out" do
    log_out
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "There can only be one Super Admin!", flash[:error]
  end

  test "can not create super when user" do
    become_user
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "There can only be one Super Admin!", flash[:error]
  end

  test "can not create super when admin" do
    become_admin
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "There can only be one Super Admin!", flash[:error]
  end

  test "can not create super when super" do
    become_super
    assert_difference("User.count", 0) do
      @basic_user[:rights] = "super"
      post :create, user: @basic_user
    end
    assert_equal "There can only be one Super Admin!", flash[:error]
  end

  # Destroying user tests

  test "should not be able to destroy user if logged out" do
    log_out
    assert_difference("User.count", 0) do
      delete :destroy, id: users(:user).id
    end
    assert_equal "You must be logged in!", flash[:error]
  end

  test "should not be able to destroy user if user" do
    become_user
    assert_not_equal session[:user_id], users(:jghall07).id
    assert_difference("User.count", 0) do
      delete :destroy, id: users(:jghall07).id
    end
    assert_equal "You can only edit your own account!", flash[:error]
  end

  test "should be able to destroy user if admin" do
    become_admin
    assert_difference("User.count", -1) do
      delete :destroy, id: users(:user).id
    end
  end

  test "should be able to destroy user if super" do
    become_super
    assert_difference("User.count", -1) do
      delete :destroy, id: users(:user).id
    end
  end

  # Destroying admin tests

  test "should not be able to destroy admin if logged out" do
    log_out
    assert_difference("User.count", 0) do
      delete :destroy, id: users(:admin).id
    end
    assert_equal "You must be logged in!", flash[:error]
  end

  test "should not be able to destroy admin if user" do
    become_user
    assert_difference("User.count", 0) do
      delete :destroy, id: users(:admin).id
    end
    assert_equal "You can only edit your own account!", flash[:error]
  end

  test "should not be able to destroy admin if admin" do
    become_admin
    assert_not_equal session[:user_id], users(:admin2).id
    assert_difference("User.count", 0) do
      delete :destroy, id: users(:admin2).id
    end
    assert_equal "Admins can't edit other admin's data!", flash[:error]
  end

  test "should be able to destroy admin if super" do
    become_super
    assert_difference("User.count", -1) do
      delete :destroy, id: users(:admin).id
    end
  end

  # Destroying super tests

  test "no one should be able to destroy super" do
    [users(:user), users(:admin), users(:super)].each do |user|
      session[:user_id] = user.id
      assert_difference("User.count", 0) do
        delete :destroy, id: users(:super).id
      end
      assert_not_nil flash[:error]
    end
  end

  # Viewing user "credentials" tests

  test "should not show user when logged out" do
    log_out
    get(:show, {"id" => users(:user).id})
    assert_nil assigns(:user)
  end

  test "should not show user when user" do
    become_user
    assert_not_equal session[:user_id], users(:dfarrell07).id
    get(:show, {"id" => users(:dfarrell07).id})
    assert_nil assigns(:user)
  end

  test "should show user when admin" do
    become_admin
    get(:show, {"id" => users(:user).id})
    assert_not_nil assigns(:user)
  end

  test "should show user when super" do
    become_super
    get(:show, {"id" => users(:user).id})
    assert_not_nil assigns(:user)
  end

  # Viewing admin "credentials" tests

  test "should not show admin when logged out" do
    log_out
    get(:show, {"id" => users(:admin).id})
    assert_nil assigns(:user)
  end

  test "should not show admin when user" do
    become_user
    get(:show, {"id" => users(:admin).id})
    assert_nil assigns(:user)
  end

  test "should not show admin when admin" do
    become_admin
    assert_not_equal session[:user_id], users(:admin2).id
    get(:show, {"id" => users(:admin2).id})
    assert_nil assigns(:user)
  end

  test "should show admin when super" do
    become_super
    get(:show, {"id" => users(:admin).id})
    assert_not_nil assigns(:user)
  end

  # Viewing super "credentials" tests

  test "should not show super when logged out" do
    log_out
    get(:show, {"id" => users(:super).id})
    assert_nil assigns(:user)
  end

  test "should not show super when user" do
    become_user
    get(:show, {"id" => users(:super).id})
    assert_nil assigns(:user)
  end

  test "should not show super when admin" do
    become_admin
    assert_not_equal session[:user_id], users(:admin2).id
    get(:show, {"id" => users(:admin2).id})
    assert_nil assigns(:user)
  end

  test "should show super when super" do
    become_super
    get(:show, {"id" => users(:super).id})
    assert_not_nil assigns(:user)
  end

  # Showing self "credentials"

  test "should show self when user" do
    become_user
    get(:show, {"id" => session[:user_id]})
    assert_not_nil assigns(:user)
    assert_equal users(:user).id, assigns(:user).id
  end

  test "should show self when admin" do
    become_admin
    get(:show, {"id" => session[:user_id]})
    assert_not_nil assigns(:user)
    assert_equal users(:admin).id, assigns(:user).id
  end

  test "should show self when super" do
    become_super
    get(:show, {"id" => session[:user_id]})
    assert_not_nil assigns(:user)
    assert_equal users(:super).id, assigns(:user).id
  end


  # Creating first user tests

  test "first user should be super even if user chosen" do
    destroy_all_users
    log_out
    assert_difference("User.count") do
      post :create, user: @basic_user
    end
    assert_redirected_to root_path
    assert_equal "super", User.first.rights
    assert_equal "You're the first user! You were upgraded to Super Admin!", flash[:notice]
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

  def destroy_all_users
    session[:user_id] = "super"
    User.all.each do |user|
      assert_difference("User.count", -1) do
        user.destroy
      end
    end
  end

  def log_out; session[:user_id] = nil; end
  def become_super; session[:user_id] = users(:super).id; end
  def become_admin; session[:user_id] = users(:admin).id; end
  def become_user; session[:user_id] = users(:user).id; end
  
end
