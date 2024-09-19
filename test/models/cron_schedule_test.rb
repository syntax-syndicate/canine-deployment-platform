# == Schema Information
#
# Table name: cron_schedules
#
#  id         :bigint           not null, primary key
#  schedule   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :bigint           not null
#
# Indexes
#
#  index_cron_schedules_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
require "test_helper"

class CronScheduleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
