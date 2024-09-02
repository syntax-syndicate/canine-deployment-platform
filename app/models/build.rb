class Build < ApplicationRecord
  include Loggable
  belongs_to :project
  has_one :deployment, dependent: :destroy
  enum status: {
    in_progress: 0,
    completed: 1,
    failed: 2
  }
end
