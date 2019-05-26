require "test_helper"

class MonthlyinputsControllerTest < ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    @user = users(:john)
    login_as(@user, :scope => :user)
  end

  test "get list" do
    assert true
  end
end
