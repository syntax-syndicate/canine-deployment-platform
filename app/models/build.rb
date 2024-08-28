class Build < ApplicationRecord
  include Loggable
  belongs_to :project
  has_many :deployments
  enum status: {
    in_progress: 0,
    completed: 1,
    failed: 2
  }
end
