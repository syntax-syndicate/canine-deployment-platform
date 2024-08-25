class ProjectAddOn < ApplicationRecord
  belongs_to :project
  belongs_to :add_on
end
