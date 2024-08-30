class Cluster < ApplicationRecord
  include Loggable
  broadcasts_refreshes
  belongs_to :user
  has_many :projects, dependent: :destroy
  has_many :domains, through: :projects
  validates_presence_of :name
  enum status: {
    initializing: 1,
    installing: 2,
    running: 3,
    failed: 4,
  }

  # Set up a cluster
  def self.install(cluster)
    # Run the install_cert_manager.sh script
  end
end
