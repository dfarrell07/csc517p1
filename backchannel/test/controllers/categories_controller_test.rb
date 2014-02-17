require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
   test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:categories)
   end

  test "should get new" do
    get :new
  end

  test "should get edit" do
    get(:edit, {id: categories(:homework1)}, {user_id: users(:super).id})
  end

  test "should get show" do
    get(:show, {id: categories(:homework1)}, {user_id: users(:super)})
  end

  test "should not create when logged out" do
    assert_difference("Category.count", 0) do
      post :create, category: {name: "Test"}
    end
    assert_redirected_to categories_path
    assert_equal "You must be logged in!", flash[:error]
  end

  test "should create as pending when user" do
    session["user_id"] = users(:dfarrell07)
    assert_difference("Category.count") do
      post :create, category: {name: "Test"}
    end
    assert_redirected_to categories_path
    assert_equal "Category proposed!", flash[:notice]
    assert_equal "pending", assigns(:category).status
  end

  test "should create as accepted when admin" do
    session["user_id"] = users(:admin)
    assert_difference("Category.count") do
      post :create, category: {name: "Test"}
    end
    assert_redirected_to categories_path
    assert_equal "Category proposed!", flash[:notice]
    assert_equal "approved", assigns(:category).status
  end

  test "should create as accepted when super" do
    session["user_id"] = users(:super)
    assert_difference("Category.count") do
      post :create, category: {name: "Test"}
    end
    assert_redirected_to categories_path
    assert_equal "Category proposed!", flash[:notice]
    assert_equal "approved", assigns(:category).status
  end

  test "should not be able to edit if user" do
    get(:edit, {id: categories(:homework1)}, {user_id: users(:dfarrell07).id})
    assert_equal "You must be an admin to approve/reject categories!", flash[:error]
    assert_redirected_to categories_path
  end
    
  test "should be able to edit if admin" do
    get(:edit, {id: categories(:homework1)}, {user_id: users(:admin).id})
    assert_equal nil, flash[:error]
    assert_response :success
  end
    
  test "should be able to edit if super" do
    get(:edit, {id: categories(:homework1)}, {user_id: users(:super).id})
    assert_equal nil, flash[:error]
    assert_response :success
  end

  test "should not be able to destroy if logged out" do
    session[:user_id] = nil
    assert_difference("Category.count", 0) do
      delete :destroy, id: categories(:homework1).id
    end
    assert_equal "You must be logged in!", flash[:error]
  end

  test "should not be able to destroy if user" do
    session[:user_id] = users(:dfarrell07).id
    assert_difference("Category.count", 0) do
      delete :destroy, id: categories(:homework1).id
    end
    assert_equal "You must be an admin to approve/reject categories!", flash[:error]
  end

  test "should be able to destroy if admin" do
    session[:user_id] = users(:admin).id
    assert_difference("Category.count", -1) do
      delete :destroy, id: categories(:homework1).id
    end
  end

  test "should be able to destroy if super" do
    session[:user_id] = users(:super).id
    assert_difference("Category.count", -1) do
      delete :destroy, id: categories(:homework1).id
    end
  end

end
