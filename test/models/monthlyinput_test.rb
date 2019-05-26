require "test_helper"

class MonthlyinputTest < ActiveSupport::TestCase
  include Warden::Test::Helpers

  def setup
    Warden.test_mode!
    @user = users(:john)
    login_as(@user, :scope => :user)
  end

  test "get list" do
    monthlyinput = Monthlyinput.all
    assert true
  end
end
