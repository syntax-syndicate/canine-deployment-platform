require "application_system_test_case"

class AddOnsTest < ApplicationSystemTestCase
  setup do
    @add_on = add_ons(:one)
  end

  test "visiting the index" do
    visit add_ons_url
    assert_selector "h1", text: "Add Ons"
  end

  test "creating a Add on" do
    visit add_ons_url
    click_on "New Add On"

    fill_in "Add on type", with: @add_on.add_on_type
    fill_in "Cluster", with: @add_on.cluster_id
    fill_in "Metadata", with: @add_on.metadata
    fill_in "Name", with: @add_on.name
    click_on "Create Add on"

    assert_text "Add on was successfully created"
    assert_selector "h1", text: "Add Ons"
  end

  test "updating a Add on" do
    visit add_on_url(@add_on)
    click_on "Edit", match: :first

    fill_in "Add on type", with: @add_on.add_on_type
    fill_in "Cluster", with: @add_on.cluster_id
    fill_in "Metadata", with: @add_on.metadata
    fill_in "Name", with: @add_on.name
    click_on "Update Add on"

    assert_text "Add on was successfully updated"
    assert_selector "h1", text: "Add Ons"
  end

  test "destroying a Add on" do
    visit edit_add_on_url(@add_on)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Add on was successfully destroyed"
  end
end
