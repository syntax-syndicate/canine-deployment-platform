class Cluster < ApplicationRecord
  include Loggable
  broadcasts_refreshes
  belongs_to :user
  has_many :projects, dependent: :destroy
  has_many :add_ons, dependent: :destroy
  has_many :domains, through: :projects
  validates_presence_of :name
  enum status: {
    initializing: 0,
    installing: 1,
    running: 2,
    failed: 3,
  }
end
