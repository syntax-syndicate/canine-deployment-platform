class Project < ApplicationRecord
  broadcasts_refreshes
  belongs_to :cluster
  has_one :user, through: :cluster
  has_many :environment_variables, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :builds, dependent: :destroy
  has_many :deployments, through: :builds
  validates :name, presence: true, format: { with: /\A[a-z0-9_-]+\z/, message: "must be lowercase, numbers, hyphens, and underscores only" }

  enum status: {
    created: 0,
    deployed: 1
  }

  enum project_type: {
    web_service: 0,
    internal_service: 1,
    background_service: 2,
  }

  def current_deployment
    deployments.order(created_at: :desc).where(status: :completed).first
  end

  def last_deployed_at
    deployments.order(created_at: :desc).first&.created_at
  end

  def repository_name
    repository_url.split('/').last
  end

  def full_repository_url
    "https://github.com/#{repository_url}"
  end

  def container_registry_url
    "ghcr.io/#{repository_url}:latest"
  end
end