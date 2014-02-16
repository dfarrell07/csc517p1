require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "should not save without without required fields" do
    user = User.new
    assert !user.save
  end

end
