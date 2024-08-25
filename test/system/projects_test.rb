require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup do
    @project = projects(:one)
  end

  test "visiting the index" do
    visit projects_url
    assert_selector "h1", text: "Projects"
  end

  test "creating a Project" do
    visit projects_url
    click_on "New Project"

    fill_in "Branch", with: @project.branch
    fill_in "Cluster", with: @project.cluster_id
    fill_in "Name", with: @project.name
    fill_in "Repository url", with: @project.repository_url
    fill_in "Subfolder", with: @project.subfolder
    click_on "Create Project"

    assert_text "Project was successfully created"
    assert_selector "h1", text: "Projects"
  end

  test "updating a Project" do
    visit project_url(@project)
    click_on "Edit", match: :first

    fill_in "Branch", with: @project.branch
    fill_in "Cluster", with: @project.cluster_id
    fill_in "Name", with: @project.name
    fill_in "Repository url", with: @project.repository_url
    fill_in "Subfolder", with: @project.subfolder
    click_on "Update Project"

    assert_text "Project was successfully updated"
    assert_selector "h1", text: "Projects"
  end

  test "destroying a Project" do
    visit edit_project_url(@project)
    click_on "Delete", match: :first
    click_on "Confirm"

    assert_text "Project was successfully destroyed"
  end
end
