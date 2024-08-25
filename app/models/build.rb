class Build < ApplicationRecord
  include Loggable
  belongs_to :project
end
