require "test_helper"

class AddOnsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @add_on = add_ons(:one)
  end

  test "should get index" do
    get add_ons_url
    assert_response :success
  end

  test "should get new" do
    get new_add_on_url
    assert_response :success
  end

  test "should create add_on" do
    assert_difference("AddOn.count") do
      post add_ons_url, params: {add_on: {add_on_type: @add_on.add_on_type, cluster_id: @add_on.cluster_id, metadata: @add_on.metadata, name: @add_on.name}}
    end

    assert_redirected_to add_on_url(AddOn.last)
  end

  test "should show add_on" do
    get add_on_url(@add_on)
    assert_response :success
  end

  test "should get edit" do
    get edit_add_on_url(@add_on)
    assert_response :success
  end

  test "should update add_on" do
    patch add_on_url(@add_on), params: {add_on: {add_on_type: @add_on.add_on_type, cluster_id: @add_on.cluster_id, metadata: @add_on.metadata, name: @add_on.name}}
    assert_redirected_to add_on_url(@add_on)
  end

  test "should destroy add_on" do
    assert_difference("AddOn.count", -1) do
      delete add_on_url(@add_on)
    end

    assert_redirected_to add_ons_url
  end
end
