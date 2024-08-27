class Deployment < ApplicationRecord
  include Loggable
  belongs_to :build
  has_one :project, through: :build
end
