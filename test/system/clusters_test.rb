require "application_system_test_case"

class ClustersTest < ApplicationSystemTestCase
  setup do
    @cluster = clusters(:one)
  end

  test "visiting the index" do
    visit clusters_url
    assert_selector "h1", text: "Clusters"
  end

  test "creating a Cluster" do
    visit clusters_url
    click_on "New Cluster"

    fill_in "Kubeconfig", with: @cluster.kubeconfig
    fill_in "Name", with: @cluster.name
    fill_in "User", with: @cluster.user_id
    click_on "Create Cluster"

    assert_text "Cluster was successfully created"
    assert_selector "h1", text: "Clusters"
  end

  test "updating a Cluster" do
    visit cluster_url(@cluster)
    click_on "Edit", match: :first

    fill_in "Kubeconfig", with: @cluster.kubeconfig
    fill_in "Name", with: @cluster.name
    fill_in "User", with: @cluster.user_id
    click_on "Update Cluster"

    assert_text "Cluster was successfully updated"
    assert_selector "h1", text: "Clusters"
  end

  test "destroying a Cluster" do
    visit edit_cluster_url(@cluster)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Cluster was successfully destroyed"
  end
end
