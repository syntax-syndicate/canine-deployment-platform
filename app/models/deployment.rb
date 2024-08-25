class Deployment < ApplicationRecord
  include Loggable
  belongs_to :project
  belongs_to :build
end
