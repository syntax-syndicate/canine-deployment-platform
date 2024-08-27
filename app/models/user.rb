class User < ApplicationRecord
  has_prefix_id :user

  include Accounts
  include Agreements
  include Authenticatable
  include Mentions
  include Notifiable
  include Searchable
  include Theme

  has_one_attached :avatar
  has_person_name

  validates :avatar, resizable_image: true
  validates :name, presence: true
  has_many :clusters, dependent: :destroy
  has_many :projects, through: :clusters
  has_one :docker_hub_credential, dependent: :destroy

  def github_username
    github_account.auth['info']['nickname']
  end

  def github_access_token
    github_account.access_token
  end

  def github_account
    @_github_account ||= User.first.connected_accounts.find_by(provider: "github")
  end
end
