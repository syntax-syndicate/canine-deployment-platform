class CronSchedule < ApplicationRecord
  belongs_to :project
  validates :schedule, presence: true
end
