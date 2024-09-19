# == Schema Information
#
# Table name: projects
#
#  id                             :bigint           not null, primary key
#  autodeploy                     :boolean          default(TRUE), not null
#  branch                         :string           default("main"), not null
#  docker_build_context_directory :string           default("."), not null
#  docker_command                 :string
#  dockerfile_path                :string           default("./Dockerfile"), not null
#  name                           :string           not null
#  predeploy_command              :string
#  project_type                   :integer          not null
#  repository_url                 :string           not null
#  status                         :integer          default("created"), not null
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#  cluster_id                     :bigint           not null
#
# Indexes
#
#  index_projects_on_cluster_id  (cluster_id)
#  index_projects_on_name        (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (cluster_id => clusters.id)
#
class Project < ApplicationRecord
  broadcasts_refreshes
  belongs_to :cluster
  has_one :user, through: :cluster
  has_many :environment_variables, dependent: :destroy
  has_many :domains, dependent: :destroy
  has_many :builds, dependent: :destroy
  has_many :deployments, through: :builds
  validates :name, presence: true, format: { with: /\A[a-z0-9_-]+\z/, message: "must be lowercase, numbers, hyphens, and underscores only" }
  has_one :cron_schedule
  validates :cron_schedule, presence: true, if: :cron_job?
  validates :command, presence: true, if: :cron_job?

  enum status: {
    created: 0,
    deployed: 1
  }

  enum project_type: {
    web_service: 0,
    internal_service: 1,
    background_service: 2,
    cron_job: 3,
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
