class Service < ApplicationRecord
  belongs_to :project
  enum service_type: {
    web_service: 0,
    internal_service: 1,
    background_service: 2,
    cron_job: 3,
  }
end
