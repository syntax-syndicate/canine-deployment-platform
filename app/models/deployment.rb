class Deployment < ApplicationRecord
  include Loggable
  belongs_to :build
  has_one :project, through: :build
  enum status: {
    in_progress: 0,
    completed: 1,
    failed: 2
  }
end
