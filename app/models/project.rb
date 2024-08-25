class Project < ApplicationRecord
  broadcasts_refreshes
  belongs_to :cluster
  has_many :environment_variables, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :builds, dependent: :destroy
  validates :name, presence: true, format: { with: /\A[a-z0-9_-]+\z/, message: "must be lowercase, numbers, hyphens, and underscores only" }
end
