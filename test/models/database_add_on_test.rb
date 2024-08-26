require "test_helper"

class DatabaseAddOnTest < ActiveSupport::TestCase
  test "create generates valid metadata" do
    cluster = clusters(:one)
    add_on = DatabaseAddOn.make(cluster, "name")
    
    assert_not_nil add_on.metadata["db"]
    assert_not_nil add_on.metadata["username"]
    assert_not_nil add_on.metadata["password"]
    
    assert_equal 32, add_on.metadata["db"].length
    assert_equal 32, add_on.metadata["username"].length
    assert_equal 32, add_on.metadata["password"].length
  end
end