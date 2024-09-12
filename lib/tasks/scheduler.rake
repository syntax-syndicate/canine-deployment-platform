namespace :scheduler do
  desc "Delete uninstalled add-ons that were not updated in the last day"
  task :clean_uninstalled_add_ons do
    AddOn.uninstalled.where(updated_at: ..1.day.ago).destroy_all
  end
end
