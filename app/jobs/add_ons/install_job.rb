class AddOns::InstallJob < ApplicationJob
  def perform(add_on_id)
    add_on = AddOn.find(add_on_id)
    AddOns::InstallHelmChart.execute(add_on:)
  end
end